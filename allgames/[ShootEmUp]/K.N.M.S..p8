pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- k.n.m.s. (vertical shooter)
-- by k-miso

bgo={}
ene={}
blt={}
itm={}
eff={}
se={}

gm_stt=0
gm_phs=0
gm_time=0
gm_tmp=0

--+++++++++++++++++++++++++++++
--+ 
--+++++++++++++++++++++++++++++
function set_gm_stt(stt)
	gm_stt =stt
	gm_phs =0
	gm_time=0
end

function reset_game()

	ply=new_ply(0,59,100)
	
	opt_fl=new_opt()
	opt_fr=new_opt()
	opt_bl=new_opt()
	opt_br=new_opt()
	setup_wpn()
	setup_spd()

	clear_list(ene)
	clear_list(blt)
	clear_list(itm)
	clear_list(eff)

	ene_time=0
	ene_type=0
	ene_cnt =0
	ene_stt =0
	ene_phs =0
	ene_bs_x=0
	ene_grp =0
	ene_lv  =0

	tscore=0
	ipoint=0
end

function clear_list(lst)
	for p in all(lst) do
		del(lst,p)
	end
end

--+++++++++++++++++++++++++++++
--+ sound
--+++++++++++++++++++++++++++++
function play_se(no)
	n=no+1
	if se[n]==0 then
		sfx(no)
		se[n]=1
	end
end

--+++++++++++++++++++++++++++++
--+ create function
--+++++++++++++++++++++++++++++
function new_bg_obj(no,x,y,spd)
	local p={no,x,y,spd}
	p.no=no
	p.x=x
	p.y=y
	p.spd=spd
	return p
end

function setup_cmn(p,sx,sy,sw,sh)
	p.sx=sx
	p.sy=sy
	p.sw=sw
	p.sh=sh
end

function setup_ply(p,sx,sy,sw,sh)
	setup_cmn(p,sx,sy,sw,sh)
	p.spd=0
	p.hp=3
	p.wt_m=0
	p.wt_s=0
	p.lv_wpn=0
	p.lv_spd=0
	p.scssr=0
	p.ox_fl=0
	p.ox_fr=0
	p.ox_bl=0
	p.ox_br=0
end

function setup_ene(p,sx,sy,sw,sh,spd,hp,point,score,sht_rt,sht_time,blt_id)
	setup_cmn(p,sx,sy,sw,sh)
	p.spd=spd
	p.hp=hp*(1.0+(ene_lv*0.2))
	p.point=point
	p.score=score
	p.sht_rt=sht_rt+ene_lv*2
	p.sht_wt=rnd_bs2(sht_time,sht_time*0.5)
	p.sht_time=sht_time*(1.0-(ene_lv*0.01))
	p.blt_id=blt_id
end

function setup_blt(p,sx,sy,sw,sh,spd,hp,atk)
	setup_cmn(p,sx,sy,sw,sh)
	p.spd=spd
	p.hp=hp
	p.atk=atk
end

function setup_itm(p,sx,sy,sw,sh,spd,score)
	setup_cmn(p,sx,sy,sw,sh)
	p.spd=spd
	p.score=score
end

function new_obj(tp,id,x,y)
	local p={tp,id,x,y,sx,sy,sw,sh,scl}
	p.tp=tp
	p.force=0
	p.id=id
	p.x=x
	p.y=y
	p.wx=x*10
	p.wy=y*10
	p.mvx=0
	p.mvy=0
	p.scl=1
	p.hp=1
	p.atk=1
	p.inv=0
	p.spd=0
	p.rot=0
	p.cnt=0
	p.stt=0
	p.phs=0
	p.flg=0
	p.dmg_wt=0
	p.dmg_stt=0
	p.onscr=0
	p.disp=1
	if tp==0 then
		--ply----------
		if id==0 then
			setup_ply(p,0,0,9,10)
		end
		---------------
	elseif tp==1 then
		--ene----------
		if id==0 then
			setup_ene(p, 0,32, 8, 8,  5,1,3,10,  0,100,10)
		elseif id==1 then
			setup_ene(p, 0,32, 8, 8, 18,1,4,20,  5,60,10)
		elseif id==2 then
			setup_ene(p, 0,32, 8, 8, 18,1,4,20,  5,60,10)
		elseif id==3 then
			setup_ene(p,16,32, 8, 8, 25,2,5,30, 15,50,11)
		elseif id==4 then
			setup_ene(p,16,32, 8, 8, 25,2,5,30, 15,50,11)
		elseif id==20 then
			setup_ene(p, 0,48,16,16, 18,40,0,0, 100,60,11)
			p.inv=1
		elseif id==21 then
			setup_ene(p,48,48,16,16, 18,25,0,0,   0,60,11)
		elseif id==22 then
			setup_ene(p,48,48,16,16, 18,25,0,0,   0,60,11)
			p.scl=0.7
		elseif id==23 then
			setup_ene(p,48,48,16,16, 18,25,0,0,   0,60,11)
			p.scl=0.4
		end
		---------------
	elseif tp==2 then
		--blt----------
		if id==0 then
			setup_blt(p,40,24,1,3, 50, 1, 1.0*(1.0+(0.2*ply.lv_wpn)))
		elseif id==1 then
			setup_blt(p,48,24,1,8, 50,99, 1.0*(1.0+(0.1*ply.lv_wpn)))
		elseif id==2 then
			setup_blt(p,56,24,7,7, 30, 1, 1.5*(1.0+(0.2*ply.lv_wpn)))
		elseif id==3 then
			setup_blt(p, 0, 0,1,1, 40,99, 1)
		elseif id==10 then
			setup_blt(p,64,32,4,4, 10, 1, 1)
		elseif id==11 then
			setup_blt(p,64,32,4,4, 15, 1, 1)
		end
		---------------
	elseif tp==3 then
		--itm----------
		if id==0 then
			setup_itm(p,  0,24,7, 7, 5,100)
		elseif id==1 then
			setup_itm(p,  8,24,7, 7, 5,100)
		elseif id==2 then
			setup_itm(p, 16,24,7, 7, 5,100)
		elseif id==3 then
			setup_itm(p, 80, 0,9,10, 4,100)
		elseif id==4 then
			setup_itm(p, 96, 0,9,10, 4,100)
		elseif id==5 then
			setup_itm(p,112, 0,9,10, 4,100)
		end
		---------------
	end
	return p
end

function new_ply(id,x,y)
	p=new_obj(0,id,x,y)
	p.rld_m=0
	p.rld_s=0
	return p
end

function new_ene_cnt(id,x,y,cnt)
	p=new_obj(1,id,x,y)
	p.grp=ene_grp
	p.cnt=cnt
	p.force=1
	return p
end

function new_ene(id,x,y)
	return new_ene_cnt(id,x,y,0)
end

function new_blt_rot(id,grp,x,y,rot)
	p=new_obj(2,id,x,y)
	p.grp=grp
	p.rot=rot+180
	set_mv(p)
	return p
end

