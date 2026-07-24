pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--quest for the book of truth
--by mush
xs={x=0,y=0,s=0}
function xs:new(s)
self.__index=self
return setmetatable(s or {},self)
end
function xs:dw(ax,ay)
if not self.xi then
if self.pal then
set_pal(self.pal)
end
spr(self.s,ax+self.x,ay+self.y,1,1,self.f,self.vf)
r_p()
end
if self.fk then
self.xi=not self.xi
end
end
function nss(num)
return {xs:new({s=num})}
end
function nps(num,x,y)
return xs:new({s=num,x=x,y=y})
end
function ns(num)
return nps(num,0,0)
end
function set_pal(p)
for i=0,15 do
pal(i,p[i+1])
end
end
ac={x=0,y=0,w=7,h=7,sp={},
vel=0,dir=0,max_vel=3,acc=0}
function ac:new(a)
self.__index=self
return setmetatable(a or {},self)
end
function ac:dw()
for s in all(self.sp) do
s:dw(self.x,self.y)
end
end
function ac:up()
self.dir=self.dir%1
self.vel+=self.acc
self.vel=clamp(self.vel,0,self.max_vel)
self:move_x()
self:move_y()
end
function ac:clip_out()
if self:is_in_wall() and tr_z==0 then
for i=1,8 do
if (wrpt(self.x+i,self.y,self)) return
if (wrpt(self.x-i,self.y,self)) return
if (wrpt(self.x,self.y+i,self)) return
if (wrpt(self.x,self.y-i,self)) return
end
end
end
function ac:p_a(a)
self.dir=atan2(a.x-self.x,a.y-self.y)
end
function ac:dist_to(a)
local xd,yd=abs(self.x-a.x),abs(self.y-a.y)
return sqrt(xd*xd+yd*yd)
end
function ac:move_x()
self.x+=cos(self.dir)*self.vel
if self:is_in_wall() then
self.x=on8(self.x+4)
return false
end
return true
end
function ac:move_y()
self.y+=sin(self.dir)*self.vel
if self:is_in_wall() then
self.y=on8(self.y+4)
return false
end
return true
end
function ac:is_in_wall()
return is_solid(self.x,self.y)
or is_solid(self.x+self.w+0.8,self.y)
or is_solid(self.x,self.y+self.h+0.8)
or is_solid(self.x+self.w+0.8,self.y+self.h+0.8)
end
function ac:iaf()
return iaf(self.x,self.y)
and iaf(self.x+self.w+0.8,self.y)
and iaf(self.x,self.y+self.h+0.8)
and iaf(self.x+self.w+0.8,self.y+self.h+0.8)
end
function ac:kill_outside_room()
if self.x<cam_x-8 or self.y<cam_y-8 or self.x>cam_x+128 or self.y>cam_y+128 then
self.dead=true
end
end
function ac:hit(wp,dam)
end
function ac:fall()
if (tr_x!=0 or tr_y!=0) return
add(acs,o_f:new({x=self.x,y=self.y+2}))
self.dead=true
sfx(16)
end
function ac:is_on_hole()
return mget((self.x+4)/8,(self.y+4)/8)==206
end
function ac:be_plr_sword()
self.x,self.y=plr.x+self.dist*cos(self.dir),plr.y+self.dist*sin(self.dir)
end
function ac:swing()
self.rel_dir=(self.rel_dir+self.move_spd)%1
self.dir=(plr.sdir+self.rel_dir)%1
self.l-=1
end
function ac:inta(a)
for i in all(self.sp) do
for j in all (a.sp) do
if sp_intersect(i.s,j.s,i.x+self.x,j.x+a.x,i.y+self.y,j.y+a.y,i.f,j.f,i.vf,j.vf) then
return true
end
end
end
return false
end
function sp_overlap(ax,bx,ay,by)
if ax+8<bx then return false end
if bx+8<ax then return false end
if ay+8<by then return false end
if by+8<ay then return false end
return true
end
function sp_intersect(as,bs,ax,bx,ay,by,af,bf,avf,bvf)
if not sp_overlap(ax,bx,ay,by) then return false end
rectfill(0,0,16,8,0)
spr(as,0,0,1,1,af,avf)
spr(bs,8,0,1,1,bf,avf)
x_dif=bx-ax
y_dif=by-ay
for x=max(0,x_dif),min(7,7+x_dif) do
for y=max(0,y_dif),min(7,7+y_dif) do
a_pix=pget(x,y)
b_pix=pget(8+x-x_dif,y-y_dif)
if a_pix!=0 and b_pix!=0 then
return true
end
end
end
return false
end
exn=ac:new({size=0,col=7,fk=true})
function exn:up()
self.size+=0.2
if self.size>4 then
self.dead=true
end
end
function exn:dw()
circfill(self.x,self.y,self.size,self.col)
end
bomb=ac:new({time=120,s1=44,s2=43})
function bomb:st()
self.sp=nss(42)
self.x=plr.x+6*cos(plr.dir)
self.y=plr.y+6*sin(plr.dir)
end
function bomb:up()
self.time-=1
if self.time<30 then
if (self.time%6==0) self:shu()
elseif self.time<60 then
if (self.time%10==0) self:shu()
end
if self.time<=0 then
self:ex()
elseif self:is_on_hole() and self.time<110 then
self:fall()
end
end
function bomb:shu()
local s=self.sp[1]
if s.s==self.s1 then
s.s=self.s2
else
s.s=self.s1
end
end
function bomb:ex()
self:boom()
for a in all(acs) do
if a.x>=self.x-10 and a.x<self.x+18 and a.y>=self.y-10 and a.y<self.y+18 then
a:hit(self,10)
end
end
sfx(7)
self.dead=true
bomb_destroy(self.x,self.y)
end
function bomb:boom()
for i=0,25 do
add_ac(
exn:new({x=self.x+rnd(15)-4,y=self.y+rnd(15)-4,
size=rnd(3),col=6+rnd(2)})
)
end
end
telebomb=bomb:new({s1=46,s2=47})
function telebomb:st()
bomb.st(self)
self.sp=nss(45)
self:clip_out()
end
function telebomb:ex()
self:boom()
wrpt(self.x,self.y)
sfx(6)
self.dead=true
end
arrow=ac:new({l=-1,xs_m=0})
function arrow:up()
if self.s==nil then
local mod=self.xs_m
if self.dir==0 then
self.sp=ns(36+mod)
self.h=2
elseif self.dir==0.25 then
self.sp=ns(37+mod)
self.w=2
elseif self.dir==0.5 then
self.sp=ns(36+mod)
self.sp.f=true
self.h=2
elseif self.dir==0.75 then
self.sp=ns(37+mod)
self.sp.vf=true
self.w=2
else
self.sp=xs:new()
end
self.sp={self.sp}
end
if self.l>0 then
self.l-=1
if self.l<30 then
self.sp.xi=self.l%2==0
end
if self.l==0 then
self.dead=true
end
end
local move_sp=2
if self.gng then
if self.dir==0 then
self.x+=move_sp
elseif self.dir==0.25 then
self.y-=move_sp
elseif self.dir==0.5 then
self.x-=move_sp
elseif self.dir==0.75 then
self.y+=move_sp
end
if not self:iaf() then
self:hit_wall()
end
self:h_e()
end
self:kill_outside_room()
end
function arrow:hit_wall()
self.gng,self.l=false,120
self:gw()
end
function arrow:h_e()
for a in all(acs) do
if a.is_en and self:inta(a) then
a:hit(self,2)
self.dead=true
end
end
end
function arrow:gw()
if self.dir==0 then
self.x=on8(self.x)+1
elseif self.dir==0.25 then
self.y=on8(self.y+4)-3
elseif self.dir==0.5 then
self.x=on8(self.x+4)-1
elseif self.dir==0.75 then
self.y=on8(self.y)
end
end
b_a=arrow:new({xs_m=2})
function b_a:hit_wall()
arrow.hit_wall(self)
self:boom()
end
function b_a:boom()
self.dead=true
local b=bomb:new({x=self.x,y=self.y})
b.sp=nss(42)
b.time=0
add_ac(b)
end
function b_a:h_e()
for a in all(acs) do
if a.is_en and self:inta(a) then
self:boom()
end
end
end
t_a=arrow:new({xs_m=4})
function t_a:hit_wall()
self.gng=false
self:gw()
if self.dir==0 or self.dir==0.5 then
self.dead=wrpt(self.x,self.y-3)
else
self.dead=wrpt(self.x-2,self.y)
end
if (self.dead) sfx(6)
arrow.hit_wall(self)
end
function t_a:h_e()
end
en=ac:new({hit_t=0,is_en=true,hp=1})
function en:up()
ac.up(self)
self.hit_t=max(self.hit_t-1,0)
for i in all(self.sp) do
i.fk=self.hit_t>0
if not i.fk then
i.xi=false
end
end
if self.hit_t==0 and self.hp<=0 then
self.dead=true
if rnd(100)<=25 then
local heart=heart:new({x=self.x,y=self.y})
add_ac(heart)
end
end
self.x,self.y=clamp(self.x,0,120),clamp(self.y,0,120)
if self:is_on_hole() then
self:fall()
end
end
function en:st()
for s in all(self.sp) do
if self.dif==2 then
s.pal=opal
elseif self.dif==3 then
s.pal=gpal
end
end
self.hp=self.dif*2
end
function en:hit(wp,dam)
if self.hit_t>0 then return end
self.hp-=dam
if self.hp<=0 then
self:ex()
else
sfx(4)
self:p_a(wp)
self.dir+=0.5
self.vel,self.acc,self.hit_t=1.5,-0.1,11
end
end
function ac:ex()
for i=0,8 do
add_ac(
exn:new({x=self.x+rnd(7),y=self.y+rnd(7),
size=-rnd(5),col=6+rnd(2)})
)
end
self.hit_t=20
sfx(3)
self.vel,self.acc=0,0
end
function en:cmn()
return self.hit_t==0
end
sl=en:new({dam=3,hp=3,h=7,la_t=0,la_sp=0})
function sl:st()
self.sp=nss(64)
en.st(self)
end
function sl:up()
if self:cmn() then
if self.vel>0 then
self.vel=max(0,self.vel-0.4)
else
self:p_a(plr)
self.la_t+=self.la_sp
self.la_sp+=0.01
self.sp[1].s=64+(self.la_t%10)/5
if self.la_t>=100 then
self.vel,self.la_t,self.la_sp,self.sp[1].s=5,self.dif*10,0,65
end
end
end
self.sp[1].y=-abs(self.vel)
en.up(self)
end
gob=en:new({dam=3,hp=3,h=7,c=0})
function gob:st()
self.sp,self.dir,self.an,self.an_cg={ns(84),nps(83,0,-3)},self:rnd_dir(),rnd(0.5)-0.25,0.01
en.st(self)
end
function gob:rnd_dir()
return flr(rnd(4))/4
end
function gob:up()
if self:cmn() then
d=self:dist_to(plr)
if d<48 and d>8 then
self:p_a(plr)
self.dir+=self.an
self.an+=self.an_cg
if (self.an>0.25 or self.an<-0.25) self.an_cg*=-1
else
self.dir+=self.an_cg
end
self.sp[2].s=80+((self.dir+0.125)%1)*4
self.vel=self.dif/5
self.c+=self.vel
if self.c>4 then
local s=self.sp[1].s
self.sp[1].s=169 - s
if s==84 then
self.sp[1].f=not self.sp[1].f
end
self.c=0
end
end
en.up(self)
end
ga=ac:new({sp={ns(66),nps(67,8,0),nps(68,4,-8)}})
function ga:up()
if plr.y<self.y+8 then
self.dead=true
sfx(26)
end
end
bk=ac:new({sp=nss(79)})
function bk:up()
if self:inta(plr) then
won=true
music(13)
end
end
heart=ac:new({mom=0.2,dm=0.1,t=0,sp=nss(17)})
function heart:up()
if self.mom<1 then
self.y-=self.mom
self.mom+=0.2
elseif self.dm<0.6 then
self.y+=self.dm
self.dm+=0.1
end
if self:inta(plr) then
self.dead=true
sfx(8)
hp+=6
end
end
sw=en:new({dam=0,t=0,sp=nss(115)})
function sw:up()
if self.t>0 then
self.t-=1
end
end
function sw:hit()
if self.t==0 then
sw_bl()
self:ex()
self.t=20
bl_up=not bl_up
end
end
o_sw=sw:new({sp=nss(116)})
function o_sw:up()
end
function o_sw:hit()
if self.t==0 then
self.sp=nss(114)
self.t=20
self:ex()
if mx>=4 then
mset(5,3,237)
mset(9,3,252)
for i=21,25 do
mset(i,3,0)
end
else
rooms[0][0]="5u5t5t5v5t4q4p4p4p4p4p4o5t5v5t5v59595959595a5p5p745p5p58595959594p4p4p564p571r6k507u0s554p4p4p4p5p5p5l1m5n5q0s0s0s0s1r5o5p5p5p5p4u4v1r0s1r0s0s0s0s0s0s0s1r4u4v4u4v4u4v0s0s1c1c0s1s0s0sbe0s1r4u4v99999999991j1k9999999999999999999p9p9p9p9p1j1k9p9p9p9p9p9p9p9p9p82828282821j1k8282828282828282828i948i8i8i1j1k8i8i8i8i948i8i8i8i8i8i9e89891j1k8989898989898989898i848o1s0s0c0c0s1r4u4v4u4v0s1c1c8i8j8o0s0s0s0s0s0s1s0s1r0s0t1t1t948j8o4u4v0s1r0s0s1c1c0s0s4u4v0c8i8j8o484949494a0t1t1t0r484949498i8j8o4o5t5u5t4q0t1t1t0r4o5t5v5t"
bd_c=6
end
end
end
pf=ac:new({l=0,sp=nss(18)})
function pf:up()
if self.l==0 then
self.sp[1].s=18
end
self.l+=1
if self.l%5==0 then
self.sp[1].s+=1
end
if self.l>=20 then
self.dead,plr.dead,plr.x,plr.y,plr.sdir=true,false,plr.entry_x,plr.entry_y,plr.entry_dir
add_ac(plr)
sfx(17)
end
end
o_f=pf:new()
function o_f:up()
if self.l==0 then
self.sp[1].s=20
end
self.l+=1
if self.l%5==0 then
self.sp[1].s+=1
end
if self.l>=10 then
self.dead=true
end
end
function ati(name,s)
add(inv,it:new({name=name,s=s,id=name}))
while inv[1].name!=name do
next_it()
end
end
get_it=ac:new({l=0})
function get_it:up()
local list={2,1,27,4,2,23,5,3,23,5,2,26,6,0,28,7,3,23}
local s=d_it
for i=1,18,3 do
if mx==list[i] and my==list[i+1] then
s=list[i+2]
end
end
self.sp=nss(s)
self.x,self.y=on8(plr.x+4),plr.y-14
self.l+=1
if self.l==1 then
names={"bow and arrows","bombs","teleport rod","bomb arrows","teleport arrows","telebombs"}
if s==23 then
keys+=1
elseif s==54 then
max_hp+=6
hp=max_hp
else
got[s]=true
ati(names[s-25],s+32)
end
elseif self.l>90 then
gi=nil
play_music(current_music)
end
end
it=ac:new({name="sword",s=57,id="sword"})
function _init()
acs,hp,prev_hp,show_hp,max_hp,won_t,deaths,keys,prev_hp_time,mx,my,mi,sd,tc,f_c,bl_up,inv,ml,ti,got={},21,21,21,21,0,0,0,0,1,3,0,0,0,0,false,{},{},true,{}
r_p()
mx_c,my_c,map_dw_x_c,map_dw_y_c,cam_x,cam_y,cam_w,cam_h,it_sw_oft,tr_x,tr_y,tr_z=0,0,0,0,0,0,128,128,0,0,0,0
plr_init()
imoc,it_menu_open=-1,false
add(inv,it:new())
init_rooms()
poke(0x5f2c,3)
for i=0,1.6,0.2 do
add(ml,i)
add(ml,-i)
end
end
function play_music(x)
current_music=x
music(x)
end
function on8(n)
return flr8(n)*8
end
function flr8(n)
return flr(n/8)
end
function load_cr(load_enemies)
lr(mx,my,0,0,load_enemies)
plr.set_entry=false
end
function load_cr_below()
lr(mx,my,0,16,true)
end
function init_rooms()
rooms={}
for i= 0,7 do
rooms[i]={}
end
rooms[0]={ "8i8j8o585959595a0t1t1v0r585959478i8j8o554p4p4p570t1t1t0r554p4p4o948j8o5o5p5p5p5q0t1u1t0r5o5p5p4o8i8j989999999999991j1k999999994o8i8j9o9p9p9p9p9p9p1j1k9p9p9p9p4o8i8k828282828282821j1k828282834o89898989899f8i8i9e1j1k9f8i948j4o4v4u4v1s0t1i1i1i1i0b0c8q858i8j4o4u4v0s1c1d1h1h1h1h0r1s8q8h8i8j4o9999991j1k9a91939899999a8h8i8j4o9p9p9p1j1k9q8h8j9o9p9p9q8h8i8j4o8282821j1k828l8k828282828l948j4o8i9e891j1k899f8i8i948i8i8i8i8j4o898n0t1t0b0s8m89898989898989894o4v1r1r0c0s0s0s0s0s1r0s1r4u4v4s4o4u4v1s0s1r0s0s1r0s0s1s0s0s4u4v4o017l01j902df","4v4s1r0s0s0s0s0s0s0s0s0s0s4s4s4o4u4v0s0s0s0s0s0s1s0s0s1r0s4u4v584v0s1s1r0s4u4v0s0s1r0s1s0s0s0s554u4v0s0s4u4v0s4849494a0s0s1r0s554v4u4v0s0s1r484n4u4v4q1s0s1r0s5o4u4v4u4v0s0s4o4u4v465a0s0s0s0s0s4v4u4v0s1s0s5859595a571c1c1c1c1c4u4v4u4v0s0s554p4p575q1v1t1t1u1t4v4u4v4u4v0s5o5p5p5q0t1t0b0c0c0c4u4v4u4v0s1c1c1c1c1c1d1t0r0s1r0s4v4u4v0s0t1t1u1t1t1v1t1v0r0s0s4u4u4v0s1r0t1t0b0c0c0c0c0c1r0s4u4v4v4u4v0s0t1v0r0s1s4u4v0s0s0s0s4u4u4v0s0s0t1t0r0s0s0s4u4v1r0s4u4v4v4u4v1r0t1u0r0s1r0s0s0s0s0s1r4u4u4v0s0s0t1t0r0s4u4v4u4v4u4v4u4v01pp117l01o6","4v4s1r0s0t1t0r1r4s4u4v4u4v4u4v4u4u4v1r0s1d1u0r0s4u4v4u4v4u4v4u4v4v4u4v0t1t1t0r0s484949494a4u4v4u4u4v0s0t1v0b1r0s4o5t5u5t4q5r4u4v4v4u4v0t1t1b0s0s585959595a4u4v4u4u4v0s0t1t1u0r1r554p564p575r4u4v4v4u4v0s0d1t0r0s5o5l1m5n5q4u4v4u4u4v4u4v0t1v0r4u4v1s1c1s4u4v4u4v4v4u4v0s0t1t1b0s0s1d1t0r0s4u4v4u4u4v4u4v0t1t1v0r0t1t1v0r4u4v4u4v4v4u4v4u4v0c0c0s0s0c0c4u4v4u4v4u4u4v4u4v4u4v4u4v4u4v4u4v4u4v4u4v999999999999999999999999999999999p9p9p9p9p9p9p9p9p9p9p9p9p9p9p9p828282828282828282828282828282828i8i948i8i8i948i8i8i8i948i8i948i12ag","5u5t5t5v5t4q4p4p4p4p4p4o5t5v5t5v59595959595a5p5p745p5p58595959594p4p4p564p571r6k507u0s554p4p4p4p5p5p5l1m5n5q0s0s0s0s1r5o5p5p5p5p4u4v1r0s1r0s0s0s0s0s0s0s1r4u4v4u4v4u4v0s0s1c1c0s1s0s0s9g0s1r4u4v999999999999999999999999999999999p9p9p9p9p9p9p9p9p9p9p9p9p9p9p9p828282828282828282828282828282828i948i8i8i8i8i8i8i8i8i948i8i8i8i8i8i9e898989898989898989898989898i848o1s0s0c0c0s1r4u4v4u4v0s1c1c8i8j8o0s0s0s0s0s0s1s0s1r0s0t1t1t948j8o4u4v0s1r0s0s1c1c0s0s4u4v0c8i8j8o484949494a0t1t1t0r484949498i8j8o4o5t5u5t4q0t1t1t0r4o5t5v5t"}
rooms[1]={ "5t5v5t5u5t5t5t5t5v5t5t5u5t5t5t5t5t46595959595959595959595959475t5t4q4p4p4p4p4p4p4p4p4p4p4p4p4o5t5t4q4p4p4p4p4p4p4p4p4p4p4p4p4o5t5u4q5p4p4p4p5p5p5p5p4p4p4p5p4o5v5t4q8q8p8p8p8o0s0s8q8p8p8p8o4o5u5t4q8q9p9p9p8o8s8s8q9p9p9p8o4o5t4c4q8q818283985j5k9a8182838o4o5t5r4q8q8h948j9o5j5k9q8h948j8o4o5v4s4q8q8h8i8k825j5k828l8i8j8o4o5t4s4q8m898989891j1k898989898n4o5t5r4q4u4v1r0s1r0s0s0s1r4u4v4s4o4c4s4q1s0s0s0s0s0s0s1r0s1s4u4v4o4s4s4m494a0s1c0s484949494949494n5r4s4s5r4q0t1t0r4o5r4s4s4s4s5r4s4s5r4s4s4q0t1u0r4o4s4u4v4u4v4u4v4u","4s4s5r4q0s0c0s4o4s5r4u4v4u4v4u4v5959595a0s1c0s585959474u4v4659594p4p4p570t1u0r554p4p5859595a4p4p4p4p4p570t1t0r554p4p554p4p574p4p5p5p5p5q0s0c0s5o5p5p554p4p575p5p0s0s0s1r0s1c0s0s0s1s5o5p5p5q1s0s1c1c0s0s1d1t1b1c0s0s1c1c0s0s1c1c1t1v0r0t1t1u1t1t0r0t1t1v0r0t1u1t0c0c0s0t1t1t0b0c0s0s0c0c0s0s0c0c0s1r0s0t1t1t0r0s0s0s0s0s0s0s0s0s4v0s0s0t1v0b0s0s0s4u4v0s1r0s0s4u4u4v0s0s0c0s1c1c0s0s0s0s0s0s4u4v4v0s0s0s0s0t1t1t1b0s0s0s0s0s0s4u4u4v0s1r0s0t1t1t1t0r1r0s1s0s4u4v4v4u4v0s0s0s0d1t1u0r0s0s0s4u4v4u4u4v4u4v4u4v0t1t1t0r4u4v4u4v4u4v01eg","4v4u4v4u4v4s0t1t1t0r4s4u4v4u4v4u4u4v4u4v4u4v0t1u1t0r4u4v4u4v4u4v4v4u4v4u4v0s0t1t1t0r0s4u4v4u4v4u4u4v4u4v1r0s0t1t0b0s0s0s4u4v4u4v4v4u4v0s0s1s0s0d0r0s1s1r0s4u4v4u4u4v0s0s0s0s0s0t1b0s0s0s0s0s4u4v4v0s0s0s4u4v0s1d1t0r4u4v0s4u4v4u4u4v0s1s0s0s1d1t1u1b0s0s0s0s4u4v4v0s0s0s0s0t1t1t1t1t0r0s0s4u4v4u4u4v0s1r0s0t1u1t1t1v0r0s1r0s4u4v4v4u4v1s0s0s0c0c0c0c0s0s1s4u4v4u4u4v8699999999999999870s4u4v4u4v99999a9p9p9p9p9p9p9p9899999999999p9p9q818282828282839o9p9p9p9p9p8282828l8i8i948i8i8k8282828282828i8i948i8i8i8i8i8i8i8i948i8i8i8i","5u5t5v5t5u5t5t5v5t5t5t5t5u5t5v5t595959595959595959595959595959594p4p4p4p4p4p4p4p4p4p4p4p4p4p4p4p5p5p5p5p5p5p5p5p5p5p5p5p5p5p5p5p4v4u4v0s1c1c0s1r0s0s1s4u4v0s0s1r4u4v0s0t1t1u0r0s0s1r0s0s1s1r0s0s999999991j1k999999999999999999999p9p9p9p1j1k9p9p9p9p9p9p9p9p9p9p828282821j1k828282828282828282828i948i8i1j1k8i8i948i8i8i8i948i8i898989891j1k898989898989898989891c1c1c1d1t1u1b1c1c1c1c1c1c1c1c1c1u1t1t1t1v1t1t1t1v1t1t1t1t1t1t1v0c0c0c4u4v0c0c0c0c0c0c4u4v0c0c0c494949494949494949494949494949495t5t5t5t5t5t5t5t5t5t5t5t5t5t5t5t019g12f9"}
rooms[2]={ "5t4q0t1t0r0s8q8h8i8j8o0s0s0s4u4v5t4q0s0c0s1c8q8h948j8o0s1r0s0s4u5u4q4u4v0t401i1i1i1i1i1s6s1s4u4v5t4q1c1c1d401h1h1h1h1h0s1r0s0s4u5v4q869999999a9192939899999999995t4q8q9p9p9p9q8h948j9o9p9p9p9p9p5t4q8q818282828l8i8k8282828282825u4q8q8h8i948i8i8i8i8i8i8i948i8i5t4q8m898989898989898989898989895t4q0s1c1c1c1c1c1c1c1c1c1c1c1c1c5v4q0t1t1u1t1t1t1t1t1v1t1t1t1v1t4c4q0s0c0c0c0c0c0c0c0d1t0b0c0c0c4s4m494949494a0s0s1r0t1t0r1r0s0s4s4s4s4s4s4s4q4u4v0s0t1t0r0s4u4v4u4v4u4v4u4v4q4s4u4v0t1u0r4u4v4u4v4u4v4u4v465a4u4v0s0t1t0r0s4u4v01mk026k1156","4u4v4u4v465a574s4s0s0t1t0r0s4s4u595959595a57574u4v0s0t1u0r0s4u4v4p4p4p4p57575q4s4u4v0s0c0s4u4v4u4p4p4p4p575q4u4v0s0s0s1c0s1s4u4v5p5p5p5p5q4u4v1s0s0s0t1t0r1r0s0s0s0s0s1c1c1c1c1c0s0s1d1t1b1c1c1c1c1c1d1t1t1t1v1t0r0t1t1v1t1t1u1t1t1v1t1t0b0c0c0c0s0s0c0c0c0c0c0c0c0c0c0c0s0s0s0s0s0s86999999870s0s1r1s0s0s1r869999999a9p9p9p98994v0s0s1r0s0s8q9p9p9p9q8182839o9p4u4v0s0s1c0s8q818282828l948k82824v4u4v0t1t0r8q8h8i849e9f858i8i8i4u4v0s0t1v0r8q8h8i8j989a8h8i8i8i4v0s1s0t1t0r8q8h8i8j9o9q8h8i8i944u4v0s0t1t0r8q8h948k82828l8i8i8i01hc117l","4v4s0s0t1v0r8q8h8i948i8i8i8i8i8i4u4v0s0t1t0r8q8h8i8i8i8i8i8i8i8i4v0s1r0t1t0r8q8h8i5e4949495f8i944u4v0s0t1u0r8q8h8i4o5t5u5t4q8i8i4v0s0s0s0d0r8q8h84585959595a858i4u4v0s1s0t0r8q8h8j554p564p578h8i4v4u4v0s1d0r8q8h8j555l1m5n5q9f8i4u4v0s0t1t0r8q8h8j958o0r4u4v8q854v0s1r0t1u0r8q8h8j9o8o0r0s6s8q8h4u4v0s0t0b1r8q8h8k838o1b1c1d8q8h4v4u4v0s0s0s8q8h8i8j989999999a8h4u4v4u4v0s1s8q8h948j9o9p9p9p9q8h9999999999999a8h8i8k82828282828l9p9p9p9p9p9p9q8h8i8i8i8i8i8i8i8i828282828282828l8i8i8i8i948i8i8i8i8i948i8i8i8i8i948i8i8i8i8i8i8i124g","5t5t5t5t4q4p4p4p4o5t5t5t5t5t5t5t595959595a8p8p8p58595959595959594p4p4p4p579p9p9p554p4p4p4p4p4p4p5p5p5p5p5q8182835o5p5p5p5p5p5p5p0s0s1r0s1i1i1i1i1i0s1r0s0s1s0s0s1r0s0s0s1h1h1h1h1h0s0s0s0s0s0s0s999999999a9192939899870s0s0s0s0s9p9p9p9p9q8h8i8j9o9p8o0s0s0s4u4v82828282828l948k82838o1s0s1r0s4u8i948i8i8i8i8i8i8i8j8o0s0s0s4u4v8989898989899f8i8i8j8o0s1r0s0s4u1c1c1c1c4u4v8q858i8j8o0s0s0s4u4v1t1u1t1t0r0s8q8h8i8j8o1r1r0s0s4u0c0c0d1t0r0s8q8h948j8o1s1r1r4u4v494a0t1t0r0s8q8h8i8j8o1r1r0s0s4u5t4q0t1u0r0s8q8h8i8j8o1r0s0s4u4v129o03ok02b811nb"}
rooms[3]={ "4u4v0s0s1s0s0t1v1t0r0s1s0s0s58594v0s1r0s0s0s0t1t1t0r0s0s1r0s554p4u4v0s0s0s4u4v0c0c4u4v0s0s0s554p4v4u4v0s1r0s0s0s0s0s0s1r4u4v5o5p999999999999991j1k999999999999999p9p9p9p9p9p9p1j1k9p9p9p9p9p9p9p828282828282821j1k828282828282828i8i948i8i8i8i1j1k8i8i8i948i8i8i898989898989891j1k898989898989891c0s1r0s0s1r0s0s0s0s0s0s4u4v4u4v1t0r0s0s0s0s0s1c1c0s1s0s0s4u4v4u0c0s0s4u4v0s0t1u1t0r1r0s0s0s4u4v0s0s0s0s0s1s0t1t1t0r0s0s0s0s0s4u4u4v1r0s0s0s0t1t1t0r0s4u4v0s4u4v4v0s0s0s0s0s0t1t1u0r0s0s0s1r0s4u4u4v0s0s1r0s0t1t1t0r0s1r0s0s4u4v01fc12no","4v4s0s0s0s0s0t1t1t0r0s0s0s0s4u4v4u4v0s1r0s1r0t1u1t1b0s1r0s0s0s4u4v4u4v0s0s0s0t1t1t1t0r0s0s0s4u4v4u4v0s0s0s4u4v0d1t1v0r0s0s4u4v4u0s0s0s1r4u4v1s0s0d1t0r0s1r0s4u4v1c1c0s0s0s1c1c1c0s0c0s0s0s4u4v4u1u1t1b1r0t1t1u1t1b0s0s1r0s0s4u4v0c0c0c0s0s0d1t1t1t0r0s4u4v0s0s4u0s1r0s0s0s1r0c0c0c0s4u4v1r0s4u4v99999999870s0s1c1c0s1r0s0s4u4v4u9p9p9p9p8o1c1d1t1u0r0s0s4u4v4u4v828282838o1t1t1t1t869999999999998i8i8i8j8o1u1t1t1v8q9p9p9p9p9p9p8i948i8j98991j1k999a8182828282828i8i8i8j9o9p1j1k9p9q8h8i8i8i948i8i8i948k82821j1k82828l8i8i8i8i8i12c811je12p8","8i8i8i8i8i8i1j1k8i8i8i8i8i8i8i8i8i948i9e89891j1k899f8i8i948i8i8i8i8i848o0s1r0s0s0s8q858i8i8i8i8i8i8i8j8o0s0s0s0s1r8q8h8i8i8i948i8i9e898n0s1s0s86999a8h8i8i8i8i8i848o0s0s0s0s0s8q9p9q8h8i948i8i8i8j8o0s0s0s0s1r8q81828l8i8i8i8i8i8j8o0s4u4v0s0s8q8h948i8i8i8i8i8i8j8o0s0s0s0s1c8q8h8i8i9e89899f8i8j9899870s0t1t1i1i1i1i1i40408q858j9o9p8o1s0t1t1h1h1h1h1h40408q8h8k82838o1c1d1u8q9192938o6s0c8q8h8i8i8j989999999a8h8i8j8o1r1s8q8h8i948j9o9p9p9p9q8h8i8j9899999a8h8i8i8k82828282828l8i8j9o9p9p9q8h8i8i8i8i8i8i8i8i8i948k828282828l129711fj","5t5u5t5t5t5t5t5t5t5t5t5t5t5t5t5t595959475u46595959475t5t5u5t5t5v4p4p4p58595a4p4p4p4o5t5t5t5t5t5t5p5p5p554p575p5p5p4o5t5v5t5t5t5t0s0s0d5o5p5q1t1t1t5859595959475t0s0s1r0c0d1t1t1v1t554p564p4p4o5t0s0s0s0s0s0d1t1t1t5o5l1m5n5p4o5t4u4v0s0s1r0t1t1t1t1t1b1c0s1s4o5t4v4u4v0s0s0t1t1t1t1t1t1t0r0s4o5t4u4v0s1r0s1d1t0b0c0c0d1t1b0s4o5t4v4u4v0s0t1t1t0r4u4v0t1t1t0r4o5v4v4u4v0s0t1t1t1b1c1c1d1t1t0r4o5t4u4v0s0s0t1t1t1t1t1t1t1v1t0r4o5t4u4v0s0s0s0c0d1t1t1t1t1t0b0s4o5u4v4u4v0s1s0s0t1v1t0b0c0c0s0s4o5t4u4v0s0s0s0s0t1t1t0r0s1r0s0s4o5t118l12ea11hi"}
rooms[4]={ "6062632465626262626262626262617v66706j3c6l6i6i6i6i6i6i6i6i71697v66672c2c2c2c2cau2c2c2c2c2c68697v66672c2c2c2c2cau2c2c2caf2c68697v66672c2c2c2c2cau2c2c2c2c2c68697v667g727272727272727b2c2c2c68697v6g7i7i7i7i7i7i7i6b672c2c2c68697v6e6e6e6e6e6e6e6e66672v2v2v68697v60626262626262626r672c2c2c68697v66706i6i6i6i6i6i6i7r2c2c2c68697v66672c2c2c2c2cau2c2c2c2c2c68697v66672c2c2c2c2cau2c2c2c2c2c68697v66672c2c2c2c2cau2c2c2c2c2c68697v667g733t7572727272727272727h697v6g7i7j3k7l7i7i7i7i7i7i7i7i7i6h7v7v7v7v3v7v7v7v7v7v7v7v7v7v7v7v7v","606263246562626262626262617v7v7v66706j3c6l6i6i6i6i6i6i71697v7v7v66672c2c2c2c2c2v2c2c2c68697v7v7v66672c2c2c2c2c2v2c6t2c68697v7v7v66672c2c2c2c2c2v2c2c2c68697v7v7v667g7272727272727272727h697v7v7v6g7i7i7i7i7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v606262626262626262626262617v7v7v66706i6i6i6i6i6i6i6i6i71697v7v7v66672c2c2c2c2c2c2c2c2c6o6p7v7v7v66672caf2c2c2c2c2c2c2c3d393v7v7v66672c2c2c2c2c2c2c2c2c7o7p7v7v7v667g7272733t75727272727h697v7v7v6g7i7i7i7j3k7l7i7i7i7i7i6h7v7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v","6062626262626324656262626262617v66706i6i6i6i6j3c6l6i6i6i6i71697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c7a7272727b2c2c2c68697v66672c2c2c686a7i6b672c2c2c68697v66672c2c2c68697v66672c2c2c68697v66672c2c2c686q626r672c2c2c68697v66672c2c2c7q6i6i6i7r2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2d2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v667g72727272727272727272727h697v6g7i7i7i7i7i7i7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v01me1169","606262626262617v606262626262617v66706i6i6i71697v66706i6i6i71697v66672c2c2c6o6p7v6m6n2c2d2c6o6p7v66672c2c2c78797v76772c2c2c3d393v66672c2c2c7o7p7v7m7n2c2c2c7o7p7v66672c2c2c686q626r672c2c2c68697v66672c2c2c7q6i6i6i7r2c2c2c68697v66672e2e2e2e2e2e2e2e2e2e2e68697v66672c2c2c2e2e2e2e2e2e2e2e68697v66672c2c2c2e2e2e2c2c2e2e2e68697v66672c2c2c2e2e2e2cbf2e2e2e68697v66672c2c2c2e2e2e2c2c7a72727h697v66672c2c2c2e2e2e2e2e686a7i7i6h7v667g733t7572727272727h697v7v7v7v6g7i7j3k7l7i7i7i7i7i7i6h7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v7v7v7v7v"}
rooms[5]={ "7v7v7v7v60626262626263246562617v7v7v7v7v66706i6i6i6i6j3c6l71697v7v7v7v7v66672c2c2c2c2c2c2c68697v7v7v7v7v66672c2c2c2c2c2c2c68697v606262626r672c2c2c2c2c2c2c68697v66706i6i6i7r2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c6o6p7v66672c2c2c2c2c2c2c2c2c2c2c3d393v66672c2c2c2c2c2c2c2c2c2c2c7o7p7v66672c2c2c2c2c2c2c7a7272727h697v66672c2c2c2c2c2c2c686a7i7i7i6h7v66672c2c2c2c2c2c2c68697v7v7v7v7v66672c2c2c2c2c2c2c68697v7v7v7v7v667g733t75727272727h697v7v7v7v7v6g7i7j3k7l7i7i7i7i7i6h7v7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v7v7v7v7v13k803ai","6062632465626262626262626262617v66706j3c6l6i6i6i6i6i6i6i6i71697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c6t2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672e2e2e2e2v2v2v7a7272727h697v66672c2c2c2e2c2c2c686a7i7i7i6h7v66672caf2c2e2c2c2c68697v6e7v7v7v66672c2c2c2e2c2c2c686q626262617v66672e2e2e2eauauau7q6i6i6i71697v6m6n2c2c2c2c2c2c2c2c2c2c2c6o6p7v363s2c2c2c2c2c2c2c2c2c2c2c3d393v7m7n2c2c2c2c2c2c2c2c2c2c2c7o7p7v667g72727272727272727272727h697v6g7i7i7i7i7i7i7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v11ee","6062626262626262626262626262617v66706i6i6i6i6i6i6i6i6i6i6i71697v66672c2c2c2e2e2c2c2c2c2c2e68697v66672c2c2c2e2e2c2c2c2c2c2e68697v66672c2c2c2e2e2c2c2c2c2c2e68697v66672c2c2c7a7272727b2c2c2c68697v66672c2c2c686a7i6b672c2c2c6o6p7v66672c2c2c68697v66672c2c2c3d393v66672c2c2c686q626r672c2c2c7o7p7v66672c2c2c7q6i6i6i7r2c2c2c68697v66672e2c2c2c2c6t2e2e2c2c2c68697v66672e2c2c2c2c2c2e2e2c2c2c68697v66672e2c2c2c2c2c2e2e2c2c2c68697v667g72727272727272727272727h697v6g7i7i7i7i7i7i7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v11i6136d","6062626262626262626262626262617v66706i6i6i6i6i6i6i6i6i6i6i71697v6m6n2cau2c2c2e2e2c2c2c2c2c68697v363s2cau2c2c2e2e2c2c2c2c2c68697v7m7n2cau2c2c2e2e2c2c2c2c2c68697v66672e2e40402e2e2c2c2c2c2c68697v66672e2e2c2c2e2eaf2c2c2c2c68697v66672e2e2c2c2e2e2e2e2c2c2c68697v66672e2e2c2c2e2e2e2e2c2c2c68697v66672e2e2v2v2c2c2cauau2c2c68697v66672e2e2v2v2c2c2cauau2c2c68697v66672e2e2e2e2e2e2e2e2c2c2c68697v66672e2e2e2e2e2e2e2e2c2c2c68697v667g7272727272727272733t757h697v6g7i7i7i7i7i7i7i7i7i7j3k7l7i6h7v7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v"}
rooms[6]={ "7v7v7v7v606263246562617v7v7v7v7v7v7v7v7v66706j3c6l71697v7v7v7v7v7v7v7v7v66672c2c2c686q626262617v7v7v7v7v66672c2c2c7q6i6i6i71697v606262626r672c2c2c2c2c2c2c68697v66706i6i6i7r2c2c2c2c2c2c2c68697v6m6n2c2c2c2c2c2c2c2c2c2c2c68697v363s2c2c2c2c2c2c2c2c2c2c2c68697v7m7n2c2c2c2c2c2c2c2c2c2c2c68697v667g7272727b2c2c2c2c2c2c2c68697v6g7i7i7i6b672c2c2c2c2c2c2c68697v7v7v7v7v66672c2c2c7a7272727h697v7v7v7v7v66672c2c2c686a7i7i7i6h7v7v7v7v7v667g733t757h697v7v7v7v7v7v7v7v7v6g7i7j3k7l7i6h7v7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v13ma13mi","6062626262626324656262626262617v66706i6i6i6i6j3c6l6i6i6i6i71697v66672c2c2c2c2c2c2c2c2c2c2c6o6p7v66672c2c2c2c2c2c2c2c2c2c2c3d393v66672c2c2c2c2c2c2c2c2c2c2c7o7p7v66672c2c2c2c2c2c2c2c7a72727h697v66672c2c2c2c2c2c2c2c686a7i7i6h7v66672c2c2c2c2c2c2c2c68697v7v7v7v66672c2c2c2e2e2c2e2e686q6262617v66672c2c2c2e2e2v2e2e7q6i6i71697v6m6n2c2c2c2e2e2c2e2e2c2caf68697v363s2c2c2c2e2eau2e2e7a72727h697v7m7n2c2c2c2e2e2c2e2e686a7i7i6h7v667g72727272733t75727h697v7v7v7v6g7i7i7i7i7i7j3k7l7i7i6h7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v136a13f9","7v7v7v6062626324656262617v7v7v7v7v7v7v66706i6j3c6l6i71697v7v7v7v7v7v7v66672c2c2c2c2c68697v7v7v7v6062626r672c2c2c2c2c686q6262617v66706i6i7r2c2c2c2c2c7q6i6i71697v66672c2c2c2c2c2c2c2c2c2c2c68697v6m6n2c2c2c2c2c2c2c2c2c2c2c68697v363s2c2c2c2c2caf2c2c2c2d2c68697v7m7n2c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v667g72727b2c2c2c2c2c7a72727h697v6g7i7i6b672c2c2c2c2c686a7i7i6h7v7v7v7v66672c2c2c2c2c68697v7v7v7v7v7v7v667g72727272727h697v7v7v7v7v7v7v6g7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v03em","7v7v7v7v606262626262617v7v7v7v7v7v7v7v7v66706i6i6i71697v7v7v7v7v7v7v7v7v66672c2c2c68697v7v7v7v7v606262626r672c6t2c686q626262617v66706i6i6i7r2c2c2c7q6i6i6i71697v66672c2c2c2c2c2c2c2cau2c2c68697v66672c2c2c2c2c2c2c2cau2c2c6o6p7v66672caf2c2c2c2c2c2cau2c2c3d393v66672c2c2c2c2c2c2c2cau2c2c7o7p7v66672c2c2c2c2c2c2c2cau2c2c68697v667g7272727b2e2e2e7a7272727h697v6g7i7i7i6b672c2c2c686a7i7i7i6h7v7v7v7v7v66672c2c2c68697v7v7v7v7v7v7v7v7v667g733t757h697v7v7v7v7v7v7v7v7v6g7i7j3k7l7i6h7v7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v7v7v7v7v"}
rooms[7]={ "7v7v7v7v606263246562617v7v7v7v7v7v7v7v7v66706j3c6l71697v7v7v7v7v7v7v7v7v66672c2c2c68697v7v7v7v7v606262626r672c2c2c686q626262617v66706i6i6i7r2c2c2c7q6i6i6i71697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c2c2c2c2c2c2c2c2c68697v66672c2c2c7a7272727b2c2c2c68697v66672c2c2c686a7i6b672c2c2c68697v667g7272727h697v667g733t757h697v6g7i7i7i7i7i6h7v6g7i7j3k7l7i6h7v7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v13ec13mi036h","606262626262617v606263246562617v66706i6i6i71697v66706j3c6l71697v6m6n2c2c2c6o6p7v6m6n2c2c2c68697v363s2c2c2c78797v76772c2c2c68697v7m7n2c2c2c7o7p7v7m7n2c2c2c68697v66672c2c2c68697v66672c2c2c68697v66672c2c2c68697v66672c2c2c68697v66672e2e2e68697v66672c2c2c68697v66672c2c2c686q626r672c2c2c68697v66672c2c2c7q6i6i6i7r2c2c2c68697v66672c2c2c2c2c2e2c2c2c2c2c68697v66672cbf2c2c2c2e2c2c2c2c2c68697v66672c2c2c2c2c2e2c2c2c2c2c68697v667g7272727272727272733t757h697v6g7i7i7i7i7i7i7i7i7i7j3k7l7i6h7v7v7v7v7v7v7v7v7v7v7v7v3v7v7v7v7v","606262626262617v606263246562617v66706i6i6i71697v66706j3c6l71697v66672e6t2e6o6p7v6m6n2c2c2c68697v66672c2c2c78797v76772caf2c68697v66672c2cbf7o7p7v7m7n2c2c2c68697v6667au7a727h697v66672c2c2c68697v6667au686a7i6h7v66672c2c2c68697v66672c68697v7v7v66672c2c2c68697v66672c686q62617v66672c2c2c68697v66672c7q6i716q626r672c2c2c68697v66672c2c2c7q6i6i6i7r2c2c2c68697v66672e2v2v2c2c2c2c2c2c2c2c68697v66672e2v2v2c2c2c2c2c2e2e2e68697v667g72727272727272727272727h697v6g7i7i7i7i7i7i7i7i7i7i7i7i7i6h7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v7v","606262626262613v3v3v3v3v3v3v3v3v66706i6i6i71693v3v3v3v3v3v3v3v3v66672c2c2c68693v3v3v3v3v3v3v3v3v66672c2c2c68693v606262626262613v66672c2c2c68693v66706i6i6i71693v66672c2c2c68693v66672c2c2c68693v6m6n2c2c2c686q626r672c2d2c68693v363s2c2c2c7q6i6i6i7r2c2c2c68693v7m7n2c2c2c2c2c2c2c2c2c2c2c68693v66672c2c2c2c2c2c2c2c2c2c2c68693v66672c2c2c2c2c2c2c2c2c2c2c68693v66672c2c2c2c2c2c2c2c2c2c2c68693v66672c2c2c2c2c2c2c2c2c2c2c68693v667g72727272733t75727272727h693v6g7i7i7i7i7i7j3k7l7i7i7i7i7i6h3v3v3v3v3v3v3v3v3v3v3v3v3v3v3v3v3v136611ei016m01mm"}
chests={}
for i=0,7 do
chests[i]={}
rooms[i][0]=rooms[i][4]
end
end
function lr(rm_x,rm_y,x,y,there_are_enemies)
d_it=54
string=rooms[rm_x][rm_y]
local i=1
for j=y,y+15 do
for k=x,x+15 do
local num1,num2=cti(cat(string,i)),cti(cat(string,i+1))
local num=num2+num1*32
mset(k,j,num%128+128)
mset(k+16,j,flr(num/128))
i+=2
end
end
acs,plr.sword,plr.tro,plr.bow={plr,hand},nil,nil
if there_are_enemies then
if rm_x==1 and rm_y==1 then
add_ac(ga:new({x=56,y=72}))
add_ac(ga:new({x=56,y=56}))
add_ac(bk:new({x=60,y=44}))
for i=0,keys*2 do
mset(23,10-i,0)
mset(24,10-i,0)
end
end
load_enemies(rm_x,rm_y)
for i=0,15 do
for j=0,15 do
tile=mget(i,j)
if tile==207 then
s=sw:new({x=i*8,y=j*8})
add(acs,s)
elseif tile==239 or tile==176 then
s=o_sw:new({x=i*8,y=j*8})
add(acs,s)
end
end
end
end
if bl_up then
sw_bl()
end
if (chests[rm_x][rm_y]) o_c(y)
end
function load_enemies(rm_x,rm_y)
m=rooms[rm_x][rm_y]
for i=513,#m,4 do
props={x=4*cti(cat(m,i+2)),y=4*cti(cat(m,i+3)),dif=cti(cat(m,i+1))}
a=sl:new(props)
if cat(m,i)=="0" then
a=gob:new(props)
end
a:st()
add(acs,a)
end
end
function _update60()
if ti then
if btnp(4) or btnp(5) then
ti,ti_count,tr_z=false,1,150
sfx(33)
end
return
end
if ti_count then
ti_count+=1
if (ti_count%4==0) apply_pal_pset(dpal)
if ti_count>16 then
poke(0x5f2c,0)
load_cr()
plr:animate_sp()
ti_count=false
end
return
end
if won then
won_t+=1
if won_t==16 then
apply_pal_pset(dpal)
if (sd<10) sd="0"..sd
end
return
end
if bd_c then
mset(5,bd_c,179)
mset(6,bd_c,180)
mset(21,bd_c,0)
mset(22,bd_c,0)
if (bd_c%1<0.05) sfx(37)
bd_c+=0.05
if bd_c>=11 then
bd_c=nil
end
return
end
tc+=1
if tc>=60 then
sd+=1
tc=0
if sd>=60 then
mi+=1
sd=0
end
end
if f_a then
if f_c%48==0 then
fs_cg=nil
if btnp(1) and #inv>=4  then
fs_cg=4
elseif btnp(0) and #inv>=4 then
fs_cg=-4
elseif btnp(4) then
f_a=false
if f_c==0 then
f_r,m1,m2=29,26,27
elseif f_c==48 then
f_r,m1,m2=31,27,28
else
f_r,m1,m2=30,26,28
end
d_it=f_r
rfi(m1)
rfi(m2)
sci()
elseif btnp(5) then
f_a=false
end
end
if (fs_cg) f_c=(f_c+fs_cg)%144
return
end
ins=mx>3
if (up_trs()) return
if dap then
up_death_animation()
else
if up_it_menu() then
if not gi then
if not d_it2 then
for a in all(acs) do
a:up()
if a.dead then
del(acs,a)
end
end
else
d_it=d_it2
d_it2=nil
sci()
end
else
gi:up()
end
sort_acs_by_y()
if btnp(5) then
it_menu_open=true
end
end
up_hp()
local num_enemies=0
for i in all(acs) do
if i.is_en then
num_enemies+=1
end
end
if show_hp<=0 then
dap,dapc=true,0
deaths+=1
music(-1)
sfx(15)
end
end
end
function sci()
gi=get_it:new()
music(12)
end
function rfi(num)
for i in all(inv) do
if i.s-32==num then
del(inv,i)
end
end
end
function go_to_zero(num,aps)
if num>aps then
return num-aps
elseif num<-aps then
return num+aps
end
return 0
end
function up_trs()
local sx,sy,sz=tr_x,tr_y,tr_z
tr_x,tr_y=go_to_zero(tr_x,6),go_to_zero(tr_y,6)
if tr_z>0 then
tr_z-=6
if tr_z==150 then
position_plr()
cam_x,cam_y=-4-cam_x,-4-cam_y
end
if tr_z<=0 then
load_cr(true)
if ins then
play_music(5)
else
play_music(0)
end
end
end
return sx!=tr_x or sy!=tr_y or sz!=tr_z
end
function position_plr()
for i=0,15 do
for j=0,15 do
local tile=mget(i,j)
if tile==182 then
plr.x,plr.y=i*8,j*8+2
elseif tile==205 then
plr.x,plr.y=i*8-4,j*8+4
end
end
end
plr.dir,plr.sdir=0.75,0.75
plr:animate_sp()
end
function up_death_animation()
dapc+=1
if dapc<=16 then
if dapc%4==0 then
apply_pal_pset(dpal)
end
elseif dapc==32 then
tr_z,hp,dapc,dap,plr.x,plr.y,plr.hit_t,plr.fk_t,cam_x,cam_y,mx,my=150,max_hp,0,false,60,64,0,0,0,0,1,3
load_cr()
end
end
function add_ac(a)
add(acs,a)
end
function sort_acs_by_y()
new_acs={}
for i=1,#acs do
lowest=acs[1]
for j in all(acs) do
if j.y<lowest.y then
lowest=j
end
end
add(new_acs,lowest)
del(acs,lowest)
end
acs=new_acs
end
function bomb_destroy(x,y)
for i=flr8(x-12),flr8(x+12) do
for j=flr8(y-12),flr8(y+12) do
if i>=0 and j>=0 and i<16 and j<16 and fget(mget(i+mx_c,j+my_c),3) then
mset(i+mx_c,j+my_c,144)
mset(i+mx_c+16,j+my_c,0)
end
end
end
end
function d_d(d1,d2)
dif=abs(d1-d2)
if dif>0.5 then
dif=1-dif
end
return dif
end
function clamp(val,min,max)
if (val>max) return max
if (val<min) return min
return val
end
function is_solid(x,y)
x,y=clamp(x,0,cam_w-4),clamp(y,0,cam_h-4)
solidity=mget(16+x/8,my_c+y/8)
return solidity!=0
end
function iaf(x,y)
if (x<0 or y<0 or x>cam_w or y>cam_h) return true
solidity=mget(16+x/8,my_c+y/8)
return solidity!=1
end
function up_it_menu()
if it_sw_oft==0 then
if it_menu_open then
imoc=min(14,imoc+2)
else
imoc=max(-1,imoc-2)
end
if (imoc<=-1) return true
cam_x,cam_y=(imoc)/2,-(imoc)/2
if ins then
cam_x-=4
cam_y-=4
end
if btnp(4) or btnp(5) then
it_menu_open=false
end
if #inv>1 then
if btnp(3) then
it_sw_oft=-0.5
elseif btnp(2) then
it_sw_oft=0.5
end
end
else
if it_sw_oft<0 then
it_sw_oft-=0.15
else
it_sw_oft+=0.15
end
if it_sw_oft<=-1 then
it_sw_oft=0
next_it()
elseif it_sw_oft>=1 then
it_sw_oft=0
prev_it()
end
end
return false
end
function up_hp()
if show_hp<hp then
show_hp+=1
elseif show_hp>hp then
show_hp-=1
end
if prev_hp_time==0 then
if show_hp<prev_hp then
prev_hp-=0.5
else
prev_hp=show_hp
end
else
prev_hp_time-=1
end
hp=clamp(hp,0,max_hp)
show_hp=max(show_hp,0)
end
function dam_hp(amount)
hp-=amount
prev_hp_time=60
end
function sw_bl()
for i=0,15 do
for j=0,15 do
tile=mget(i,j)
if tile==222 then
mset(i,j,223)
mset(i+16,j,0)
elseif tile==223 then
mset(i,j,222)
mset(i+16,j,2)
end
end
end
end
function o_c(y)
for i=0,15 do
for j=y,y+15 do
tile=mget(i,j)
if tile==220 then
mset(i,j,112)
elseif tile==221 then
mset(i,j,113)
end
end
end
end
function p_w(s,dir,base)
s.f=d_d(0,dir)>0.25
s.vf=d_d(0.25,dir)>0.25
s.s=base+1
if d_d(0.25,dir)<0.0625
or d_d(0.75,dir)<0.0625 then
s.s=base+2
end
if d_d(0,dir)<0.0625
or d_d(0.5,dir)<0.0625 then
s.s=base
end
end
function plr_init()
plr_head=nps(1,0,-4)
plr_arm1=ns(6)
plr_arm2=ns(6)
plr_body=xs:new()
plr=ac:new({x=60,y=64,h=7,max_vel=0.9,sdir=0.75,dir=0.75,
aro=0.5,arm_length=4.5,aas=true,
hit_t=0,fk_t=0,holes_dist=0,
sp={
plr_body,
plr_arm1,
plr_arm2,
plr_head
}})
add_ac(plr)
function plr:up()
if self.hit_t<=0 then
if self.fk_t<=0 then
for i in all(self.sp) do
i.fk=false
i.xi=false
end
end
self.acc=0.4
local old_dir=self.dir
if btn(0) then
if btn(2) then
self.dir=0.375
elseif btn(3) then
self.dir=0.625
else
self.dir=0.5
end
elseif btn(1) then
plr_head.f=false
if btn(2) then
self.dir=0.125
elseif btn(3) then
self.dir=0.875
else
self.dir=0
end
else
if btn(2) then
self.dir=0.25
elseif btn(3) then
self.dir=0.75
else
self.acc=-0.6
end
end
if self.aas then
self.aro+=self.vel/100
if self.aro>=0.6 then
self.aas=false
end
else
self.aro-=self.vel/100
if self.aro<=0.4 then
self.aas=true
end
end
if self.vel==0 then
self.arm_length=4.5
self.aro=0.5
end
self.vel-=d_d(self.dir,old_dir)
it_id=inv[1].id
if it_id=="sword" and can_use_it() then
if self.sword==nil then
self.sword=new_sword(self.dir)
self.sdir=self.dir
add_ac(self.sword)
sfx(1)
elseif self.sword.l==0 then
self.sword.move_spd=-self.sword.move_spd
self.sword.end_frames=6
self.sword.l=10
self.sword.dist=10
sfx(1)
end
elseif it_id=="teleport rod" and can_use_it() then
if self.tro==nil then
self.sdir=flr(self.dir/0.25)*0.25
self.tro=new_tro(self.dir)
add_ac(self.tro)
sfx(1)
end
elseif it_id=="bow and arrows" and can_use_it() and not self.bow then
self:do_bow(0)
elseif it_id=="bomb arrows" and can_use_it() and not self.bow then
self:do_bow(1)
elseif it_id=="teleport arrows" and can_use_it() and not self.bow then
self:do_bow(2)
elseif can_use_it() and (it_id=="bombs" or it_id=="telebombs") then
local b=bomb:new({x=self.x,y=self.y})
if it_id=="telebombs" then
b=telebomb:new({x=self.x,y=self.y})
end
b:st()
add_ac(b)
inv[1].use_t=90
inv[1].use_t_max=90
end
if (self.sword and self.sword.dead) self.sword=nil
if (self.tro and self.tro.dead) self.tro=nil
if (self.bow and self.bow.dead) self.bow=nil
if not self.sword and not self.tro and not self.bow and self.hit_t==0 then
self.sdir=self.dir
end
for i in all(inv) do
if i.use_t then
if i.use_t>0 then
i.use_t-=1
else
i.use_t=nil
end
end
end
if self.fk_t<=0 then
for i in all(acs) do
if i.is_en and self:inta(i) and i.dam>0 then
self:p_a(i)
self.dir,self.vel,self.hit_t,self.fk_t,self.acc=0.5,2,15,60,0.5
dam_hp(i.dam)
sfx(32)
break
end
end
end
else
self.hit_t-=1
for i in all(self.sp) do
i.fk=true
end
if self.hit_t==0 then
self.dir=self.sdir
end
end
if self.fk_t>0 then
self.fk_t-=1
for i in all(self.sp) do
i.fk=true
end
end
self:animate_sp()
ac.up(self)
self:clip_out()
if not self.set_entry and self.x>10 and self.y>10 and self.x<cam_w-18 and self.y<cam_h-18 then
self.entry_x,self.entry_y,self.entry_dir,self.set_entry=self.x,self.y,self.dir,true
end
self:fall_down_holes()
self.holes_dist=0
self:tr_rooms()
if self.sdir==0.25 and self.y%8==0 then
local tile=mget(flr8(self.x+4),self.y/8-1)
if tile==220 or tile==221 then
o_c(0)
sci()
chests[mx][my]=true
elseif tile==160 or tile==212 or tile==254 then
self.y+=0.1
if f_r then
rfi(f_r)
f_r,self.vel,d_it,d_it2=nil,0,m1,m2
sci()
else
self.vel,f_a=0,true
if (not got[26]) f_c=48
if (not got[27]) f_c=96
end
end
end
end
function plr:do_bow(arrow_num)
self.sdir=flr(self.dir/0.25)*0.25
self.bow=new_bow(self.sdir,arrow_num)
add_ac(self.bow)
end
function can_use_it()
return btnp(4) and not inv[1].use_t
end
function plr:fall_down_holes()
num_holes=0
for i=-1,1,2 do
for j=-1,1,2 do
tile=mget((self.x+3+i*self.holes_dist)/8,(self.y+3+j*self.holes_dist)/8)
if tile==206 then
num_holes+=1
end
end
end
if num_holes>=2 then
if hp>3 then
self.dead=true
add_ac(pf:new({x=self.x,y=self.y}))
end
dam_hp(3)
self.hit_t,self.fk_t,self.vel,self.acc=15,60,0,0
sfx(16)
end
end
function plr:tr_rooms()
if self.y>cam_y+cam_h-4 then
load_cr_below()
self.y-=cam_h
my+=1
tr_y=128
load_cr(true)
elseif self.y<cam_y-4 then
load_cr_below()
self.y+=cam_h
my-=1
tr_y=-128
load_cr(true)
elseif self.x>cam_x+cam_w-4 then
load_cr_below()
self.x-=cam_w
mx+=1
tr_x=128
load_cr(true)
elseif self.x<cam_x-4 then
load_cr_below()
self.x+=cam_w
mx-=1
tr_x=-128
load_cr(true)
else
tile=mget((self.x+4)/8,(self.y+4)/8)
if self.y%8==0 and tile==182 then
load_cr_below()
mx+=4
tr_z=300
music(-1)
sfx(19)
load_cr()
elseif tile==205 then
load_cr_below()
mx-=4
tr_z=300
music(-1)
sfx(19)
load_cr()
end
end
end
function plr:animate_sp()
local head_dir=self.sdir
plr_head.s=3
plr_head.f=false
if head_dir>0.8125 and head_dir<0.9375 then
plr_head.s=2
elseif head_dir>0.6875 then
plr_head.s=1
elseif head_dir>0.5625 then
plr_head.s=2
plr_head.f=true
elseif head_dir>0.4375 then
plr_head.f=true
elseif head_dir>0.3125 then
plr_head.s=4
plr_head.f=true
elseif head_dir>0.1875 then
plr_head.s=5
elseif head_dir>0.0625 then
plr_head.s=4
end
local arm_dif=0.35
local length=self.arm_length
local arm1_an=(self.aro+self.sdir-arm_dif)%1
plr_arm1.x=flr(3+cos(arm1_an)*length)
plr_arm1.y=flr((5+sin(arm1_an)*length)/2.5)
if self.hit_t==0 then
plr_arm1.xi=(d_d(0.75,arm1_an)>0.3)
end
local arm2_an=(self.aro+self.sdir+arm_dif)%1
plr_arm2.x=flr(3+cos(arm2_an)*length)
plr_arm2.y=flr((5+sin(arm2_an)*length)/2.5)
if self.hit_t==0 then
plr_arm2.xi=(d_d(0.75,arm2_an)>0.3)
end
if not plr_arm2.xi then
plr_arm2.xi=self.sword!=nil or self.tro!=nil or self.bow!=nil
end
if not plr_arm1.xi then
plr_arm1.xi=self.bow!=nil and self.bow.l==-1
end
plr_body.f=self.aro>0.5
plr_body.s=0
if abs(self.aro-0.5)>0.05 then
plr_body.s=16
end
end
function plr:move_x()
local st_y=self.y
list=ml
if (plr.dir*4)%1!=0 then
list={0}
end
for i in all(list) do
self.y=st_y+i
if (ac.move_x(self)) return
end
self.y=st_y
end
function plr:move_y()
local st_x=self.x
list=ml
if (plr.dir*4)%1!=0 then
list={0}
end
for i in all(ml) do
self.x=st_x+i
if (ac.move_y(self)) return
end
self.x=st_x
end
hand=ac:new({sp={nps(6,4,4)}})
function hand:up()
if plr.sword!=nil then
self.x=plr.x+5*cos(plr.sword.dir)-2
self.y=plr.y+4*sin(plr.sword.dir)-2
elseif plr.tro!=nil then
self.x=plr.x+5*cos(plr.tro.dir)-2
self.y=plr.y+4*sin(plr.tro.dir)-2
else
self.x=-2000
end
end
add_ac(hand)
end
function new_sword(direc)
local sb=ns(48)
sword=ac:new({l=11,dist=10,end_frames=6,dir=0,rel_dir=-0.2,
move_spd=0.035,sp={sb},bl=sb})
function sword:up()
if self.l>0 then
self:swing()
else
if self.end_frames>0 then
self.end_frames-=1
else
self.dead=true
end
end
self:be_plr_sword()
p_w(self.bl,self.dir,48)
for i in all(acs) do
if i:inta(self) then
i:hit(plr,2)
end
end
end
return sword
end
function new_tro(direc)
local sb=ns(51)
teleport=ac:new({l=6,dist=9,end_frames=6,dir=0,rel_dir=-0.2,
move_spd=0.035,sp={sb},bl=sb})
function teleport:up()
local bl=self.bl
local can_warp=not is_solid(self.x+4,self.y+4)
if self.l>0 then
self:swing()
else
if self.end_frames>0 then
self.end_frames-=1
elseif self.end_frames==0 then
self.sp=copy_sp(plr.sp)
add(self.sp,bl)
self.end_frames=-1
elseif not btn(4) then
self.dead=true
if can_warp then
wrpt(self.x,self.y)
sfx(6)
end
plr.dir=plr.sdir
end
end
for i in all(self.sp) do
if i!=bl then
if can_warp then
i.pal=grpal
else
i.pal=drpal
end
end
end
self:be_plr_sword()
p_w(bl,self.dir,51)
if self.l==0 then
for i in all(self.sp) do
i.fk=true
end
sb.fk=false
local px,py=plr.x,plr.y
if plr.sdir==0 then
self.x,self.y,sb.x=px+16,py,-8
elseif plr.sdir==0.25 then
self.x,self.y,sb.y=px,py-16,8
elseif plr.sdir==0.5 then
self.x,self.y,sb.x=px-16,py,8
elseif plr.sdir==0.75 then
self.x,self.y,sb.y=px,py+16,-8
end
end
end
return teleport
end
function wrpt(x,y,a)
if (not a) a=plr
x,y=clamp(x,0,cam_w-8),clamp(y,0,cam_h-8)
if (is_solid(x+4,y+4)) return false
if a==plr then
for i=0,20 do
add_ac(
exn:new({x=a.x+rnd(7),y=a.y+rnd(12)-4,
size=rnd(5),col=6+rnd(2)})
)
end
end
a.x,a.y,a.holes_dist=x,y,1.5
return true
end
function new_bow(direc,arrow_type)
local sb=ns(32)
local cd,ar=30,arrow:new({dir=direc})
if arrow_type==1 then
ar=b_a:new({dir=direc})
cd=120
elseif arrow_type==2 then
ar=t_a:new({dir=direc})
cd=90
end
add_ac(ar)
bow=ac:new({l=-1,dist=4,dir=direc,
move_spd=0.035,sp={sb},bl=sb,
arrow=ar,cd=cd})
function bow:up()
local bl=self.bl
if self.l>0 then
self.l-=1
elseif self.l==0 then
self.dead=true
plr.dir=plr.sdir
elseif not btn(4) then
self.l=6
self.dist-=2
self.bl.s+=1
self.arrow.gng=true
inv[1].use_t=self.cd
inv[1].use_t_max=self.cd
sfx(4)
end
for i in all(self.sp) do
if i!=bl then
if can_warp then
i.pal=gpal
else
i.pal=drpal
end
end
end
self:be_plr_sword()
bl.f=d_d(0,self.dir)>0.25
bl.vf=d_d(0.25,self.dir)>0.25
if self.l<0 then
bl.s=34
if d_d(0.25,self.dir)<0.0625
or d_d(0.75,self.dir)<0.0625 then
bl.s=34
end
if d_d(0,self.dir)<0.0625
or d_d(0.5,self.dir)<0.0625 then
bl.s=32
end
self.arrow.x=self.x
self.arrow.y=self.y+0.01
if self.dir==0 or self.dir==0.5 then
self.arrow.y+=3
else
self.arrow.x+=2
end
end
end
return bow
end
function next_it()
for i=1,#inv do
inv[i-1]=inv[i]
end
inv[#inv]=inv[0]
inv[0]=nil
end
function prev_it()
for i=2,#inv do
next_it()
end
end
function copy_sp(list)
local nl={}
for k,v in pairs(list) do
nl[k]=v:new()
end
return nl
end
function cat(s,i)
return sub(s,i,i)
end
function cti(c)
for i=0,31 do
if cat("0123456789abcdefghijklmnopqrstuv",i+1)==c then
return i
end
end
end
function s_t_a(s)
-- a={}
-- for i=1,#s+1 do
-- add(a,cti(cat(s,i)))
-- end
a=split(s)
return a
end
grpal=s_t_a("0,3,5,3,5,5,6,7,11,11,11,11,11,6,6,7")
opal=s_t_a("0,2,5,4,5,5,6,7,9,9,9,9,9,6,6,7")
gpal=s_t_a("0,5,5,5,5,5,7,7,7,7,7,7,7,7,7,7")
drpal=s_t_a("0,2,5,2,5,5,6,8,8,8,8,8,8,6,6,8")
dpal=s_t_a("0,0,0,5,2,0,5,6,2,4,9,3,1,5,2,15")
function _draw()
if ti_count then return end
if won and won_t>2 then
if won_t>64 then
print("      congratulations!\n\n       you have found\n     the book of truth!\n\n\n\n\n\n\n\n\n\n      your time: " .. mi .. ":" .. sd .."\n         deaths: "..deaths,8,14,7)
end
return
end
if dap and dapc>=4 then
plr:dw()
else
cls()
local add_x,add_y=0,0
local is_tr=tr_x!=0 or tr_y!=0 or tr_z>150
if is_tr then
my_c=16
if tr_y>0 then
add_y=128
elseif tr_y<0 then
add_y=-128
end
if tr_x>0 then
add_x=128
elseif tr_x<0 then
add_x=-128
end
camera(cam_x-tr_x+add_x,cam_y-tr_y+add_y)
dw_map()
my_c=0
end
camera(cam_x-tr_x,cam_y-tr_y)
if (tr_z<=150) dw_map()
for a in all(acs) do
a:dw()
end
if (gi!=nil) gi:dw()
if is_tr then
my_c=16
camera(cam_x-tr_x+add_x,cam_y-tr_y+add_y)
dmtl()
my_c=0
end
camera(cam_x-tr_x,cam_y-tr_y)
if (tr_z<=150) dmtl()
camera()
dw_it_menu()
dw_hp()
if ti then
cls()
for i=0,63 do
for j=0,31 do
pset(i,j,mget(i,j))
pset(i,j+32,mget(i+64,j))
end
end
end
if tr_z>0 then
rectfill(tr_z-172,0,tr_z,128,0)
end
end
if f_a then
rectfill(0,68,127,100,0)
s="          fusion altar\n\n\n\n Ž - fuse items   — - go back"
if  #inv>=4 then
s="          fusion altar\n\n  ‹                       ‘\n\n Ž - fuse items   — - go back"
end
print(s,0,69,7)
camera(f_c,0)
for i=0,5 do
spr(106+i,36+48*i,80)
end
end
end
function r_p()
pal()
palt(0,false)
palt(14,true)
end
function dw_map()
map(mx_c,my_c,map_dw_x_c,map_dw_y_c,16,16)
end
function dmtl()
for x=mx_c,mx_c+15 do
for y=my_c,my_c+15 do
local til=mget(x,y)
local xv,yv=(x-mx_c)*8,(y-my_c)*8
if til==158 then
spr(142,xv,yv-8)
elseif til==159 then
spr(143,xv,yv-8)
end
if y==my_c+15 then
til1=mget(x-1,y)
til2=mget(x+1,y)
if (til1==159 or til1==158 or x==mx_c) and (til2==159 or til2==158 or x==mx_c+15) then
if til==159 then
spr(142,xv,yv)
elseif til==158 then
spr(143,xv,yv)
end
end
end
end
end
if ins or tr_z>150 then
rectfill(-4,-4,128,-1,0)
rectfill(-4,-4,-1,128,0)
end
map(mx_c,my_c,map_dw_x_c,map_dw_y_c,16,16,128)
end
function dw_it_menu()
local a_m=127-imoc
rectfill(0,-1,127,imoc,0)
rectfill(128,0,a_m,127,5)
line(a_m,0,a_m,127,7)
line(0,imoc,a_m,imoc,7)
name=inv[1].name
print(name,110-4*#name,imoc-10,7)
rectfill(115,1,126,12,0)
pos=0
for i in all(inv) do
x=117
if pos>0 then
x=131-imoc
end
y=((pos+it_sw_oft)*128/#inv+3)%128
rectfill(x-1,y-1,x+8,y+8,0)
if i.use_t then
fraction=(1-(i.use_t/i.use_t_max))*9
rectfill(x-1,y+fraction,x+8,y+8,13)
end
spr(i.s,x,y)
pos+=1
end
rect(115,1,126,12,1)
for i=1,keys do
spr(55,i*8-6,imoc-11)
end
end
function dw_hp()
local i3,i7=imoc+3,imoc+7
rectfill(2,i3,3+max_hp,i7,0)
rectfill(2,i3,2+prev_hp,i7,10)
rectfill(2,i3,2+show_hp,i7,8)
rectfill(2,imoc+6,2+show_hp,i7,2)
rect(2,i3,3+max_hp,i7,5)
end
function apply_pal(p)
for i=0,15 do
pal(i,p[i+1],1)
end
end
function apply_pal_pset(p)
for x=0,127 do
for y=0,127 do
local col=pget(x,y)
pset(x,y,p[col+1])
end
end
end
__gfx__
eeeeeeeeee0000eeee0000eeee0000eeee0000eeee0000eee0eeeeeeee0000ee8888888800000000e9aaaaeee77777eeaaaeeeeeee000eeeeeee000eeeeeeeee
ee0000eee011110ee011110ee011110ee011110ee011110e0f0eeeeee011110e88888888000000009aae9aae7eeeee7eaeaeeeeee0aaa0eeeee0aaa0eeeeeeee
e0cccc0e0111111001110110011110100111111001111110e0eeeeee0111111088888888000000009aae9aae7eeeee7eaaaeeeeee0a0a0eeeee0a0a0eeeeeeee
0cccccc0010100100100f00001100f000111110001111110eeeeeeee011111108888888800000000e9aaaaeee7eee7eeeaeeeeeee0aaa0eeeee0aaa0eeeeeeee
0cccccc00070f70000f77f70011077f0011110f000111100eeeeeeee010100108888888800000000ee9aaeeeee7e7eeeeaaeeeeeee0a0eeeee0a000eeeeeeeee
01cccc10070ff0700ff70f70000f70f000000ff00f0000f0eeeeeeee006066008888888800000000ee9aaaeeee7e77eeeaaeeeeeee0aa0eee0a0eeeeeeeeeeee
e011110ee0ffff0ee0ffff0ee0ffff0ee0ffff0ee0ffff0eeeeeeeeee0ffff0e8888888800000000ee9aaeeeee7e7eeeeeeeeeeeee0aa0ee0aa0eeeeeeeeeeee
ee0000eeee0000eeee0000eeee0000eeee0000eeee0000eeeeeeeeeeee0000ee8888888800000000ee9aaaeeee7777eeeeeeeeeeeee00eeee00eeeeeeeeeeeee
eeeeeeeee00e00eeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000e00000000eeeee000ee000eeeeeeeeeeeeeeee00ee000eeeee000eeeeeeeeeeee
ee0000ee0880880eee0110eeeee0eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0aaa000000000eeee06d0ee0420eeeee00eeeeeee07b0e0420e00e0420eeeeee00eee
e0cccc0e0888880eee0ff0eeee0f0eeeeeeeeeeeee7e7eeeeeeeeeeeeee0a0a000000000e0e06d60ee70420eee0550eeeeee0b30e7040070e704000eee0550ee
0cccccc0e08880eee0e00e0eee0c0eeeeee7eeeeeee7eeeeeeeeeeeeeee0aaa0000000000c06d60eee7e040ee011110eeee0400ee7000110e70007b0e077bb0e
0cccccc0ee080eeeee0cc0eeeee0eeeeeeeeeeeeee7e7eeeeeeeeeeeee0a000e000000000c0d60eeee7e040ee011110eee040eee0744011007440b30e077bb0e
01cccc10eee0eeeeee0110eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0a0eeee00000000e0c00eeeee70420ee011110ee040eeeee700000ee700000ee0bb330e
e001110eeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0aa0eeee000000000c0cc0eeee0420eee011110e040eeeeee0420eeee0420eeee0bb330e
e00000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeee00000000e0e00eeeee000eeeee0000ee00eeeeeee000eeeee000eeeeee0000ee
eeee42eeeeeeeeeeee2222eeeee222ee67eeee6ee6eeeeee67eee111111eeeee67eee77bb33eeeeeeeeeeeeeeee00eeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeee
eee7e42eeeee42eee244442eee24442ee6744466666eeeeee6744111111eeeeee67447b37b3eeeeeeee00eeeee0550eeeee00eeeeee00eeeee0550eeeee00eee
ee7eee42eeee742e24eeee42e24eee4267eeee6ee4eeeeee67eee611116eeeee67eeeb3377beeeeeee0550eee011110ee005500eee0550eee077bb0ee005500e
e07eee42eeee7e424eeeeee4e4777774eeeeeeeee4eeeeeeeee77eeee4e7eeeeeeeeeeeee4eeeeeee011110ee011110e01111110e077bb0ee077bb0e0777bbb0
0f0eee42eeee7e42e7eeee7eeeeeeeeeeeeeeeeee4eeeeeeeeeeeeeee4e7eeeeeeeeeeeee4eeeeeee011110ee011110e01111110e077bb0ee077bb0e0777bbb0
e07eee42eeee7e42ee7707eeeeeeeeeeeeeeeeeee7eeeeeeeeeeeeeee7eeeeeeeeeeeeeee7eeeeeee011110ee011110e01111110e0bb330ee0bb330e0bbb3330
eee7e42eeeee742eeee0f0eeeeeeeeeeeeeeeeee767eeeeeeeeeeeee767eeeeeeeeeeeee767eeeeee011110ee011110e01111110e0bb330ee0bb330e0bbb3330
eeee42eeeeee42eeeeee0eeeeeeeeeeeeeeeeeee6e6eeeeeeeeeeeee6e6eeeeeeeeeeeee6e6eeeeeee0000eeee0000eee000000eee0000eeee0000eee000000e
eeeeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeeeeee7beeeeee44eeeeeaaaaeeeee00eeeeeeeee6666eeee44eeee666eeeeee7bee17eee447beeee44eeee666e
eeeeeeeeeeeeeeeeeee6deeeeeeeeeeeeeee7beeee77bbeeeec44ceeeaaeeaaeee0440eeeeeee6d662ee44e7eee55ee6eeee77bb111744e7b3ee44e7eee55ee6
eceeeeeeeeee66deeee6deeeeeeee7beeee77bbeeebb33eeeecccceeeaaeeaaeee0000eeeeee6d6eee24ee7ee1111ee6eeeebb33e124ee7eee24ee7ee77bbee6
1c66666eeee66deeeee6deee444477bbeeebb33eeeeb3eeeec8888ceeeaaaaeee0cccc0ecee6d6eeee42e7ee111771eeeee4db3eee42e7eeee42e7ee777bbbee
1cddddddee66deeeeee6deee2222bb33ee44b3eeeee42eeeec8888ceeeeaaeeee088880ecc6d6eeee4ee2eee111171eeee4d2eeee4ee2eeee4ee2eee777bbbee
eceeeeeec66deeeeeee6deeeeeeeeb3ee442eeeeeee42eeeec8888ceeeeaaaeee088880eecc6eeeee4e7e27e111111eee4d2eeeee4e7e27ee4e7e27ebbb333ee
eeeeeeeeccdeeeeeeecccceeeeeeeeee442eeeeeeee42eeeec8dd8ceeeeaaeeee088880ec1cceeee4e7ee767111111ee4d2eeeee4e7ee7674e7ee767bbb333ee
eeeeeeee1cceeeeeeee11eeeeeeeeeee42eeeeeeeee42eeeeecccceeeeeaaaeeee0000eeececceee47eeee7ee1111eee42eeeeee47eeee7e47eeee7eebb33eee
eeeeeeeeeee11eee77ee76666667ee77eeeeeeee77eee77700000000eeeeeeee00000000000000000000000000000000000000000000000000000000e2222222
eeeeeeeeee1cc1ee66ee66600666ee66eeeeeeee66ee766600000000eeeeeeee0000000000000000000000000000000000000000000000000000000047777772
ee1111eee1cccc1e6677660000667766eeeeeeee6677666000000000eeeeeeee0000000000000000000000000000000000000000000000000000000044444472
e1cccc1ee1cccc1e6666660000666666eeeeeeee6666660000000000eeeeeeee000000000000000000000000000000000000000000000000000000004ffff472
1cccccc1e1cccc1e6666666006666666eeeeeeee6666666000000000eeeeeeee000000000000000000000000000000000000000000000000000000004ffff472
1cccccc1e1cccc1e6655660000665566eeeeeeee6655660000000000eeeeeeee0000000000000000000000000000000000000000000000000000000044444472
e111111eee1111ee66ee56666665ee66ee7777ee66ee566600000000ee7777ee0000000000000000000000000000000000000000000000000000000044004422
eeeeeeeeeeeeeeee55ee55555555ee55e766667e55ee555500000000e766667e00000000000000000000000000000000000000000000000000000000444444ee
11eeeeeeeeeeeeeeeeeeee11eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77ee766677ee666600000000000000000000000000000000000000000000000000000000
111eeeee1eeeeee1eeeee1111eeeeee1ee1111eeee1111eeeee1111166ee666066ee666600000000000000000000000000000000000000000000000000000000
e111111e11eeee11e111111e11eeee11e1cccc1ee1cccc1eeee1c1c1667766006677666000000000000000000000000000000000000000000000000000000000
ee111c1e11111111e1c111ee111111111cccccc11cccccc1eee11111666666006666660000000000000000000000000000000000000000000000000000000000
eee11111e111111e11111eeee1c11c1e1cccccc11cccccc1eee1c1c1666666606666666000000000000000000000000000000000000000000000000000000000
eeee1111e111111e1111eeeee111111e11cccc1111cccc11eee1c1c1665566006655660000000000000000000000000000000000000000000000000000000000
eeeeee11ee1111ee11eeeeeeee1111eee111111ee111111eeeee111e66ee566666ee566600000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeee11eeeee1111eee11111eeeeeeeeee55ee555555ee555500000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000eeeeeeeeeeeeeeee0000000000000000000000000000000066eeee44eeee666eeeeee7be66eeee44eeee666eeeeee7be
00000000000000000000000000000000ee1111eeee1111ee0000000000000000000000000000000062ee44e7eee55ee6eeee77bb62ee44e7eee55ee6eeee77bb
00000000000000000000000000000000e1cccc1ee1cccc1e00000000000000000000000000000000ee24ee7ee1111ee6eeeebb33ee24ee7ee1111ee6eeeebb33
000000000000000000000000000000001cccccc11cccccc100000000000000000000000000000000ee42e7ee111771eeeee4db3eee42e7ee111771eeeee4db3e
000000000000000000000000000000001cccccc11cccccc100000000000000000000000000000000e4ee2eee111171eeee4d2eeee4ee2eee111171eeee4d2eee
0000000000000000000000000000000011cccc1111cccc1100000000000000000000000000000000e4e7e27e111111eee4d2eeeee4e7e27e111111eee4d2eeee
00000000000000000000000000000000e111111ee111111e000000000000000000000000000000004e7ee767111111ee4d2eeeee4e7ee767111111ee4d2eeeee
00000000000000000000000000000000ee1111eee11111ee0000000000000000000000000000000047eeee7ee1111eee42eeeeee47eeee7ee1111eee42eeeeee
bbbbbbbb49544594ee0000eeee0000eeee0000ee00000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeee0eeee00000000
0000000000000000e055550ee011110ee099990e00000000000000000000000000000000000000000000000000000000eeeeeeeeeee0eeeeee000eee00000000
0555555005555550e056550ee01c110ee09a990e00000000000000000000000000000000000000000000000000000000eee0eeeeeee00eeeee00000e00000000
055555500555555000555500001111000099990000000000000000000000000000000000000000000000000000000000eee000eeee00000ee000000000000000
000000000000000000555500001111000099990000000000000000000000000000000000000000000000000000000000ee000eeee00000ee0000000e00000000
098aa8900d1661d006000060060000600600006000000000000000000000000000000000000000000000000000000000eeee0eeeeee00eeee00000ee00000000
098888900d1111d00dddddd00dddddd00dddddd000000000000000000000000000000000000000000000000000000000eeeeeeeeeeee0eeeeee000ee00000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeee0eee00000000
ff5005ff777777777777777777777777cccccccccccccccc5000000000000005bb00000000000000000000bbffffffffffffffffffffffffeeeee000000eeeee
f005500f711771177117711771177117cccccccccccccccc0244244444424420b0022000220000220002200bff33ffb33fb3ffb33bff33ffeee0333333330eee
051551d0711111111111111111111117cccccccccccccccc0444442442444440002222222222222222222200f3bbb3bbb3bbb3bbbb3bbb3fee033303303330ee
0d511550771111111111111111111177cccccccccccccccc0240000000000420022222222222222222222220ffbbbbbbbbbbbbbbbbbbbbffe03003333330030e
00d5d50077111cc11cc11cc11cc11177cccccc1111cccccc0440222222220440022220000000000000022220fffbbbbbbbbbbbbbbbbbbfffe33333333333333e
005d5500711cccccccccccccccccc117ccccc111111ccccc0420244224420240022202444244424444202220ff3bbbbbbbbbbbbbbbbbb3ff0303333333333030
05d55d50711cccccccccccccccccc117cccc11177111cccc0440204444020440002204444442444244402200f3bbbbbbbbbbbbbbbbbbbb3f3333333333333333
f000000f7711cccccccccccccccc1177cccc11777711cccc0240200440020420002204400000000004402200ffbbbbbbbbbbbbbbbbbbbbff0330033333300330
ffffffff7711cccccccccccccccc1177cccc11777711cccc0240220000220420002204404444444404402200ffbbbbbbbbbbbbbbbbbbbbff0333333333333330
ff5fffff711cccccccccccccccccc117cccc11177111cccc0440222002220440002202404242444404202200f3bbbbbbbbbbbbbbbbbbbb3f0030333333330300
f566ff5f711cccccccccccccccccc117ccccc111111ccccc0420222222220240022204404424444404402220ff3bbbbbbbbbbbbbbbbbb3ff0303030330303030
fffff6657711cccccccccccccccc1177ccccc111111ccccc0440422222240440022204204444444402402220fffbbbbbbbbbbbbbbbbbbfffb03000300300030b
ffffffff7711cccccccccccccccc1177cccccc1111cccccc0240000000000420022204404444444404402220ffbbbbbbbbbbbbbbbbbbbbff0000300000030000
ff5fffff711cccccccccccccccccc117cccccccccccccccc0444442442444440002202404444242404202200f3bbbbbbbbbbbbbbbbbbbb3f0044004444004400
f565ffff711cccccccccccccccccc117cccccccccccccccc0244244444424420000204404444424404402000ff3bbbbbbbbbbbbbbbbbb3ff0000440440440000
ffffffff7711cccccccccccccccc1177cccccccccccccccc5000000000000005002204204444444402402200fffbbbbbbbbbbbbbbbbbbfffbb000000000000bb
55577555661111111111111111111166cccccccc022244444444444444442220002204400000000004402200ffbbbbbbbbbbbbbbbbbbbbffcc000000000000cc
85977958611111111111111111111116cccccccc022444444242444444444220002204444442444244402200f3bbbbbbbbbbbbbbbbbbbb3fc00220000002200c
85999958611111111111111111111116ccccc77c022444444424444444444220022202444244424444202220ff3bbbbbbbbbbbbbbbbbb3ff0022222222222200
55555555661111111111111111111166cccccccc022444444444444444444220022220000000000000022220fffbbbbbbbbbbbbbbbbbbfff0222222222222220
00000000661111111111111111111166cccccccc002244444444444444442200022222222222222222222220ffbbbbbbbbbbbbbbbbbbbbff0222200000022220
55555555611111111111111111111116c77ccccc000244444422224444442000002242222224422222242200f3bbb33bb3bb33bbbb33bb3f0222024444202220
55555555611111111111111111111116cccccccc002244442200002244442200000244244244442442442000ff333ff33f33ff3333ff33ff0022044444402200
00000000661111111111111111111166cccccccc0224444420eeee0244444220002244444444444444442200ffffffffffffffffffffffff0022044004402200
bb0000bb99949994999099909999999999999999444444420000000024444444022444444444444444444220bbbbbbbbbbbbbbbbffffffffffffffffffffffff
b099990b99949994949494949499999999999949444444420000000024444444022444444242444444444220bbbbbb3bb77bbbbbfffffffff99fffffffffffff
b09a990b99949994999499949999999999999999444444200000000002444444022444444424444444444220bbbb3b3b7337bbbbfffffffff99ffffff9ffffff
0099990099949994999499940444444444444440444444200000000002444444022444444444444444444220bbbbbbbbb77bbbbbffffffffffffffffffffffff
0099990099949994999499949999999999999999224444420000000024444422022244222244442222442220bbbbbbbbbbbbb77bffffffffffffffffffffffff
0600006099949994999499949499999999999949222224420000000024422222022222222222222222222220b3bbbbbbbbbb7337ffffffffffffff9ffffff99f
0dddddd094949494999499949999999999999999222222200333333002222222002222222222222222222200b3b3bbbbbbbbb77bfffffffffffffffffffff99f
0000000099909990999499940444444444444440000000003bbbbbb300000000000000000000000000000000bbbbbbbbbbbbbbbbffffffffffffffffffffffff
6665666666665666665666666656666666566666665666666660cccd0ccd0cd00dc0dcc0dccc06660dddddddddddddd049544594495400000000000049000094
6665666666665666665666666656666666566666665666666660cccd0ccd0cd00dc00000dccc0666d0cccccccccccc0d9544445995000ff00000000090111109
666566666666566666566666665666666656666666566666666000000ccd00000dc0dcc0dccc0555dc0cccccccccc0cd54499445000f0ff000000000501c1105
5550000000000555000000000000000000000000000000006660cccd0ccd0cd00dc0dcc0dccc0666dcc0cccccccc0ccd449449440f0f0ff00000000000111100
66600cccccc00666ccccc0ccccccc0ccccccc0ccccccc0cc6660cccd0ccd0cd00dc0dcc0dccc0666dccc00000000cccd449449440f0f04400000000000111100
6660c0cccc0c0666ccccc0cccc06666666666666666660cc5550cccd0ccd0cd00000dcc000000666dccc06666660cccd544994450f0400000000000006000060
6660cc0cc0cc0666ccccc0cccc0dddddddddddddddddd0cc6660cccd00000cd00dc0dcc0dccc0666dccc06666660cccd9544445904000000000000000dddddd0
6660ccc00ccc0666ddddd0dddd00000000000000000000dd6660cccd0ccd0cd00dc0dcc0dccc0666dccc06666660cccd49544594000000000000000000000000
6660ccc00ccc0666000000000000060005888888006000006660cccd0ccd0cd00dc0dcc0dccc0666dccc06666660cccdb000000b400000044000000449544594
6660cc0cc0cc0666c0ccccccc0cc0d000888668800d0cccc6660cccd0ccd0cd00dc00000dccc0666dccc06666660cccd07877870071771706055550666666666
6660c0cccc0c0666c0ccccccc0cc0d000888668800d0cccc666000000ccd00000dc0dcc0000c0555dccc06666660cccd0a8aa8a0061661606055550660000006
66600cccccc00666d0ddddddd0dd0000058888880000dddd6660c6d00ccd0cd00dc0dcc00d6c0666dccc00000000cccd099999900dddddd06055550660555506
5550000000000555000000000000006000022220060000006660c6d000000cd00dc000000d6c0666dcc0cccccccc0ccd00000000000000006000000660555506
6665666666665666ccccc0ccccccc0d0055588550d0cc0cc5550c6d06dd0000000000dd60d600666dc0cccccccccc0cd098aa8900d1661d060dddd0660555506
6665666666665666ddddd0ddddddd0d0055555550d0dd0dd6660c6d000006dd00dd600000d6c0666d0cccccccccccc0d098888900d1111d06000000660000006
6665666666665666000000000000000000000000000000006660c6d000000000000000000d6c06660dddddddddddddd000000000000000006666666666666666
0000000000000000000000000000000044444444000000006660c6d0dddd00044000dddd0d6c066600000000000000000000000040000000bb0000bb49000094
00ccccccc0cccc00dd0ddddddd0dd0d0424244440d0ddddd6660c6d0dddddd5995dddddd0d6c066600dddddddddddd000000000095000000b055550b90999909
0c0cccccc0ccc0c0cc0ccccccc0cc0d0442444440d0ccccc666006d0dddddd4554dddddd0d6c05550d0cccccccccc0d00000000054000000b056550b509a9905
0cc0ddddd0dd0cc0000000000000006044444444060000006660c6d0d1d1d14444d1d1d10d6c06660dc0000000000cd000000000440000000055550000999900
0ccd00000000dcc0dddddd0ddddd00002244a4220000dd0d6660c6d01d1d1d44441d1d1d0d6c06660dc00dddddd00cd000000000440000000055550000999900
0ccd00cccc00dcc0cccccc0ccccc0d00222a922200d0cc0c5550c6d0dddddd4554dddddd0d6006660dc0d0cccc0d0cd000000000540000000600006006000060
00000c0dd0c0dcc0cccccc0ccccc0d002227722200d0cc0c6660c6d0dddddd5995dddddd0d6c06660dc0dc0cc0cd0cd005444450950000000dddddd00dddddd0
0ccd0cd00dc0dcc0000000000000060000077000006000006660c6d0dddd00044000dddd0d6c06660dc0dcc00ccd0cd049544594400000000000000000000000
0ccd0cd00dc0dcc0dd0ddddddd00000000000000000000dd6660c6d000000000000000000d6c06660dc0dcc00ccd0cd000000004495445948888885000000000
0ccd0c0dd0c00000cc0ccccccc0dddddddddddddddddd0cc6660c6d000006dd00dd600000d6c06660dc0dc0cc0cd0cd000000059054444508866888000000000
0ccd00cccc00dcc0cc0ccccccc06666666666666666660cc666006d06dd0000000000dd60d6c05550dc0d0cccc0d0cd000000045000000008866888000000000
0ccd00000000dcc0cc0ccccccc0ccccccc0ccccccc0ccccc6660c6d000000cd00dc000000d6c06660dc00dddddd00cd000000044000000008888885000000000
0cc0dd0ddddd0cc0000000000000000000000000000000006660c6d00ccd0cd00dc0dcc00d6c06660dc0000000000cd000000044000000000222200000000000
0c0ccc0cccccc0c0666665666666656666666566666665665550c0000ccd0cd00000dcc0000006660d0cccccccccc0d000000045000000005588555000000000
00cccc0ccccccc00666665666666656666666566666665666660cccd00000cd00dc0dcc0dccc066600dddddddddddd0000000059000000005555555000000000
0000000000000000666665666666656666666566666665666660cccd0ccd0cd00dc0dcc0dccc0666000000000000000000000004000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030000000000000000000000000000
0800000000000303030303000000000000000000000003030303030000000303000000000003830303030300000003030000000000030003030303000000000083838383838383030383838300000000838303030003830303838383030300000303030303038303038303030303000003038383838383030383030303030080
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000606060606060608080808080808080006060608080800000808000606080808000008080006060e0808000606080800060606060606060606060606060600
00000000000000000000000000000000000000000606060606060606060606060606060606060606060606050000000000000000000000000000000000000000000606060606060608080800000808080800060e0808000606080800060e08080006060808000606080808000e08080800060606060606060606060606060600
0000000000000000000005060606060606060606060606060606060606060606060606060606060606060606060606060606060606050000000000000000000000060606060606060808080006000808080006080808000606080800060808080006060808000606080808080808080006060606060000060000000606060600
00000000000005060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060605000000000000000606060606060e0808000606060808080006080800060606080800060808000606060808000606080808080808000606060606000600060006060606060600
000000000506060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060605000000000006060606060608080800060606080808000608080006060e0808000608080006060e080800060e080800080808000606060606000600060000060606060600
00000000060606060606060e080808080800060606060606060606060606060606060606060606060606060606060606060606060606060606060606000000000006060606060e0808080006060e0808080006080800060608080800060808000606080808000608080800000808080006060606000600060006060606060600
0000000506060606060608080808080808080006060606060606060606060606060606060606060606060606060606060606060606060606060606060500000000060606060e08080808080808080808000606000808080808080006060008080808080800060608080800060008080006060606000006060006060606060600
0000000606060606060808080000000008080800060606060606060606060606060606060606060606060606060606060606060606060606060606060600000000060606060808080808080808080800050606060008080808000606060600080808080006060608080800060608080006060606060606060606060606060600
00000006060606060e0808000606060600080800060606060606060606060606060606060606060606060606060606060606060608080006060606060600000000060606060000000000000000000006060606060600000000060606060606000000000606060600000000060600000006060606060606060606060606060600
0000000606060606080808000606060606080808000606060606060606060606060606060606060606060606060606060606060608080006060606060600000000060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060600
000005060606060e080800060606060606080808000608080006060808000606060e08080800060606060e08080808000606080808080808000606060605000000060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060600
00000606060606080808000606060606060808080006080800060608080006060e08080808080006060e0808080808080006080808080800060606060606000000050606060606060606060808080808080808080808000606060606060606060606060606060606060606060606060606060606060606060606060606060500
0000060606060608080800060606060608080808000608080006060808000606080800000008080006080800000000000006000808000006060606060606000000000606060606060606080808080808080808080808000606060606060606060606060606060606060606060606060606060606060606060606060606060000
0000060606060608080800060606060608080800060e0808000606080800060e080800060608080006080800060606060606060808000606060606060606000000000606060606060608080808080808080808080800060606060606060606060606060606060606060606060606060606060606060606060606060606060000
00000606060606080808000606080800080808000608080006060e0808000608080808080808080006080808080800060606060808000606060606060606000000000606060606060600000000000808080000000006060606060606060606060606060606060606060808000606060608080800060606060606060606060000
00000606060606080808000606080800080808000608080006060808000606080808080808080800060608080808080006060e0808000606060606060606000000000606060606060606060606060808080006060606060606060606060606060606060606060606060808000606060608080800060606060606060606060000
00000606060606000808000606080808080800060608080006060808000606080808000000000006060606060808080800060808000606060606060606060000000006060606060606060606060e0808000506060808000808080800060608080006060808000608080808080800060608080006060606060606060606060000
0000060606060606080808000606080808000006060808000606080800060608080800060606060608080006060608080006080800060e08000606060606000000000606060606060606060606080808000606060808080808080808000608080006060808000608080808080800060608080006060606060606060606060000
0000060606060606000808080808080808080006060808080808080800060600080808080808000608080808080808080006080808080800060606060606000000000606060606060606060606080808000606060808080800000808000608080006060808000600080800000006060e08080006060606060606060606060000
000006060606060606000008080808000808080006000808080800080800060600080808080800060008080808080800060600080808000606060606060600000000060606060606060606060e0808000506060e0808000006060000060e08080006060808000606080800060606060808080808000606060606060606060000
00050606060606060606060000000006000808000606000000000600000606060600000000000606060000000000000606060600000006060606060606060500000006060606060606060606080808000606060808080006060606060608080006060e0808000606080800060606060808080808080006060606060606060000
000606060606060606060606060606060600000006060606060606060606060606060606060606060606060606060606060606060606060606060606060606000000050606060606060606060808080006060608080800060606060606080800060608080006060e080800060606060808000008080800060606060606050000
0006060606060606060606060606060606060606060606000000060600000600000006060606000000060006000600000006060606060606060606060606060000000006060606060606060e080800050606060808080006060606060608080006060808000606080800060606060e0808000600080800060606060606000000
000606060606060606060606060606060606060606060600060606000600060006000606060606000606000600060006060606060606060606060606060606000000000606060606060606080808000606060e080800060606060606060808000606080800060608080006060606080800060606080800060606060606000000
000606060606060606060606060606060606060606060600000606000600060000060606060606000606000000060000060606060606060606060606060606000000000606060606060608080808000606060808080006060606060606080808080808080006060808080808060e08080006060e080800060606060606000000
0006060606060606080808080808080808000606060606000606060006000600060006060606060006060006000600060606060606060606060606060606060000000005060606060608080808080800060608080800060606060606060008080808000808000600080808000608080800060608080800060606060605000000
0006060606060606000808080808080808080006060606000606060000060600060006060606060006060006000600000006060606060606060606060606060000000000060606060600000000000000060600000000060606060606060600000000060000060606000000060600000000060600000006060606060600000000
0006060606060606060008080800000808080006060606060606060606060606060606060606060606060606060606060606060606060606060606060606060000000000050606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060500000000
0006060606060606060808080006060008080006060606060606060606060606060606060606060606080808000606060606060606060606060606060606060000000000000005060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060605000000000000
0006060606060606060808080006060808080006060606060606060606060606060606060606060606080808000606060606060606060606060606060606060000000000000000000000050606060606060606060606060606060606060606060606060606060606060606060606060606060606060500000000000000000000
0006060606060606060808080808080808000606060e0808080006060606060e080808000606060606080808000606060606060606060606060606060606060000000000000000000000000000000000000000000506060606060606060606060606060606060606060606050000000000000000000000000000000000000000
00060606060606060e08080808080808000606060e0808080808000606060e08080808080006060606080808000606060606060606060606060606060606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000e0502b050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001663015640146501364012630116200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00000e62500000000000060513625006050060500605136250e6251362500605136250060500000006050e6250e6250e6250060513625006050060500605136250e625136250060513625006051362500605
000100001855022550145501f550115501a5500d550000000c55000000000000e550000001b550000002454020600216002560000000000000000000000000000000000000000000000000000000000000000000
000100002055014550215501852000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000024450224501f4501b45019450174301545015420144401241012430124101242011410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000294502d3502555024550225502155022550215501e350275502a5502b5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002365026650276502a6502a6502865025650206501d6501b650196501765015650156501565016650186501a6501f65030500206401e6002c5001c6300000000000166200000000000000000000000000
000300002d0502f050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00200c5530c5030c5530c5530c5530c5030c553105030e5530c5030e5530e5530e5530c5000e5531050315553135031555315553155530c50315553175031155311553115531155315503115531155300500
010c000024050240502405024050240422403224022240151f0501f0501f0421f0321f0221f015260502605529050290502905229052280502805028055260502805028050280502805228042280322802228015
010c00002d0502d0502905029050260502605023050230552b0502b050280502805024050240501f0501f05500000000002605026050280502805029050290502b0502b0502b0522b0522b0422b0322b0222b015
010c00000232500005023250000502325000050232500005073250000502325000050232500005023250000509325000050232500005023250000502325000050732500005003250000500325000050032500005
010c00001d233000031d23300203002030020300203002031c233002031c233002030020300203002030020300203002032b2032b2032d2032d2032f2032f2032d2332d2332b2332b23329223292232821328213
010c00002d0502d0502905029050260502605023050230552b0502b050280502805024050240501f0501f05500000000002905029050260502605023050230502405024050240522405224042240322402224015
010400001d555000051c555000051a555000051955500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000000000000000000000000
000300002b0502d0502e0502d0502c0502b05029050280502605023050210501f0501c05019050160501405012050100500e05000000000000000000000000000000000000000000000000000000000000000000
010500001f1500000023150001001c150340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001a7521a7521a7521a7551d7521d7521d7521d7551c7521c7521c7521c7551d7521d7521d7521d7551a7521a7521a7521a7551d7521d7521d7521d7551c7521c7521c7521c7551d7521d7521d7521d755
010500001065010640106330c6000c6001064010630106230c6000c600106401063010623000000c6000c6000c600000000000000000000000000000000000000000000000000000000000000000000000000000
010800002603026030260302603026030260302603026030260302603026030260302603026030260302603021030210302103021030210302103021030210302403024030240302403024030240302403024030
01080000220302203022030220302203022030220302203022030220302203022030220302203022030220301f0301f0301f0301f0301f0301f0301f0301f0302203022030220302203022030220302203022030
01080000187321873218732187351c7321c7321c7321c735187321873218732187351c7321c7321c7321c735187321873218732187351c7321c7321c7321c735187321873218732187351c7321c7321c7321c735
0108000021030210302103021030210302103021030210301f0301f0301f0301f0301f0301f0301f0301f0301d0301d0301d0301d0301d0301d0301d0301d0301c0301c0301c0301c0301c0301c0301c0301c030
010400002315023140231301f1501f1401f1301e1501e1401e1301a1501a1401a1301f1501f1501f1501f1421f1321f1220010000100001000010000100001000000000000000000000000000000000000000000
010400001a1501a1501a1501c1501c1501c1501a1501a1501a1502115021150211502315023150231502315023150231500000000000000000000000000000000000000000000000000000000000000000000000
010200002415024150241502415029150291502915029150251002510024100231002310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0020185321853218532185321a5321a5321a5321a5321c5321c5321c5321c5321f5321f5321f5321f532185321853218532185321a5321a5321a5321a5321c5321c5321c5321c5321f5321f5321f5321f532
010c00001d5321d5321d5321d5321a5321a5321a5321a53217532175321753217532135321353213532135321d5321d5321d5321d5321a5321a5321a5321a5321753217532175321753213532135321353213532
010500000c0500d0500e0500f050100501105012050130501405015050160501705018050190501a0501b05000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00001553215532155321553217532175321753217532185321853218532185321a5321a5321a5321a53218532185321853218532135321353213532135321553215532155321553218532185321853218532
010c000017532175321753217532185321853218532185321a5321a5321a5321a5321c5321c5321c5321c53218532185321853218532185321853218532185320000000000000000000000000000000000000000
000100001a15018150151501515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800001f040000001f030000001f020000001f01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000185321a5321c5321f532185321a5321c5321f5321d5321a53217532135321d5321a53217532135321553217532185321a5321c5321d5321f5321d532185321a5321c5321d5321f5321f5321f5321f532
010f0000215321f5321d5321c532215321f5321d5321c5321f5321d5321c5321a532185321753215532135321553217532185321d5321a53217532135321353217532185321a5321c53218532185321853218532
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000182501a2501c2501c2501c2501a2500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
01 09 0a 0c 44
00 09 0b 0d 44
00 09 0a 0c 44
00 09 0e 0c 44
02 09 42 0c 44
01 12 42 43 44
00 12 42 43 44
00 12 14 43 44
00 12 15 43 44
02 12 17 43 44
01 1b 42 43 44
00 1c 42 43 44
04 18 19 43 44
01 1d 42 43 44
01 22 42 43 44
02 23 42 43 44
00 1e 42 43 44
02 1f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
