pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--dragondot 3
--by nathan mccoy
gravity=0.12
function begin_game()
lsbtn=btn()
vsh=get_hoard()
en_l()
title=false
end
function draw_title()
cls(12)
pal(4,139,1)
rectfill(0,64,128,128,4)
pal(14,136,1)
pal(1,130,1)
pal(13,135,1)
spr(64,0,32,16,3)
if not has("sk0") then
print("é new game",40,90,7)
else
print("é continue\nà"..flr(dget(8)/1.21).."% è"..get_hoard().."\n\nó new game",40,82,7)
if(wipe_tm > 0) print("hold to confirm",34,106,8)
line(-1,112,wipe_tm-1,112,8)
end
end
function trig(angle,dist,dx,dy)
return cos(angle)*(dist or 1)+(dx or 0),sin(angle)*(dist or 1)+(dy or 0)
end
function xfer(dest,src)
if src then
for k,v in pairs(src) do
dest[k]=v
end
end
return dest
end
function toby(init,fin,amt)
if(fin<init) amt=-abs(amt)
return mid(init, init+amt, fin)
end
function c32(c)
if(cmap[c]==nil) cmap[c]=cct cct+=1
color(cmap[c])
return cmap[c]
end
function draw_shd(obj)
if(obj.spawn_time>0) return
if obj.size == 0 then
rectfill(obj.x-1,obj.y+1,obj.x,obj.y+1,1) 
return
end
local sw = obj.size>1 and 2 or 1
local sp = obj.size*2+30
if(obj.size==1)sp=33
spr(sp,obj.x-obj.r,obj.y-obj.r,sw,sw)
end
function draw_orb(obj)
if(obj.spawn_time>0) d_chr(obj.x,obj.y,obj.spawn_time/spawn_time,{7}) return
draw_atk(obj)
local sx = obj.x - obj.r
local sy = obj.y - obj.z - obj.r
local size = obj.size
local sw = size>1 and 2 or 1
local sp = size*2-2
if(size==1)sp=1
local flash=obj.st.flash
local col = flash and obj.ocol or obj.col
local shade = flash and obj.oshade or obj.shade
local rim = flash and obj.orim or obj.rim
pal(1,c32(col))
pal(2,c32(shade))
pal(3,c32(rim))
br = (obj.bobble or 7+size*2)/2
bobble=0
if obj.gd and (obj.vx!=0 or obj.vy != 0) and frame%(br*2)<br then
bobble=-1
end
if(size==0) sspr(0,0,2,2,sx,sy) else spr(sp,sx,sy+bobble, sw, sw)
pal()
end
function btnr(b)
return band(band(btn(),bnot(lsbtn)),shl(1,b)) != 0
end
function dist(x1,y1,x2,y2)
local dx=x2-x1
local dy=y2-y1
local scl = max(abs(dx), abs(dy))
if(scl == 0) return 0
tx,ty = dx*4/scl, dy*4/scl
return sqrt(tx*tx+ty*ty)*scl/4
end
function cull(list)
for i=1,#list do
if(list[i] and list[i].destroy) then
list[#list],list[i]=nil,list[#list]
end
end
end
function sort(a,cmp)
for i=1,#a do
local j = i
while j > 1 and cmp(a[j-1], a[j]) do
a[j],a[j-1] = a[j-1],a[j]
j = j - 1
end
end
end
function draw_hp(obj)
if not obj.hp or obj.spawn_time>0 or not obj.st.show_hp and obj.hp == obj.max_hp then return end
bx = obj.x - flr(obj.max_hp/2)+obj.r%1
by = obj.y -obj.z - obj.r -2
line(bx, by, bx+obj.max_hp-1, by,0)
if(obj.hp>0) line(bx, by, bx+obj.hp-1, by,c32(8))
end
function d_gl()
cash="è"..held_gold
full=held_gold>=c_lim
bg=gleam>0 and gleam<6 and 10 or full and 136 or 9
fg=gleam>3 and 7 or full and 9 or 10
s_txt(cash,124-#cash*4,1,c32(fg),c32(bg))
end
function s_txt(text,x,y,fg,bg)
print(text,x,y+1,bg)
print(text,x,y,fg)
end
function d_nm(obj)
if(obj.spawn_time>0) return
if(obj.st.show_name) s_txt(obj.name, obj.x-#obj.name*2, obj.y-obj.z-obj.r-10,c32(7),0,printevery)
end
function atkr_stage(obj)
if(not obj.attks or obj.atk_cbo == 0) return -1
return atk_stage(obj.attks[obj.atk_cbo],obj.atk_frame)
end
function atk_stage(attk, frame)
phases={attk.warm,attk.active,attk.cool,attk.chain}
for i=1,4 do
frame -= phases[i]
if(frame<0) return i-1
end
return 4
end
function test_attk(obj,defender) 
if(defender.spawn_time>0) return
swing=obj.lvat
if(swing and
defender.hp and
not obj.melee_hits[defender]) then 
if(abs(defender.z-obj.z)>swing.rad) return false
if overlap(obj.live_hbx,defender) > 0 then
olap,angle = overlap(obj,defender)
elem = {}
elem.crit=obj.st.can_crit and crit_exposed(defender,obj)
elem.magic=obj.st.ph
damg = un_h(defender,swing.dmg+(obj.strength or 0),angle,swing.hkb,swing.vkb,elem,swing.stun)
obj.melee_hits[defender]=true
obj.st.stun = swing.hitlag
if(defender.st.thn and not obj.st.ph) ap_damg(obj,1) kbk(obj,angle+0.5,1,1)
end
end
end
function overlap(a,b)
return a.r+b.r-dist(a.x,a.y,b.x,b.y), atan2(b.x-a.x,b.y-a.y)
end
function pw_attks(list)
if(#list<=1) return
for i=1,#list-1 do
for j=i+1,#list do
a=list[i]
b=list[j]
olap,angle=overlap(a,b)
if a.ph == b.ph then
if(olap > 0 and abs(a.z-b.z)<4) then
dx,dy=trig(angle)
if(a.weight<=b.weight) a.x-=dx a.y-=dy cl2scr(a)
if(b.weight<=a.weight) b.x+=dx b.y+=dy cl2scr(b)
end
end
test_attk(a,b)
test_attk(b,a)
end
end
end
function begin_attk(obj,cbo)
obj.atk_cbo = cbo
obj.atk_frame=0
obj.wish_attk=false
obj.melee_hits = {}
end
function cnl_attk(obj,cbo)
obj.atk_cbo = 0
obj.atk_frame = 0
obj.st.dazed=40
obj.lvat=nil
obj.wish_attk=false
if(obj==ddt) fc_t=0
end
function glfn(amt,x,y)
angle=rnd()
for i=1, amt do
angle+=0.618
vel=sqrt(angle*0.005)
vx,vy=trig(angle,vel)
add(ths, gold(x,y,vx,vy))
end
end
function kbk(obj,angle,h,v,stun)
v-=obj.weight
if v>0 then
obj.vz=v
obj.vx,obj.vy=trig(angle,h)
obj.gd=false
obj.st.stun = stun or 5
cnl_attk(obj)
end
end
function rfl_shot(shot,rflor)
flash(rflor,7,7,7,10)
shot.owner=rflor
shot.vx*=-1
shot.vy*=-1
shot.life=shot.max_life
shot.angle+=0.5
sfx(53)
tms.drama=20
emtx(rflor,"reflect!",7)
end
function col_s(obj,shot)
if(shot.owner == obj) return false
if(overlap(shot,{x=obj.x,y=obj.y-obj.z,r=obj.r})>0) then
if not shot.hits[obj] then
if obj.st.rfl then rfl_shot(shot,obj) else
un_h(obj,shot.damg,shot.angle,shot.hkb,shot.vkb,shot.elem)
shot.hits[obj]=true
end
end
end
end
function z_fl(obj, fields)
local f= cspl(fields)
for i in all(f) do
obj[i]=0
end
end
function ddt_died()
dset(1,held_gold)
dset(2,map_x)
dset(3,map_y)
dset(4,ddt.x)
dset(5,ddt.y)
dset(6,strs_x)
dset(7,strs_y)
swm(-1)
ddt.level=held_gold
held_gold=0
tms.death=180
tms.b_lk=nil
clz()
end
function award_sk(skill)
if not has(skill) then
set_sk(skill,1)
skpop=skill
sfx(57)
end
end
function dpsk(skill,x,y)
if skill and not has(skill) then
orb=xfer(gold(x,y,0,0),{
size=1, r=3, vz=2.5,
g_i=skill})
add(ths, orb)
end
end
function unlock()
map_kills[map_x.."!"..map_y]=true g_t(dest_x,dest_y) sfx(51)
end
function sct_check(area,t)
if not tms.tink and sct!=0 and dist(area.x,area.y,land_x,land_y)<area.r then 
if(t==sct) unlock() else sfx(53) tms.tink=10 fx_on({},d_imp)
end
end
function defeat(obj)
obj.destroy=true
if obj.hp then
if obj!=ddt then
map_kills[map_x..","..map_y..","..obj.id]=true 
tribute=min(tribute+0.21*obj.level,c_lim)
else 
ddt_died()
end
glfn(obj.level,obj.x, obj.y)
end
poof(obj)
dpsk(obj.item,obj.x,obj.y)
end
function tk_tms(tms)
for k,v in pairs(tms) do
if(type(v)=="number") tms[k]=v > 0 and v-1 or nil
end
end
function tk_cr(obj)
if(obj.hp<=0 and obj.gd and not(obj==ddt and inv)) then
sfx(50)
defeat(obj)
return true
end
for i=1,#pjs do 
shot=pjs[i] 
col_s(obj,shot)
end
if(obj.atk_cbo ==0) then
obj.atk_frame=0
if(obj.wish_attk and #obj.attks > 0) then
local index = 1  
if(obj.attks[obj.wish_attk]) index=obj.wish_attk
begin_attk(obj,index)
end
end
if(obj.atk_cbo != 0 and obj.atk_cbo <= #obj.attks) then
obj.atk_frame += 1
local cur_attk = obj.attks[obj.atk_cbo]
if obj.atk_frame==cur_attk.kick_frame then
if(cur_attk.h_kick!=0) obj.vx,obj.vy=trig(obj.fcg,bsign(cur_attk.h_kick)/10)
if(cur_attk.v_kick!=0) obj.vz = bsign(cur_attk.v_kick)/10
end
if obj.atk_frame==cur_attk.warm then 
if(cur_attk.sound) sfx(cur_attk.sound)
if(cur_attk.avt) cur_attk.avt(obj)
end
obj.lvat=nil
if atkr_stage(obj)==1 then
obj.lvat=cur_attk
local dx,dy=trig(obj.fcg,cur_attk.reach,obj.x, obj.y)
obj.live_hbx={x=dx,y=dy,r=cur_attk.rad}
sct_check(obj.live_hbx,obj.reveals)
end
if(atkr_stage(obj) >= 3 and obj.wish_attk and obj.atk_cbo > 0) then
if(obj.atk_cbo >= #obj.attks) obj.atk_cbo = 0
begin_attk(obj,obj.atk_cbo+1)
end
if(atkr_stage(obj)==4) then 
obj.atk_cbo=0
obj.melee_hits={}
end
end
if(obj.atk_cbo > #obj.attks) obj.atk_cbo = 0
return true
end
function ap_vl(obj)
obj.x += obj.vx
obj.y += obj.vy
end
function cl2scr(obj)
obj.x=mid(1,obj.x,127)
obj.y=mid(1,obj.y,127)
end
function tk_phys(obj)
if(obj.destroy) return
tk_tms(obj.st)
if obj.boss and not ddt.destroy then
swm(24,3)
tms.b_lk=90
end
if(obj.st.stun) return
if(obj.spawn_time>0) obj.spawn_time-=1 return
ap_vl(obj)
if(obj.hp and not tk_cr(obj)) return
obj.vz -= (obj.gravity or gravity)
obj.z += obj.vz
obj.gd=false
if obj.z<0 then
obj.z=0 
obj.vz=0
obj.gd = true
end
ejk(obj)
obj.scy=obj.y-obj.z
if(obj.ai) ai[obj.ai](obj)
local stage=atkr_stage(obj)
if(stage>-1 and stage<3 and obj.gd) obj.mx=0 obj.my=0
grip=obj.gd and obj.gdfric or obj.airfric
obj.vx = toby(obj.vx,obj.mx,grip/50)
obj.vy = toby(obj.vy,obj.my,grip/50)
try_drown(obj)
if obj!=ddt or not ddt.gd or tms.b_lk then
cl2scr(obj)
end
if(obj==ddt and obj.gd and tile_safe(obj.x,obj.y,obj)) last_gd_x=obj.x last_gd_y=obj.y
end
function eth(fn)
for k,v in pairs(ths) do
fn(v)
end
end
function swm(track)
poke4(0x5f40,track>63 and 0x0300.0000 or 0)
track%=64
if npl!=track then
music(track,0,3)
npl=track
end
end
function sweep_pos(angle,t,r,rev)
if(rev) t=1-t
return trig(angle+t/2-0.25,r)
end
function rn_dfl(att,x,y,angle,t)
c32(att.color or 7)
circfill(x,y,att.rad)
end
function d_wn(obj)
if obj.attks then
local attk=obj.attks[obj.atk_cbo]
t=nil
if attk and attk.warm>20 and atkr_stage(obj) == 0 then
t=1-obj.atk_frame/attk.warm
end
if(obj==ddt and fc_t > 1 and fc_t < fch_t) then
t=1-fc_t/fch_t
end
if(t) d_chr(obj.x,obj.y-obj.z,t)
end
end
function draw_atk(obj)
local att = obj.lvat
if att then
local t = (obj.atk_frame-att.warm)/att.active
att:rn(obj.live_hbx.x,obj.live_hbx.y-obj.z,obj.fcg,t,obj.atk_cbo%2==0)
end
end
function grd(range, t)
return c32(range[ceil(mid(0.01,t,1)*#range)])
end
function crit_exposed(obj,attker)
return atkr_stage(obj)>=2 and not(obj.melee_hits[attker])
end
function fx_on(obj,rn,life)
part={x=obj.x or land_x,
y=obj.scy or obj.y or land_y,
r=3,
life=life or 6,
draw=rn}
z_fl(part,"vx,vy,g,t")
add(ptks, part)
return part
end
function tk_ptk(part)
ap_vl(part)
part.vy+=part.g
part.t+= 1/part.life
if(part.t > 1) part.destroy=true 
end
function d_txp(part)
print(part.text,part.x-#part.text*2,part.y-3,c32(part.color))
end
function d_spk(part)
c32(10)
circfill(part.x,part.y,4*(1-part.t))
c32(7) star(part.x,part.y,4*part.t,4)
end
function star(x,y,r,sides,angle)
if(r<0) return
for i=1,sides do 
ax,ay=trig((angle or 0)+i/sides,r,x,y)
line(x,y,ax,ay)
end
end
function d_imp(part)
c32(9)
w=(1-part.t)*6*part.r
star(part.x,part.y,w,4,0.125)
circfill(part.x,part.y,w*0.7,c32(7))
end
function draw_poof(part)
c32(7)
t=part.t
for i=0,4 do
a=i/4+0.125-t*part.life/25
r=min(t*3,1)*part.r*1.7
if(i==0) r=0
x,y=trig(a,r,part.x,part.y)
circfill(x,y,part.r*(1-t))
end
end
function weave(ks,vs)
local out={}
local keys=cspl(ks)
local vals=cspl(vs)
for i=1,#keys do
out[tonum(keys[i]) or keys[i]]=tonum(vals[i]) or vals[i]
end
return out
end
function cspl(str)
local out={}
l=1
for i=1, #str do
if sub(str,i,i)==(",") then
add(out, sub(str,l,i-1))
l=i+1
end
end
add(out, sub(str,l,-1))
return out
end
function draw_fire(part)
r=(1-part.t)*(part.r+1)
circfill(part.x,part.y,r,grd({7,10,9,8,136},part.t))
end
function rn_fireshot(obj)
for i=1,2 do
part=fx_on(obj,draw_fire,20)
part.vx,part.vy=trig(rnd(),0.5)
part.r=obj.r
end
end
function tk_shots()
for i=1,#pjs do
shot=pjs[i]
shot.life -= 1
ap_vl(shot)
tile=tile_at(shot.x,shot.y)
if(shot.life <= 0 or (tile.solid and not shot.phase)) shot.destroy=true 
sct_check(shot,64)
end
end
function shoot(owner,angle,damg,radius,speed,life)
shot={
owner=owner,
x=owner.x,
y=owner.scy,
life=life,
max_life=life,
r=radius,
damg=damg,
rn=rn_fireshot,
hits={},
elem={magic=true},
vkb=20,
hkb=10,
angle=angle}
add(pjs,shot)
shot.vx,shot.vy=trig(angle,speed)
return shot
end
function poof(obj)
part=fx_on(obj,draw_poof,10+obj.size*5)
part.r = obj.r+1
end
function en_fi(source)
atk=source.attks[1]
shot=shoot(source,atan2(ddt.x-source.x,ddt.scy-source.scy),atk.dmg,atk.rad,atk.reach/10,60)
shot.hkb=atk.hkb
shot.vkb=atk.vkb
shot.phase=source.st.fl
return shot
end
function cbt(original,changes)
return xfer(xfer({},original),changes)
end
function emtx(obj,text,col)
part = xfer(fx_on(obj,d_txp,30),{vx=obj.vx,vy=obj.vy-1.5,g=0.07,color=col,text=text})
return part
end
function flash(obj,c,s,r,t)
obj.ocol=c
obj.oshade=s
obj.orim=r
obj.st.flash=t or 4
end
function mkcm(obj)
xfer(obj,{
hp=obj.max_hp,
spawn_time=spawn_time,
lgx=obj.x,
lgy=obj.y,
})
z_fl(obj,"atk_frame,atk_cbo,z,vx,vy,vz,mx,my,otime,fcg")
return obj
end
function c_hp(obj,amt)
obj.hp=mid(obj.max_hp, obj.hp+amt, 0)
obj.st.show_hp=120
end
function cl_dm(obj,amt,elem)
if(obj.st.ph and not elem.magic) return 0,"immune!"
report=nil
if(elem.crit) amt+=1 report="crit"
if(elem.magic) amt-=obj.resist else amt-=obj.armor
return max(amt,0),report
end
function un_h(target,amount,angle,hkb,vkb,element,stun)
damg, report = cl_dm(target,amount,element)
if damg > 0 then
kbk(target,angle,hkb/10,vkb/10,stun)
end
ap_damg(target,damg,report)
end 
function ap_damg(obj,damg,report)
c_hp(obj, -damg)
if(damg==0) sfx(53) text=report or "0"
if damg>0 then
sfx(obj.name=="kobold" and 40 or 30) 
p=fx_on(obj,d_imp,7) 
p.r=damg
text=""..damg
end
if(report=="crit") text=damg.."!"
emtx(obj,text,7)
end
lair_x=5
lair_y=5
spawn_time=60
vsh=0
inv=true
function togin()
inv=not inv
menuitem(2,"can't die: "..(inv and "on" or "off"),togin)
end
function _init()
cartdata("nmccoy_dragondot")
togin()
title=true
unp_sks()
tms = {}
frame = 0
lsbtn=0
held_gold = 0
gleam=0
sk_crs=1
swm(22)
end
wipe_tm=0
function _update60()
frame += 1
tk_tms(tms)
if title then
if(btnp(é)) begin_game() return
if(btn(ó)) wipe_tm += 1 else wipe_tm=0
if(wipe_tm >= 130) memset(0x5e00,0,256) begin_game() return
return
end
gleam=max(gleam-1,0)
if(lair) then
up_l()
else
if not (tms.strs or tms.scl) then
for i=1,#ptks do
tk_ptk(ptks[i])
end
cull(ptks)
if(tms.drama) return
eth(tk_phys)
ftrs={}
for i=1,#ths do
if(ths[i].hp) add(ftrs,ths[i])
end
tk_shots()
cull(pjs)
pw_attks(ftrs) 
cull(ths)
sort(ths,function(a, b) return not a or b and a.y+a.r > b.y+b.r end)
if(#ftrs==1 and sct==32) unlock()
end
if(tms.b_lk==89) swm(-1)
if(tms.b_lk==1) swm(23)
if(tms.death==1) en_l()
try_scl(flr(ddt.x/128),flr(ddt.y/128))
end
lsbtn=btn()
end
function _draw()
if(title) draw_title() return
cmap={} cct=0 c32(0)
if lair then
draw_lair()
else
d_mp_s()
eth(d_tsh)
if(tms.b_lk and not tms.scl) rect(0,0,127,127,c32(8))
if(tms.death) cls(0)
eth(draw_orb)
eth(d_wn)
for p in all(ptks) do
p:draw()
end
for p in all(pjs) do
p:rn()
end
eth(draw_hp) 
eth(d_nm)
camera()
if skpop then
d_skc(skpop,2,60,7,0)
s_txt("acquired!",47,54,c32(7),0)
end
d_gl()
minimap()
if(tms.strs) circfill(ddt.x,ddt.y,(30-abs(tms.strs-30))*5,0)
end
for k, v in pairs(cmap) do
pal(v, k, 1)
end
end
function rn_claw(att,x,y,angle,t,rev)
color(c32(7))
for i=-0.3,0.3,0.1 do
x1,y1=sweep_pos(angle,t+i,att.rad,rev)
x2,y2=sweep_pos(angle,t+i+0.1,att.rad,rev)
for i=-1,1,2 do
line(x1+x,y1+y-i,x2+x,y2+y-i)
end
end
end
function scan()rx+=1 return mget(rx,ry)
end
fields={
"level",
"size",
"max_hp",
"col",
"shade",
"rim",
"movespeed",
"range",
"gdfric",
"airfric",
"bobble",
"armor",
"weight",
"boss",
"atk_flurry",
"special_st",
"atk_dmg",
"atk_reach",
"atk_rad",
"atk_sound",
"atk_warm",
"atk_active",
"atk_cool",
"atk_chain",
"atk_hkb",
"atk_vkb",
"atk_h_kick",
"atk_v_kick",
"atk_stun",
"atk_hitlag",
"atk_rn_style",
"atk_avt_proc",
"atk_color",
"atk_kick_frame",
"resist",}
cr_dex={
"goblin","kobold","wuf","hoblin","ghost","zombie","burble","ninja","crystalynx","giant","treasure orb","pushroom","pyroc","cactoid","golith","buzzirb",
"tygrel","hopling","dragon","wilsp","wraith","cinder tree","dead eye","peench"}
item_dex={}
tribute=0
proc_dex={
function(k) 
t=emtx(k,"á",14) t.x-=1 
c_hp(ddt,skill("sk15")) 
offering=min(tribute,c_lim-held_gold)*skill("tribute")
glfn(offering,k.x,k.y) tribute-=offering
end,
shoot_fire,
en_fi,
}
st_dex=cspl(
"can_crit,rfl,ph,aq,fl,thn"
)
rn_styles={
rn_dfl,
rn_claw,
}
function bsign(b)
return b > 127 and b-256 or b
end
function read_cr(index)
local cr={reveals=index}
attk={}
local st_ad=0x2040+index*128
for i=1, #fields do
fln=fields[i]
byte=peek(st_ad+i-1)
if sub(fln,1,4)=="atk_" then
attk[sub(fln,5)]=byte
else
cr[fln]=byte
end
end
attk.rn=
rn_styles[attk.rn_style]
attk.avt=proc_dex[attk.avt_proc]
st={}
spec=st_dex[cr.special_st]
if(spec) st[spec]=true
xfer(cr,{st=st,
ai="hst",
boss=cr.boss!=0,
r=({3,5,5.5,7})[cr.size],
name=cr_dex[index],
attks={attk},
range = bsign(cr.range)})
for i=1,attk.flurry do
extra_attk=cbt(attk,{warm=1})
extra_attk.kick_frame-=attk.warm
add(cr.attks,extra_attk)
end return cr
end
fc_t=0
jumps=0
function d_ctl(ddot)
ddot.strength=skill("sk13")
if has("sk12") then
d_claw.avt=function(obj) obj.st.rfl=10 end
end
if(ddot.lvat) ddot.vz=0
wx=0
wy=0
local speed=1
if(fc_t > 1) speed=0.5+skill("sk22")*0.2
if(btn(ã)) wx -= 1
if(btn(ë)) wx += 1
if(btn(î)) wy -= 1
if(btn(É)) wy += 1
want_move= wx != 0 or wy != 0
if btnr(ó) then
ddt.wish_attk=true
skpop=nil
end

stage = atkr_stage(ddot) 
if btn(ó) and ddot.gd and (stage == -1 or stage>2) and has("sk4") and not ddot.wish_attk then
fc_t += 1
if(fc_t == fch_t) sfx(63)
if(fc_t >= fch_t and frame%5==1) then
flash(ddot,8,136,2,3)
end
else 
if fc_t >= fch_t then
brf()
end
fc_t=0
end
if want_move then
if(can_move(ddot) or ddot.atk_frame==0) ddot.fcg=atan2(wx, wy)
else
speed=0
end
ddot.mx,ddot.my=trig(atan2(wx,wy),speed)
if(ddot.gd) jumps=skill("wings")+1
if(btnr(é)) tms.jump_buffer=10

if not ddot.lvat and tms.jump_buffer and jumps>0 then
tms.jump_buffer=nil
ddot.vz=1.9
ddot.vx=ddot.mx
ddot.vy=ddot.my
ddot.gd=false
jumps-=1
if fc_t >= fch_t and has("sk20") then
ddot.vz=2.5
ddot.vx*=3
ddot.vy*=3
shoot(ddt,0.5+ddt.fcg,skill("sk4"),10+skill("sk17")*4,0,3)
sfx(52)
end
fc_t=0
end
end
function d_chr(x,y,t,grad)
grd(grad or {10,9},t)
for i=1,4 do
dx,dy=trig(t+i/4+0.125,t*20)
circfill(x+dx,y+dy,1)
end
end
function brf()
firecrit=fc_t<=fch_t+10 and has("sk2")
shot = shoot(ddt,ddt.fcg,skill("sk4"),4+skill("sk17")*2,firecrit and 4 or 2,30)
if firecrit then
sfx(52) 
ddt.vx,ddt.vy=trig(ddt.fcg,-0.7)
ddt.vz=0.7
flash(ddt,10,9,8)
shot.elem.crit=true
else 
sfx(58) 
end
shot.phase=has("phasefire")
shot.hkb=10+skill("sk24")*10
end
function dragon()
local derg = mkcm(cbt(mons[19],{ai="dragon",extra=ddot_extra}))
d_claw=derg.attks[1]
d_bite=cbt(d_claw,{rn=rn_dfl})
xfer(d_bite,weave("dmg,reach,rad,cool,sound","2,7,5,15,41"))
derg.attks={d_claw,d_claw,d_bite}
return derg
end
mons={}
for i=1,#cr_dex do mons[i]=read_cr(i) end
function can_move(obj)
stage=atkr_stage(obj)
return (obj.gd or obj.st.fl) and (stage<0 or stage>2)
end
function hst_ai(obj)
if(obj.hp<=0) obj.airfric=0 return
if(obj.st.fl and obj.z < 14) obj.vz=min(obj.vz+.2,1)
in_range=dist(ddt.x, ddt.y, obj.x, obj.y) -ddt.r < abs(obj.range) and ddt.z<abs(obj.range)
if(obj.range<0) in_range=not in_range
cbo=obj.atk_cbo
if can_move(obj) then
obj.fcg=atan2(ddt.x-obj.x,ddt.y-obj.y)
if cbo < #obj.attks and (in_range or cbo > 0) then
if not obj.st.dazed then
obj.wish_attk=true
end
else
if(not in_range) obj.mx,obj.my=trig(obj.fcg,obj.movespeed/10*sgn(obj.range))
end
end
end
function gold_ai(obj)
x=obj.x y=obj.y
if((-x*0.2-y*0.2+frame)%60<6) flash(obj,7,10,10)
if fc_t > 1 and has("avarice") then
obj.vx,obj.vy=trig(atan2(ddt.x-x,ddt.y-y),0.20,obj.vx*0.98,obj.vy*0.98)
if(obj.landed) obj.z=1 obj.vz=0
if(fc_t==300) glfn(3,x,y) fc_t=301 sfx(57) fx_on(obj,d_spk,6)
end

if dist(x,y,ddt.x,ddt.y)<7 and ddt.gd and not ddt.destroy and obj.z<=2 then
if obj.g_i then award_sk(obj.g_i) else
held_gold=min(1+held_gold, c_lim)
c_hp(ddt,skill("sk6"))
gleam=8
sfx(47)
end
fx_on(obj,d_spk)
obj.destroy=true
end
if (obj.gd and not obj.landed) sfx(48) obj.landed=true
end
ai={hst=hst_ai,
dragon=d_ctl,
gold=gold_ai}
function gold(x,y,vx,vy)
obj={
r=1,
size=0,
x=x,
y=y,
col=10,
rim=9,
shade=9,
gdfric = 5,
st={},
ai="gold",
vx=vx,
vy=vy,
vz=dist(vx,vy,0,0)+1.5,
gravity=0.07,
lgx=x,
lgy=y}
z_fl(obj,"z,mx,my,spawn_time,airfric,fcg,gold")
return obj
end
function skill(name)
return peek(sk_data[name].index+0x5e80)
end
function unp_sks()
for k,v in pairs(sk_data) do
sk_data[k]=weave(sk_template,sk_data[k])
item_dex[sk_data[k].index+0]=k
end
end
function set_sk(id,value)
poke(0x5e80+sk_data[id].index,value)
end
function has(sk)
return skill(sk)>0
end
function sk_info(id)
local lk = sk_data[id]
lev = skill(id)
cost = 0
lk.ranks = lk.ranks or 0
lk.base = lk.base or 0
lk.inc = lk.inc or 0
if(lev<0+lk.ranks) cost = lk.base+lev*lk.inc
return xfer({
level = lev,
afford = cost <= get_hoard(),
cost = cost,
},lk)
end
function d_skc(id, x, y, fg, bg, shop)
local w=123
local h=19
data=sk_info(id)
rectfill(x,y,x+w,y+h,c32(bg))
rect(x,y,x+w,y+h,c32(fg))
local level = skill(id)
if(shop) level+=1
name=data.name
if(data.ranks+0 > 1) name = name .." lv. "..level
print(name,x+3,y+3,c32(fg))
print(data.desc,x+3,y+11,c32(fg))
if(shop) then
cost = "è"..data.cost
print(cost,x+w-5-#cost*4,y+3,c32(data.afford and fg+3 or fg))
end
end
function sk_av(id)
data = sk_info(id)
if(not data.base or 0+data.ranks<=skill(id)) return false 
if(not data.prereq or has(data.prereq)) return true
end
function sk_offers()
offers = {}
for k,v in pairs(sk_data) do
if(sk_av(k)) add(offers, k)
end
return offers
end
colortable={
á={130,2},
è={131,3},
Ç={1,140},
Ö={132,4},
}
function skl_k()
known = {}
for k,v in pairs(sk_data) do
if(has(k)) add(known, k)
end
return known
end
sk_template="index,name,desc,ranks,base,inc,prereq"
sk_data={
sk0="0,Ç natural weapons,tap ó to claw and bite foes.,1",
sk1="1,á draconic pride,get bonus á from hoard size.,1,10",
sk2="2,Ö fire blast,time ó release to crit.,1,30",
jump="3,Ç hatchling leap,tap é to jump; dodge melee.,1",
sk4="4,Ö fire breath,charge up with ó.,3,0,100",
carry="5,è covetousness,carry è25 per skill level.,4,0,25",
sk6="6,á gleaming triumph,gain á when you collect è.,1,10,0,sk1",
avarice="7,è projected avarice,draw in è when you focus Ö.,1,10,0,sk4",
sk8="8,Ö rapid fire,fire breath charges faster.,1,50,0,sk2",
opportunist="9,Ç opportunist,melee crits on foes who miss.,1,30",
sk10="10,Ç lunging bite,launch forward when biting.,1,20",
wings="11,Ç fledgling wings,é to jump again in midair.,1,100",
sk12="12,Ç crystal claw,reflect during claw attack.",
sk13="13,Ç giant strength,+1 to melee damage.,3,0,300,sk13",
sk14="14,á damp yet dignified,don't lose á from liquids.",
sk15="15,á reciprocal affection,kobold cheers restore á.,1,10,0,tribute",
sk16="16,Ç armored scales,take less physical damage.,1,250",
sk17="17,Ö searing swath,fire breath hits a wider area.,3,50,100,sk17",
sk18="18,Ç sharpened scales,physical attackers get hurt.,1,200",
sk19="19,Ç combo claw,first claw doesn't knock away.,1,30",
sk20="20,Ö rocket jump,use Ö charge to blast off.",
tribute="21,è tribute,kobolds offer è sometimes.",
sk22="22,Ö agile focus,move faster when charging Ö.",
phasefire="23,Ö phasefire,your fire goes through walls.",
sk24="24,Ö concussive flame,more fire breath kbk."
}
function get_hoard()
return dget(0)
end
function adj_hoard(amt)
if(amt<0 or dget(0)<30000) dset(0,dget(0)+amt)
end
function sk_colors(id)
icon=sub(sk_info(id).name,1,1)
colors=colortable[icon]
return colors[1],colors[2]
end
function sk1_bonus()
return skill("sk1")*flr(sqrt(get_hoard()))
end
function dp_l()
lair=false
tms.strs=29
ddt=xfer(dragon(),{
max_hp=10+sk1_bonus(),
x=64,
y=70,
spawn_time=0,
st={can_crit=has("opportunist"),thn=has("sk18")},
armor=skill("sk16")
})
ddt.hp=ddt.max_hp
fch_t=30-8*skill("sk8")
sz(lair_x,lair_y)
if has("sk19") then
ddt.attks[1]=cbt(d_claw,{hkb=0})
end
if has("sk10") then
d_bite.h_kick=25
d_bite.v_kick=5
d_bite.kick_frame=1
end
c_lim = skill("carry")*25

menuitem(1,"to lair (drop è)", function() defeat(ddt) sfx(50) end)
end
function en_l()
map_kills={}
swm(22)
lair=true
prep_lair()
sk_crs = 1
adj_hoard(held_gold)
held_gold=0
menuitem(1)
end
function fix_crs()
sk_crs = mid(1,sk_crs,#active_list)
sel_sk=active_list[sk_crs]
end
function prep_lair()
known_list=skl_k()
shop_list=sk_offers()
sort(shop_list, 
function(a,b) return sk_info(b).cost < sk_info(a).cost end
)
shop=true
active_list=shop_list
fix_crs()
end
function afford_seld()
return #active_list > 0 and sk_info(sel_sk).afford
end
function draw_sk_list(list)
start=1
last=#list
top=57
if #list>3 then 
start=mid(1,sk_crs-1,#list-2)
last=start+2
end
c32(6)
if(start > 1) line(2,top-2, 125, top-2)
if(last < #list) line(2,top+63, 125,top+63)

for i=start, last do
bg,bgs=sk_colors(active_list[i])
fg=6 l=0
if(i==sk_crs) fg=7 bg=bgs l=1
d_skc(list[i],2-l,top,fg,bg,shop)
top += 21
end
end
function draw_lair()
cls(c32(128))
for i in all(cspl("sk12,phasefire,sk17,sk20,sk13")) do
c32(has(i) and 10 or 140)
print("Ü")
end
rectfill(0,55,128,120,0)
draw_sk_list(active_list)
if(shop) print("ã gain skills ë",31,49,c32(9)) else print("ã known skills ë",29,49,c32(12))
c32(6)
if(can_leave) print("é depart",2,122)
if(shop and afford_seld()) print("ó purchase skill",59,122)
step=46
hoard=vsh
gold_heap(hoard)
hoard="è"..hoard
print(hoard,61-#hoard*2,step-6,c32(10))
pb=sk1_bonus()
if pb>0 then
pb="á+"..pb
print(pb,120-#pb*4,41,c32(14))
end
end
function gold_heap(amount)
srand(amount)
while amount > 0 do
row=ceil(sqrt(amount)*2-1)
left=64-flr(row/2)
rectfill(left,step,left+row-1,step,c32(9))
pset(left+rnd(row*0.7),step,c32(((frame/2-step)%80<10) and 7 or 10))
amount -= row
step -= 1
end
end
function buy()
if(not afford_seld()) sfx(53) return
adj_hoard(-sk_info(sel_sk).cost)
set_sk(sel_sk,skill(sel_sk)+1)
prep_lair()
sfx(57)
end
function up_l()
hoard=get_hoard()
can_leave = has("sk0") and has("jump") and has("carry") and has("sk4")
if(vsh<hoard) sfx(47)
vsh=toby(vsh,hoard,1)
stain=dget(1) stain_x=dget(2) stain_y=dget(3)
if(btnp(ã) or btnp(ë)) shop=not shop sfx(56)
if(shop) active_list=shop_list else active_list=known_list
if(btnp(î)) sk_crs -= 1 sfx(56)
if(btnp(É)) sk_crs += 1 sfx(56)
fix_crs()
if(btnr(ó) and shop) buy()
if(btnp(é) and can_leave) dp_l()
end
function depth(x,y)
local biome=fbi(x,y)
ex,ey=mget(110,biome),mget(111,biome)
return abs(x-ex)+abs(y-ey)
end
function fbi(mapx,mapy)
return sget(96+mapx,16+mapy)+(mapx>13 and 16 or 0)
end
function map_tile(map_x,map_y,t_x,t_y)
map_x*=2
map_y*=2
map_x+=flr(t_x/8)
map_y+=flr(t_y/8)
t_x%=8
t_y%=8
sn=mget(map_x,map_y)
spx=sn%16
spy=flr(sn/16)
return sget(spx*8+t_x,spy*8+t_y)
end
function num_loc(num)
return num%16*8,flr(num/16)*8
end
function sw_fl()
if dest_x then
if(map_x<12) strs_x=map_x strs_y=map_y
ddt.x,ddt.y=land_x,land_y
sz(dest_x, dest_y)
z_fl(ddt,"vx,vy,vz,z")
else
en_l()
end
end
function ch_st()
if(tms.strs==30) sw_fl()
if not tms.strs and tile_under(ddt).door then
tms.strs=60
end
end
function tile_at(x,y,tiles)
return (tiles or zone_tiles)[tc(x)..","..tc(y)]
end
function try_scl(dx,dy)
if(ddt.destroy) return
ch_st()
if(dx==0 and dy==0) return
old_tiles=zone_tiles
scl_x=dx
scl_y=dy
sz(map_x+dx,map_y+dy)
ddt.x%=128
ddt.y%=128
--ddt.scy%=128
tms.scl=40
end
function d_mp_s()
if tms.scl then
nt=tms.scl/40
camera(-128*nt*scl_x+128*scl_x,-128*nt*scl_y+128*scl_y)
d_trn(old_tiles)
camera(-128*nt*scl_x,-128*nt*scl_y)
end
d_trn(zone_tiles)
end
function draw_tile(tile)
x,y=tile.x,tile.y
c32(tms.drama and tile.bg or tile.fg)
rectfill(x, y, x+7, y+7)
frn=tile_at(x,y-8,tile.zone)
c32(tile.bg)
if(tile.water and not frn.water or frn.solid) rectfill(x,y,x+7,y)
end
function d_trn(tiles)
for x=0,15 do for y=0,15 do
draw_tile(tiles[x..","..y])
end end
end
function d_tsh(obj)
if(obj.size == 0 and obj.gd) return
tiles=tl_sh(obj)
for k,v in pairs(tiles) do
shd_over(obj,k)
end
end
function shd_over(obj,tile)
clip(tile.x,tile.y,8,8)
pal(1,c32(tile.bg))
draw_shd(obj)
pal()
clip()
end
function tile_under(obj)
return tile_at(obj.x,obj.y)
end
function try_drown(obj)
if(obj.st.ph or not obj.gd) return
wet=tile_under(obj).water
if(obj.st.aq) wet=not wet
if wet then
obj.gd=false
sfx(52)
if obj != ddt then
defeat(obj)
else
poof(obj)
cnl_attk(obj)
obj.spawn_time=spawn_time
if(not has("sk14")) ap_damg(obj,1)
obj.x=last_gd_x
obj.y=last_gd_y
end
return true
end
end
function drowns_in(obj,tile)
if(obj.st.aq) return not tile.water else return tile.water
end
function tile_safe(x,y,obj)
tile=tile_at(x,y)
if(tile.solid) return false
return not drowns_in(obj,tile)
end
function ejk(obj)
if(obj.st.ph or obj.landed) return
if tile_at(obj.x,obj.y).solid then
obj.x,obj.y=obj.lgx,obj.lgy
else
if not obj.gold then
for a=0,0.75,0.25 do
dx,dy=trig(a)
tile=tile_at(obj.x+dx*obj.r,obj.y+dy*obj.r)
if tile.solid or obj.gd and drowns_in(obj,tile) then
obj.x-=dx*max(abs(obj.vx),1)
obj.y-=dy*max(abs(obj.vy),1)
end
end
end
obj.lgx,obj.lgy=obj.x,obj.y
end
end
tcmap={[3]=113,[4]=115,[12]=117,[6]=119}
function tile_colors(biome,tile)
if(tile==0) return 0,0
x=tcmap[tile]
return mget(x,biome),mget(x+1,biome)
end
land_x=0 land_y=0
function g_t(x,y)
tiles={}
tiles.colors={}
biome=fbi(x,y)
srand(x+y)
for i=0,15 do for j=0,15 do
tile=map_tile(x,y,i+4,j+4)
fg,bg=tile_colors(biome,tile)
tiles[i..","..j] = {x=i*8,y=j*8,fg=fg,bg=bg,solid=tile==6, water=tile==12,door=tile==0,id=tile,zone=tiles}
tiles.colors[fg]=true
tiles.colors[bg]=true
end end
dest_x=nil sct=0
for i=0,99 do
if x==mget(i,27) and y==mget(i,28) then
dest_x=mget(i,29)
dest_y=mget(i,30)
land_x,land_y=num_loc(mget(i,31))
sct=mget(i,26)
break
end
end
zone_tiles=tiles
if(map_kills[x.."!"..y]) g_t(dest_x,dest_y)
end
map_kills={}
function add_color(col)
if(colorset[col]) return true
if(colorcount>=16) return false
colorset[col]=true colorcount+=1
return true
end
function biome_pop(biome)
pop={}
for i=121,127 do
c=mget(i,biome)
if(c>0) add(pop,c)
end
return pop
end
function get_fixed_spawns()
for i=1,31 do
if map_x==mget(103,i) and map_y==mget(104,i) then
spawn_x,spawn_y=num_loc(mget(105,i))
tospawn={}
for n=1,mget(107,i) do add(tospawn,mget(106,i)) end
treasure=mget(108,i)
spawn_r=0
return tospawn
end
end
end
function prep_proc_spawns()
spawn_r=16
colorset=weave("0,130,2,136,8,9,10,7","t,t,t,t,t,t,t,t")
xfer(colorset,zone_tiles.colors)
colorcount=0
for k,v in pairs(colorset) do colorcount+=1 end
pop=biome_pop(fbi(map_x,map_y))
budget=depth(map_x,map_y)
tospawn={}
while(budget>0 and #pop>0) do 
choice=pop[1+flr(rnd(#pop))]
local c=mons[choice]
if budget>=c.level
and add_color(c.col) 
and add_color(c.shade) 
and add_color(c.rim)
then 
budget-=c.level
add(tospawn,choice)
else 
budget-=0.1
end
end
return tospawn
end
function do_spawn(id,i)
if(not map_kills[map_x..","..map_y..","..i]) then
proto=mons[id]
local r=spawn_r+8*(i-1)
for tries=1,16 do
 x,y=trig(r*0.07725,r,spawn_x,spawn_y)
 r+=7
 if tile_safe(x,y,proto) then
spawn=cbt(proto,
{id=i,x,y,x=x,y=y,st=xfer({show_name=120,show_hp=120},proto.st),item=item_dex[treasure]})
mkcm(spawn)
 add(ths, spawn)
 return spawn
 end
end
end
end
function sp_cr()
treasure=-1
spawn_x=64
spawn_y=64
srand(map_x+256*map_y)
local to_spawn=get_fixed_spawns() or prep_proc_spawns()
for i=1,#to_spawn do
do_spawn(to_spawn[i],i,to_spawn.x,to_spawn.y)
end
end
function clz()
ths={}
ptks={}
pjs={}
add(ths, ddt)
end
function tc(x)
return mid(0,flr(x/8),15)
end
function tinbox(x,y,w,h)
cvg={}
for ix=tc(x),tc(x+w) do for iy=tc(y),tc(y+h) do
cvg[tile_at(ix*8,iy*8)]=true
end end
return cvg
end
function tl_sh(obj)
shx,shy =obj.x-obj.r,obj.y+1
sw=obj.r*2
sh=obj.r
return tinbox(shx,shy,sw,sh)
end
function sz(x,y)
swm(mget(112,fbi(x,y)))
clz()
map_x=x
map_y=y
g_t(x,y)
sp_cr()
if(stain>0 and x==stain_x and y==stain_y) glfn(stain,dget(4),dget(5)) dset(1,0) stain=0
end
function visited(x,y,set)
y+=16
vrow=dget(y)
vcol=lshr(0x8000,x)
if(set)dset(y,bor(vrow,vcol))
return band(vrow,vcol)!=0
end
function minimap()
if(map_x>10) return
visited(map_x,map_y,true)
camera(-2,-2)
rectfill(0,0,10,10,c32(130))
seen=0
for ix=0,10 do for iy=0,10 do
if(visited(ix,iy)) pset(ix,iy,c32(2)) seen+=1
end end 
dset(8,seen)
local sx=stain_x local sy=stain_y
if (sx>10) sx=dget(6) sy=dget(7)
pset(5,5,c32(136))
if(stain>0) pset(sx,sy,c32(9+flr(frame/30%2)))
pset(map_x,map_y,c32(8))
camera()
end
__gfx__
120000000033300000003330000000000000333300000000000003333300000033333333333333333333333300aaa000000aa0000aaaaa000aaaaaa0000aaa00
22000000031113000033111330000000003311113300000000033111113300003333333333333333333663330a44aa0000aaa000aa444aa00444aa4000aaaa00
0000000031111230031111111300000003111111113000000031111111113000333333333336633333666633aa004aa0004aa0004400aaa0000aa4000aa4aa00
0000000031111230031111111300000003111111113000000311111111111300333663333366663336666663aa000aa0000aa00000aaaa4000aaaa00aa40aa00
0000000031112230311111111230000031111111112300000311111111111300333663333366663336666663aa000aa0000aa0000aaaa40000444aa0aaaaaaa0
00000000032223003111111122300000311111111223000031111111111112303333333333366333336666334aa00a40000aa000aaa44000aa000aa04444aa40
000000000033300031111111223000003111111112230000311111111111123033333333333333333336633304aaa4000aaaaaa0aaaaaaa04aaaaa400000aa00
00000000000000000311111223000000311111112223000031111111111122303333333333333333333333330044400004444440444444400444440000004400
3ccccccc36633663031112222300000003111112223000003111111111112230333663333366663336666663aaaaaa0000aaaa00aaaaaaa00aaaa0000aaaaa00
33cccccc33333333003322233000000003111222223000003111111111122230336666333666666366666666aa4444000aa44400aa444aa0aa444a00aa444aa0
333ccccc33333333000033300000000000332222330000000311111111222300366666636666666666666666aaaaaa00aa4000004400aa40aaa00a00aa000aa0
333ccccc3336633300000000000000000000333300000000031111111222230066666666666666666666666644444aa0aaaaaa00000aa4004aaaa4004aaaaaa0
333ccccc3336633300000000000000000000000000000000003111122222300066666666666666666666666600000aa0aa444aa000aa4000a44aaaa004444aa0
333ccccc33333333000000000000000000000000000000000003322222330000366666636666666666666666aa000aa0aa000aa000aa0000a0044aa00000aa40
33cccccc333333330000000000000000000000000000000000000333330000003366663336666663666666664aaaaa404aaaaa4000aa00004aaaaa400aaaa400
3ccccccc366336630000000000000000000000000000000000000000000000003336633333666633366666630444440004444400004400000444440004444000
000000000000000000000000000000000000000000000000000000000000000033333333333663333334433333333333bbb4444444403010eee2328888244440
110000000000000000000000000000000000000000000000000000000000000033366633336666333334433333666333bbb4444444400000eee2322882244440
000000000000000000000000000000000000000000000000000000000000000033666663336666333334433336666633bbb444444440b0b0eee2b22222244440
000000000000000000000000000000000000000000000000000000000000000036666663366666633334433336666663bbb33333fff000002222bbb222222220
000000000111110000000000000000000000000000000000000000000000000036666663366666633334433336666663bbb33333fff0d0c0fff2bbb222227220
000000001111111000000000000000000000000000000000000000000000000036666633336666333334333333666663bbb33733fff00000fff2bbb252522220
000000000111110000000000000000000000000000000000000000000000000033666333336666333333433333366633bbb33333fff00000fff2222222222220
000000000000000000000000000000000000000000000000000000000000000033333333333663333333333333333333bbbcccccfff000002222b26332222220
66633333333336660011111110000000001111111100000000000000000000003333333333333333333333333666666311111cccddd00000ddd2225222222220
666663333336666611111111111000001111111111110000000000000000000033333336633333333333333333666633111ccc7cddd00000ddd2222222222220
666666333366666611111111111000001111111111110000000111111111000033333366663333333333333333333333111cccccddd000002222222222222220
36666663366666630011111110000000111111111111000001111111111111003333336666333333333333333333333300000000000000002222222222222220
36666663366666630000000000000000001111111100000011111111111111103333336666333333333333333333333300000000000000002222222222222220
33666666666666330000000000000000000000000000000011111111111111103333336666333333333333333333333300000000000000002222222222222220
33366666666663330000000000000000000000000000000001111111111111003333333663333333336666333333333300000000000000002222222222222220
33333666666333330000000000000000000000000000000000011111111100003333333333333333366666633333333300000000000000000000000000000000
ccc111111ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccccccccccccccccc11ccccccccccaccccccc
cc1eeeeee11cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ee1cccccccccccccccc1ee1ccccccccaaacccccc
cc1eeeeeeee1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ee1cccccccccccccccc1ee1cccccccaaaddccccc
cc1ee2222eee1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ee1cccccccccccccccc1ee1ccccccaadddddcccc
cc1ee11112eee1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ee1cccccccccccccccc1ee1cccccdddddddddccc
cc1ee1ccc12ee1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ee1cccccccccccccccc1ee1ccccddddd9dddddcc
cc1ee1cccc1eee1cc11c1111cccccccc1111c11cccccc1111c11cccccc1111cccccc11c111ccccccccc11111ee1ccccc1111ccccc111ee111cc9ddd9ccdddddc
cc1ee1ccccc1ee1c1ee1eeee11cccc11eeee1ee1ccc11eeee1ee1ccc11eeee11ccc1ee1eee11ccccc11eeee1ee1ccc11eeee11cc1eeeeeeee1cc9d9ccddddd9c
cc1ee1ccccc1ee1c1eeee22eee1cc1eee22eeee1cc1eee22eeee1cc1eeeeeeee1cc1eeeeeeee1ccc1eee22eeee1cc1eee22eee1c1222ee2221ccc9ccddddd9cc
cc1ee1ccccc1ee1c1eee2112ee1cc1ee2112eee1cc1ee2112eee1cc1eeeeeeee1cc1eee222ee1ccc1ee2112eee1cc1ee2112ee1cc111ee111ccccccddddd9ccc
cc1ee1ccccc1ee1c1ee21cc1221c1ee21cc12ee1c1ee21cc12ee1c1eeeeeeeee21c1ee21112ee1c1ee21cc12ee1c1ee21cc12ee1ccc1ee1cccccccdddda9cccc
cc1ee1cccc1ee21c1ee1cccc11cc1ee1cccc1ee1c1ee1cccc1ee1c1eeeeeeee221c1ee1ccc1ee1c1ee1cccc1ee1c1ee1cccc1ee1ccc1ee1ccccccc9daaaacccc
cc1ee1ccc1eee1cc1ee1cccccccc1ee1cccc1ee1c1ee1cccc1ee1c1eeeeeeee221c1ee1ccc1ee1c1ee1cccc1ee1c1ee1cccc1ee1ccc1ee1cccccccc9aaaaaccc
cc1ee1111eee21cc1ee1cccccccc12ee1cc1eee1c12ee1cc1eee1c1eeeeeee2221c1ee1ccc1ee1c12ee1cc1eee1c12ee1cc1ee21ccc1ee1ccccccacc9aaaaacc
cc1eeeeeeee21ccc1ee1ccccccccc1eee11eeee1cc1eee11eeee1cc1eeeee2221cc1ee1ccc1ee1cc1eee11eeee1cc1eee11eee1cccc1ee11ccccaaacc9aaaaac
cc1eeeeee221cccc1ee1ccccccccc122eeee2ee1cc122eeee2ee1cc1eee222221cc1ee1ccc1ee1cc122eeee2ee1cc122eeee221cccc12eee1ccaaaaacaaaaa9c
cc122222211ccccc1221cccccccccc1122221221ccc1122221ee1ccc11222211ccc1221ccc1221ccc1122221221ccc11222211cccccc12221cc9aaaaaaaaa9cc
ccc111111cccccccc11ccccccccccccc1111c11cccccc11111ee1ccccc1111cccccc11ccccc11cccccc1111c11cccccc1111ccccccccc111cccc9aaaaaaa9ccc
ccccccccccccccccccccccccccccccccccccccccccc11cccc1ee1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9aaaaa9cccc
cccccccccccccccccccccccccccccccccccccccccc1ee1cc1ee21c777c777cc77cc77ccccc777c77cc7c7c777c77cc777c7c7c777c777cc77ccccc9aaa9ccccc
cccccccccccccccccccccccccccccccccccccccccc1eee11eee1cc7c7cc7cc7ccc7c7ccccc7c7c7c7c7c7c7ccc7c7cc7cc7c7c7c7c7ccc7cccccccc9a9cccccc
cccccccccccccccccccccccccccccccccccccccccc122eeee221cc777cc7cc7ccc7c7ccccc777c7c7c7c7c77cc7c7cc7cc7c7c77cc77cc777ccccccc9ccccccc
ccccccccccccccccccccccccccccccccccccccccccc11222211ccc7cccc7cc7ccc7c7ccccc7c7c7c7c777c7ccc7c7cc7cc7c7c7c7c7ccccc7ccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccc1111ccccc7ccc777cc77c77cccccc7c7c777cc7cc777c7c7cc7ccc77c7c7c777c77cccccccccccccccc
000000000000000000000000ccccccccccccccccc333333c44466444aa00aaa00aa0aaa0aaa0aa00446666443334433333466433334664333334433334444443
000000000000000000000000cccccccccccccccc3333333340066004a0a00a00a000a0a0a000a0a0c666666c3344443333466433334664333433334344666644
000000000000000000000000cccccccc666666663333333340066004aa000a00a000aa00aa00a0a0666666664446644434466443444664443344443346666664
000000000000000000000000cccccccc666666660000000066666666a0a00a00a000a0a0a000a0a0666666666666666644666644666666664346643446644664
000000000000000000000000cccccccc666666666666666666666666aa00aaa00aa0a0a0aaa0a0a0666666666666666644666644666666664346643446644664
000000000000000000000000ccccc444666666666666666644444444000000000000000000000000666666664446644434466443444664443344443346666664
000000000000000000000000ccccc444666666666666666633333333000000000000000000000000c666666c3344443333466433334664333433334344666643
000000000000000000000000ccccc444666666666666666633444433000000000000000000000000cc6666cc3334433333466433334664333334433334444443
33333333666666633666666633333333333333333333333333333333333333333333333333333333666666663333333366666666333333333366663333333333
33333333666666333366666636633663c333333c3443344334433443666446663344434334344343666666663333333366600666333333333666666333333333
33333333666666333366666666600666cc3333cc444444443444444366600666343343333343343366666666333443336600006633333ccc66666666cccccccc
33333333666663333336666666666666cccccccc4444444434344343666666663334444334344343666666663444444336444463333ccccc66666666cccccccc
33333333666663333336666666666666cccccccc4444444434444443666666663333434334344343666666664443344433333333333ccccc66666666cccccccc
33333333666333333333366666666666cccccccc344444433344443366666666334333433343343366666666433333343433334333cccccc66666666cccccccc
33333333633333333333333636666663cccccccc334444333343343366666666343334333434434366600666333333333444444333ccccc33666666333333333
33333333333333333333333333666633cccccccc333443333333333366666666333333333333333366644666333333334434434433cccc333333333333333333
66666666333333333333333344333344cccccccc3334433333366333333663333334433333333333663333333333333344cccc443333333333cccc3333cccc33
66666666633333333333333643333334cccccccc33344333333663333336633334333343333336636633333336633333cccccccc333333333ccccc3333cccc33
66666666666333333333366633344333cccccccc33333333333663333336633333333333333336633333333336633333cccccccc66344366cccccc3336666663
66666666666663333336666633444433cccccccc44344344334444333336633343333334333333333336633333333333cccccccc66644666ccccc33344444444
66666666666663333336666633444433cccccccc44344344334444333336633343333334336633333336633333333333cccccccc66666666ccccc33344444444
66666666666666333366666633344333cc3333cc33333333333663333336633333333333366663333333333333333663cccccccc66344366ccc3333336666663
66666666666666333366666643333334c333333c33344333333663333336633334333343366663333333336633333663cccccccc333333333333333333cccc33
666666666666666336666666443333443333333333344333333663333336633333344333336633333333336633333333cccccccc333333333333333333cccc33
44444444cccccccc3666666333333333366666633444444333333366333663333333333333366333cc3333ccc33333cc33333333333333333333333333366666
44444444cccccccc3666666366333366366666633344443333333366333663333333333333366333ccc33ccc33333ccc36633663333333333333333333333666
444444443cc33ccc33666633666336663366663333344333333333333336633333333333333663333cccccc3333cccc336633663663333333333333333333366
44444444333333cc333663336663366633666633333333333336633333366666666666666666633333cccc3333cccc3333333333663334444444444444333336
44444444333333cc333333336663366633666633333333333336633333366666666666666666633333cccc3333cccc3333333333333344444444444444433336
444444443cc33ccc33333333666336663366663333333333333333333333333333333333333333333cccccc33cccc33343366333333444333333333334443333
44444444cccccccc3366663366333366366666633333333366333333333333333333333333333333ccc33cccccc3333343366333333443333333333333444333
44444444cccccccc3666666333333333366666633333333366333333333333333333333333333333cc3333cccc33333c44333333333443333333333333344333
cccccccccccccccc33333333333333333366663333333333c344443cccccccccc333333ccc33333cccccc6664433434433cccc33333443333334433333344333
cccccccccccccccc6633336633333333336666333333333333333343cccccccc33333333ccc33333ccccc666c444344c33cccc33333443333334433333344333
cccccccc3ccccccc6666666666333366333663336334433634443334cc6666cc333cc3333cccc333ccccc666cc4444cc33cccc33333444333334433333444333
cccccccc33cccccc6666666666666666333663336664466643344334cc6446cc33cccc3333cccc33ccccc666ccc44ccc33cccc33333344443334433344443333
cccccccc33cccccc6666666666666666333663336664466643344334cc6446cc33cccc3333cccc33ccccc666ccc33ccc33cccc33366334443334433344433363
cccccccc3ccccccc6666666666333366333663336334433643334443cc6666cc333cc333333cccc3ccccc666ccc33ccc33cccc33666633333334433333333666
cccccccccccccccc6633336633333333336666333333333334333333cccccccc3333333333333cccccccc666ccc33ccc33cccc33666633333334433333333363
cccccccccccccccc33333333333333333366663333333333c344443cccccccccc333333cc33333ccccccc666cc3333cc33cccc33366333333334433333333333
33333333666666666666666643443333ccccc44444cccccc33333343333334334333333433333333366333333333333333444433633333363366663333333333
33333333666666666666666634443333cccc4444444ccccc34334333333333333443344334333343366333333343443334444443633333363666666333333333
33666633666666666666666643443333ccc4444444444ccc334433333433333334444443333443333333333334cccc4344444444633333366666666636333363
66666666666666666666666634443434cc444433334444cc33443333333343343344443333444433333333333cccccc444444444663333666666666636633663
66666666666666666666666643443344c4444333333444cc34334333333334433344443333444433333333334cccccc344444444366666636666666636633663
33666633333333333336666634443333c44443333334444c333333343343344334444443333443333333333334cccc4344444444333333336660066636633333
33333333333333333336666643443333444433333333444433333433333343343443344334333343333366333334343334444443333333333663366333333336
33333333336336336336666634443333444333333333344433433333433333334333333433333333333366333333333333444433333333333333333333333333
333333333333333333366666366666634443333333334444333344333336633333366333cccccccccccccccc333333333334433333333333cc6666cc33366333
333333333333333333366666366666634443333363364444333344433336633333366333cccccccccc3443cc333663333334433333333333c666666c33366333
33333333336336336336666633666633c444333360064444333344433333333333333333cc4444ccc334433c3336633333344333663443666666666633366333
33444333333333333336666633300333cc4444336006444c443344336633336633333333cc4664ccc443344c3333333333344333666446666666666633666633
44444444333333333336666633300333cc4444446666444c434344336633336633333333cc4664ccc443344c3333333333344333666446666666666633666633
44444444336336336336666633666633ccc44444444444cc333344433333333333333333cc4444ccc334433c3663366333344333663443666666666633666633
444ccc44333333333336666636666663ccccc44444444ccc333344433336633333366333cccccccccc3443cc36633663c334433c33333333c660066c33333333
4cccccc4333333333336666636666663ccccccc4444ccccc333344333336633333666633cccccccccccccccc33333333cc3333cc33333333cc6446cc33333333
063666663363363364366666333333443366663333633633cc3333cc33333333366666633333333334444443336666333344443333366333333333334c4334c4
333666663333333333366666333666343666666336600663ccc33ccc33333333666666663333333344cccc4433666633344cc44366666666333333634c4334c4
333666663333333333366666336666636666666666600666ccc33ccc3333333666666666633333334cccccc43336633366cccc6666666666333333334cc44cc4
666666666666666666666666366666636666666666666666ccc33ccc3333336666600666663333334cccccc433333333666cc666666666663663333334cccc43
666666666666666666666666366666636666666666666666ccc33ccc3333366666600666666333334cccccc43333333366666666666666663663333333444433
666666666666666666666666366666336666666466600666ccc33ccc3333333333333333333333334cccccc43336633366666666666666663333363333333343
666666666666666666666666336663333666664436600663ccc33ccc33333333333333333333333344cccc4433666633666666666666666633333333333334c4
666666666666666666666666333333334466644433633633cc3333cc333333333333333333333333344444433366663366666666366336633333333333333343
444333333333344444cccc44333333334466664433666633ccccccc3cccccccccc3333cc33666333666666664433333333333333c344443cdd00dd00aa00aa00
444333333333344444444444333333334666666436666663cccccc33ccccccccccc33ccc3666663366666666436663336633333333333343d00dd00da00aa00a
c44433333333444c44444444333333336666666666666666ccc333333cccccc3cccccccc6666666c666666663666663366663366344cc33400dd00dd00aa00aa
c44433333333444c33444433333333336666666630066003cc33333333cccc33cccccccc6666666c66666666366666636666666643c00c340dd00dd00aa00aa0
c44433333333444c33333333334444336666666630066003cc33333333cccc33cccccccc6666666c66666666366666636666666643c00c34dd00dd00aa00aa00
c44433333333444c33333333444444446660066666666666ccc333333cccccc3cccccccc366666cc66cccc663366666366666666433cc443d00dd00da00aa00a
444333333333344433333333444444443660066336666663cccccc33ccccccccccc33ccc33666cc3666cc66633366633336666333433333300dd00dd00aa00aa
44433333333334443333333344cccc443333333333666633ccccccc3cccccccccc3333cc33cccc33666cc6663333333333333333c344443c0dd00dd00aa00aa0
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
19b319b319c019c0b3b21a8ab2b2908a90fc1ab21afc19fe0a2a1afeb9b8abfeb0b0b0b0b0b0b0b319ce19a8b0b0b0b0b0b0b0b0b0a81a19fc191a9090a8b0007874757600ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff000000007900000000007770717200fefefefefefefe77fefefefefefe
b4b6b485b4c6eb803a8080ef8085a489a2801180b4b6b4fe80b6d3feabceb9feb0fdb0b6b0fdb08019c61980b0939393b0939393b0981980099f3b829098970c0101038b038006060f000900000000000103043c0c0519140a0a00000a040100070000ff0000000505d80203000c0205008b0303838c01838307140707000000
19c9199d19801ab21afc1938fcfc1ab21afc90391a391afe19b31afeb9b8abfeb0b0d9dad9b0b08019c81980b087b093b093b087b0aeb48d1919198090ae970d00010106868206140f000900000000000000003e0c0519140a0a00080a040101070a00ff00000019058809010c0d17074e858080008c01868601030408000000
19c7c7c7c9c8b49a09c9ebee8080ee3aeb80a28080091afefefefefefefefefeb0b6dafddab6b08019c71980be98b0939393b0b0b0981a9e19fd1999b498970e030206860580061e0f000b000000000002050629140528140a0a19080a040100070500ff0000000a038807010e0e0606008b0304840c8c06060103040b000000
19c719c719ce19091afc1aed1aa390909039829091801afe19ce19fe19dd19feb0b0d9dad9b0b08019831980a0aeb0b0b0b0b0b0b0ae1a8019b519801aae970f02010689048006060f000900000000000203043c0c0519140a0a00000a040100070000ff0000000107550c01000f0606138605858009890606100d1200000000
19c9c7c619c8b4cba2db3bee3a09a2113b3a3a80809290fec6c6b4fec7c7c9feb0fdb0b6b0fdb080b4c9b48080808080b0b0b0b0b098a486be98b4cbb498971b04020307870c320a0101140000000003010008370c0519140a0a00000a040100070000ff0000000207bb0c01001b070740858080008908868600000000000000
19c6191919c71ab2908afa8a90a39090909090a31a9090fe19c719fe19c719feb0b0b0b0b0b0b080199d191919191980b0b0b0b0b0ae90ec1ab31a871aae971c01010383010003060f001401000000000103043c0c0519140a0a00000a040100070000ff0000001a05880201001c0707008b0304840c8c060601030408000000
19c7c9c7c7c9c3aeaebfbccd80bdaeaf90818080c7cbb4fefefefefefefefefe19c7c78080808080b485b4c6c719b480808080808080be98be98be98be98971d03010103830206e20f00090000000004010f023a1e005a140a0a00000a040103070000ff0000000503580b01151d0707008b0303830c8c060601030408000000
19c6cbc7198e19ee0928bc801afc19bea4802b800ac6b4fedfd1d2fe19ce19fe7d7b7d7b7d7b7d8019c719c719b31ab31ab21ab3198080ae73b0b0aea0ae971e0401040181000d050f000900000000010103043c050528140a0aec140a040100070a00ff0000000100880201001e18024e038383010181050507000000000000
19c7c6c9c6c6b408808d9ecb80adae95d68080cf808019fed1d1d2fed0f3d0fe7c86987f7e7e7c80b419c7190986b408809b8086b4808080b0b0b098be98971f0a03058e0e06051e0f000d01000102020107073c1405015a0a0a140a0c040200070a00ff00000b0506880000001f0707008b0304840c8c060601030408000000
19c719ce19c719b319bc2b3a0a2a1abea4803080288019fee1e1e0feb094b0fe7db57d987d987d8019c619b319b519831aec1aae19b31aae747574aea0ae970b1404100f8f04060e0f000f000301000004070a3a14051414282800000a040100040000ff0000001c01000000000b0707008b0304840c8c060601030408000000
19c6c6c819c6b4db8d9e808c80b6a4beb4eedb803a30b4fefefefefefefefefe7c987c7e7c987c8019c719fd9698b4808080b4989685b498be98be98be98970c0a030182020000000f000d01000000000000003c0c0519140a0a00000a040100070000ff0000001c02881101140c03060b03838b038c0183830c080301000000
191919c719c7198d9eca19a519b31abe19c0c0b38180b4fefefefefefefefefe7db57d987d7e7d801983191919b31980808019b31a871aae908090aea0ae970d0201020f8f88000c0f0009000a00000001001034320514141e1400000a040100070000ff0000000600880201000d0505008b030f8f0c8c060618070000000000
19c6c6c719c7c39faeaeae95aeaeaebfb499ee80ee8019fefefefefefefefefe7cfd7c987cc97c808080808080808080808080808080808080808080be98970e0502068d82880c1901020b0000000005020c033a1e0002780a0a000a0a040103071e00ff0000001005881501170e06062f0d8d02820c8c060605060000000000
19c91983198d199e198e1980198028801a8031d809eeb4fefefefefefefefefe7d7b7d877d7b7d9819dd199818a8189890b39087a0ae908090ae9080a0ae970f0202040b8b0305060f000b01000000060100063c010519140a0a00000a040100070000ff0000001104880b01000f07072788890e0f8c0c878700000000000000
19c6198d8f9ee4f3d0f3d0d0f3f3d0aca429e7e8e9cfa4fefefefefefefefefe9798be98be989898b485b49897859798a485a498be98be8080808080be98971b030303048480030b0f000d01000000000207073c140519140a0a00000a040100070003ff0000001403880201001b0504230f868b030c8c0404100e0f00000000
7abb7a9c7abbb0b0b094b0b0b0b0b0d49080c1c1c1c1c2fefefefefefefefefe7d7b7d7b7d7b7d9819c7199818831898908790aea0ae90ae90ae90aea0ae971c020101868480062300010900000000050103043c0a141e780a0a14ec0a040100070a00ff00000016058816011100000000000000000000000000000000000000
f7b8aaf7aab8a1b0f69810b0c4f4c5b0bad1d1d1d1d1d2fefefefefefefefefe7c7d767d7c7d7c989898989897c89798be98be98be98be98be98be98be98971d0a030a0989000a140f000d00020100000308063a10005a140a0a111e0a040103071003ff0000001807880201000c0205008b0303838c01838307000000000000
f7abb9b8abb9b1b0b084b0c4fb09e3c5bad1dfd1dfd1d2fefefefefefefefefe7c7d7c7d7c7c7da019a019ae188318aea0aea0aea0aea0aea0aea0aea0ae971e0201030d8d82003c0f0009000000000001000629010510140a0a08140a040100070600ff0000001206881701180d17074e858080008c01868601030408000000
f7abab8eb9b9b1c4f2f4f2fb098809f1bad1d1b6d1d1d2fefefefefefefefefe7c7d7c7d7b7d7c98be98be98be98be98be98be98be98be98be98be98be98971f00030a880282060b19020d00000001000104073c030508190a0a00000a040200070000ff0000001006000000000e03064b03838b038c01838300000000000000
f7b9b9b8ababb1f00980288028092bf1bad1dfd1dfd1d2fefefefefefefefefe7d7b7d7b7d7b7daea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0ae97ff0201010a090e0a1801011400000000050100013e0c001914001ef6000a040103070501ff0000000609880b010b0f18066505858000098984840f140000000000
f7ababb6b9b9b1d4d0f3d0d0f3d0d0d5bad1d1d1d1d1d2fefefefefefefefefe9798be98be98be98be98be98be98be98be98be98be98be98be98be98be9897ff0a030a02820c3278010114000801020303000837281e143c0a0a19000a040100072900ff0000001402880b01161b070740858080008908868600000000000000
b0f8f8f8f8f8b0b0b0b0b0b0b0b0b0b0bae1e1e1e1e1e2fefefefefefefefefe97aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0ae97ff0a040a8b030200780f000f0114010800010a123a64000c14000000000a040103070000ff0000000408880a010d1c070756018188020c8c868600000000000000
fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe9798be98be98be98be98be98be98be98be98be98be98be98be98be98be9897ff050301070688001e0f000d020a0000000446083478001914320500000a040103070003ff0000001505000000001d070717068687870c0c8b8b00000000000000
fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefe97aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0aea0ae97ff02010308888208040f000900000000000104022905050514000a00000a040100070000ff0000001607880206001e18024e038383010181050507000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000160888180c001f0707008b0304840c8c060601030408000000
000000004000000000000000000013000000000000000000000000000040000013131300000000000013000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0707008b0304840c8c060601030408000000
04171a050610121012110214011401160419051d1c0911011415100c0e020c1801140a0c101107071c040e160616000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeff0000000000000000000c14016403838b038c0183830c080301000000
030405030500000202010201060009000900000201070605050506000004020701030a0408080a00040704070808000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeff0000000000000000000d0707008b030f8f0c8c060601030408000000
1704051a0c000a010906140214010e0119041d051111091401101211160c18020e140c11070a101c070e16041606000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeff0000000000000000000e11076f8d0102820c8c060606000000000000
040303050000000a090501020006000900090200000607050501010100020704020704080a0a0804000407070808000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeff0000000000000000000f21016788890e0f8c0a878700000000000000
c83838c88f8888888888c84848c8b8b8c8b8b83888c8a8c8388888b8c838c8381818cc2246db3ed84838c838c8c8000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeff0000000000000000001b110969860583010c8c8484060f0000000000
__sfx__
010605060c1700c1600c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c1000c100001000010000100001000010000100001000010000100001000c100
01080f1518150181501815018151181411814118141181311813118131181211812118120181201812018120181201812018120181201812018120181000c1000c1000c1000c1000c1000c1000c1000c1000c100
010700001715018150181501815118141181411814118131181311813118121181211812118121181201812018120181201812018120181200010000100001000010000100001000010000100001000010000100
010800001835018341183421834218342183421834218342183421834218342183421834218342183421834500000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000c17500175071750c1750c17500175071750c1750c17500175071750c1750c17500175071750c175081750c1750f1750c1750f175141750f175141750a1750e17511175161750e17511175161751a175
010d0000257702572125731257412575125761257712577020770207212073120741257702572125731257712c7712c7212c7312c7402c7502c7602c7702c7702a7702a7312a7712a77028770287312877128770
011a000018575187351872518545187251871518535137251f5751f7251d5751d7251c5751c7251a5751a72500005000050000500005000050000500005000050000500005000000000000000000000000000000
010f10201515509555095551815509555095551c1550955521155095550955524155095550955528155095551515509555095551915509555095551c155095552115509555095552515509555095552815509555
011200001087023225282251087310873108731087323225282251087310873108730e87021225262250e8730e8730e8730e87321225262250e8730e8730e8730c8701f225242250c8730c8730c8730c8731f225
011200001c57020555235551757023555205551c5702055523555235702355520555215701e5552155520570215551e5551c5701e555215551e570215551e555185701c5551f5551c5701f5551c5551f5701c555
011200001f555245701f5551c555235701c5551e555215701e5551c5552057021570205701e570205701e5701c9401c9401550014940179401c94023a4023a40277002c740219402094021940255002094023500
01120000242250c8730c8730c87310870232352a2352f2351087310873158703452514870345251287033525108702f225342251087010873108730d87023740287400d8700d8730d87309870312253422509870
011200001c940205001c9401c940205001e9401e940215001c9401c9402050014940179401c94023a4023a402a7002c7402194023940259402170027940237002894025700279402794023700239402394020700
01120000098700a8700b87033225362250b8730b8730b873108702f225342251087310873108730d870287402a7400d8730d8730d87309870312253422509873098730d8700b87033225362250b8700b87308870
0112000025940259402570031740279402894027940279401c7002a9402a940237002da402da4028005337402c9402a94028940289402370023940239402150025940259401c7002874027940289402794023700
0112000009870287402d7400987004870098700b8702a7402f74033740068700b8700c8702a740307400c87030740337403474033740317400d8700b870088700987025740277400987004870098700b87027005
0112000028940207002a940217002d9402d9402c7002d7402c9402d9402f9402f830318403385034850368502ca502a950289502395023950239502c7502a750287502f7502d7502c7502095021950239502aa50
011200000b8702c0050b8702a0050d8702a7402c7400d870098700d8700f8701e54020540245402354021540148702170020700148701587014870108702f0052c00510870128701087010873128701487015870
01120000289502395020950170002195019000239501b0002195021950219502d740209501e9502095020950147001c9501570020a501e9501e9501e950237502575028750277502775025750257502375023750
0112000014870108701087310000128701200014870140000d870287402a7400d8700b8700d8700b8702c7402a7400d8700b870108700f8701e750207500f870108700f8700b8702c0002a0000b8700d8700b870
011200002ca502a950289502395023950239502c7502a750287502f7502d7502c7502095021950239502aa5028950239502095028740219502a740239502c7402595025950259503173027950289502ca501e700
01120000148702f0052c00514870158701487010870280052c005108701287010870108731287014870158701487010870108732074012870217401487023740158702d7302f7301587017870198701c87004000
011200002d950107002c950127002a9502a9502a95017435194351b4351c3551e4001e35520400203552140025b5025b5025b5025b5023b5021b501cb501cb501cb501cb501cb501cb501bb501bb501bb501bb50
011200001e870210051c870230051b8702500519870270051787030005203300c500213300c500233300c5000144504445094450d44509445104450144504445094450d445094451044503445064450b4450f445
0112000017b501bb501eb5010b001bb5010b001eb5010b0024b5024b5024b5010b0024b5025b5027b5010b0025b5010b0024b5010b0025b5025b5025b5010b0025b5027b5028b5010b0027b5010b0025b5010b00
011200000b4451244503445064450b4450f4450b445124450044503445084450c445084450f4450044503445084450c445084450f4450144504445084450d445084450d44514445104450d445104450d44508445
0112000028b5028b5028b5028b5028b5028b5025b5025b5025b5025b5025b5025b5027b5027b5027b5027b5027b5027b502ab502ab502ab502ab502ab502ab5028b5028b5028b501087310873108731087310870
01120000197501975015750157501975019750217502175020750207501e7501e7501b7501b75017750177501b7501b7502375023750217502175020750207502875028750237502375021750217502075020750
010900000400004000108731087010873108701087310870108731087010870108701080010800108731087010873108701087310870108731087010870108701080010800108731087010873108701087310870
010900001c7501c7501c7501c7501775017750177501775015750157501575015750147501475014750147501275012750127501275010750107501075010750207502075020750207501e7501e7501e7501e750
010900000c6531c1001c1001d1001c100181001810018100181001a10018100181001a1001c1001d1001c1001810018100001001a100001001c10000100001000010000100001000010000100001000010000000
010d00202532525325203252532519335193351c335193352534525345203452534519335193351c335193352532525325213252532519335193351c335193352534525345213452534519335193351c33519335
010d000023325233251e3252332517335173351b3351733523345233451e3452334517335173351b335173352432524325203252432518335183351b3351833524345203451b3451834514355183552035524355
016800200cd400cd400cd400cd000cd430cd400cd400cd400cd430cd400cd400cd000cd430cd400cd4011d430cd400cd400cd400cd400cd430cd400cd4007d430cd400cd400cd400cd4011d4011d4011d4017d40
010d00002a7702a7212a7312a7412a7512a7612877028721287312874128751287612777027721277312777124770247312477124770247722477224772247722777127770277702777027772277722777227772
010d00200d46001460014650d46000400014000d46001460014650d46000400014000d4600d460014600d46501460014600d4650d460044000140001460014600d460014600d460014000d460014600146000400
0134002001e1004e6008e600de6001e1004e4008e400de4001e1004e6008e600de6001e1004e4008e400fe4001e1004e6008e600de6001e1004e4008e400de4001e1004e6008e600de6001e1004e4010e400fe40
01d00000197550c700187550c700177550c700167550c700157550c7001475515705137550c700147550c755197551b7551c75520755217551e75520755187552575421754207541e75423754257542775424754
0168000019c6019c6015c6017c6319c6019c6017c6018c6319c6019c6015c6017c6319c6019c6019c6019c6015c6014c6019c6018c6015c6014c600dc600fc6015c6014c6019c601bc601cc6019c6021c6020c60
01f0000010f6015f6017f6310f6010f6315f6017f6310f6015f6010f6315f6010f6315f6012f6317f6317f6319f6017f6315f6314f6319f6017f6315f6314f631cf601af6318f6317f631cf601af6318f6317f63
010700000c6533c53430531315242b5211b5001b5001b5001e5001e5001e5001e5000450004000040000400004000040000400004000040000400004000040000400004000040000400004000000000000000000
010a00000c6353c625000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00200d4450d425084450d4450d425084450842509445094250f4551045510425094550942510455104250d4550d425084550d4550d425084550842509455094250f445104451042512445124250c4450c425
0134002000000085650d565145650000000000000000000000000085650d5651456512565105650f5650c56500000085650d565145650000000000000000000000000085650d565145651256515565145650c565
011e00200d4450d425084450d4450d425084450842509445094250f4551045510425094550942510455104250d4550d425084550d4550d425084550842509455094250f445104451042512445124250c4450c425
011a000014560145411454514565155601556514565125601256510560105650f5600f56512560125411254510560105411054512565105650d56504500145601454114545125601256510560105650f5600f565
011a000009560095650d5600d56514560145651056512560125411254510560105650f5600f5650c5600c5650d5650d5650d565045000d565045000b5650d56504500045001c5340450015534045001c53404500
010600002f56538555045000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000450004500045000450004000040000400004000
010a00003453505500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500
01d0000017e501ce5020e501ce5019e501ce5021e501ce5018e501ce5021e5023e5020e501ce501be501ee5017e501ce5020e501ce5021e5028e5025e5021e5020e501ce501be501ee501ce5017e501ce501ce50
010a00001867300655306310020000200002000020000200002000020000200002000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001867500000273651f36523365273652e36503500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350003500035000350000000
01080000006733c6313063124631186310c6210061100615007000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500003c625363553c3150730507305073050530507305053050730508305093050530507305093050b30507305073050430507305003050030500305003050030500305003050030500305003050030500000
013000202c51523515285152d51523515285152f515235152851520515235152a51520515235152c515205152d51521515255152c515215152551528515215152a51523515275152c51523515275152d51523515
01090000304342e4742c4542a4442841438404384040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b4040b404
010500002d33534335043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305
010a00002835523355283552a3552f35523315283152a3152f3150430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504305043050430504300
01080000006440c641246710c64100645000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01f0000019574155741857419574195741b5741c574195741557414574125741157415574195741857414574195741b574195741857416574225741e5741d5741957417574155741457419574175741557418574
01030000006200c6211862124621306213c6210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01d0000008e500be5010e500be5009e500de5010e500de5009e500ce5010e5012e5017e5014e5012e5018e5008e500be5010e500be5009e500ce5010e5012e5017e5014e5015e500fe5014e5015e5014e5012e50
010500003851436511365143151134514345112f5142c5111b5001b5001b5001e5001e5001e5001e5000450004000040000400004000040000400004000040000400004000040000400004000040000400004000
010600001c44421444234442844404404044040440404404044040440404404044040440404404044040440404404044040440404404044040440404404044040440404404044040440404404044040440404404
__music__
01 09 08 43 44
00 0a 0b 43 44
00 0c 0d 43 44
00 0e 0f 43 44
00 10 11 43 44
00 12 13 43 44
00 14 15 43 44
00 16 17 43 44
00 18 19 43 44
00 1a 1b 43 44
02 1c 1d 43 44
03 25 24 43 44
02 41 42 43 44
00 41 42 43 44
01 2a 42 43 44
01 2a 2b 43 44
00 2a 2d 43 44
02 2a 2e 43 44
02 41 42 43 44
03 26 21 43 44
03 41 42 43 44
03 41 42 43 44
03 31 3d 43 44
03 36 42 43 44
01 1f 42 43 44
00 1f 23 43 44
00 1f 23 43 44
00 1f 05 43 44
00 20 22 43 44
00 1f 23 43 44
00 20 23 43 44
00 1f 05 43 44
00 20 23 43 44
00 05 1f 43 44
02 22 23 43 44
03 27 3b 43 44
03 25 2a 43 44
03 26 2a 43 44
03 21 2a 43 44
03 3b 36 43 44
03 26 24 43 44
03 27 2c 43 44
00 41 42 43 44
01 2b 24 43 44
00 41 42 43 44
00 2d 24 43 44
02 2e 24 43 44
03 25 2b 43 44
00 25 21 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