function new_blt_ene1(id,e,rng)
	rot=-ang_to_deg(atan2(ply.x-e.x,ply.y-e.y))+90
	rot-=rnd_bs1(0,rng)
	p=new_blt_rot(id,10,e.x,e.y,rot)
	p.force=1
	p.spd+=ene_lv*2
	p.spd+=rndf_bs2(0,p.spd*0.1)
	set_mv(p)
	return p
end

function new_blt(id,grp,x,y)
	return new_blt_rot(id,grp,x,y,0)
end

function new_itm(id,x,y)
	return new_obj(3,id,x,y)
end

function new_opt()
	local o={id,x,y,x2,y2,x3,y3,ox,oy,sx,sy,sw,sh,stt}
	o.id=0
	o.x=-100
	o.y=-100
	o.x2=-100
	o.y2=-100
	o.x3=-100
	o.y3=-100
	o.hp=0
	o.stt=0
	o.dmg_wt=0
	o.dmg_stt=0
	return o
end

function set_opt(opt,sx,sy,sw,sh,ox,oy,hp)
	setup_cmn(opt,sx,sy,sw,sh)
	opt.ox=ox
	opt.oy=oy
	opt.hp=hp
end

function setup_opt(o,id,lr)
	o.id=id
	if id==1 then
		if lr==0 then
			set_opt(o, 80,0,4,10, -2,-3, 4)
		else
			set_opt(o, 85,0,4,10,  7,-3, 4)
		end
	elseif id==2 then
		if lr==0 then
			set_opt(o, 96,0,4,10, -2,-3, 2)
		else
			set_opt(o,101,0,4,10,  7,-3, 2)
		end
	elseif id==3 then
		if lr==0 then
			set_opt(o,112,0,4,10, -2,-3, 3)
		else
			set_opt(o,117,0,4,10,  7,-3, 3)
		end
	elseif id==4 then
		if lr==0 then
			set_opt(o,24,24,5, 5, -5,11, 3)
		else
			set_opt(o,24,24,5, 5,  9,11, 3)
		end
	end
end

function setup_eff(p,sx,sy,sw,sh,spd,num)
	setup_cmn(p,sx,sy,sw,sh)
	p.spd=spd
	p.num=num*10
end

function new_eff_1(id,x,y,cnt)
	local p={id,x,y,sx,sy,sw,sh,f,num}
	p.id=id
	p.x=x
	p.y=y
	p.f=0
	p.cnt=cnt
	if id==0 then
		setup_eff(p, 0, 64, 8, 8, 15,8)
	elseif id==1 then
		setup_eff(p, 0, 80,16,16, 10,6)
	elseif id==2 then
		setup_eff(p, 0, 72, 8, 8, 15,4)
	end
	return p
end

function new_eff_2(id,x,y)
	return new_eff_1(id,x,y,0)
end

--+++++++++++++++++++++++++++++
--+ etc
--+++++++++++++++++++++++++++++
function set_wpn_prm(m_rld,m_sht,s_rld,s_sht)
	ply.rld_m=m_rld
	ply.sht_m=m_sht
	ply.rld_s=s_rld
	ply.sht_s=s_sht
end

function setup_wpn()
	if ply.scssr<=1 then
		ply.ox_fl=2
		ply.ox_fr=1
		ply.ox_bl=2
		ply.ox_br=2
		if ply.lv_wpn==0 then
			set_wpn_prm(5.00, 3, 0,0)
		elseif ply.lv_wpn==1 then
			set_wpn_prm(4.25, 3, 0,0)
		elseif ply.lv_wpn==2 then
			set_wpn_prm(3.50, 4, 0,0)
		elseif ply.lv_wpn==3 then
			set_wpn_prm(2.75, 4, 0,0)
		elseif ply.lv_wpn==4 then
			set_wpn_prm(2.50, 4, 0,0)
		elseif ply.lv_wpn==5 then
			set_wpn_prm(2.75, 5, 0,0)
		end
	elseif ply.scssr==2 then
		ply.ox_fl=2
		ply.ox_fr=1
		ply.ox_bl=2
		ply.ox_br=2
		if ply.lv_wpn==0 then
			set_wpn_prm(6.00, 3, 12, 1)
		elseif ply.lv_wpn==1 then
			set_wpn_prm(5.75, 3, 11, 1)
		elseif ply.lv_wpn==2 then
			set_wpn_prm(5.50, 3, 10, 1)
		elseif ply.lv_wpn==3 then
			set_wpn_prm(5.25, 4, 10, 2)
		elseif ply.lv_wpn==4 then
			set_wpn_prm(5.00, 4,  9, 2)
		elseif ply.lv_wpn==5 then
			set_wpn_prm(4.75, 5,  8, 2)
		end
	elseif ply.scssr==3 then
		ply.ox_fl=0
		ply.ox_fr=0
		ply.ox_bl=-1
		ply.ox_br=-1
		if ply.lv_wpn==0 then
			set_wpn_prm(6.25, 3, 9.00, 2)
		elseif ply.lv_wpn==1 then
			set_wpn_prm(5.75, 3, 8.50, 2)
		elseif ply.lv_wpn==2 then
			set_wpn_prm(5.50, 3, 8.00, 3)
		elseif ply.lv_wpn==3 then
			set_wpn_prm(5.25, 4, 7.50, 3)
		elseif ply.lv_wpn==4 then
			set_wpn_prm(5.00, 4, 7.00, 3)
		elseif ply.lv_wpn==5 then
			set_wpn_prm(4.75, 4, 6.50, 3)
		end
	end
end

function setup_spd()
	ply.spd=13+(ply.lv_spd*2)
end

function pop_itm()
	v=rnd_bs1(0,100)
	if v>80 then
		id=rnd_bs1(3,3)
	elseif v>20 then
		id=rnd_bs1(1,2)
	else
		id=0
	end
	x =rnd_bs2(64,48)
	add(itm,new_itm(id,x,-10))
end

--+++++++++++++++++++++++++++++
--+ coll
--+++++++++++++++++++++++++++++
function is_on(p,l,t,r,b)
	if p.x+p.sw>l and
	   p.y+p.sh>t and
	   p.x     <r and
	   p.y     <b then
		return 1
	end
	return 0
end

function is_on_scr(p)
	return is_on(p,0,0,128,128)
end

function is_on_valid_area(p)
	return is_on(p,-64,-64,192,192)
end

function is_coll(p1,p2)
	if p1.x      <p2.x+p2.sw and
	   p1.y      <p2.y+p2.sh and
	   p1.x+p1.sw>p2.x and
	   p1.y+p1.sh>p2.y then
		return 1
	end
	return 0
end

function chk_coll_ene()
	for b in all(blt) do
		for e in all(ene) do

			if b.force==0 and
			   e.inv<=1 and
			   b.hp>0 and
			   e.hp>0 and
			   is_coll(b,e)==1 then

				if e.inv==1 then

					add(eff,new_eff_2(2,b.x,b.y))
					play_se(3)
					b.hp=0

				else

					if e.dmg_wt<=0 then
						proc_dmg_1(e,b.atk)
						e.dmg_wt=3
						e.dmg_stt=1

						if e.hp>0 then
							add(eff,new_eff_2(0,b.x,b.y))
							play_se(5)
						else

							add(eff,new_eff_2(0,e.x,e.y))
							play_se(2)

							tscore+=e.score

							ipoint+=e.point
							if ipoint>=50 then
								ipoint-=50
								pop_itm()
							end
						end
					end
					if b.hp>0 then
						b.hp-=1
					end
				end
			end
		end
	end
