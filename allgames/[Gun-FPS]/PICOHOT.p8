pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--picohot by superhot team

--#include code/picohot.min.lua
nil_func=function() end

pr=print
rf=rectfill
ln=line
cm=camera
sp=sspr

function yd()
    yield()
end

function prs(f)
    if tonum(f)==nil then
        return f
    end
    return tonum(f)
end

function expl_r(str,dels,di)
    di=di or 1
    if di-1==#dels then return prs(str) end
    local a=expl(str,dels[di])
    di=di+1
    for i,v in pairs(a) do
        a[i]=expl_r(v,dels,di)
    end
    return a;
end

function expl(str,del)
    local a={}
    local lst=1
    local ai=1
    for i=1,#str+1 do
        if i==#str+1 or sub(str,i,i)==del then
            local s=sub(str,lst,i-1)
            add(a,prs(s))
            ai=ai+1
            i=i+1
            lst=i
        end
    end
    return a
end

function clone(o)
    c={}
    for k,v in pairs(o) do
        c[k] = v
    end
    return c
end

vmt={}

function vec(x,y,z)
	return setmetatable({x=x,y=y,z=z},vmt)
end

function vec_cl(v)
    return vec(v.x,v.y,v.z)
end

function vec0()
    return vec(0,0,0)
end

function vmt.__len(v)
	return sqrt(v.x*v.x+v.y*v.y+v.z*v.z)
end

function nrm(v)
	local l=#v
	return l==0 and vec(0,0,0) or v/l
end

function vmt.__add(a, b)
	if type(b)=="number" then
		return vec(a.x+b,a.y+b,a.z+b)
	else
		return vec(a.x+b.x,a.y+b.y,a.z+b.z)
	end
end

function vmt.__sub(a,b)
	if type(b)=="number" then
		return vec(a.x-b,a.y-b,a.z-b)
	else
		return vec(a.x-b.x,a.y-b.y,a.z-b.z)
	end
end

function vmt.__mul(a,b)
	if type(b)=="number" then
		return vec(a.x*b,a.y*b,a.z*b)
	else
		return vec(a.x*b.x,a.y*b.y,a.z*b.z)
	end
end

function vmt.__div(a,b)
	if type(b)=="number" then
		return vec(a.x/b,a.y/b,a.z/b)
	else
		return vec(a.x/b.x,a.y/b.y,a.z/b.z)
	end
end

function dot(a,b)
	return a.x*b.x+a.y*b.y+a.z*b.z
end

function lerp(a,b,t)
	return a+(b-a)*t;
end

function ease_in_out(t)
	t=t*2
	if t<1 then
		return .5*t*t
	else
		t=t-1
		return -.5*(t*(t-2)-1);
	end
end

function rndr(min,max)
	return rnd(max-min)+min
end

function rndi(min,max)
	return flr(rndr(min,max))
end

function rndd()
	return nrm(vec(rndr(-1,1),rndr(-1,1),rndr(-1,1)))
end

vec_f=vec(0,0,1)
morph=1
vm={}

function r_upd()
	if wd then
		cosp,sinp,cosy,siny=
		cos(p_rx),sin(p_rx),
		cos(p_ry),sin(p_ry)
		local x,y,z=
			vec(cosy,0,-siny),
			vec(siny*sinp,cosp,cosy*sinp),
			vec(siny*cosp,-sinp,cosp*cosy)
		p=vec(p_p.x,p_p.y+1.5,p_p.z)
		vm={
			m11=x.x,m12=y.x,m13=z.x,m14=0,
			m21=x.y,m22=y.y,m23=z.y,m24=0,
			m31=x.z,m32=y.z,m33=z.z,m34=0,
			m41=-dot(x,p),m42=-dot(y,p),m43=-dot(z,p),m44=1}
	end
end

function r_render()
	if wd then w_render() end
	if os then os_render() end
	if scl then s_render() end
end

function prj_v(v)
	return prj(v.x,v.y,v.z)
end

function prj(vx,vy,vz)
	local p=vec(
		vx*vm.m11+vy*vm.m21+vz*vm.m31+vm.m41,
		vx*vm.m12+vy*vm.m22+vz*vm.m32+vm.m42,
		vx*vm.m13+vy*vm.m23+vz*vm.m33+vm.m43)

	local z=p.z*.7
	if abs(z)<=.1 then z=.1 end
	local x=p.x/z
	local y=p.y/z
	if z<0 then x=2*p.x-x y=2*p.y-y	end

	y=-y
	x=x*morph
	x=x*64+64
	y=y*64+64

	return x,y,z
end
t=true
f=false
dlt=1/60

function _init()
	cartdata("picohot_v2")
	lg_init()
end

function _update60()
	lg_upd()
	for c in all(l_crs) do
		if costatus(c) then
			coresume(c)
		else
			del(l_crs,c)
		end
	end
	r_upd()
end

function _draw()
	if cls_enb then cls() end
	r_render()
	for c in all(r_crs) do
		if costatus(c) then
			coresume(c)
		else
			del(r_crs,c)
		end
	end
end

function l_cr(c)
	return add(l_crs,cocreate(c))
end

function r_cr(c)
	return add(r_crs,cocreate(c))
end

function stop_r_cr(c)
	del(r_crs,c)
end

function quit()
	extcmd('shutdown')
end
min_g_dlt=dlt/30
b_speed=10

function reset()
    
    --core
    
    l_crs={}
	r_crs={}
    inp_enb=t
    g_dlt=dlt
    cls_enb=t
    music(-1,100)
    cm()
    pal()

    --world

    wd=f
    bts={}
    shk=f
    prtcs={}
    props={}
    is_endl=f
    
    --enemy
    
    es={}
    on_e_kill=nil_func

    --item

    its={}

    --player

    p_rx=0
    p_ry=0
    p_p=vec0()
    p_alv=t
    p_vx=0
    p_vz=0
    p_ctrl=f
    p_i=nil
    p_n_i=nil
    p_n_e=nil
    p_rld=f
    p_pun_anm_f=1
    p_gun_anm_t=0
    p_lst_pun_t=0

    --os
    
    os=f
    os_sel_opt=1
    os_opts={}
    os_list_enb=t
    os_pass=""
    os_scrl=0

    --social

    scl=f
    s_posts={}
    s_dwnld=f
end

function lg_init()
    menuitem(1,"exit to menu",os_init)
    reset()
    load_sv()
    r_cr(os_intro)
end