end

function chk_reset_scssr()
	if opt_fl.hp<=0 and
	   opt_fr.hp<=0 then
		ply.scssr=0
		ply.lv_wpn=0
	end
end

function proc_dmg_1(p1,atk)
	if p1.inv==0 and
	   p1.dmg_wt<=0 then
		p1.hp-=atk
		if p1.tp==1 and
			p1.id>=20 and
			p1.id<=23 and
			p1.hp<=1 then
			p1.hp=1
			if p1.id==20 then
				p1.stt=10
				p1.inv=2
			elseif p1.id>=20 and
				p1.id<=23 then
				p1.inv=1
			end
		end
	end
end

function proc_dmg_2(p1,p2)
	proc_dmg_1(p1,p2.atk)
	proc_dmg_1(p2,p1.atk)
end

function chk_coll_ply_opt(p,opt)
	if p.hp>0 and
	   opt.hp>0 and
	   opt.dmg_wt<=0 and
	   is_coll(p,opt)==1 then
		proc_dmg_1(p,1)
		opt.hp-=1
		opt.stt=1
		opt.dmg_wt=20
		play_se(6)
		chk_reset_scssr()
	end
end

function chk_coll_ply(ol)
	for p in all(ol) do
		if p.force==1 and
		   p.inv<=1 and
		   ply.hp>0 and
		   ply.inv<=1 then

			chk_coll_ply_opt(p,opt_fl)
			chk_coll_ply_opt(p,opt_fr)
			chk_coll_ply_opt(p,opt_bl)
			chk_coll_ply_opt(p,opt_br)

			if p.hp>0 and
			   ply.hp>0 and
			   ply.dmg_wt<=0 and
			   is_coll(ply,p)==1 then
				proc_dmg_1(p,1)
				ply.hp-=1
				ply.dmg_wt=20
				ply.lv_spd=max(ply.lv_spd-3,0)
				setup_spd()
				play_se(7)
				add(eff,new_eff_2(1,ply.x,ply.y))
			end
		end
	end
end

function chk_coll_itm()
	if ply.hp>0 then
		for i in all(itm) do
			if is_coll(ply,i)==1 then

				play_se(1)
				tscore+=i.score

				if i.id==0 then

					if ply.lv_wpn<5 then
						ply.lv_wpn+=1
						setup_wpn()
					end

				elseif i.id==1 then

					if ply.lv_spd<5 then
						ply.lv_spd+=1
						setup_spd()
					end

				elseif i.id==2 then

					if opt_bl.hp==0 then
						setup_opt(opt_bl,4,0)
					elseif opt_br.hp==0 then
						setup_opt(opt_br,4,1)
					end
					setup_wpn()

				elseif i.id==3 then

					if ply.scssr!=1 then
						ply.lv_wpn=0
					end
					ply.scssr=1
					setup_wpn()
					setup_opt(opt_fl,1,0)
					setup_opt(opt_fr,1,1)

				elseif i.id==4 then

					if ply.scssr!=2 then
						ply.lv_wpn=0
					end
					ply.scssr=2
					setup_wpn()
					setup_opt(opt_fl,2,0)
					setup_opt(opt_fr,2,1)

				elseif i.id==5 then
					
					if ply.scssr!=3 then
						ply.lv_wpn=0
					end
					ply.scssr=3
					setup_wpn()
					setup_opt(opt_fl,3,0)
					setup_opt(opt_fr,3,1)
					
				end

				del(itm,i)

			end
		end
	end
end

--+++++++++++++++++++++++++++++
--+ utility
--+++++++++++++++++++++++++++++
function chk_del_bg_obj()
	for b in all(bgo) do
		if b.x<-32 or
		   b.y<-32 or
		   b.x>160 or
		   b.y>160 then
			del(bgo,b)
		end
	end
end

function chk_del_obj(ol)
	for p in all(ol) do 
		if p.hp<=0 or
		   (p.onscr==1 and is_on_scr(p)==0) or
		   is_on_valid_area(p)==0 then
			del(ol,p)
		end
	end
end


function get_obj_num_id(ol,id)
	n=0
	for p in all(ol) do
		if p.id==id then
			n+=1
		end
	end
	return n
end

function get_obj_num_grp(ol,grp)
	n=0
	for p in all(ol) do
		if p.grp==grp then
			n+=1
		end
	end
	return n
end

function deg_to_ang(deg)
	if deg>=360 then
		deg-=360
	end
	if deg<0 then
		deg+=360
	end
	return deg/360.0
end

function ang_to_deg(ang)
	return 360.0*ang
end

function rnd_bs1(b,s)
	return b+flr(rnd(s))
end

function rnd_bs2(b,s)
	return rnd_bs1(b-s,s*2)
end

function rndf_bs1(b,s)
	return b+rnd(s)
end

function rndf_bs2(b,s)
	return rndf_bs1(b-s,s*2)
end

function lmt(v,mn,mx)
	if v<mn then
		return mn
	elseif v>mx then
		return mx
	end
	return v
end

--+++++++++++++++++++++++++++++
--+ update function
--+++++++++++++++++++++++++++++
----------------------
--+ update common
----------------------
function upd_pos(p)
	p.x=p.wx/10
	p.y=p.wy/10
	if p.onscr==0 and is_on_scr(p)==1 then
		p.onscr=1
	end
end

function set_mv(p)
	ang=deg_to_ang(p.rot)
	p.mvx=sin(ang)*p.spd
	p.mvy=cos(ang)*p.spd
end

function upd_mv(p)
	p.wx+=p.mvx
	p.wy+=p.mvy
end

function upd_dmg(p)
	p.dmg_wt =max(p.dmg_wt-1,0)
	p.dmg_stt=0
end

----------------------
--+ update bg
----------------------
function upd_bg()
	bg_shtx=0
	bg_shty=0

	tmp=deg_to_ang(bg_rot)
	bg_mvx=sin(tmp)
	bg_mvy=cos(tmp)

	bg_time-=1
	if bg_time<=0 then
		no =rnd_bs1(1,15)
		spd=rnd_bs1(1,3)
		x=lmt(64-(96*bg_mvx)+(rnd_bs2(0,96)*bg_mvy),-12,140)
		y=lmt(64-(96*bg_mvy)+(rnd_bs2(0,96)*bg_mvx),-12,140)
		add(bgo,new_bg_obj(no,x,y,spd))
		bg_time=rnd_bs1(1,3)
	end
end

function upd_bg_obj(b)
	tmp=b.spd*bg_spd
	b.x+=(bg_mvx*tmp)+(bg_shtx*tmp)
	b.y+=(bg_mvy*tmp)+(bg_shty*tmp)
end

----------------------
--+ update ply
----------------------
function upd_opt(opt)
	upd_dmg(opt)
	if opt.hp>0 or
	   (opt.hp==0 and opt.dmg_wt>0) then
		tmp_x=ply.x+opt.ox
		tmp_y=ply.y+opt.oy
		if opt.id==4 then
			opt.x=opt.x3
			opt.y=opt.y3
			opt.x3=opt.x2
			opt.y3=opt.y2
			opt.x2=tmp_x
			opt.y2=tmp_y
		else
			opt.x=tmp_x
			opt.y=tmp_y
		end
	end
end

function mk_blt_m(p,grp,ox,cnt)
	if cnt<p.sht_m then
		add(blt,new_blt(0,grp,p.x+ox,p.y))
		return 1
	end
	return 0
end

function mk_blt_opt(opt,id,grp,ox,cnt,sht,rot_b,rot_s)
	if opt.hp>0 and cnt<sht then
		add(blt,new_blt_rot(id,grp,opt.x+ox,opt.y,rnd_bs2(rot_b,rot_s)))
		return 1
	end
	return 0
end

function upd_ply(p)
	upd_dmg(p)
	if p.hp<=0 then

		if p.phs==0 then

			p.cnt=72
			p.phs=1

		elseif p.phs==1 then

			if p.cnt%6==0 then
				add(eff,new_eff_2(1,rnd_bs2(p.x,8),rnd_bs2(p.y,8)))
				play_se(7)
			end

			p.cnt-=1
			if p.cnt<36 then
				p.disp=0
			end
			
			if p.cnt<=0 then
				p.cnt=30
				p.phs=2
			end

		elseif p.phs==2 then

			p.cnt-=1
			if p.cnt<=0 then
				p.phs=3
				set_gm_stt(2)
			end

		end

	else

		p.stt=0

		if btn(0) then
			p.wx-=p.spd
			p.stt=1
			bg_shtx+=0.3
		end

		if btn(1) then
			p.wx+=p.spd
			p.stt=2
			bg_shtx-=0.5
		end

		if btn(2) then
			p.wy-=p.spd
		end

		if btn(3) then
			p.wy+=p.spd
		end

		if p.wx>(128-p.sw)*10 then
			p.wx=(128-p.sw)*10
		elseif p.wx<0 then
			p.wx=0
		end

		if p.wy>(128-p.sh)*10 then
			p.wy=(128-p.sh)*10
		elseif p.wy<0 then
			p.wy=0
		end

		upd_pos(p)

		if p.wt_m>0 then
			p.wt_m-=1
		end
		if p.wt_s>0 then
			p.wt_s-=1
		end

		if btn(4) then
			sht=0

			cnt_m =get_obj_num_grp(blt,0)
			cnt_fl=get_obj_num_grp(blt,1)
			cnt_fr=get_obj_num_grp(blt,2)
			cnt_bl=get_obj_num_grp(blt,3)
			cnt_br=get_obj_num_grp(blt,4)

			-- main shot ----
			if p.wt_m<=0 then

				p.wt_m=p.rld_m

				if p.scssr==0 then
					sht+=mk_blt_m(p,0,4,cnt_m)
				end

				if p.scssr<=1 then
					sht+=mk_blt_opt(opt_fl,0,1,p.ox_fl,cnt_fl,p.sht_m,0,0)
					sht+=mk_blt_opt(opt_fr,0,2,p.ox_fr,cnt_fr,p.sht_m,0,0)
					sht+=mk_blt_opt(opt_bl,0,3,p.ox_bl,cnt_bl,p.sht_m,0,0)
					sht+=mk_blt_opt(opt_br,0,4,p.ox_br,cnt_br,p.sht_m,0,0)
				end
			end

			-- sub shot ----
			if p.wt_s<=0 then

				p.wt_s=p.rld_s
				b_id=p.scssr-1

				if p.scssr==2 then
					-- scssr.2
					sht+=mk_blt_opt(opt_fl,1,1,p.ox_fl,cnt_fl,p.sht_s,0,0)
					sht+=mk_blt_opt(opt_fr,1,2,p.ox_fr,cnt_fr,p.sht_s,0,0)
					sht+=mk_blt_opt(opt_bl,1,3,p.ox_bl,cnt_bl,p.sht_s,0,0)
					sht+=mk_blt_opt(opt_br,1,4,p.ox_br,cnt_br,p.sht_s,0,0)
				elseif p.scssr==3 then
					-- scssr.3
					sht+=mk_blt_opt(opt_fl,2,1,p.ox_fl,cnt_fl,p.sht_s, -4,4)
					sht+=mk_blt_opt(opt_fr,2,2,p.ox_fr,cnt_fr,p.sht_s,  4,4)
					sht+=mk_blt_opt(opt_bl,2,3,p.ox_bl,cnt_bl,p.sht_s,-14,6)
					sht+=mk_blt_opt(opt_br,2,4,p.ox_br,cnt_br,p.sht_s, 14,6)
				end

			end

			if sht>0 then
				play_se(4)
			end
		end
	end
end

----------------------
--+ update ene
----------------------
function upd_ene_00(p)
	if p.stt==0 then
		p.rot=0
		set_mv(p)
		p.stt=1
	end
end

function upd_ene_01_02(p)
	if p.stt==0 then
		if p.id==1 then
			p.rot=-30
		else
			p.rot= 30
		end
		set_mv(p)
		p.stt=1
	elseif p.stt==1 then
		if((p.id==1 and p.x>ply.x) or
		   (p.id==2 and p.x<ply.x)) then
			p.rot=0
			set_mv(p)
			p.stt=2
		end
	end
end

function upd_ene_03_04(p)
	if p.stt==0 then
	
		if p.id==3 then
			p.rot=-30
		else
			p.rot= 30
		end
		set_mv(p)
		p.stt=1
		p.cnt=0
		
	elseif p.stt==1 then
		
		p.cnt+=1
		if p.cnt>=20 then
			p.stt=2
		end
		
	elseif p.stt==2 then
		
		if p.id==3 then
			p.rot-=4
			if p.rot<-180 then
				p.stt=3
			end
		else
			p.rot+=4
			if p.rot> 180 then
				p.stt=3
			end
		end
		set_mv(p)
	end
end