function lg_upd()
    poke(0x5f30,1) --disable pause menu
    
    if scl then
        --social

        if btn(2) then s_scrl=s_scrl+2 end
        if btn(3) then s_scrl=s_scrl-2 end
        s_scrl=min(s_scrl,0)
        if s_dwnld and (btnp(5) or btnp(6)) then
            sfx(12)
            os_download()
        elseif btnp(4) then
            sfx(12)
            os_init()
        end
    elseif os then
        --os

        if inp_enb then
            if btnp(2) and os_sel_opt>1 then
                sfx(14)
                os_sel_opt=os_sel_opt-1
                os_shk()
            elseif btnp(3) and os_sel_opt<#(os_opts) then
                sfx(14)
                os_sel_opt=os_sel_opt+1
                os_shk()
            elseif btnp(5) or btnp(6) then
                if os_opts[os_sel_opt][4]>sv.prg then
                    r_cr(os_br)
                else
                    sfx(12)
                    os_view_in()
                    os_opts[os_sel_opt][2]()
                end
            end
        end
    elseif wd then
        --world

        if btnp(6) then extcmd("pause") end

        --player

        if p_alv and p_ctrl and inp_enb then
            inp=vec0()
            if btn(0) then inp.x=-1
            elseif btn(1) then inp.x=1 end
            if btn(2) then inp.z=1
            elseif btn(3) then inp.z=-1 end

            inp=nrm(inp)*p_max_v

            p_vx=lerp(p_vx,inp.x,dlt*10)
            p_vz=lerp(p_vz,inp.z,dlt*10)

            if p_n_e and abs(p_n_e.p.z-p_p.z)<.7 then p_vz=min(p_vz,0) end

            p_p.x=p_p.x+p_vx*dlt
            p_p.z=p_p.z+p_vz*dlt

            w_coll(p_p,.5)

            move_time(abs(p_vx)/p_max_v)
            move_time(abs(p_vz)/p_max_v)

            if btnp(4) then p_action_b() end
            if btnp(5) then p_action_a() end
        end

        --enemies

        for i=1,#es do
            j=i
            while j>1 and es[j-1].p.z<es[j].p.z do
                es[j],es[j-1]=es[j-1],es[j]
                j=j-1
            end
        end

        if p_alv then
            for e in all(es) do
                if e.stn and e.gt_b>1 then
                    e_unstun(e)
                end
                e.t=e.t+dlt
                e.gt_a=e.gt_a+g_dlt
                e.gt_b=e.gt_b+g_dlt
                e.gt_c=e.gt_c+g_dlt
                e.ai.upd(e)
            end
        end

        --bullets

        if p_alv then
            for b in all(bts) do
                b.p=b.p+b.d*b_speed*g_dlt
                if w_is_coll(b.p,-10) or b.p.y<0 then
                    del(bts,b)
                elseif b.id==0 then
                    for e in all(es) do
                        if e_b_coll(e,b) then
                            e_kill(e)
                            del(bts,b)
                        end
                    end
                elseif p_b_coll(b) then
                    p_kill()
                    del(bts,b)
                end
                pane_coll(b.p)
            end
        end

        --particles

		for p in all(prtcs) do
			if p.l<=0 then
				del(prtcs,p)
			else
				p.l=p.l-g_dlt
				if p.p.y<=0 then
					p.v=vec0()
				else
					p.v=p.v-p.v*.1*g_dlt
					p.v.y=p.v.y-3*g_dlt
					p.p=p.p+p.v*g_dlt
				end
			end
        end

        --near enemy

        p_n_e=nil
        
        for i=#es,1,-1 do
            e=es[i]
            if abs(e.p.x-p_p.x)<.5 and e.p.z>p_p.z+.1 and e.p.z<p_p.z+1.2 then
                p_n_e=e
                break
            end
        end

        --misc

        if p_alv and p_i and p_rld and p_i.t>p_i.rel_t then
            p_rld=f
            w_blk_cross=t
            sfx(21)
        end

        --items

        p_n_i=nil
        for i in all(its) do
            if i.thr then
                pane_coll(i.p)
                if w_is_coll(i.p) then
                    i_del(i)
                    goto i_done
                end
                i.p=i.p+i.v*g_dlt
                if i.dmg then
                    for b in all(bts) do
                        if coll(b.p,i.p,.3) then
                            del(bts,b)
                            sfx(27)
                        end
                    end
                    for e in all(es) do
                        if coll(e.p,i.p,.4) then
                            e_stun(e)
                            i_del(i)
                            goto i_done
                        end
                    end
                    goto i_done
                end
            end
            if not p_i and coll(p_p,i.p,1.5) then
                p_n_i=i
            end
        end
        ::i_done::
        if p_i then
            p_i.t=p_i.t+g_dlt
        end
        g_dlt=min_g_dlt
    end
end

function prg_story(p)
    sv.prg=max(sv.prg,p)
    save_sv()
end

function load_sv()
    sv={
        prg=dget(0),
        scr=max(dget(1),20)
    }
end

function save_sv()
    dset(0,sv.prg)
    dset(1,sv.scr)
end

function p_b_coll(b)
    return b.p.y<2 and b.p.z>p_p.z+.2 and coll(p_p,b.p,.4)
end

function e_b_coll(e,b)
    return b.p.y<2 and coll(e.p,b.p,.4)
end

function move_time(v)
    g_dlt=g_dlt+min(dlt*v,dlt)
end

function coll(a,b,r)
    r=r or 0
    return abs(a.x-b.x)<r and abs(a.z-b.z)<r
end
function w_init()
	wd=t
	w_morph_in(.5,.1)
	sfx(26)
end

function w_coll(p,r)
	r=r or 0
	p.x=mid(l_bnd[1]+r,p.x,l_bnd[2]-r)
	p.z=mid(l_bnd[3]+r,p.z,l_bnd[4]-r)

	for pn in all(panes) do
		if p.x>pn[1]-r and p.x<pn[2]+r then
			if p.z<pn[3] then
				p.z=min(p.z,pn[3]-r)
			elseif p.z>pn[3] then
				p.z=max(p.z,pn[3]+r)
			end
		end
	end
end

function w_is_coll(p,r)
	r=r or 0
	return p.x<l_bnd[1]+r or p.x>l_bnd[2]-r or p.z<l_bnd[3]+r or p.z>l_bnd[4]-r
end

function w_des_pane(pn)
    w_shk(1)
    sfx(28)
    for i=0,5 do
		w_prtc(vec((pn[1]+pn[2])*.5,(pn[4]+pn[5])*.5,pn[3])+rndd(),rndd(),60,6,rndr(.5,1),rndi(0,4))
    end
    del(panes,pn)
end

function pane_coll(p)
	for pn in all(panes) do
		if p.x>pn[1] and p.x<pn[2] and abs(p.z-pn[3])<.3 then
			w_des_pane(pn)
		end
	end
end

function w_sp_muzzle_flare(p)
	w_prtc(vec_cl(p),vec0(),40,7,.2,4)
end

function w_sp_b(p,d,id)
    add(bts,{p=vec_cl(p),d=vec_cl(d),id=id,gt=0})
end

function w_sp_prop(x,y,z,p)
	p=d_props[p]
	add(props,{
		p=vec(x,y,z),
		sx=p[2],
		sy=p[3],
		sw=p[4],
		sh=p[5],
		w=p[6],
		h=p[7]
	})
end

function w_prtc(p,v,s,c,ls,spr)
	if #prtcs<20 then
		add(prtcs,{
			p=vec_cl(p),
			v=vec_cl(v),
			s=s,
			c=c,
			l=ls,
			spr=spr
		})
	end
end