function upd_ene_20_23(p)

	b_end=0
	sht_num=3+flr(ene_lv/2)

	if p.id==20 then
		if p.inv==1 then
			n=0
			for e in all(ene) do
				if e.inv==0 then
					n+=1
				end
			end
			if n==0 then
				p.inv=0
			end
		end
	end

	if p.stt==0 then

		p.cnt-=1
		if p.cnt<=0 then
			p.stt=1
			p.cnt=0
		end

	elseif p.stt==1 then

		p.cnt+=1
		if p.cnt>=20 then
			p.stt=2
		end
		set_mv(p)

	elseif p.stt==2 then

		p.rot+=3
		if p.rot>=360 then
			p.rot=360
			p.stt=3
			if p.id==20 then
				for n=1, sht_num do
					add(blt,new_blt_ene1(10,p,30))
				end
			end
		end
		set_mv(p)

	elseif p.stt==3 then

		p.rot-=3
		if p.rot<=0 then
			p.rot=0
			p.stt=2
			if p.id==20 then
				for n=1, sht_num do
					add(blt,new_blt_ene1(10,p,30))
				end
			end
		end
		set_mv(p)

	elseif p.stt==10 then

		c=0
		for e in all(ene) do
			e.inv=2
			e.spd=0
			e.cnt=c*6
			e.stt=11
			set_mv(e)
			c+=1
		end

		elseif p.stt==11 then

			p.cnt-=1
			if p.cnt<=0 then
				p.cnt=60
				p.stt=12
			end

		elseif p.stt==12 then

			if p.cnt%12==0 then
				add(eff,new_eff_2(1,rnd_bs2(p.x,18),rnd_bs2(p.y,18)))
				play_se(7)
			end

			p.cnt-=1
			if p.cnt<0 then
			b_end=1
		end

	end

	if b_end==1 then
		del(ene,p)
	end
end

function upd_ene(p)
	p.flg=0
	if p.id==0 then
		
		upd_ene_00(p)
		
	elseif p.id==1 or
		   p.id==2 then
		
		upd_ene_01_02(p)
		
	elseif p.id==3 or
		   p.id==4 then
		
		upd_ene_03_04(p)
		
	elseif p.id>=20 and
		   p.id<=23 then
		
		upd_ene_20_23(p)
		
	end
	
	if p.hp>0 then
		if p.sht_rt>0 then
			p.sht_wt-=1
			if p.sht_wt<=0 then
				p.sht_wt=rnd_bs2(p.sht_time,p.sht_time*0.1)
				if rnd_bs1(0,100)<=p.sht_rt then
					add(blt,new_blt_ene1(p.blt_id,p,5))
				end
			end
		end
	end

	upd_dmg(p)
	upd_mv(p)
	upd_pos(p)
end

----------------------
--+ update blt
----------------------
function upd_blt(p)
	if p.id==3 then
		p.rot+=5
		if p.rot>=360 then
			p.rot=0
		end
		set_mv(p)
	end
	
	if p.id>=10 then
		p.stt+=1
		if p.stt>=3 then
			p.stt=0
		end
	end
	
	upd_mv(p)
	upd_pos(p)
end

----------------------

--+ update itm
----------------------
function upd_itm(p)
	p.wy+=p.spd
	upd_pos(p)
end

----------------------
--+ update eff
----------------------
function upd_eff(p)
	if p.cnt>0 then
		p.cnt-=1
	else
		p.f+=p.spd
		if p.f>=p.num then
			p.f=p.num
		end
	end
end

----------------------
--+ update pop ene 00
----------------------
function upd_pop_ene_00()
	if ene_stt==1 then
		ene_bs_x=rnd_bs2(64,48)
		ene_stt=2
	end

	if ene_time<=0 then
		x=ene_bs_x+rnd_bs2(0,20)
		add(ene,new_ene(0,x,-10))
		ene_cnt+=1
		if ene_cnt<5 then
			ene_time=8
		else
			ene_stt=0
			ene_time=20
		end
	end
end

----------------------
--+ update pop ene 01 or 02
----------------------
function upd_pop_ene_01_02()
	if ene_stt==1 then
		if ene_type==1 then
			ene_bs_x=rnd_bs2(  0,20)
		else
			ene_bs_x=rnd_bs2(128,20)
		end
		ene_stt=2
	end

	if ene_time<=0 then
		x=rnd_bs2(ene_bs_x,2)
		if ene_type==1 then
			add(ene,new_ene(1,x,-10))
		elseif ene_type==2 then
			add(ene,new_ene(2,x,-10))
		end
		ene_cnt+=1
		
		if ene_cnt<5 then
			ene_time=8
		else
			ene_stt =0
			ene_time=50
		end
	end
end

----------------------
--+ update pop ene 03 op 04
----------------------
function upd_pop_ene_03_04()
	if ene_stt==1 then
		if ene_type==3 then
			ene_bs_x=rnd_bs2(  0,20)
		else
			ene_bs_x=rnd_bs2(128,20)
		end
		ene_stt=2
	end

	if ene_time<=0 then
		x=ene_bs_x+rnd_bs2(0,2)
		if ene_type==3 then
			add(ene,new_ene(3,x,-10))
		elseif ene_type==4 then
			add(ene,new_ene(4,x,-10))
		end

		ene_cnt+=1
		if ene_cnt<5 then
			ene_time=8
		else
			ene_stt =0
			ene_time=50
		end
	end
end

----------------------
--+ update pop ene 20
----------------------
function upd_pop_ene_20()
	if ene_stt==1 then
		x=54
		y=-16
		add(ene,new_ene(20,x,y))
		add(ene,new_ene_cnt(21,x,y, 6))

		add(ene,new_ene_cnt(21,x,y,12))
		add(ene,new_ene_cnt(21,x,y,18))
		add(ene,new_ene_cnt(21,x,y,24))
		add(ene,new_ene_cnt(21,x,y,30))
		add(ene,new_ene_cnt(21,x,y,36))
		add(ene,new_ene_cnt(22,x,y,40))
		add(ene,new_ene_cnt(23,x,y,42))
		ene_stt=2
	end

	n=get_obj_num_grp(ene,ene_grp)
	if n==0 then
		tscore+=1000*(ene_lv+3)
		ene_lv +=1
		ene_stt =0
		ene_time=90
	end
end

----------------------
--+ update pop ene
----------------------
function upd_pop_ene()
	if ene_stt==0 then
		ene_time-=1
		if ene_time<=0 then
			ene_phs+=1
			if ene_phs<20 then
				ene_type=rnd_bs1(0,5)
			else
				ene_phs =0
				ene_type=20
			end

			ene_time=0
			ene_stt =1
			ene_cnt =0
			ene_bs_x=0
			ene_grp+=1
		end
	else
		ene_time-=1
		if ene_type==0 then
			upd_pop_ene_00()
		elseif ene_type==1 then
			upd_pop_ene_01_02()
		elseif ene_type==2 then
			upd_pop_ene_01_02()
		elseif ene_type==3 then
			upd_pop_ene_03_04()
		elseif ene_type==4 then
			upd_pop_ene_03_04()
		elseif ene_type==20 then
			upd_pop_ene_20()
		else
			ene_stt.a=0
		end
	end
end

--+++++++++++++++++++++++++++++
--+ draw function
--+++++++++++++++++++++++++++++
function draw_bg_obj(b)
 line(b.x,b.y,b.x,b.y,b.no)
end

function draw_obj(p)

	if p.disp==1 then

		sx=p.sx
		sy=p.sy
		if p.tp==0 then
			
			sx+=16*p.stt
			
			if p.dmg_wt%3==1 then
				sy+=10
			end
			
		elseif p.tp==1 then

			if p.id>=20 and
			   p.id<=23 then

				if p.hp<=1 then
					sx+=32
				elseif p.hp<=20 then
					sx+=16
				elseif p.dmg_stt==1 then
					sx=64
				end

			else

				if p.dmg_stt==1 then
					sx+=8
				end

			end
			
		elseif p.tp==2 then
			
			sx+=p.stt*p.sw
			
		end

		x=p.x
		y=p.y
		if p.dmg_wt>0 then
			x+=rnd_bs2(0,1)
			y+=rnd_bs2(0,1)
		end

		sspr(sx,sy,p.sw,p.sh,x,y,p.sw*p.scl,p.sh*p.scl)
	end
end

function draw_opt(opt)
	if opt.hp>0 or
	   (opt.hp==0 and opt.dmg_wt>0) then
		sx=opt.sx
		sy=opt.sy
		if opt.dmg_wt>0 then
			if opt.id==4 then
				sx+=8
			else
				sy+=16
			end
		end

		x=opt.x
		y=opt.y
		if opt.dmg_wt>0 then
			x+=rnd_bs2(0,2)
			y+=rnd_bs2(0,2)
		end

		sspr(sx,sy,opt.sw,opt.sh,x,y)
	end
end

function draw_obj_sort(ol)
	p_tmp=nil
	for c=1, #ol do
		y_min=999
		for n=1, #ol do
			p=ol[n]
			if p.flg==0 and
			   p.y<y_min then
				y_min=p.y
				p_tmp=p
			end
		end
		draw_obj(p_tmp)
		p_tmp.flg=1
	end
end

function draw_obj_opt()
	if ply.disp==1 then
		draw_opt(opt_fl)
		draw_opt(opt_fr)
		draw_opt(opt_bl)
		draw_opt(opt_br)
	end
end

function draw_eff(p)
	if p.f<p.num then
		sx=p.sx+(p.sw*flr(p.f/10))
		sspr(sx,p.sy,p.sw,p.sh,p.x,p.y)
	end
end

function draw_value(v,digit,x,y,c)
	x+=(digit-1)*4
	for n=1, digit do
		tmp=flr(v)%10
		print(tmp,x,y,c)
		v/=10
		x-=4
	end
end

--+++++++++++++++++++++++++++++
--+ main init
--+++++++++++++++++++++++++++++
function _init()
	bg_time=0
	bg_rot=0
	bg_mvx=0
	bg_mvy=0
	bg_spd=2
	bg_shtx=0
	bg_shty=0

	reset_game()

	for n=1, 32 do
		add(se,0)
	end
end

--+++++++++++++++++++++++++++++
--+ main update
--+++++++++++++++++++++++++++++
function update_title()
	gm_time=lmt(gm_time+1,0,9999)

	if gm_phs==0 then

		bg_spd =3
		bg_rot =180
		gm_phs =1
		gm_time=0

	elseif gm_phs==1 then

		if gm_time>50  then
			gm_phs=2
		end

	elseif gm_phs==2 then

		if gm_tmp>0 then
			gm_tmp+=2.5
				if gm_tmp>=360 then
					gm_tmp=0
				end
			bg_spd=3+(cos(deg_to_ang(gm_tmp))*1.5)
		end

		if bg_rot>0 then
			bg_rot+=1.5
			if bg_rot>=360 then
				bg_rot=0
			end
		end

		if gm_tmp==0 and
			bg_rot==0 then
			gm_phs=3
		end

	elseif gm_phs==3 then

		if btn(4) or btn(5) then
			gm_phs=4
		end

	elseif gm_phs==4 then

		bg_spd-=0.2
		if bg_spd<=1.1 then
			bg_spd=1
			gm_stt=1
			reset_game()
		end

	end
end

function update_main()

	upd_ply(ply)
	foreach(ene,upd_ene)
	foreach(blt,upd_blt)
	foreach(itm,upd_itm)
	foreach(eff,upd_eff)

	chk_coll_ene()
	chk_coll_itm()

	upd_opt(opt_fl)
	upd_opt(opt_fr)
	upd_opt(opt_bl)
	upd_opt(opt_br)

	chk_coll_ply(ene)
	chk_coll_ply(blt)

	chk_del_obj(ene)
	chk_del_obj(blt)
	chk_del_obj(itm)

	upd_pop_ene()

	for p in all(eff) do
		if p.f>=p.num then
			del(eff,p)
		end
	end
end

function update_result()
	gm_time=lmt(gm_time+1,0,9999)

	if gm_phs==0 then

		gm_phs =1
		gm_time=0

	elseif gm_phs==1 then

	if gm_time>120 then
		set_gm_stt(0)
	end

	end
end

function _update()

	upd_bg()

	if gm_stt==0 then
		update_title()
	elseif gm_stt==1 then
		update_main()
	elseif gm_stt==2 then
		update_main()
		update_result()
	end

	for n=1, 32 do
		se[n]=0
	end

	foreach(bgo,upd_bg_obj)
	chk_del_bg_obj()

end

--+++++++++++++++++++++++++++++
--+ main draw
--+++++++++++++++++++++++++++++
function draw_title()
	if gm_time>120 then
		print("k.n.m.s.",48,54,7)
	elseif gm_time>30 then
		print("k-miso presents",35,62,7)
	end

	if gm_phs==3 then
		print("push z key or btn 1",24,72,7)
	end
end

function draw_hp(x,y,val)
	sx=0
	if val<=ply.hp then
		sx=64
	end
	if val-1==ply.hp and
		   ply.dmg_wt%3==1 then
		sx=68
		x+=rnd_bs2(0,1)
		y+=rnd_bs2(0,1)
	end
	if sx>0 then
		sspr(sx,8,3,6,x,y)
	end
end

function draw_main()

	draw_obj_sort(ene)
	foreach(blt,draw_obj)
	foreach(itm,draw_obj)
	foreach(eff,draw_eff)
	draw_obj(ply)
	draw_obj_opt()

--	if true then
		print("st",2,2,7)
		print(".",9,2,7)
		draw_value(ene_lv+1,2,12,2,7)
		
		print("score",78,2,7)
		draw_value(tscore,7,100,2,7)

		sspr(64,14,13,2,24,6)
		draw_hp(25,1,1)
		draw_hp(29,1,2)
		draw_hp(33,1,3)

		sspr(64,28,16,2,40,6)
		if ply.lv_wpn>0 then
			sspr(64,22,(3*ply.lv_wpn),6,40,1)
		end

		sspr(64,28,16,2,58,6)
		if ply.lv_spd>0 then
			sspr(64,16,(3*ply.lv_spd),6,58,1)
		end
--	end
end

function draw_result()
	if gm_time>10 then
		print("game over",48,62,7)
	end
end

function _draw()
	cls()

	foreach(bgo,draw_bg_obj)

	if gm_stt==0 then
		draw_title()
	elseif gm_stt==1 then
		draw_main()
	elseif gm_stt==2 then
		draw_main()
		draw_result()
	end