function w_txt(txt,d)
	r_cr(function()
		sfx(11)
		w_morph_in(.6,.05)
		w_blk()
		yd()
		for i=0,d,dlt do
			txt=tostr(txt)
			local s=3
			pr(txt,0,0,11)
			tw2=#txt*2
			tx,ty=64-tw2*s,64-3*s
			bsx,bex=tx-2,64+tw2*s-2
			rf(bsx,53,bex,71,13)
			for y=0,4 do
				for x=0,#txt*4-2 do
					if pget(x,y)==11 then
						rf(
							x*s+tx,
							y*s+ty,
							x*s+s-1+tx,
							y*s+s-1+ty,
							7
						)
					end
				end
			end
			rf(0,0,#txt*4,4,7)
			yd()
		end
	end)
end

function w_blk()
	rf(0,0,127,127,7)
end

function w_morph_in(s,v)
	r_cr(function()
		morph=s
		for i=s,1,v do
			morph=ease_in_out(i)
			yd()
		end
		morph=1
	end)
end

function w_shk(s)
	r_cr(function()
		if not shk then
			shk=t
			pa,ya=rnd(),rnd()
			for i=0,1,5*dlt do
				tr=s*(1-i)*.007
				p_ry=sin(i+pa)*tr
				p_rx=sin(i+ya)*tr
				yd()
			end
			p_ry,p_rx,shk=0,0,f
		end
	end)
end
p_max_v=7
p_pun_anm=expl("48,48,0,64,64,0,0,80,64,0",",")

function p_kill()
    if p_alv then
        p_alv=f
        l_crs={}
	    r_crs={}
        sfx(31)
        if is_endl then
            if scr>sv.scr then
                sv.scr=scr
                save_sv()
            end
            w_txt(scr,2)
        end
        l_cr(function()
            w_blk()
            tay=rnd()
            for i=0,1.6,dlt do
                t=time()*.2
                local a=.1*dlt
                p_rx=p_rx+sin(t)*a
                p_ry=p_ry+sin(t+tay)*a
                yd()
            end
            music(-1,1000)
            start_lvl(lvl)
        end)
    end
end

function p_action_a()
    if p_i then
        p_i.use(p_i)
    elseif p_n_e then
        --player punch
        if p_pun_anm_f==9 then p_pun_anm_f=1 end
        p_pun_anm_f=p_pun_anm_f+2
        p_lst_pun_t=time()
        sfx(9)
        w_shk(1)
        r_cr(function()
            circfill(rndr(20,107),rndr(20,107),rndr(10,60),7)
            cm(rndr(-10,10),rndr(-10,10))
            yd()
            cm()
        end)
        e_stun(p_n_e)
    end
end

function p_action_b()
    if p_i then
        p_throw()
    elseif p_n_i then
        --player grab
        p_i=p_n_i
        del(its,p_i)
        t_shift(.1)
        sfx(18)
        p_rld=f
    end
end

function p_throw()
    if p_i then
        sfx(16)
        w_shk(1)
        p_rld=f
        p_i.p=p_p+vec(0,1.2,0)+vec_f*.5
        p_i.v=vec_f*20
        p_i.dmg=t
        throw(p_i)
        p_i=nil
        t_shift(.2)
        p_rld=f
    end
end

function p_sht(g)
    if not p_rld then
        if g.ammo==0 then
            w_txt("no ammo",.5)
        else
            p_rld=t
            g.ammo=g.ammo-1
            g.t=0
            w_shk(.7)
            t_shift(.3)
            g.sht(vec(p_p.x,p_p.y+1.2,p_p.z)+vec_f*.5,vec_f,0)
            l_cr(function()
                wt(.05)
                p_gun_anm_t=1
                wt(.1)
                p_gun_anm_t=2
                wt(.1)
                p_gun_anm_t=0
            end)
        end
    end
end
lvl=1
l_bnd={}
l_flow=0

function start_lvl(l)
	reset()
	lvl=l
	l_load_data(lvl)
	extcmd("rec")
	l_cr(function() flow(l_data[3]) end)
end

function launch()
	start_lvl(min(sv.prg,6))

	-- fl=f
	-- r_cr(function()
	-- 	os=f
	-- 	szumy()
	-- 	l_cr(function()
	-- 		while not fl do
	-- 			ps_ch(0,"‹")
	-- 			ps_ch(1,"‘")
	-- 			ps_ch(2,"”")
	-- 			ps_ch(3,"ƒ")
	-- 			if btnp(4) then sfx(12) os_init() end
	-- 			for p in all(d_pass) do
	-- 				if p[1]==os_pass then
	-- 					sfx(23)
	-- 					wt(.2)
	-- 					fl=p[2]
	-- 					flow(fl)
	-- 					return
	-- 				end
	-- 			end
	-- 			if #os_pass==6 then
	-- 				wt(.1)
	-- 				sfx(25)
	-- 				os_pass=""
	-- 				r_cr(os_br)
	-- 				i=0
	-- 			end
	-- 			yd()
	-- 		end
	-- 	end)
	-- 	r_cr(os_br)
	-- 	i=0
	-- 	while not fl do
	-- 		os_draw_szumy(i)
	-- 		i=i+1
	-- 		rf(16,34,109,96,0)
	-- 		rf(15,39,110,91)
	-- 		rf(14,47,111,82)
	-- 		pr("password:",46,45,6)
	-- 		pr("Žback",50,80)
	-- 		ti=1
	-- 		for x=20,100,15 do
	-- 			rect(x,61,x+10,69)
	-- 			pr(sub(os_pass,ti,ti),x+2,63)
	-- 			ti=ti+1
	-- 		end
	-- 		yd()
	-- 	end
	-- 	sfx(12)
	-- 	os_view_in()
	-- end)
end

function ps_ch(b,c)
	if btnp(b) then
		os_pass=os_pass..c
		os_shk()
		sfx(14)
	end
end

function t_shift(t)
	l_cr(function()
		for i=0,t,dlt do
			move_time(1)
			yd()
		end
	end)
end

function wt(t)
	for i=0,t,dlt do yd() end
end

function e_cb()
	while #es>0 do yd() end
end

function lvl_fade_in()
	szumy()
	w_init()
	p_ctrl=t
	wt(.3)
end

function lf_des_pane(g)
	w_des_pane(panes[g])
end

function finish_lvl()
	e_cb()
	p_ctrl=f
	bts={}
	w_blk()
	t_shift(1)
	wt(.5)
	p_throw()
	wt(.5)
	wd=f
	shc=r_cr(function()
		while t do
			sfx(29)
			sh_spr(0,36,18,36,"f9 save replay")
			sh_spr(36,27,12,26,"— hand over the control")
		end
	end)
	while not btnp(5) do yd() end
	stop_r_cr(shc)
end

function sh_spr(sx,sw,x,w,t)
	w_blk()
	yd()
	for i=0,1,dlt*2 do
		s=1-i
		s=s*s*s*s+1
		s=s*3
		sp(sx,0,sw,8,ceil(64-x*s),ceil(64-4*s),w*s,8*s)
		pr(t,64-#t*2,120,13)
		yd()
	end
	for i=0,.5,dlt do
		s=3
		sp(sx,0,sw,8,64-x*s,64-4*s,w*s,8*s)
		yd()
	end
end

function pyramid_flow()
	p_ctrl=f
	inp_enb=f
	wt(2)
	os_br()
	for i=0,2,dlt do
		p_p.z=p_p.z-200*dlt
		yd()
	end
	wd=f
end

function boss()
	while not bts[1] or bts[1].p.z<7 do yd() end
	i_del(its[1])
end

function escp()
	while p_p.x>-23 do yd() end
	es={}
end

function endl()
	is_endl=t
	blk_txt_wt(sv.scr,1)
	scr=0
	on_e_kill=function()
		if p_alv then
			scr=scr+1
			w_txt(scr,.5)
		end
	end
	while t do
		if scr>49 then e_max=5
		elseif scr>24 then e_max=4
		elseif scr>14 then e_max=3
		elseif scr>2 then e_max=2
		else e_max=1 end
		if #es<e_max then
			keys={}
			for k,v in pairs(e_tps) do
				add(keys,k)
			end
			e_sp(rndr(-3,3),rndr(4,9),keys[ceil(rndr(1,#keys))])
		end
		wt(rnd(2))
	end
end

function szumy()
	r_cr(os_anim_szumy)
	wt(1.8)
end

function blk_txt_wt(s,d)
	d=d or .3
	w_txt(s,d)
	wt(d)
end

function l_load_data(l)
	l_data=d_lvls[l]
	d=expl_r(d_lvls_geo[l_data[2]],{":","|",","})
	sbx=d[1][1][6]
    l_bnd=d[1][1]
    walls=d[2]
    panes=d[3]
end

function credits()
	cls_enb=f
	music(2)
	wt(1)
	pr("the end",50,20,6)
	wt(2)
	pr("piotr kulla",42,36)
	wt(2)
	pr("wojciech dziedzic",30,44)
	wt(2)
	pr("mariusz tarkowski",30,52)
	wt(2)
	pr("superhot team",38,68)
	wt(2)
	pr("thx to all backers",28,84)
	wt(2)
	pr("press —",48,100, 5)
	while not btnp(5) do yd() end
	cls_enb=t
end
function e_sp(x,z,tp,y)
    y=y or 0
    e={
        p=vec(x,y,z),
        t=0,
        gt_a=0,
        gt_b=0,
        gt_c=0,
        stns=0,
        mov=f,
        ai=e_tps[tp],
        it=nil
    }
    e.ai.init(e)
    add(es,e)
    sfx(8)
end

function e_stun(e)
    if e.stns>1 then
        e_kill(e)
    else
        e.gt_b=0
        e.stn=t
        e.stns=e.stns+1
        sfx(17)
        e_throw(e)
        e.ai=e_tps.m
        e.ai.init(e)
    end
end

function e_unstun(e)
    e.stn=f
    e.stns=0
end

function e_kill(e)
    sfx(10)
    for i=0,5 do
		w_prtc(vec(e.p.x,rndr(.2,1.8),e.p.z),rndd()*1.5,rndr(30,40),max(8,9-i),rndr(1,2),rndi(0,4))
    end
    e_throw(e)
    on_e_kill()
    del(es,e)
end

function e_sht(e)
    d=nrm(p_p-e.p)
    d=d+rndd()*.01
    e.it.sht(vec(e.p.x,e.p.y+1.2,e.p.z),d,1)
end

function e_throw(e)
    if e.it then
        e.it.p=e.p+vec(0,1.2,0)
        e.it.v=nrm(p_p-e.p)*5+rndd()
        throw(e.it)
        e.it=nil
    end
end

function e_new_dst(e)
    e.dest=vec(
        rndr(p_p.x-4,p_p.x+4),
        0,
        rndr(p_p.z+2,p_p.z+6)
    )

    w_coll(e.dest,.5)
end

function e_go_to(e,p,v)
    p=vec_cl(p)
    d=(p-e.p)
    l=#d
    e.mov=l>.01
    if e.mov then
        e.p=e.p+d/l*7*v*g_dlt
    end
    return l
end

function e_give_it(e,i)
    e.it=i
    del(its,i)
end

function e_can_sht(e)
    x,y,z=prj_v(e.p)
    return x>0 and x<127 and z>.1 or e.p.z<p_p.z
end

e_tps={}
--camper pistol
e_tps.cp={
    spr=96,
    init=function(e)
        e_give_it(e,i_sp(0,0,2))
        e.gt_c=rnd(.5)
    end,
    upd=function(e)
        if not e_can_sht(e) then e.gt_c=0 end
        if e.gt_c>rndr(.9,1.1) then
            e_sht(e)
            e.gt_c=0
        end
    end
}
--camper shotgun
e_tps.cs={
    spr=112,
    init=function(e)
        e_give_it(e,i_sp(0,0,3))
        e.gt_c=rnd(.5)
    end,
    upd=e_tps.cp.upd
}
--brawler pistol
e_tps.bp={
    spr=96,
    init=function(e)
        e_tps.cp.init(e)
        e_new_dst(e)
    end,
    upd=function(e)
        if e_go_to(e,e.dest,.4)<.1 or not e_can_sht(e) then
            e_new_dst(e)
        end
        e_tps.cp.upd(e)
    end
}
--brawler shotgun
e_tps.bs={
    spr=112,
    init=function(e)
        e_tps.cs.init(e)
        e_new_dst(e)
    end,
    upd=e_tps.bp.upd
}
--melee
e_tps.m={
    spr=0,
    init=function(e)
        e.st="ch"
        e.gt_c=0
    end,
    upd=function(e)
        if e.stn then
            e.gt_c=0
            e.st="ch"
        elseif e.st=="ch" then
            e.ai.spr=0
            if p_alv and e_go_to(e,p_p+vec_f*.6,1)<.5 then
                e.punch_target=vec_cl(p_p)
                e.st="pnc"
                e.gt_c=0
            end
        elseif e.st=="pnc" then
            e.ai.spr=16+16*flr((e.gt_c*6))
            if e.gt_c>.5 then
                if coll(p_p,e.punch_target,.5) then p_kill() end
                e.ai.spr=64
                e.gt_c=0
                e.st="wt"
            end
        elseif e.gt_c>.2 then
            e.st="ch"
        end
    end
}

os_m_step=0

function os_init()
	reset()
	os=t
	os_list_opts(d_opts)
	os_view_in()
	sfx(14)
	music(0,1000)
end

function os_render()
	--options
	if os_list_enb then
		h=#os_opts*10
		y=20-os_scrl
		if h<60 then
			y=64-h*.5
		else
			sy=y+os_sel_opt*10
			if sy>110 then
				os_scrl=os_scrl+10
			elseif sy<30 then
				os_scrl=os_scrl-10
			end
			y=20-os_scrl
		end
		for i,o in pairs(os_opts) do
			c=6
			if o[4]>sv.prg then c=5 end
			if i==os_sel_opt then
				rf(30,y-2,97,y+6,8)
				c=7
			end
			pr(o[1],64-#o[1]*2,y,c)
			y=y+10
		end
	end
	--frame
	rf(0,0,127,16,0)
	rf(0,106,127,128)
	for y=4,123 do
		w=ceil(sin(y/256+.5)*4)
		xa,xb=7-w,120+w
		pset(7-w,y,6)
		pset(120+w,y)
		if y==4 then
			for x=xa,xb do
				h=ceil(sin(x/256+.5)*3)
				pset(x,y-h)
				pset(x,y+118+h)
			end
		end
	end
	rf(10,0,32,6,0)
	pr("PICos",12,0,6)
end

function os_list_opts(opts)
	os_opts={}
	for o in all(opts) do
		if not o[3] or sv.prg>=o[3] then
			add(os_opts,o)
		end
	end
	os_sel_opt=1
	os_scrl=0
end

function os_list_lvls()
	los={}
	add(los,{"/.. go back",function() os_init() end,0,0})
	for i,l in pairs(d_lvls) do
		add(los,{
			l[1],
			function() start_lvl(i) end,
			0,
			i
		})
	end
	os_list_opts(los)
end

function os_view_in()
	r_cr(function()
		for di=0,.1,dlt do
			for i=0,di*1000 do
				local x,y=rnd(127),rnd(127)
				spr(37,x-x%8,y-y%8)
			end
			yd()
		end
		os_shk()
	end)
end

function os_shk()
	r_cr(function()
		cm(1,1)
		for i=0,1.6,dlt do
			local y=rnd(127)
			ln(0,y,127,y,0)
			if rnd()<.1 then
				yd()
				cm()
			end
		end
		yd()
		cm()
	end)
end

function os_intro()
	-- os_init() yd() --disable intro for development
	cls_enb=f
	pr("controls",46,10,7)
	pr("”     move forward\nƒ     move backward\n‹     strafe left\n‘     strafe right\n\nŽ (z) grab / throw\n— (x) attack\n\nf6     save screenshot\nf9     save replay",20,28)
	pr("press Ž and — to proceed",15,100,8)
	while not (btn(4) and btn(5)) do yd() end
	cls_enb=t
	sfx(13)
	for i=1,0,-dlt*.5 do
		yd()
		sp(87,0,20,9,25,15+i*30,80,36)
		pr("os of the future (tm)",25,80+i*30,6)
	end
	cls_enb=f
	wt(2)
	os_init()
end

function os_anim_szumy()
	wd=f
	music(-1,100)
	sfx(24,0)
	for i=0,1.6,dlt do
		os_draw_szumy(flr(i*50))
		yd()
	end
	sfx(-1,0)
end

function os_draw_szumy(i)
	for y=10,118 do
		local v=y+i*2
		local w=50+sin(y/256+.5)*5
		w=min(w*i/10,w)
		if(v%5==0 or v%3==0) then
			ln(64-w,y,64+w,y,7)
		end
	end
end

function os_download()
	os_init()
	inp_enb=f
	r_cr(function()
		os_list_enb=f
		p=0
		while p<1 do
			pr("downloading",42,40,6)
			if rnd()<.2 then p=p+rnd(2)*dlt sfx(15) end
			rect(30,60,97,70,6)
			rf(32,62,32+p*63,68,6)
			yd()
		end
		sfx(22)
		os_init()
		l_cr(function()
			wt(1)
			sfx(23)
			prg_story(1)
			os_init()
			os_sel_opt=2
		end)
	end)
end

function os_m(m,wtk)
	wd=f
	os_br()
	music(1,100)
	mcr=r_cr(function()
		while t do
			pr(m,64-#m*2,61,8)
    		rect(59-#m*2,56,69+#m*2,70,8)
			if wtk then
				pr("press —",50,110,13)
			end
			yd()
		end
	end)
	if wtk then
		while not btnp(5) do yd() end
	else
		wt(3)
	end
	stop_r_cr(mcr)
	music(-1,100)
end

function os_br()
	sfx(25)
	pal(7,8)
	pal(6,8)
	os_view_in()
	wt(.1)
	pal()
end
function s_init()
    reset()
    scl=t
    r_cr(function()
        os_view_in()
        wt(.5)
        for i=0,2,dlt do
            pr("hello, ‰sp33d",37,50,7)
            pr("LOADING "..(ceil(i*10)*5).."%",42,80,6)
			yd()
        end
        wt(1)
        s_scrl=0
        s_load_data()
	end)
end

function s_render()
    cls(1)
    if s_posts[1] then

        --posts

        y=10+s_scrl
        for p in all(s_posts) do
            h=7+#p[2]*8
            a=p[1][1]
            if p[3] then h=h+20 end
            if a=="super.exe" then pal(6,0) pal(7,0) pal(5,8) pal(1,8) end
            y=y+10
            rf(2,y,125,y+10,6)
            pr("‰"..a,4,y+3,1)
            y=y+10
            rf(2,y,125,y+h,7)
            for lni,ln in pairs(p[2]) do
                pr(ln,4,y+lni*8-3,5)
            end
            y=y+h
            if p[3] then
                c=6
                if abs(y-60)<50 then
                    s_dwnld=t
                    c=12
                end
                rf(15,y-17,112,y-5,c)
                pr("download",48,y-13,7)
            end
            pal()
        end
        
        pr("NO MORE NEW CHIRPS",25,y+10,6)
        pr("aRE YOU LOOKING FOR SOMETHING?",2,y+10000,8)

        --top bar

        rf(0,0,127,10,6)
        rf(119,2,125,8,14)
        sp(0,57,28,7,2,2,28,7)

        --bottom bar

        rf(0,117,127,127,6)
        s="ƒ”scroll Žexit"
        if s_dwnld then
            s=s.." —download"
        end
        pr(s ,2,120,5)
    end
end

function s_load_data()
    for i=#d_posts,1,-1 do
        if d_posts[i][2]<=sv.prg then
            s_posts=expl_r(d_posts[i][1],{"|",";","/"})
            return
        end
    end
end
w_blk_cross=f

function w_render()
	--skybox

	cls(7)
	if p_alv then
		if sbx==1 then
			rf(20,20,50,127,6)
			rf(80,50,110,127)
		elseif sbx==2 then
			cls(6)
		end
	end
	
	--floor
	cx,cz=p_p.x,p_p.z
	sx,ex,sz,ez=cx-cx%1-10,cx-cx%1+10,cz-cz%1,cz-cz%1+16
	hsx,hsy=prj(0,0,l_bnd[5])
	hex,hey=prj(ex,0,min(ez,l_bnd[5]))
	rf(0,hsy,127,hey,6)
	rf(0,hey,127,127,7)
	for x=sx,ex do
		if x>l_bnd[1] and x<l_bnd[2] then
			ax,ay=prj(x,0,sz)
			bx,by=prj(x,0,min(ez,l_bnd[5]))
			ln(ax,ay,bx,by,6)
		end
	end
	for z=sz,ez do
		if z<=l_bnd[5] then
			ax,ay=prj(max(sx,l_bnd[1]),0,z)
			bx,by=prj(min(ex,l_bnd[2]),0,z)
			ln(ax,ay,bx,by)
		end
	end

	--walls

	for w in all(walls) do
		w_r_wall(w[1],w[2],w[3],w[4],w[5],w[6])
	end

	--panes

	for pn in all(panes) do
		ax,ay,az=prj(pn[1],pn[5],pn[3])
		bx,by=prj(pn[2],pn[4],pn[3])
		if az>.1 and (ax>0 or bx>0 or ax<127 or bx<127) then
			sp(
				0,64,
				32,32,
				ax,ay,
				bx-ax+1,by-ay+2
			)
			ln(ax,ay,ax,by,13)
			ln(bx,ay,bx,by)
			ln(ax,ay,bx,ay)
			ln(ax,by,bx,by)
		end
	end

	--props

	for p in all(props) do
		x,y,z=prj_v(p.p)
		if z>.1 then
			w,h=p.w/z,p.h/z
			sp(
				p.sx,p.sy,
				p.sw,p.sh,
				x-w*.5,y-h,
				w,ceil(h))
		end
	end

	--enemies

	for e in all(es) do
		x,y,z=prj_v(e.p+vec(0,1,0))
		if z>.1 then
			w_palt()
			s=64/z
			hs=s*.5
			if e.t<.2 then
				pal(8,7)
			elseif e.t<.5 then
				pal(8,9)
			end
			top_spr=e.ai.spr
			if e.stn then top_spr=80 end
			sp(top_spr,96,16,16,x-hs,y-s,s,ceil(s))
			bot_spr=0
			if e.mov then
				bot_spr=16+16*flr((e.gt_a*5)%2)
			end
			sp(bot_spr,112,16,16,x-hs,y,s,ceil(s))
			pal()
		end
	end

	--particles

	for p in all(prtcs) do
		x,y,z=prj_v(p.p)
		if z>.1 then
			s=p.s/z
			pal(7,p.c)
			sp(
				p.spr*8,16,
				8,8,
				x-s*.5,y-s*.5,s,s)
		end
	end
	pal()

	w_palt()

	--items

	for i in all(its) do
		x,y,z=prj_v(i.p)
		if z>.1 then
			sx=i[4]/z*i[6]
			sy=i[5]/z*i[6]
			sp(
				i[2],i[3],
				i[4],i[5],
				x-sx*.5,y-sy*.5,sx,ceil(sy)
			)
		end
	end

	--bullets

	for b in all(bts) do
		px,py,pz=prj_v(b.p)
		if pz>.1 then
			s=max(8/pz,2)
			hs=s*.5
			e=b.p-b.d*3
			ex,ey,ez=prj_v(e)
			if ez>0 then
				h=min(s,1)
				ln(ex,ey,px,py,8)
				ln(ex,ey,px,py-h)
				ln(ex,ey,px,py+h)
				ln(ex,ey,px-h,py)
				ln(ex,ey,px+h,py)
			end
			sp(115,17,13,13,px-hs,py-hs,s,ceil(s))
		end
	end

	if time()-p_lst_pun_t>.5 then p_pun_anm_f=1 end

	if p_alv then
		--player

		if p_i then
			x=p_i[7]
			if p_i.is_gun then
				x=x+14*p_gun_anm_t
			end
			sp(
				x,p_i[8],
				p_i[9],p_i[10],
				p_i[11],128-p_i[10]*2,
				p_i[9]*p_i[6],p_i[10]*p_i[6]
			)
		else
			if p_pun_anm[p_pun_anm_f]~=0 then
				sp(p_pun_anm[p_pun_anm_f],112,16,16,0,72,64,64)
			end
			if p_pun_anm[p_pun_anm_f+1]~=0 then
				sp(p_pun_anm[p_pun_anm_f+1],112,16,16,64,64,64,64,t)
			end
		end
		
		palt()

		--ui
	
		if p_n_i then
			s="Ž grab "..p_n_i[1]
			rf(63-#s*2,115,67+#s*2,121,13)
			pr(s,64-#s*2,116,7)
		end

		if w_blk_cross then
			circfill(64,64,6,13)
		end

		--crosshair
		
		if p_i then
			if p_i.is_gun then
				spr(17+min(flr(p_i.t/p_i.rel_t*5),5),60,60)
			else
				spr(22,60,60)
			end
		elseif p_n_e then
			spr(16,60,60)
		end
	end
	w_blk_cross=f
	palt()
end

function w_r_wall(wax,waz,wbx,wbz,wy,wh)
	ax,ay,az=prj(wax,wy,waz)
	if ay<0 then return end
	bx,by=prj(wbx,wy,wbz)
	if ax<0 and bx<0 or ax>127 and bx>127 then return end
	cx,cy=prj(wax,wy+wh,waz)
	dx,dy=prj(wbx,wy+wh,wbz)
	if waz>wbz then
		pal(6,13)
		pal(7,6)
	end
	lx,ah,bh=bx-ax,by-ay,dy-cy
	for x=ax,bx do
		if x>0 and x<128 then
			i=(x-ax)/lx
			ln(x,ay+ah*i,x,cy+bh*i,7)
		end
	end
	ln(ax,ay,bx,by,6)
	ln(ax,ay+(cy-ay)*.6,bx,by+(dy-by)*.6)
	ln(cx,cy,dx,dy)
	ln(ax,ay,cx,cy)
	ln(bx,by,dx,dy)
	pal()
end

function w_palt()
	palt(7,t)
	palt(0,f)
end
function i_sp(x,z,it,y)
    y=y or 0
    i=clone(d_its[it])
    i[6]=i[6] or 2
    i[7]=i[7] or i[2]
    i[8]=i[8] or i[3]
    i[9]=i[9] or i[4]
    i[10]=i[10] or i[5]
    i[11]=i[11] or 70
    i.p=vec(x,y,z)
    i.v=vec0()
    i.thr=f
    i.dmg=f
    i.t=0
    i.use=p_throw

    if it==2 or it==3 then
        i.use=p_sht
        i.is_gun=t
        i.rel_t=1
        i.t=100
        i.ammo=rndi(3,5)
        i.sht=function(p,d,id)
            w_sp_b(p,d,id)
            w_sp_muzzle_flare(p)
            sfx(30)
        end
    end

    if it==3 then
        i.ammo=2
        i.rel_t=1.5
        i.sht=function(p,d,id)
            w_sp_b(p,d,id)
            w_sp_muzzle_flare(p)
            for i=0,rndr(2,4) do
                d=nrm(d+rndd()*.15)
                w_sp_b(p,d,id)
            end
            sfx(19)
        end
    end

    add(its,i)

    return i
end

function throw(i)
    i.thr=t
    add(its,i)
end

function i_del(i)
    sfx(20)
    for pi=0,5 do
		w_prtc(i.p,rndd(),20,0,rndr(.5,1),rndi(0,4))
    end
    del(its,i)
end
flfs={
    fl=flow,
    wd=lvl_fade_in,
    w=wt,
    t=blk_txt_wt,
    cb=e_cb,
    i=i_sp,
    e=e_sp,
    des_pn=lf_des_pane,
    fin=finish_lvl,
    lvl=start_lvl,
    endl=endl,
    prg=prg_story,
    br=os_br,
    m=os_m,
    os=os_init,
    p=w_sp_prop,
    prmd=pyramid_flow,
    boss=boss,
    crd=credits,
    esc=escp
}

function flow(f)
    dat=expl_r(f,{"|",":"})
    for fd in all(dat) do
        for i,arg in pairs(fd) do
            fd[i]=prs(arg)
        end
        if #fd==5 then
            flfs[fd[1]](fd[2],fd[3],fd[4],fd[5])
        elseif #fd==4 then
            flfs[fd[1]](fd[2],fd[3],fd[4])
        elseif #fd==3 then
            flfs[fd[1]](fd[2],fd[3])
        elseif #fd==2 then
            flfs[fd[1]](fd[2])
        else
            flfs[fd[1]]()
        end
    end
end
d_pass=expl_r("”””ƒ”ƒ*prg:2|lvl:1$‹‹‹‹‹”*prg:10|m:we know:1|br|w:1|lvl:5$‘‹‹”””*prg:16|m:again?:1|m:why are you here?:1|m:you are not enough:1|br|w:1|lvl:8$ƒƒ‹ƒ‘‹*prg:24|m:your mind is weak|m:but here|m:indulge|br|w:1|lvl:12$”‹”ƒ‘‘*prg:32|m:give up|m:you won:1|m:it's pointless|m:you are not enough:1|m:you are not enough:1|m:you are not enough:1|br|w:1|lvl:16",{"$","*"})

d_its=expl_r("bottle,107,0,8,16|pistol,113,49,15,12,2,32,83,14,13,51|shotgun,0,24,48,11,2,32,67,14,16,76|pyramid,96,20,19,10,20|tv,96,112,16,16,3|flowers,117,30,10,19,3|flask,67,9,13,13|floppy,116,71,12,12|teapot,116,61,12,10,3|callum,116,0,12,16,3|mug,56,8,8,8,2.5|skull,87,21,9,11,3",{"|",","})

d_props=expl_r("serv,74,66,13,16,100,128|ac,91,9,16,11,128,80|monitor,80,9,11,12,44,48|ceil_lamp,92,10,1,1,128,8|door,74,81,11,15,100,128|cctv,48,16,17,13,68,52|heli,0,35,47,20,564,240|wnd_a,48,29,23,18,92,72|wnd_b,48,47,23,18,92,72|rock,88,32,24,63,720,1890",{"|",","})

d_lvls_geo={
    --intro
    "-2,5,-1,10,10,0:5,20,5,10,0,10|5,10,10,10,0,10|-2,10,5,10,0,2|-2,-1,-2,10,0,2|5,10,5,-1,0,2",
    --cage_fight
    "-3,3,-3,14,14,2:-3,14,3,14,0,2|-3,-3,-3,14,0,2|3,14,3,-3,0,2:-3,3,5,0,2",
    --corridor
    "-2,2,-1,16,20,2:-2,20,2,20,0,2|-2,-1,-2,20,0,2|2,20,2,-1,0,2",
    --blocks
    "-2,2,-1,34,40,1:-5,40,8,40,0,4|-2,30,-2,36,0,10|5,35,5,27,0,15|2,36,2,24,0,2|-8,30,-2,30,0,10|5,27,15,27,0,15|-2,16,-2,30,0,4|2,24,2,20,0,3|2,20,2,13,0,5|-10,16,-2,16,0,4|2,13,6,13,0,5|-2,7,-2,16,0,3|2,13,2,0,0,2|-2,0,-2,7,0,10",
    --next_round
    "-5,5,-1,9,10,1:-5,1,-5,10,0,6|5,10,5,1,0,6|-5,10,5,10,0,2.5|-5,10,5,10,5,1:-5,-2,10,2.5,5|-2,2,10,2.5,5|2,5,10,2.5,5",
    --roof
    "-5,5,-1,10,17,1:-3,12,-3,16,0,8|-1,16,-1,12,0,5|3,16,3,12,0,5|1,12,1,15,0,5|-7,12,-3,12,0,8|-1,12,1,12,0,5|3,12,9,12,0,5|-5,10,5,10,0,.5|-5,0,-5,10,0,2.5|5,10,5,0,0,2.5:-5,-3,10,.5,2.5|-3,-1,10,.5,2.5|-1,1,10,.5,2.5|1,3,10,.5,2.5|3,5,10,.5,2.5"
}

d_lvls={
    --1. stage
    {
        "intro",
        1,
        "p:5:1:9:6|i:0:3:2|wd|t:you|t:move:.6|t:time|t:moves|e:0:9:cp|e:3:9:cp|fin|prg:2|lvl:2"
    },
    {
        "cage_fight",
        2,
        "p:2:1:13:2|wd|t:fight|e:0:3:m|cb|t:just|t:a|t:warm-up|e:-2:6:m|e:0:13:m|e:2:10:m|w:.5|des_pn:1|fin|prg:3|lvl:3",
    },
    {
        "corridor",
        3,
        "p:-1:0:18:1|p:1:0:16:3|p:0:2:12:4|p:0:2:10:4|p:0:2:8:4|p:0:2:6:4|p:0:2:4:4|wd|e:0:14:cp|fin|prg:4|lvl:4"
    },
    {
        "blocks",
        4,
        "p:2:3:39:2|p:1:0:35:1|p:-1:0:35:1|p:2.5:3:12.6:2|i:-1:15:1|i:1.2:10:1|i:1:7:1|wd|e:1:3:bp|cb|e:-1:7:m|cb|e:1:11:m|cb|e:-1:13:bp|fin|prg:5|lvl:5"
    },
    {
        "next_round",
        5,
        "i:-2:6.5:7|i:-2.5:7:7|i:3:4:2|p:-2:0:9:1|p:0:0:9.5:5|p:2:0:9:1|wd|e:0:8:m|w:1|e:3:8:m|cb|w:.5|t:next|t:round|e:-3:8:cs|e:3:8:cs|w:.5|e:0:8:bp|cb|w:1|fin|prg:6|w:1|m:congrats|br|w:4|crd|w:1|m:you are free|m:to play forever|br|w:1|os"
    },
    {
        "endless",
        6,
        "i:3:6:3|i:-2:4:2|i:3:9:3|i:-1:8:2|wd|t:record|t:to|t:beat|w:.3|endl"
    }
}

d_posts={
    {
        "ony_anth;this game is best|ony_anth;i just kill red dudes|marxus_001;how to play? ‰ony_anth|johhnnny;this game sooo good!|ony_anth;here is the game, just play;d",
        0
    }
    -- “ˆ“
}

d_opts={
    {
        "picohot.exe",
        launch,
        1,
        1
    },
    {
        "endless",
        function() start_lvl(6) end,
        6,
        6
    },
    {
        "levels",
        os_list_lvls,
        2,
        2
    },
    {
        "chirp.exe",
        s_init,
        0,
        0
    },
    {
        "quit",
        quit,
        0,
        0
    }
}
__gfx__
0101677107100717777107777617776101001017600761067776017777771010000000000066666666666600000000000006600066077000177e700700117017
1016000717101717000717100007000610100017610760677677616677661010000006666666676776776760000000000060060600677101177e701000000107
1017000007001707000717000007000710101017600761770017710177100000000666666666666666666660000060000060060600077700777e700000000007
0001771007101707000617777117000710001017666760771017710177101000006666666666666666666660660000066060060066077700777e777000000777
0000007107101717776107100007777101000017777761770007710077100000066660000067777777777766006060600060060000670000117e777001100777
0000000717101717100007100007000700001017600760771017700077101000666600000067777777777766006060600060060600610001111e777000000777
1016000716100617100007000007000710101017610761677677610177101000666000000006777777777766660060066006600066001010011e777710017777
0101677101676107101017777617000671011017610761167776100177101006660000000000666666666606000000000000000000000100010e777001110777
0d6d6d600d6000000d00000000000d0000000d00000d6000000d000000010077eeeeeeeeeeeeeeeeeeeeeee6000000000000000000000100010e700010110007
6d6d6d6000d000d000d000d0d600d600d000d00000060000000d000010100017eee777700011777706666666660666666666666666601100101e100100010001
6ddddddd00000d6000000d000d0000000d000000600000000000000011000101eee777710111777767777777776677777777777777611010101e110000001011
66d6666d00000000000000000000000000000000d60006d0dd000dd011101170eee777770007777767ddddddd76677766677777777611001101e777000000777
666ddd6d6d0000000d00000000000d0000000d00000000600000000000010070eee7777700077777676666666766776d7767777777610001110e777700017777
6666666dd000d000d000d00006d006d000d000d000060000000d000000111010eee777770017777767ddddddd766667676d6666666610001110e777110100777
066666d000006d0000000d000d0000000d000000006d0000000d000001011007eee777770117777767666666676676776776777777601110010e770017700177
0000000000000000000000000000000000000000000000000000000010001077eee777771117777767ddddddd76676d67676777777611100001e770007701177
0000000000000000000000000000000077070007606060606666666666666600000777711000777767666666676677677d677777776eeeeeeeeeeeeeeeeeeeee
00070000007700000000000007000000700777000606060667777777777776000007770010001777677777777766777666777777776eeeeeeee7777100017777
000770000007770000070000077000000077777060606060677777dd777676000007700001011077066666666606777777777777776eeeeeeee7771000001777
00077700000777770007700077770000777777770606060667777d7dd77776000007000111111007000066600006666666666666666eeeeeeee77d1000001177
00077770000077770007770077777000077777706060606067777dddd7777600000001111000110000666666600eeeee77777777717777777777ddd100011117
000777000000777000077000000777000077770006060606677777dd777776000001111100000010eeeeeee7700111777777777700177777777dddd100011101
0007000000000700000700000000000007077077606060600666666666666000000eeee0000d760d7660000710100117777777700011777777711ddd10110000
0000000000000000000000000000000070007007060606060000067760000000000eeee6666d76ddd77666600100000177777710000117777771111dd1000000
0177777777777777777777777777777777777777777777770000066666600000000eeee7777d76766dd777701110111077777001000111777771111110000000
1000011000101000111011000000111111777777777777770000067777766666600eeeedddddd76dddddddd10700170177770000100111077777111111000001
0000000000000011110001100011001111007777777777770000066677777777600eeee00000d766000000000700070077700000010010117777111100100017
7777777777777771100000111000000001001111117777770000000066677777600eeee6666ddd77666666600001000077000010000011111777711000010177
7777777777777777100011000000000000110011110000100000000000066677600eeee7777766dd777777770001001770010001000011101177771000001777
77777777777777777777777777717700710100001100110066666666666666666666666dddddddddddddddd00000000000001000000001011117777100077777
777777777777777777777777777710077700100001010000677777777777777777777760000000000000000110101011eeeeeeeeeeeeeeeeeeeee77771077777
777777777777777777777777777777777770100110100000676666666666666666666766666666666666666770001077eeeeeeeeeeeeeeeeeeeee77770107777
777777777777777777777777777777777777777000111000676000000000000000006767777777777777777e000000000000006000000000eeeee77777017777
77777777777777777777777777777777777777777711110067666666666666666666676dddddddddddddddde000000000000006000000000eeeee77107077777
777777777777777777777777777777777777777777777110676000000000000000006760000000000066666e000000000000006000000000eeeee77017077107
00000000000000066660000000000000000000000000000e676666666666666666666760000000006677777e000000000000006000000000eeeee77107077017
66667766667676666666676666777666660000000000000e6760000000000000000067600000000677ddddde000000000000066600000000eeeee07717077107
00000000000000006600000000000000000000000000666e67666666666666666666676000000067dd00000e000000000000066600000000eeeee70717071177
00000000000000066760000000000000000000000006760e6760000000000000000067600000667d0066666e000000000000667760000000eeeee70717071177
00000000000000066666000000000000000000000006600e676666666666666666666766666677d06676777e000000000000667760000000eeeee77011071777
00000000666666677776600000000000000000000067600e6760000000000000000067677677dd0677ddddde666000000000667760000000eeeee77001071777
00000066776676666666676666666666666666666677600e67666666666666666666676ddddd0067dd00000e676000000000667760000000eeeee00001071007
00000667776777760000067777777766666666666666660e6760000000000000000067600000667d0066666e676000000006666666000000eeeee77001010770
00006666666777760000066666666600000000000006666e676000000000000000006766666677d06677777e676000000066666666600000eeeee70000000177
00066777776777760000067777776000000000000000666e6766666666666666666667677777dd0677ddddde676000000066777777600000eeeee71100011177
00067777776666660000067777776000000000000000000e67777777777777777777776ddddd0067dd00000e676000000066666666600000eeeee77110111777
00667777777777600000677777660000000000000000000e6666666666666666666666600000d67d0000000e676666666666777777600000eeeee77001011777
00667777767777600000677766000000000000000000000e666666666666666666666666666677d00000000e676676767666776767600000eeeee77701007777
00666777767777600000676600000000000000000000000e6777777777777777777777677777dd000000000e676767676766777777600000eeeee77711107777
00066677766666600000666000000000000000000000000e67666666666666666666676ddddd00000000000e676666666666777777600000e177777777777777
000006666ddddd666666006000000000000000000000000e676000000000000000006766667600000000000e676000000066777777600000e000110011100177
00000000000600000000006000000000000000000000000e676666666666666666666767777766000000000e676000000066777777600000e000000000000017
00000000006000000000000600000000000000000000000e67600000000000000000676ddddd77600000000e676000000066777777600000e010000000000117
00000600006000000000000600000000000000000000000e6766666666666666666667600000dd760000000e676000000066666666600000e110000000001177
00000066666666666666666666660000000000000000000e676000000000000000006766666600d76600000e676000000006666666000000e777770770000077
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6760000000000000000067677777660d7766666e676000000006666666000000e777771000110007
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee67666666666666666666676ddddd77d0dd77777e676000000006666666000000e777777777100007
666aaa66666666666666666666666eeeeeeeeeeeeeeeeeee6760000000000000000067600000dd7600ddddde676000000006677776000000e777777777001117
666a5a96667766666666666666666eeeeeeeeeeeeeeeeeee676000000000000000006766666600d76600000e676000000006677776000000e777777777000111
66aaaa66676667676777677767776eeeeeeeeeeeeeeeeeee6766666666660000000067676677660d7767666e676000000066666666600000e777777777710011
66aaaa66676667676676676767676eeeeeeeeeeeeeeeeeee67600000000666666666676ddddd7760dd77777e676000000066777777600000e777777777710001
6aaaaa66676667776676677667776eeeeeeeeeeeeeeeeeee6760000000000000000067600000dd7600ddddde676000000066666666600000eeee777770001177
aaaaa666667767676777676767666eeeeeeeeeeeeeeeeeee676666666666666666666760000000d76600000e676000000066777777600000eeee777707777717
66969666666666666666666666666eeeeeeeeeeeeeeeeeee6777777777777777777777600000000d7766666e676000660066777777600660eeee777707777717
00000000000000000000000000000000eeeeeeeeeeeeeeee66666666666666666666666000000000dd77767e676006676066766667606776eeee177717707707
00000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000ddddde676006666066777777606666eeee017770011177
00000000000000000000070000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6666666666666e666006676066766667606776eeee707711100017
000000077000077000007700000000007777777777777777777777777777777777777777776677777777766e676006666066777777606666eeee707011000100
000000770000777000077000000000007777777777777777777777777777777777777777776776677766776e676006676066777777606776eeee710000000100
000007700007770000770000000000007770777777777777777077777777777777777777776767767677676e676006676666777777666776eeee771011001010
000077000077700007700000000000007110117777777777711011777777777777770777776767767677676e676006676066777777606776eeee777011110001
000770000777000077000000000000000110011777777777011001177777777777110117776776677766776e676006676066777777606776eeee007111110117
007700000000000770000000000000000011011777777777001101177777777770110017776777777777776e676006676066777777606776eeee000111010011
077000000000007700000000000000007011001177777777701100177777777770010011776666666666666e676006666066777777606666eeee000111010001
070000000770000000000000000000007001100177777777700100117777777777011011776777777777776e676006676066777777606776eeee000111110000
000000007770000000000000000000007700110117777777770110117777777777011001776767676777776e676006676066777777606776eeee100000000000
000000077700000000000000000000007770110017777777770110011777777777001001176777777766776e666006676066777777606776eeee101101111100
000000777000000000000000000000007770011011777777770011011777777777701101176767677677676e676006676066777777606776eeee101001111001
000007770000000000000000000007007777011001177777777011001777777777701101176767677677676e676006676066777777606776eeee100000110100
000007700000000000000000000077007777001101177777777001001177777777700100176777777766776e676006676066777777606776eeee001000101100
000077000000000000000000000777007777700100117777777001101177777777700100116677777777766e676006666066666666606666eeee000110001101
000770000000000000000000000770007777700110117777777700100117777777770110116666666666666e676006676666777777666776eeee000011100101
007700000000000000000000000700007777770010011777777700100117777777770010016ddddddddd6eee676006676666777777666776eeee000101111000
07700000000000000000000077000000777777777777777777777777777777777d07777777677777777d6eee666006676066777777606776eeee001100111100
000000000000000000000007770000007777777777777777777d0777777777770100777777677777777d6eee676006676066777777606776eeee000000000000
00000000000000000000007770000000777777777777777777010077777777710100077777677777777d6eee6760066660666666666066666666666666666666
00000000000000000000077700007000777777777777777771010007777777710000177777677777777d6eee6760066760667777776067767777777777777777
0000000000000000000077700007700077777d077777777771000007777777700100177777677777777d6eee666006676066777777606776dddddddddddddddd
00000000000000000007770000770000777771077777777770000007777777710000177777677777777d6eee6760066660666666666066660000000000000000
00000000000000000077700007700000777101000777777700100010777777010100107777677777777d6eee6760066760667777776067766666666666666666
00000000000000000777000077000000771000000177777701000001777777010100017777677777777d6eee6660066660666666666066667777777777777777
00000000000000007770000070000000771010010077777710100100777777100100007777677777777d6eee666006676066777777606776dddddddddddddddd
00000000000000007700000000000000771111110077777710111100777777100000007777677777777d6eee6660066660666666666066660000000000000000
00000000000000000000000000000000771100001177777701000010777777001001007777677777777d6eee6660066666666666666666666666666666666666
00000000000000000000000000000000771101100177777711011001777777010000107777677777777d6eee6660066660666666666066667777777777777777
00000000000000000000000000000000771000100177777710001001777777110110017777677777777d6eee666000660006660666000660dddddddddddddddd
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777777777777777777777777777778977788777777777788a777777777777778a877777
7777777789777777777777777897777777777777789777777777777778977777777777778977777777777788a778877777777778897777777777777789a77777
77777777887777777777777778877777777777777887777777777777788777777777777788777777777777889777877777777778887777777777777788977777
77777777887777777777777778877777777777777887777777777777788777777777777782889977722777828777287777777772897777777777777728877777
777777772277777777777777722777777777777772277897777777777227789777777777222289a7722777722887287777770072277777777777777722777777
777777788877777777777772288878977777772222827887777777222888288777777772828889a7772777228828287777770188888777777777778888877777
77777788882788777777772222827887777722892882228777777822228227777777772282228997772272228822887777778828889277777777778888897777
77777828882788777777782892822287777788882882287777777889228777777777778222888987777222728977777777778028992277777777788288287777
77778222887228777777788882872877777777722897777777777788289777777777782222228877777227728977777777777228892227777777782228287777
77778889287289777777777228977777777777722897777777777772289777777777787228977777777777788977777777777778887287777777782222110777
77777788227787777777777228977777777777722887777777777772288777777777287228977777777777788877777777777778887287777777788888001777
77777772287777777777777288877777777777728887777777777772888777777777887288877777777777788877777777777778887287777777772222207777
77777772827777777777777288777777777777728877777777777772887777777777777288777777777777728877777777777778897887777777777288777777
77777772827777777777777288777777777777728877777777777772887777777777777288777777777777728877777777777772887777777777777288777777
77777772887777777777778898777777777777228877777777777777777777777777777777777777777777770101017770000000000000170d760d760d760d76
77777772887777777777778228777777777777222897777777777777777777777777777770000077777777700101010710111111111111000d760d760d760d76
77777772287777777777722228777777777777227287777777777777777777777777777700000017777777701111110701101000111001100d760d660d760d76
77777772287777777777722228777777777777827297777777777777777777777777777000100117777777701000100701001000011100100d660d760d760d76
77777778287777777777782728777777777777827727777777777777777777777777777001111007777777701011001701000100101111100d660d760d760d76
77777778227777777777782778777777777777877287777777777777777777777777710000001017777777700000017701111101000100100d760d760d760d76
77777778287777777777787772877777777778977297777777777777777777777777700000101107777777700001117701000010000100100d760d760d760d76
7777778228977777777778777287777777777887727777777777000777777777777710000010101777777777101117770100001000010010666666666d760d76
7777778228877777777779277897777777777287777777777770000007777777777110100001117777777777110077770100011100101010667777776d760d76
7777777828777777777777227887777777777287777777777770011000777777771001100777777777777777110077770100101110100110666666666d760d76
7777777828777777777777772277777777777787777777777700010011777777770001107777777777777777001077770111000111100110dddddddd6d760d76
77777778287777777777777772777777777777877777777777001111001777777000010777777777777777770010777710111111111111000d760d760d760d76
77777778287777777777777772777777777777877777777770000010011777771000017777777777777777700011777711000000000000100d760d760d760d76
7777777828777777777766ddd28677777776d2866667777770000000107777770111177777777777777777700101777710010010100110000d760d760d760d76
77776d882886677777766666d8866777766dd8866666777700000011117777770011177777777777777777701101777700101000000110000d660d760d760d76
77777666666677777777777666667777777666666777777700000111177777770001777777777777777777701001777770010001110000070d660d760d760d76
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
010200000045100451004510045100451004510045100451004410044100441004310043100431004310042100421004210042100421004110041100411004110041100411004110041100411004110040100401
000200000c5700c5700c5600c5400c5200c5100c5100c5100c5000c5000c5000c5000c5000c5000c5000c5000c500185001850018500185001850018500185001850018500185001850018500185001850018500
010a00001817018170181601816018150181501814018140181301813018122181221811418124181341814418102181001810018100181001810018100181001810018100181000010000100001000010000100
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000000004450054500000005450064500000007450000000945000000000000b45000000000000e4500000011450000000000015450000000000018450000001b450000001e45000000214502445026450
0001000000050020500305004050060500705008050080500805005350023503f65021650010502365000050000500f6501c65000050000500865000050000500005002200036500220000000000000000000000
00030000012310005538655116503b6551a655136252f6523c61029652046121463102655336510163513655116202564215615106250364511620376150762119630016230d624006150c620096221161500615
0001000000000000000060000600206501b6503d650396502f6501e65013650136401363012630126201162011610106100f6100f6100e6100e6100d6100d6100d6100c6100c6100b6100b6100a6100a6100a610
00020000000000d0503165022650154500a0500e6501e6500865002650000000100018000190001a0001c0001e0001f0000000000000000000000000000000000000000000000000000000000000000000000000
010e00001855018550185500c5500c5400c5401c5501c5501c55013540135401355013550185501c5501f55024550245502455024550245502455024550245502455024550245502455024550245500050000500
000400003c354003003330039300393000860002600000000100018000190001a0001c0001e0001f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000011650106500a4500a4501c6500a4500a4500a4500a450176500a4500a4500c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c4000c400
000100000061001630026400565007650076400764006640050400404002040000400104000030000300002000020000200001000010006000900009000070000600005000040000300002000020000100001000
00010000000000e65005650056602e65008640206100660014620046201663002640026400364005630056300563005620056200f620056200562000010056100561005600056000560005600056000560000000
0001000000000000000760006600000100b6200f630126401462001050010500d6201e6200105001050000000061003650096301e610346200000000000000000000000000000000000000000000000000000000
000200000000000040090603e670236700107000070000603066005050176502d6500d65028640030402564022640020401e6401b6401964016630116300e630000300b620076200562004620026100061000010
00010000050000001004030030500c650000501065001050010400a63001020000100000003650000000000000000000000000000000000000000000000016500000000000000000000000000000000000000000
0001000000000356503f60000000256001f6503465000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200003445034450344503445034450344503445034450344500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000c3501035011350183501835018350013000430006300093000e300103001330000000193001e3002430024300293002d300343003130000000000000000000000000000000000000000000000000000
000300200763009640096300963009640086300964007640096400963007630066300663005640066400763009630066300663006640096300663007630066300863005630056300763008630076300863008640
000100000d35010350093500f3501b35019350193501935017350133500f3500835004350003500835007350063500535007350093500f3500e3500e3500e3500e3300b310073500235000350033500635000350
00010000047500575007750097500b7502f7502a75023750127501c7501d7501b75014750207500e7502475028750087503175031750037501b75016750127500e7500c7500a7500975008750067500575004750
010100003d7223d7123d7123d7123d7123d7123d71200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400005
000200000b6313762517625226203b6253a625136252f6223c620296223e6221462102635336310163538625116202562215625106250362511610376150761119600016030d604006050c620096221160500605
000700001c614286202f630266401663001000046500d6300562000610006100061000600006000d6000d6000a60009640156500b66001650006300061000610246100f630006100d6000d6000d6000d6000d600
000200000001003020050402e6601d020150502963024650206501d6501a65017640156401464012630106300f6300e6200d6200c6200a6200961008610086100761007610066100561004610036100261001610
000700000336019660113600b36007660076600636006350043500265003350033500135001350003400034001040000400004000030017300003000430026000000000000000000000000000007000000000300
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
001700200061007610006100061001610006100061002610006100061000610006100261000610006100061000610026100241000610204100241000610006100061002610006100061000610076100161000610
00030000047440474400744057440a7440274404744047440e744027440874402744027440374402744007440a744017440a74400744047440074400744077440074403744047440174407744047440074404744
0114000021a1021a1021a101ca201ca201ca201ca201ca201ca201ca201ca201ca201ca201ca201aa101aa101ca201ca201ca201ca201ca201ca201aa101aa101da201da201da201da201da201da201aa101aa10
0114000021a1021a1021a101ca201ca201ca201ca201ca201ca201ca201ca201ca201ca201ca201aa101aa101ca201ca201ca201ca201ca201ca201aa101aa101fa201fa201fa201fa201da201da201ca201ca20
01140020219302393024930289300000023930249302893021930239302493028930000002393024930289301f930219302393028930000001f93023930289302193023930249302993000000219302493029930
011400201585021815158501581021815158500c800158501581021815008002183000000218301880021815108501c81510850108101c815108500c80010850118501d815000001d830000001d830000001d815
010a00200c0730000000000000003c62300003000000000000000000000c073000003c6250000000000000000c073000000c073000003c623000000c073000000c0730c0730c0730c0733c6250c0730c0733c625
010a00200c0730000000000000003c62300003000000000000000000000c073000003c6250000000000000000c0730000000000000003c62300000000000000000000000000c073000003c625000000000000000
__music__
03 38 42 43 44
03 39 42 43 44
00 41 42 3c 44
00 3f 42 3c 44
01 3f 3d 3c 44
00 3f 3d 3c 44
00 3f 3d 3c 3a
00 3f 3d 3c 3b
00 3f 3d 3c 3a
00 3f 3d 3c 3b
02 3e 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