end
__gfx__
008000800000000000080800000000000008080000000000000000000ee0ee000000000000000000000606000000000000900090000000000cc000cc00000000
00800080000000000008080000000000000808000000000000000000e88e87e00000000000000000006606600000000000990990000000000cc000cc00000000
00805080000000000005580000000000000855000000000000000000e88888e00000000000000000066808660000000000890980000000000c80008c00000000
0885c58800000000008c88800000000000888c800000000000000000e88888e0000000000000000066880886600000000888088800000000cc80008cc0000000
0885c58800000000008c88800000000000888c8000000000000000000e888e00000000000000000068800088600000000888088800000000c8880888c0000000
0085c58000000000000c58000000000000085c00000000000000000000e8e000000000000000000088800088800000008890009880000000c8880888c0000000
80665660800000000085568000000000008655800000000000000000000e0000000000000000000088000008800000008890009880000000c8800088c0000000
8666866680000000086868800000000000886868000000000000000000000000000000000000000068000008600000008890009880000000c8800088c0000000
860080068000000008886880000000000088688800000000080008000a000a008880aaa000000000668000866000000088890988800000000888088800000000
800000008000000008000800000000000008000800000000080508000a0a0a008880aaa000000000066000660000000008890988000000000088088000000000
00a000a000000000000a0a0000000000000a0a0000000000085c58000aaaaa008880aaa000000000000000000000000000000000000000000000000000000000
00a000a000000000000a0a0000000000000a0a0000000000885c5880aaaaaaa08880aaa000000000000000000000000000000000000000000000000000000000
00a0a0a000000000000aaa0000000000000aaa0000000000086568000aaaaa008880aaa000000000000000000000000000000000000000000000000000000000
0aaaaaaa0000000000aaaaa00000000000aaaaa00000000086686680aaaaaaa08880aaa000000000000000000000000000000000000000000000000000000000
0aaaaaaa0000000000aaaaa00000000000aaaaa00000000086080680aa0a0aa05555555555555000000000000000000000000000000000000000000000000000
00aaaaa000000000000aaa0000000000000aaa000000000080080080a00a00a05555555555555000000000000000000000000000000000000000000000000000
a0aaaaa0a000000000aaaaa00000000000aaaaa000000000000000000000000000c00c00c00c00c0000a0a000000000000a000a0000000000aa000aa00000000
aaaaaaaaa00000000aaaaaa00000000000aaaaaa0000000000000000000000000cc0cc0cc0cc0cc000aa0aa00000000000aa0aa0000000000aa000aa00000000
aa00a00aa00000000aaaaaa00000000000aaaaaa0000000000000000000000000cc0cc0cc0cc0cc00aaa0aaa0000000000aa0aa0000000000aa000aa00000000
a0000000a00000000a000a0000000000000a000a0000000000000000000000000cc0cc0cc0cc0cc0aaaa0aaaa00000000aaa0aaa00000000aaa000aaa0000000
00000000000000000000000000000000000000000000000000000000000000000cc0cc0cc0cc0cc0aaa000aaa00000000aaa0aaa00000000aaaa0aaaa0000000
00000000000000000000000000000000000000000000000000000000000000000c00c00c00c00c00aaa000aaa0000000aaa000aaa0000000aaaa0aaaa0000000
000000000000000000000000000000000000000000000000000000000000000000b00b00b00b00b0aa00000aa0000000aaa000aaa0000000aaa000aaa0000000
00000000000000000000000000000000000000000000000000000000000000000bb0bb0bb0bb0bb0aa00000aa0000000aaa000aaa0000000aaa000aaa0000000
088788000887880008878800099900000aaa000070000000a000000000ccc0000bb0bb0bb0bb0bb0aaa000aaa0000000aaaa0aaaa00000000aaa0aaa00000000
88ccc880887cc8808899988099799000aa7aa00070000000a00000000ccc7c000bb0bb0bb0bb0bb00aa000aa000000000aaa0aaa0000000000aa0aa000000000
87c7c78087c777808999798099999000aaaaa00070000000a0000000ccccccc00bb0bb0bb0bb0bb0000000000000000000000000000000000000000000000000
77ccc77077ccc7707999997099999000aaaaa00000000000a0000000ccccccc00b00b00b00b00b00000000000000000000000000000000000000000000000000
87c777808777c78089999980099900000aaa000000000000a0000000ccccccc00555555555555555000000000000000000000000000000000000000000000000
88c7788088cc788088999880000000000000000000000000a00000000ccccc005555555555555550000000000000000000000000000000000000000000000000
088788000887880008878800000000000000000000000000a000000000ccc0000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000ee009900aa00000000000000000000000000000000000000000000000000000
00eeee0000888800005555000088880000000000000000000000000000000000e99e9aa9aeea0000000000000000000000000000000000000000000000000000
0eeeeee008888880055555500888888000000000000000000000000000000000e99e9aa9aeea0000000000000000000000000000000000000000000000000000
0eeeeee0088888800555555008888880000000000000000000000000000000000ee009900aa00000000000000000000000000000000000000000000000000000
0e2ee2e0088888800585585008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0eeeeee0088888800555555008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00eeee00008888000055550000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000066660000000000006666000000000000eeee00000000000066660000000000007777000000000000eeee00000000000088880000000000000000000000
000066555566000000006622226600000000ee8888ee0000000066555566000000007722227700000000ee8888ee000000008888888800000000000000000000
00065555555560000006222222226000000e88888888e00000065555555560000007222222227000000e88888888e00000088888888880000000000000000000
0065566666655600006226666662260000e88eeeeee88e000065566666655600007227777772270000e88eeeeee88e0000888888888888000000000000000000
065566555566556006226622226622600e88ee8888ee88e0065566555566556007227722227722700e88ee8888ee88e008888888888888800000000000000000
065665555556655006266222222662200e8ee888888ee880065665555556655007277222222772200e8ee888888ee88008888888888888800000000000000000
65555555555555566222222222222226e88888888888888e65555555555555567222222222222227e88888888888888e88888888888888880000000000000000
65555555555555566222222222222226e88888888888888e65555555555555567222222222222227e88888888888888e88888888888888880000000000000000
65555555555555566222222222222226e88888888888888e65555555555555567222222222222227e88888888888888e88888888888888880000000000000000
65555555555555566222222222222226e88888888888888e65555555555555567222222222222227e88888888888888e88888888888888880000000000000000
055588555588555002228822228822200888ee8888ee888005555555555555500222222222222220088888888888888008888888888888800000000000000000
055588555588555002228822228822200888ee8888ee888005555555555555500222222222222220088888888888888008888888888888800000000000000000
00555555555555000022222222222200008888888888880000555555555555000022222222222200008888888888880000888888888888000000000000000000
00055555555550000002222222222000000888888888800000055555555550000002222222222000000888888888800000088888888880000000000000000000
00005555555500000000222222220000000088888888000000005555555500000000222222220000000088888888000000008888888800000000000000000000
00000055550000000000002222000000000000888800000000000055550000000000002222000000000000888800000000000088880000000000000000000000
00000000000000000007700000aaaa000079970000999900009aa90000a00a000000000000000000000000000000000000000000000000000000000000000000
000000000077770007aaaa700a9999a0099aa99009aaaa9009a77a90070000700000000000000000000000000000000000000000000000000000000000000000
00077000077aa7700aa99aa0a999999a79aaaa999aa77aa99a7007a9a000000a0000000000000000000000000000000000000000000000000000000000000000
0077770007aaaa707a9999a7a99aa99a9aa77aa99a7007a9a700007a000000000000000000000000000000000000000000000000000000000000000000000000
0077770007aaaa707a9999a7a99aa99a9aa77aa99a7007a9a700007a000000000000000000000000000000000000000000000000000000000000000000000000
00077000077aa7700aa99aa0a999999a79aaaa979aa77aa99a7007a9a000000a0000000000000000000000000000000000000000000000000000000000000000
000000000077770007aaaa700a9999a0099aa99009aaaa9009a77a90070000700000000000000000000000000000000000000000000000000000000000000000
00000000000000000007700000aaaa000079970000999900009aa90000a00a000000000000000000000000000000000000000000000000000000000000000000
00000000000000000007a00000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000a00000a0000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000700700000000a0a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000a0000007000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000a0a000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007007000a000000a000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000a00000000070000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000a700000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007777770000000000aaaaaa0000000000999999000000000099999900000000007077770000000000000000000000000000000000000
00000000000000000007777777777000000aaa9999aaa000000999aaaa9990000009997777999000000770000000000000000000000000000000000000000000
0000000000000000007777aaaa77770000aa99999999aa000099aaaaaaaa99000099777777779900000000000000070000000000000000000000000000000000
00000000000000000777aaaaaaaa77700aa9999999999aa0099aaaa77aaaa9900997777007777990070000000000007000000000000000000000000000000000
0000007777000000077aaaaaaaaaa7700a9999aaaa9999a009aaa777777aaa900977700000077790000000000000007000000000000000000000000000000000
0000077777700000777aaa9999aaa777aa999a7777a999aa99aa77000077aa999977000000007799700000000000000700000000000000000000000000000000
0000777aa777000077aaa999999aaa77a999a777777a999a9aaa70000007aaa99777000000007779700000000000000700000000000000000000000000000000
000077aaaa77000077aaa99aa99aaa77a999a770077a999a9aa7700000077aa99770000000000779000000000000000000000000000000000000000000000000
000077aaaa77000077aaa99aa99aaa77a999a770077a999a9aa7700000077aa99770000000000779700000000000000000000000000000000000000000000000
0000777aa777000077aaa999999aaa77a999a777777a999a9aaa70000007aaa99777000000007779700000000000000700000000000000000000000000000000
0000077777700000777aaa9999aaa777aa999a7777a999aa99aa77000077aa999977000000007799700000000000000700000000000000000000000000000000
0000007777000000077aaaaaaaaaa7700a9999aaaa9999a009aaa777777aaa900977700000077790070000000000000000000000000000000000000000000000
00000000000000000777aaaaaaaa77700aa9999999999aa0099aaaa77aaaa9900997777007777990070000000000007000000000000000000000000000000000
0000000000000000007777aaaa77770000aa99999999aa000099aaaaaaaa99000099777777779900007000000000070000000000000000000000000000000000
00000000000000000007777777777000000aaa9999aaa000000999aaaa9990000009997777999000000000000007000000000000000000000000000000000000
0000000000000000000007777770000000000aaaaaa0000000000999999000000000099999900000000007770770000000000000000000000000000000000000
00003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000050000000a00000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
000000100000000000d0000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
ce00ce000000c300ce0000000000c000cf00c2000000c300c10000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ce0000cecf0000000000000000000000c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ce0000000000c100000000cecf000000c10000000000c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c100000000000000ce00ce0000cecf00c100000000000000c200c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c2ce00d20000000000c1cecf00000000c2c100d20000000000c1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000c0000000000000cf0000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ce00ce00000000ce0000000000ce0000cf00c000000000c10000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ce0000c100ce0000ce0000ce00ce00cfc20000c100c30000c30000c100c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c20000ce00ce00000000ce000000c3cfc20000c100c300000000c0000000c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000c200000000cf00000000000000000000c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ce0000000000c300000000000000cf00c10000000000c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000c00000000000000000c300c0cf000000c00000000000000000c300c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ce0000000000000000000000000000cfc30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ce00000000ce0000ce0000ce00cf0000c200000000c00000c20000c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c100000000ce0000000000000000cf00c100000000c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c300ce00ce0000000000c30000c00000cf00c300c30000000000c30000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ce00ce000000c300ce0000000000c000ce00c2000000c300c10000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000ce0000cecf0000000000000000000000c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ce0000000000c100000000cecf000000c10000000000c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c100000000000000ce00ce0000cecf00c100000000000000c200c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c2ce00d20000000000c1cecf00000000c2c100d20000000000c1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000c0000000000000cf0000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ce00ce00000000ce0000000000ce0000cf00c000000000c10000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ce0000c100ce0000ce0000ce00ce00cfc20000c100c30000c30000c100c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c20000ce00ce00000000ce000000c3cfc20000c100c300000000c0000000c3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000c200000000cf00000000000000000000c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000ce0000000000c300000000000000cf00c10000000000c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c0000000c00000000000000000c300c0cf000000c00000000000000000c300c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00ce0000000000000000000000000000cfc30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000ce00000000ce0000ce0000ce00cf0000c200000000c00000c20000c300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000c100000000c30000000000000000cf00c100000000c30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c300ce00c30000000000c30000c00000cf00c300c30000000000c30000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000390703f0703c07034070280701d07027070310703c070270702c07031070350702d0703f0701e0001d0001c0001c0001b0001b0001a000190001800016000010000300004000010000e0000c0000c000
000100001f57020570215702357026570285702b5702f570345703a5703f5703f5701e5201f520215202352025520285202b52030520345203e5203f5201e5101f5102151024510275102c510305103e5103f510
00020000200301b03012030160300f0300403008030020301a00006000070001f50018500165000c5000c5000a5000850007500035000900009000090000a0000d00000000000000000000000000000000000000
000100003f3303f3303f3203f3203f3103f3103f3003f3003f3003f3003f3003f3003f3003f3003f3003f30002000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002c120251201e1002010001000020000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000036330313302f3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000151701a1701a170271701f1701c1702617023170191701c170231701e1701b17016170000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000036270372702c2702b2702c27027270202702327022270292701f270142702327025270212601a2601126020260222701d260122600c250182500e2500725005240092400123003230072200122001220
000100002b3702a370293702737025370223701f3701b37016370113700c370083702834028340263402434023340213401c3401834016340113400a34028340273102531024310213101e310183101231006310
000100000d37012470134701347013470053701347004370134701247010470033700f4700c4700a4700747003470014700220003300043000420004300043000330003300033000560000000000000000000000
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
000d00000507001000050700300019000000000500005000050000300005070050000507005000000000000000000040000500005000000000507000000050700500000000000000000000000050000500000000
0001000027570255702457022570205701e5701c570195701657015570275002550024500225001f5001e5001c500185001450005500105000d5000a500075000550001500035000150001600026000160001600
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
02 20 02 03 04
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
