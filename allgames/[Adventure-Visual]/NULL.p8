pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
--null
--by jusiv

--all assets and code by
--henry stadolnik
--you can follow my work
--on my twitter: @jusiv_


-- variables
firstboot = true

idle = 10
sshake = 0
still = 0

zone = 0
--[[
0=title
1=station
2=open
3=rift
4=grove
5=remains
6=end
]]

tcount = 0

vision = 0
vwait = 20

place = {"the station","the open","the rift","the grove","the remains"}
zcolor = {7,5,9,0,11,13,7,5}
said = {"hey, kid, are you alright?","you took quite a fall there","can you walk?","c'mon, stay with me here","i'm only trying to help","it's going to be ok","     oh     ","so that's where you are"," forgive me ","you must be terribly confused","    i am the writer    ","  and you, my dear jade,  ","have gone off the script","this talk never happened","   now please   "," leave this place ","your tale here may have ended","but your future lies unwritten"}

px = 59
py = 60
dx = 0
dy = 0
pdir = 1 --0=right,1=up,2=left,3=down
pmove = false
pframe = 0
plock = false
pcanact = false

mapx = 0
mapy = 0
mapw = 16
maph = 16

camx = 0
camy = 0
cx = 0
cy = 0
xlock = false
ylock = false

--generic zone variables
--[[
zvar1 = 0
zvar2 = 0
zvar3 = 0
zlock = 0
]]
--popups
p_str = ""
p_x = 0
p_y = 50
p_t = 0
p_tmax = 1
p_list = {}

--other
idle2 = 0
grays = {7,6,13,5,0}
reds = {8,8,2,1,0}
pinks = {7,14,8,2}
chars1 = "bcfghiklmnopqrstuvwxyz1234567890!@#$%&*()[]{}<>/?"
chars2 = "“…†‡‰"
news = 0
nwait = 0
nread = 0
newstext = {"police investigate","noise complaint",
            "domestic violence","charges filed",
            "child of couple on","trial goes missing",
            "break-in reported,","only food taken",
            '"we just want our',' daughter back"'}

--[redacted]
ex = 0
ey = 0
ehere = false
etalk = 0
etalked = false
safe = 0
eline = 0
efade = 0
esaid = {"you seem terribly lost","   what a pity    ",
					    "you might never see home again","do you know how long it's been?",
         "your friends don't miss you","they've all moved on... or away",
         "what if you can't leave here?","this realm will be your grave",
         "accept your fate","you are at my mercy here"}
endtext = {"   oh, you think you can escape?   ","   i'm afraid i can't allow that   ","   i have grand plans for you   ","    leave  her  be    ","you're safe now","he should be of no more concern"}
-->8
--actors+popups

-- popup
-- displays text
function popup(str)
 p_str = str
 p_x = 64-2*#str
 p_tmax = 12*#str
 p_t = p_tmax/2
 if zone <= 5 and zvar1 == 0 then
    sfx(63,0)
 end
end

function draw_popup()
 local xx = camx+p_x
 local yy = camy+p_y
 local cc = 5+mid(0,-4,flr(5*sin(p_t/p_tmax)))
 if etalk > 0 then
    cc = reds[cc]
    yy += 20+flr(rnd(6)/5)
    if zone == 6 then
       yy -= 16
    end
 else
    cc = grays[cc]
 end
 print(p_str,xx-1,yy,0)
 print(p_str,xx+1,yy)
 print(p_str,xx,yy-1)
 print(p_str,xx,yy+1)
 print(p_str,xx,yy,cc)
end


-- switch
-- Ž/— to flip
function add_switch(x,y,id)
 local a = {}
 a.n = id
 a.x = x
 a.y = y
 a.fl = false
 add(a_switch,a)
end

function flip_switch(a)
 if a.fl == false then
    if checkprox(a.x,a.y) then
       a.fl = true
       zlock = a.n
       sshake = 3
       sfx(28,0)
    end
 end
end

function draw_switch(a)
 spr(64,a.x,a.y,1,1,a.fl,false)
 --rect(px-8,py-8,px+8,py+8,8)
 if a.fl == false then
    canuse(a.x,a.y)
 end
end

-- gate
-- zone 1, impassable until opened
function add_gate(tx,ty,id)
 local a = {}
 a.n = id --gate id
 a.tx = tx
 a.ty = ty
 a.st = 0 --1 means open
 add(a_gate,a)
end

function open_gate(a)
 if zlock == a.n then
 			a.st = 1
 			mset(a.tx,a.ty,0)
 			mset(a.tx+1,a.ty,0)
 			zlock = 0
 end
end

function draw_gate(a)
 spr(44+a.st,a.tx*8,a.ty*8)
 spr(44+a.st,a.tx*8+8,a.ty*8,1,1,true,false)
end


-- trainman
-- wanders, fades when close
function add_tman(x,y)
 local a = {}
 a.x = x
 a.y = y
 a.ix = x-5
 a.iy = y-5
 a.f = frnd(16)
 add(a_tman,a)
end

function spawn_tman_group(x,y,w,h,n)
 for i=0,n do
    add_tman(x+frnd(w),y+frnd(h))
 end
end

function update_tman(a)
 local xn = a.x-1+frnd(3)
 local yn = a.y-1+frnd(3)
 a.x = mid(a.ix,xn,a.ix+10)
 a.y = mid(a.iy,yn,a.iy+10)
 a.f = (a.f+1)%16
end

function draw_tman(a)
 local dd = dist(a.x,a.y,px,py)
 if dd > 16 then
    if dd < 32 then
       if dd < 24 then
          pal(7,13)
       else
          pal(7,6)
       end
    else
    			pal()
    end
    spr(50+flr(a.f/8),a.x,a.y)
 end
end


--ring
--purple ring from portal vfx
function add_ring()
 local a = {}
 local ang = rnd(1)
 local rad = 4+rnd(2)
 a.x = 144+rad*cos(ang)
 a.y = 184+rad*sin(ang)
 a.r = 6+rnd(3)
 a.t = 0
 a.tmax = 10+frnd(20)
 add(a_ring,a)
end

function update_ring(a)
 a.t += 1
 if a.t >= a.tmax then
    del(a_ring,a)
 end
end

function draw_ring(a)
 circ(a.x,a.y,1.5*sin(idle/100)-a.r*sin(a.t/a.tmax/2),2)
end


--void
--background of rift
function add_void()
 local a={}
 a.x = frnd(128)
 a.y = frnd(480)
 add(a_void,a)
end

function draw_void(a)
 a.y -= 2
 if a.y < 0 then
    del(a_void,a)
 end
 pset(a.x,a.y,2)
end


--eye
--sets player back if it sees them
function add_eye(x,y,d,dd,w)
 local a={}
 a.x = x
 a.y = y
 a.w = w --wait
 a.wmax = w --maxwait
 a.d = d --initial direction
 --0=right,1=down,2=left,3=up
 a.dd = dd --amount to turn
 a.s = 0 --indicates it saw player
 add(a_eye,a)
end

function update_eye(a)
 --check for player
 local see = false
 if a.d == 0 then
    if mid(a.x,a.x+56,px) == px and mid(a.y-4,a.y+4,py) == py then
       see = true
    end
 elseif a.d == 1 then
    if mid(a.x-4,a.x+4,px) == px and mid(a.y,a.y+56,py) == py then
       see = true
    end
 elseif a.d == 2 then
    if mid(a.x-48,a.x+8,px) == px and mid(a.y-4,a.y+4,py) == py then
       see = true
    end
 elseif a.d == 3 then
    if mid(a.x-4,a.x+4,px) == px and mid(a.y-48,a.y+8,py) == py then
       see = true
    end
 end
 if see then
    zvar2 = 1
    a.s = min(a.s+4,12)
 end
 --rotate
 if a.w > 0 then
    a.w -= 1
 else
    a.d = (a.d+a.dd)%4
    a.w = a.wmax
 end
 --animate alarm
 if a.s > 0 then
    a.s -= 1
 end
end

function draw_eye(a)
 wcirc(a.x+3,a.y+3,a.s,8)
 wcirc(a.x+3,a.y+4,a.s,8)
 spr(73+a.d,a.x,a.y)
end


--phone
--just a phone, drifting in the void
function add_phone(x,y)
 local a={}
 a.x = x
 a.y = y
 a.f = frnd(12)
 a.o = frnd(100)
 a.friend = false
 if frnd(10) == 0 then
    a.friend = true
 end
 add(a_phone,a)
end

function update_phone(a)
 a.f = (a.f+1)%12
end

function draw_phone(a)
 local sp = 77+flr(a.f/4)
 if a.friend then
    sp = 114
 end
 spr(sp,a.x,a.y+min(1,osc(2,a.o)))
end


--tree
--sways idly in the grove
function add_tree(x,y)
 local a = {}
 a.x = x
 a.y = y
 add(a_tree,a)
end

function draw_tree1(a)
 spr(112,a.x-4,a.y,2,1)
 spr(116,a.x,a.y-1)
end

function draw_tree2(a)
 for i=2,12,2 do
    spr(115,a.x+osc(4.5*sin((i-1)/12),2*i-1),a.y-2*i+1)
    spr(116,a.x+osc(4.5*sin(i/12),2*i),a.y-2*i-1)
 end
end

function draw_tree3(a)
 spr(119,a.x,a.y-27)
 spr(120,a.x-8,a.y-28)
 spr(121,a.x-24,a.y-35,2,1)
 spr(121,a.x-24,a.y-21,2,1,false,true)
 spr(120,a.x+8,a.y-28,1,1,true,false)
 spr(121,a.x+16,a.y-35,2,1,true,false)
 spr(121,a.x+16,a.y-21,2,1,true,true)
end


-- wisp
-- directs player in zone 4
function add_wisp(xt,yt,da,aofst,glow)
 local a = {}
 a.x = px
 a.y = py
 a.xt = xt
 a.yt = yt
 a.da = da
 a.aofst = aofst
 a.glow = glow
 a.panic = 80
 add(a_wisp,a)
end

function update_wisp(a)
 if a.x < px then a.x += 0.5
 elseif a.x > px then a.x -= 0.5
 end
 if a.y < py then a.y += 0.5
 elseif a.y > py then a.y -= 0.5
 end
 if dist(px,py,a.x,a.y) < 2 then
    if a.panic > 0 then
       a.panic -= 1
    end
 elseif a.panic < 120 then
    a.panic += 8
 end
 if checkprox2(a.xt,a.yt) then
    a.panic -= 1
    if a.panic < -12 then
       if a.glow > 0 then
          zlock += 1
       end
       add_pt_rect(a.xt+4,a.yt+8)
       del(a_wisp,a)
    end
 end
end

function draw_wisp(a)
 local ang = atan2(a.xt-px,a.yt-py)-0.05*cos(idle/100)
 local ang2 = a.aofst+a.da*idle/100+a.panic/240
 local rad = 12+a.panic+2.5*sin(idle/100)
 local xdraw = px+rad*cos(ang+ang2)
 local ydraw = py+rad*sin(ang+ang2)
 local sp = 105
 if a.panic < 10 and abs(ang2) < 0.1 then
    sp += a.glow
 end
 spr(sp,xdraw,ydraw)
 --line(xdraw,ydraw,a.xt,a.yt)
 --print(a.panic,xdraw+10,ydraw)
end


-- rects
-- background effect of zone 5
function add_pt_rect(x,y)
 local a = {}
 a.x = x
 a.y = y
 a.w = 32
 a.h = 32
 a.t = 0
 a.tmax = 32
 add(a_rects,a)
 sfx(42,0)
end

function add_rects()
 local a = {}
 a.x = rnd(8*mapw)
 a.y = rnd(8*maph)
 a.w = 10+rnd(90)
 a.h = 10+rnd(90)
 a.t = 0
 a.tmax = 100+frnd(200)
 add(a_rects,a)
end

function update_rects(a)
 a.t += 1
 if a.t > a.tmax then
    del(a_rects,a)
 end
end

function draw_rects(a)
 local scale = sin(a.t/a.tmax/2)/2
 rect(a.x-a.w*scale,a.y-a.h*scale,
      a.x+a.w*scale,a.y+a.h*scale)
end


-- char
-- particle in zone 5
function add_char1(x,y,c)
 local a={}
 a.x = x
 a.y = y
 a.c = c
 local ch = 1+frnd(#chars1)
 a.ch = sub(chars1,ch,ch)
 a.t = 6
 add(a_char,a)
end

function add_char2(x,y)
 local a={}
 a.x = x
 a.y = y
 a.c = 12
 local ch = 1+frnd(#chars2)
 a.ch = sub(chars2,ch,ch)
 a.t = 5+5*zvar2+frnd(10)
 add(a_char,a)
end

function update_char(a)
 a.t -= 1
 if a.t <= 0 then
    del(a_char,a)
 end
end

function draw_char(a)
 print(a.ch,a.x,a.y,a.c)
end


-- key
-- abstract key from zone 5
function add_key(x,y)
 local a={}
 a.xi = x
 a.yi = y
 a.x = x
 a.y = y
 a.i = true
 a.dd = 0
 a.spd = 0
 a.get = false
 add(a_key,a)
end

function update_key(a)
 if a.get then
    --move to player
    a.x = px+1
    a.y = py-2
 else
    if a.i then
       --be collectable
       if checkprox(a.x,a.y) then
          a.get = true
          a.i = false
          zvar2 += 1
          sfx(17,0)
       end
    else
       --return to origin
       a.dd = atan2(a.xi-a.x,a.yi-a.y)
       if dist(a.x,a.y,a.xi,a.yi) <= 4 then
          a.spd = 0
          a.i = true
          a.x = a.xi
          a.y = a.yi
       else
          a.x += a.spd*cos(a.dd)
          a.y += a.spd*sin(a.dd)
       end
    end
 end
 --spawn chars
 if idle%5 == 0 then
    add_char2(a.x-4+rnd(8),a.y+rnd(8))
 end
end

function reset_key(a)
 if a.i == false then
    a.get = false
    a.spd = 4
 end
 zvar2 = 0
end


-- glitch
-- hazard from zone 5
function add_glitch(x,y,mode,v,r)
 local a={}
 a.xi = x
 a.yi = y
 a.x = x
 a.y = y
 a.m = mode
 a.v = v
 a.r = r
 a.c = 6*mode-6
 add(a_glitch,a)
end

function spawn_glitch(x,y,str)
 local i = 0
 local tile = 0
 for yy=0,6 do
    for xx=0,6 do
       i += 1
       tile = sub(str,i,i)
       local xxx = x+xx*16
       local yyy = y+yy*16
       if tile == "k" then
          add_key(xxx,yyy)
       elseif tile == "1" then
          add_glitch(xxx,yyy,1,0,0)
       elseif tile == "2" then
          add_glitch(xxx,yyy,2,0,36)
          add_glitch(xxx,yyy,2,100,36)
          add_key(xxx,yyy)
       elseif tile == "3" then
          for j=0,4 do
             add_glitch(xxx,yyy,2,10*j,30)
          end
       end
    end
 end
end

function update_glitch(a)
 if checkprox(a.x,a.y) then
    foreach(a_key,reset_key)
    sshake = 4
    if stat(17) == -1 then
       sfx(16,1)
    end
 end
 if a.m == 2 then
    --orbit
    a.v = (a.v+1)%200
    a.x = a.xi+a.r*cos(a.v/200)
    a.y = a.yi+a.r*sin(a.v/200)
 end
end

function show_glitch(a)
 add_char1(a.x-4+rnd(12),a.y-4+rnd(12),a.c)
end


-- paper
-- Ž/— to read
function add_paper(x,y)
 local a = {}
 a.x = x
 a.y = y
 a.unrd = true
 add(a_paper,a)
end

function read_paper(a)
 if news == 0 then
    if checkprox(a.x,a.y) then
       news = 1
       nwait = 30
       if a.unrd then
          nread += 1
          a.unrd = false
          sfx(31,0)
       end
       plock = true
    end
 end
end

function draw_paper(a)
 spr(211,a.x,a.y)
 if news == 0 then
    canuse(a.x,a.y)
 end
end

function draw_news()
 local fadeval = flr((nwait-30)/5)
 local cc = grays[5-mid(0,4,fadeval)]
 local cc2 = grays[6-mid(1,4,fadeval)]
 local cc3 = grays[5-mid(0,4,flr((nwait-40)/5))]
 rect(camx+23,camy+17,camx+105,camy+98,0)
 rect(camx+25,camy+100,camx+103,camy+100)
 rectfill(camx+24,camy+18,camx+104,camy+99,cc2)
 rect(camx+27,camy+15,camx+105,camy+95,0)
 pset(camx+24,camy+99)
 pset(camx+104,camy+99)
 rectfill(camx+28,camy+16,camx+104,camy+96,cc)
 local lmarg = camx+30
 rectfill(lmarg-1,camy+17,lmarg+4,camy+22,0)
 rect(lmarg+6,camy+18,lmarg+72,camy+18)
 rect(lmarg+6,camy+20,lmarg+72,camy+20)
 rectfill(lmarg+2,camy+67,lmarg+21,camy+86)
 rectfill(lmarg+3,camy+89,lmarg+20,camy+93)
 rectfill(lmarg+53,camy+41,lmarg+70,camy+49)
 rectfill(lmarg+53,camy+51,lmarg+61,camy+61)
 rectfill(lmarg+63,camy+51,lmarg+70,camy+61)
 rect(lmarg+26,camy+66,lmarg+67,camy+67)
 for i=0,12 do
    local yyy = camy+38+2*i
    rect(lmarg,yyy,lmarg+48,yyy)
    yyy += 32
    rect(lmarg+26,yyy,lmarg+72,yyy)
 end
 print(newstext[2*zone-1],lmarg,camy+24)
 print(newstext[2*zone],lmarg,camy+31)
 rect(lmarg+24,camy+38,lmarg+25,camy+64,cc)
 rect(lmarg+49,camy+70,lmarg+50,camy+94)
 rect(lmarg+2,camy+90,lmarg+21,camy+92)
 yyy = camy+65
 local yyy2 = yyy+3
 rect(lmarg+31,yyy,lmarg+34,yyy2)
 rect(lmarg+36,yyy,lmarg+41,yyy2)
 rect(lmarg+44,yyy,lmarg+51,yyy2)
 rect(lmarg+59,yyy,lmarg+61,yyy2)
 pal(7,cc)
 pal(6,cc2)
 sspr(8,0,8,6,lmarg+4,camy+72,16,12)
 pal()
 local yy = camy+112-flr(idle/50)
 print("Ž",camx+60,yy,0)
 rect(camx+62,yy+1,camx+64,yy+2)
 print("Ž",camx+60,yy-1,cc3)
end


--quill
--writes stuff. duh.
function add_quill(x,y)
 local a = {}
 a.x = x
 a.y = y
 a.f = frnd(8)
 add(a_quill,a)
end

function update_quill(a)
 a.f = (a.f+1)%8
end

function draw_quill(a)
 spr(211,a.x-1,a.y+4)
 spr(214+a.f/2,a.x+2*sin(idle/50),a.y)
end


--book
--just sits there.
--like a stack of books should?
function add_book(x,y)
 local a = {}
 a.x1 = x+frnd(3)
 a.y1 = y
 a.sp1 = frnd(3)
 a.x2 = x+frnd(3)
 a.y2 = y-2-frnd(2)
 a.sp2 = (a.sp1+1+frnd(2))%3
 a.x3 = x+frnd(3)
 a.y3 = a.y2-2-frnd(2)
 a.sp3 = (a.sp2+1+frnd(2))%3
 add(a_book,a) 
end

function draw_book(a)
 spr(219+a.sp1,a.x1,a.y1)
 spr(219+a.sp2,a.x2,a.y2)
 spr(219+a.sp3,a.x3,a.y3)
end
-->8
--main

function init_actors()
 a_switch = {}
 a_gate = {}
 a_tman = {}
 a_ring = {}
 a_void = {}
 a_eye = {}
 a_phone = {}
 a_tree = {}
 a_wisp = {}
 a_rects = {}
 a_char = {}
 a_key = {}
 a_glitch = {}
 a_paper = {}
 a_quill = {}
 a_book = {}
end


function confirm()
 return btn(4) or btn(5)
end


function dist(x1,y1,x2,y2)
 local dxx = x2-x1
 local dyy = y2-y1
 return sqrt(dxx*dxx+dyy*dyy)
end


function frnd(n)
 return flr(rnd(n))
end


function checkprox(x,y)
 return mid(px-8,px+8,x) == x and mid(py-8,py+8,y) == y
end


function checkprox2(x,y)
 return mid(px-4,px+4,x) == x and mid(py-4,py+4,y) == y
end


function checkflag(f,x,y)
 return fget(mget(mapx+flr(x/8),mapy+flr(y/8)),f)
end


function osc(r,ofst)
 return r*sin((idle+ofst)/100)
end


function reset()
 zone = 0
 idle = 10
 tcount = 0
 mapw = 16
 maph = 16
 camx = 0
 camy = 0
 plock = false
 nread = 0
 safe = 0
 etalk = 0
 eline = 0
 for i=0,1 do
    mset(23+i,7,15)
    mset(1+i,30,15)
    mset(26+i,36,15)
 end
 --[[
 mset(23,7,15)
 mset(24,7,15)
 mset(1,30,15)
 mset(2,30,15)
 mset(26,36,15)
 mset(27,36,15)
 ]]
 music(0)
end


function start_vision()
 vwait = 0
 vision = 1
 sfx(14,0)
end


function load_zone()
 --clear actors
 init_actors()
 --reset zone vars
 zvar1 = 0
 zvar2 = 0
 zvar3 = 0
 zlock = 0
 plock = false
 idle = 0
 mapx = 0
 mapy = 0
 mapw = 16
 maph = 16
 ehere = false
 etalked = false
 efade = 0
 --change zone
 zone += 1
 --zone = min(zone+2,7)
 --load zones
 if zone == 1 then
    mapw = 32
    maph = 40
    px = 124
    py = 260
    cx = 124
    cy = 260
    setcamera()
    xlock = true
    add_gate(26,36,1)
    add_gate(1,30,2)
    add_gate(23,7,3)
    add_switch(40,120,1)
    add_switch(224,296,2)
    spawn_tman_group(48,73,24,22,40)
    spawn_tman_group(168,138,28,4,5)
    spawn_tman_group(186,90,8,45,8)
    spawn_tman_group(224,297,0,0,3)
    spawn_tman_group(206,220,12,44,8)
    spawn_tman_group(22,200,12,16,3)
    spawn_tman_group(20,293,24,5,30)
    add_tman(95,130)
    ex = 60
    ey = 61
    music(14)
 elseif zone == 2 then
    mapx = 32
    mapw = 36
    maph = 41
    px = 140
    py = 20
    cx = 140
    cy = 20
    pdir = 3
    plock = true
    zvar2 = {1}
    zlock = 1
    idle2 = 0
    ex = 140
    ey = 192
    music(20,4000)
 elseif zone == 3 then
    mapx = 68
    maph = 48
    px = 59
    py = 360
    cx = 59
    cy = 360
    pdir = 1
    add_eye(64,88,3,1,20)
    add_eye(56,136,2,3,20)
    add_eye(68,200,0,2,40)
    add_eye(116,224,2,2,50)
    add_eye(32,216,1,2,60)
    add_phone(8,160)
    add_phone(112,140)
    add_phone(75,276)
    add_phone(20,332)
    add_phone(104,344)
    for i=0,200 do
       add_void()
    end
    add_paper(124,249)
    ex = 44
    ey = 320
    music(5)
 elseif zone == 4 then
    mapx = 96
    mapw = 32
    maph = 32
    px = 124
    py = 124
    cx = 124
    cy = 124
    local tlx = {88,160,48,96,152,200, 48, 96,152,200, 88,160}
    local tly = {48, 48,88,96, 96, 88,160,152,152,160,200,200}
    for i=1,12 do
       add_tree(tlx[i],tly[i])
    end
    add_paper(86,44)
    ex = 234
    ey = 98
    music(26)
 elseif zone == 5 then
    mapw = 48
    maph = 48
    px = 188
    py = 300
    cx = 188
    cy = 0
    add_key(188,60)
    spawn_glitch(16,12,"0111110101000110001011011100101k10110001010111110")
    spawn_glitch(272,12,"0110110100000110111011002001101110110000010110110")
    spawn_glitch(16,272,"011111010001001010101101310110101011k100010111110")
    add_key(312,312)
    for i=0,1 do
       add_glitch(312,312,2,100*i,24)
    end
    for i=0,3 do
       add_glitch(312,312,2,25+50*i,56)
    end
    add_paper(380,379)
    plock = true
    zlock = 300
    ex = 188
    ey = 150
    music(2)
 elseif zone == 6 then
    px = 0
    py = 0
    cx = 0
    cy = 0
    etalk = 1
    --safe = 5
    --nread = 5
 elseif zone == 7 then
    mapx = 112
    mapy = 32
    px = 60
    py = 117
    cx = 60
    cy = 117
    pdir = 1
    idle2 = 20
    etalk = 0
    add_quill(23,60)
    add_quill(9,37)
    add_quill(39,4)
    add_quill(84,5)
    add_quill(100,61)
    add_quill(111,36)
    local blx = {10,114,49,79,21,117,  2, 10, 20,118, 99,109}
    local bly = {17, 16,40,93,89, 69,120,110,118,120,116,107}
    for i=1,12 do
       add_book(blx[i],bly[i])
    end
 end
 setcamera()
end


function update_player()
 dx = 0
 dy = 0
 local move = false
 --get input
 if zone == 5 then
 			getinput_zone5()
 else
    getinput_main()
 end
 --pick and lock direction
 if pmove then
    if pdir == 0 or pdir == 2 then
       dy = 0
    end
    if pdir == 1 or pdir == 3 then
       dx = 0
    end
 end
 if dy != 0 then
    if dy > 0 then
       pdir = 3
    else
       pdir = 1
    end
 elseif dx != 0 then
    if dx > 0 then
       pdir = 0
    else
       pdir = 2
    end
 end
 --determine whether moving
 if dx != 0 or dy != 0 then
    move = true
    px = mid(0,8*mapw-8,px+dx)
    py = mid(0,8*maph-8,py+dy)
 end
 pmove = move
 --animate
 if pmove then
    still = 0
    pframe = (pframe+1)%16
 elseif still < 80 then
    still += 1
    pframe = 0
 end
end


function getinput_main()
 --get input
 if btn(0) then
    if checkflag(0,px,py+6) == false and
       checkflag(0,px,py+7) == false then
       dx -= 1
    end
 end
 if btn(1) then
    if checkflag(0,px+7,py+6) == false and
       checkflag(0,px+7,py+7) == false then
       dx += 1
    end
 end
 if btn(2) then
    if checkflag(0,px+1,py+5) == false and
       checkflag(0,px+6,py+5) == false then
       dy -= 1
    end
 end
 if btn(3) then
    if checkflag(0,px+1,py+8) == false and
       checkflag(0,px+6,py+8) == false then
       dy += 1
    end
 end
end


function getinput_zone5()
 --get input
 if btn(0) then
    dx -= 1
 end
 if btn(1) then
    dx += 1
 end
 if btn(2) then
    dy -= 1
 end
 if btn(3) then
    dy += 1
 end
 --collide
 if py+dy < 42 and mid(171,205,px+dx) == px+dx then
    dx = 0
    dy = 0
 end
end


function setcamera()
 if xlock == false then
    if cx > px then cx -= 1
    elseif cx < px then cx += 1
    end
    camx = mid(0,mapw*8-128,cx-60)-flr(sshake/2+rnd(sshake))
 end
 if ylock == false then
    if cy > py then cy -= 1
    elseif cy < py then cy += 1
    end
    camy = mid(0,maph*8-128,cy-60)-flr(sshake/2+rnd(sshake))
 end
end


function canuse(x,y)
 if checkprox(x,y) then
    pcanact = true
 end
end


function make_sequence()
 local seq = {1}
 for i=0,6 do
    add(seq,frnd(4))
 end
 add(seq,4)
 zvar2 = seq
 if zlock >= 9 and etalked == false then
    ehere = true
 end
 zlock = 1
end


function zone1()
 --[[
 zvar1: entered
 zvar2: ticket state
 zvar3: train pos
 zlock: unlock gates
 ]]
 if zvar1 == 0 and py < 200 then
    xlock = false
    popup("the station")
    add_paper(146,291)
    zvar1 = 1
 end
 if confirm() then
    --ticket gate
    if checkprox(200,60) then
       if zvar2 == 0 and p_t <= 0 then
          popup("you need a ticket")
       elseif zvar2 == 1 then
          zlock = 3
          sshake = 2
          zvar2 = 2
          plock = true
          ehere = true
       end
    end
    --ticket
    if zvar2 == 0 and checkprox(30,296) then
       popup("acquired: ticket")
       zvar2 = 1
       sfx(29,1)
    end
    --switches
    foreach(a_switch,flip_switch)
    foreach(a_gate,open_gate)
 end
 --animation
 foreach(a_tman,update_tman)
 if zvar2 == 2 then
    if zvar3 < 100 then
       if stat(17) == -1 then
          sfx(23,1)
       end
       zvar3 += 1
       sshake = mid(0,3,flr(zvar3/10)-1)
       if zvar3 == 90 then
          sfx(32,0)
       elseif zvar3 >= 100 then
          plock = false
          sfx(-1,1)
       end
    elseif checkprox(188,28) then
       start_vision()
       zvar2 = 3
    end
 end
 if zvar2 < 2 then
    canuse(200,60)
    if zvar2 == 0 then
       canuse(30,296)
    end
 end
end


function zone2()
 --[[
 zvar1: entered
 zvar2: sequence
 zvar3: train pos
 zlock: progress
 ]]
 idle2 = (idle2+1)%384
 --idle2 = (idle2+1-2*sin(idle/200))%320
 foreach(a_ring,update_ring)
 if zvar1 == 0 and py > 94 then
    popup(" the open ")
    zvar1 = 1
    make_sequence()
 end
 if vision == 0 and zvar3 < 150 then
    if zvar3 == 0 then
       sfx(32,0)
    elseif zvar3 > 15 and stat(17) == -1 then
       sfx(23,1)
    end
    zvar3 += 1
    sshake = flr(-3*sin(zvar3/300))
    if zvar3 >= 150 then
       plock = false
    end
 end
 --portal
 if zlock == 9 then
    if dist(px,py,140,180) <= 14 then
       start_vision()
       zlock = 10
    end
    if idle%4 == 0 then
       add_ring()
    end
 end
 --screenwrap
 if px < 63 then
 			px = 215
 			cx = 215
 			if #a_paper == 0 then
 			   add_paper(129,24)
 			end
 			if zvar2[zlock] == 2 then
 			   zlock += 1
 			else
 			   make_sequence()
 			end
 end
 if px > 215 then
 			px = 63
 			cx = 63
 			if zvar2[zlock] == 0 then
 			   zlock += 1
 			else
 			   make_sequence()
 			end
 end
 if zvar1 > 0 and py < 95 then
 			py = 255
 			cy = 255
 			if zvar2[zlock] == 1 then
 			   zlock += 1
 			else
 			   make_sequence()
 			end
 end
 if py > 255 then
    py = 95
    cy = 95
    if zvar2[zlock] == 3 then
 			   zlock += 1
 			else
 			   make_sequence()
 			end
 end
end


function zone3()
 --[[
 zvar1: entered
 zvar2: spotted
 zvar3: reset animation
 zlock: end reached
 ]]
 add_void()
 add_void()
 foreach(a_eye,update_eye)
 foreach(a_phone,update_phone)
 if zvar1 == 0 and py < 352 then
    popup("  the rift  ")
    zvar1 = 1
 end
 if zvar2 > 0 then
    plock = true
    zvar3 += 1
    if zvar3 == 1 then
       sfx(43,0)
    elseif zvar3 == 30 then
       px = 59
       py = 360
       cy = 360
       setcamera()
    elseif zvar3 >= 60 then
       zvar2 = 0
       zvar3 = 0
       plock = false
    end
 end
 if zlock == 0 and py < 80 then
    zlock = 1
    ehere = true
 end
 if zvar1 < 2 and py < 20 then
    start_vision()
    zvar1 = 2
 end
end


function zone4()
 --[[
 zvar1: entered
 zvar2: energy animation
 zvar3: end animation
 zlock: unlock state
 ]]
 if zvar1 == 0 and checkprox(124,124) == false then
    popup(" the grove ")
    zvar1 = 1
    add_wisp(212,120,0,0,1)
 end
 foreach(a_wisp,update_wisp)
 if #a_wisp == 0 then
    if zlock == 1 then
       add_wisp(124,32,0,0,1)
       add_wisp(124,32,0,1/3,0)
       add_wisp(124,32,0,2/3,0)
    end
    if zlock == 2 then
       add_wisp(124,208,1,0,1)
    end
    if zlock == 3 then
       add_wisp(36,120,1,0,1)
       add_wisp(36,120,1,1/3,0)
       add_wisp(36,120,1,2/3,0)
    end
 end
 if zlock == 4 then
    if zvar3 < 80 then
       zvar3 += 2
    elseif checkprox2(124,124) then
       zvar2 += 2
       if zvar2 > 64 then
          start_vision()
          zlock = 5
       end
    elseif zvar2 > 0 then
       zvar2 -= 1
    end
    if etalked == false and etalk == 0 then
       ehere = true
    end
 end
 foreach(a_rects,update_rects)
end


function zone5()
 --[[
 zvar1: entered
 zvar2: key count
 zvar3: ewait
 zlock: wait
 ]]
 if zvar1 == 0 and checkprox(188,300) == false then
    popup("the remains")
    zvar1 = 1
    zvar3 = 80
 end
 if zvar3 > 0 then
    zvar3 -= 1
    if zvar3 <= 0 then
       ehere = true
    end
 end
 if zlock > 0 then
    zlock -= 1
    if zlock <= 0 then
       plock = false
    end
 end
 if zvar2 >= 5 then
    if zvar2 == 5 then
       --check if at gate
       if mid(184,192,px) == px and py <= 42 then
          zvar2 += 1
          plock = true
          a_key = {}
          music(3)
       end
    elseif zvar2 < 200 then
       --show end sequence
       zvar2 += 1
       if zvar2 >= 200 then
          start_vision()
          a_glitch = {}
       end
    end
 end
 if frnd(5) == 0 and #a_rects < 100 then
    add_rects()
 end
 foreach(a_key,update_key)
 foreach(a_glitch,update_glitch)
 if idle%2 == 0 then
    foreach(a_glitch,show_glitch)
 end
 foreach(a_char,update_char)
 foreach(a_rects,update_rects)
end


function zone6()
 --[[
 zvar1: state
 zvar2: wait
 zvar3: trans
 zlock: done
 ]]
 if zvar1 > 0 and zvar2 > 0 then
    zvar2 -= 5
 end
 if zvar3 > 0 then
    zvar3 -= 1
    if zlock == 0 and zvar3 == 25 and safe >= 5 then
       music(9,500)
    end
    if zlock > 0 and zvar3 <= 25 then
       if nread >= 5 then
          if safe < 5 then
             music(12,500)
          end
          load_zone()
       else
          reset()
       end
    end
 elseif zvar1 == 0 then
    if zvar2 < 100 then
       zvar2 += 1
    elseif confirm() then
       zvar1 = 1
       zvar2 = 90
       zvar3 = 50
       if safe < 5 then
          zlock = 1
       end
       sfx(14,0)
    end
 elseif p_t <= 0 then
    local maxline = 3
    if nread >= 5 then
       maxline = 4
    end
    if zvar1 >= 4 then
       etalk = 0
    end
    if zvar1 <= maxline then
       popup(endtext[zvar1])
       zvar1 += 1
       if stat(24) != 7+zvar1 then
          music(7+zvar1)
       end
       if zvar1 >= 5 then
          sfx(22,0)
       end
    else
       zvar3 = 50
       zlock = 1
       sfx(14,0)
    end
 end
end


function zone7()
 --[[
 zvar1: entered/progress
 zvar2: animation
 zvar3: can leave/exit animation
 zlock: unlock state
 ]]
 if idle2 > 0 then
    idle2 -= 1
 end
 foreach(a_quill,update_quill)
 if zvar1 == 0 and py < 104 then
    plock = true
    p_list = {}
    if safe >= 5 then
       add(p_list,endtext[5])
       add(p_list,endtext[6])
    else
       add(p_list,said[7])
       add(p_list,said[8])
    end
    for i=9,#said do
       add(p_list,said[i])
    end
    zvar1 = 1
    pframe = 0
 end
 if zlock == 0 then
    if zvar1 > 0 and p_t <= 0 then
       if zvar3 <= 0 then
          if zvar1 <= #p_list then
             popup(p_list[zvar1])
             zvar1 += 1
             zvar3 = 10
          else
             zlock = 1
             plock = false
          end
       else
          zvar3 -= 1
       end
    end
 elseif py >= 119 and zlock == 1 then
    plock = true
    zlock = 2
    sfx(14,0)
 elseif zlock > 1 then
    --return to title
    if zlock >= 22 then
       reset()
    else
       zlock += 1
    end
 end
 zvar2 = (zvar2+1)%48
end


function _init()
 init_actors()
 music(0)
end


function _update()
 idle = (idle+1)%100
 --update popups
 if p_t > 0 then
 			p_t -= 1
 	  if p_t <= 0 then
 	     if ehere then
    	     if etalk > 1 then
 	           eline += 1
 	           etalk -= 1
 	           popup(esaid[eline])
    	     else
    	        etalked = true
    	     			safe += 1
    	     			etalk = 0
 	           plock = false
 	           still = 0
 	        end
 	     end
 	  end
 end
 if ehere and etalked and efade < 20 then
    efade += 1
    if efade >= 20 then
       ehere = false
    end
 end
 if sshake > 0 then sshake -= 1 end
 pcanact = false
 --vision
 if vision > 0 then
    if vision == 1 then
       if vwait == 40 then
          music(-1,500)
       end
       if vwait < 80 then
          vwait += 1
       elseif confirm() then
          vision = 2
       end
    end
    if vision == 2 then
       vwait -= 1
       if vwait == 21 then
          load_zone()
       elseif vwait <= 0 then
          vision = 0
       end
    end
 end
 --news
 if news > 0 then
    if news == 1 then
       if nwait < 80 then
          nwait += 1
       elseif confirm() then
          news = 2
       end
    end
    if news == 2 then
       nwait -= 1
       if nwait <= 30 then
          news = 0
          plock = false
       end
    end
 end
 --title
 if zone == 0 then
    if tcount != 40 then
       if tcount < 90 then
          tcount += 1
       elseif tcount == 90 then
          vision = 1
          tcount += 1
          firstboot = false
       end
    elseif confirm() then
       tcount += 1
       music(-1,500)
       sfx(10,0)
    end
 --ending
 elseif zone == 6 then
    zone6()
 --main gameplay
 else
    if plock == false and vision == 0 then
       update_player()
    end
    if zone == 1 then
       zone1()
    elseif zone == 2 then
       zone2()
    elseif zone == 3 then
       zone3()
    elseif zone == 4 then
       zone4()
    elseif zone == 5 then
       zone5()
 			elseif zone == 7 then
       zone7()
 			end
 			--interact
    if confirm() then
       if ehere and etalked == false and etalk == 0 and checkprox(ex,ey) then
          etalk = 2
          eline += 1
          popup(esaid[eline])
          plock = true
          sfx(30,0)
       end
       foreach(a_paper,read_paper)
    end
 end
 --position camera
 setcamera()
end
-->8
--drawing

function wcirc(x,y,r,c)
 circfill(x,y,r,c)
 circ(x+1,y,r)
end


function mspr(sp,x,y,mir)
 spr(sp,x,y,1,1,mir,false)
end


function fillscreen(trans)
 if trans == 1 then
    fillp(0b0101101001011010.1)
 elseif trans >= 2 then
    fillp()
 else
    fillp(0b0111110101111101.1)
 end
 rectfill(camx-8,camy-8,camx+136,camy+136,7)
 fillp()
end


function draw_title()
 local yy = camy+47
 if tcount >= 5 and tcount < 55 then
    title_color(15)
    spr(10,camx+29,yy-1.5*cos(min(47,idle)/50),2,2)
 end
 if tcount >= 10 and tcount < 60  then
    title_color(20)
    spr(12,camx+47,yy-1.5*cos(min(47,idle-2)/50),2,2)
 end
 if tcount >= 15 and tcount < 65 then
    title_color(25)
    spr(14,camx+65,yy-1.5*cos(min(47,idle-4)/50),2,2)
 end
 if tcount >= 20 and tcount < 70 then
    title_color(30)
    spr(14,camx+83,yy-1.5*cos(min(47,idle-6)/50),2,2)
 end
 if tcount < 60 then
    title_color(20)
    print("Ž",camx+60,camy+70-flr(idle/50),13)
 end
 if firstboot and tcount < 10 then
    if tcount < 5 then
       pal(1,12)
    else
    	  pal(1,6)
    end
    spr(238,camx+111,camy+111,2,2)
 end
end


function title_color(n)
 if tcount >= n+10 and tcount < n+30 then
    pal()
 elseif tcount >= n+5 and tcount < n+35 then
    pal(6,7)
    pal(12,6)
    pal(13,12)
 elseif tcount >= n and tcount < n+40 then
    pal(6,7)
    pal(12,7)
    pal(13,6)
 else
    pal(6,7)
    pal(12,7)
    pal(13,7)
 end
end


function draw_vision()
 color(7)
 fillscreen(min(2,flr(vwait/10)))
 local str = said[zone+1]
 local xmid = camx+64-2*#str
 if vwait > 20 then
    print(str,xmid,camy+57,
 		   				grays[1+mid(0,4,flr((vwait-30)/5))])
    print("Ž",camx+60,camy+67-flr(idle/50),
          grays[1+mid(0,4,flr((vwait-40)/5))])
 end
end


function draw_end()
 if zvar1 == 0 or (zvar1 == 1 and zvar3 > 25) then
    print("<end>",53,23,0)
    if safe >= 5 then color(8)
    elseif safe > 2 then color(2)
    end
    print("encounters: "..safe.."/5",37,48)
    sspr(120,48,8,7,26,47)
    rect(27,59,32,65,0)
    spr(211,26,58)
    if nread >= 5 then color(12)
    elseif nread > 2 then color(13)
    end
    print("newspapers: "..nread.."/5",37,60)
    print("this was made in its entirety",6,79,0)
    print('by henry "jusiv" stadolnik',12,85)
    print("thanks for playing!",26,103,grays[4+flr(osc(2,0))])
    print("Ž",59,111+flr(((idle+20)%100)/50),grays[1+flr(zvar2/20)])
 else
    local yoff = flr(idle/50)
    if zvar1 >= 5 then
       pal(0,5)
       pal(1,13)
       pal(15,5)
       pal(8,6)
       yoff = 2
    end
    rectfill(camx,camy,camx+128,camy+128,0)
    fillp(0b0101101001011010.1)
    circfill(camx+64,camy+100,88,1)
    fillp()
    circfill(camx+64,camy+112,72)
    if zvar3 <= 25 then
       sspr(mid(64,96,32+16*zvar1),112,16,16,32,64+yoff,64,64)
    end
    pal()
 end
 local fade = abs(flr(3*sin(zvar3/100)))-1
 if fade >= 0 then
    fillscreen(fade)
 end
 --print(zvar3.." "..fade,2,2,0)
end


function draw_player()
 pal()
 local sp = 1
 local mir = false
 if still >= 80 then
 			if idle >= 75 then
 			   sp = 9
 			end
 else
    if pdir == 0 or pdir == 2 then
       sp += 4
       if pdir == 2 then
	         mir = true
	      end
    elseif pdir == 1 then 
       sp += 82
    end
	   if pmove then
				   sp += flr(pframe/4)
	   end
	end
	if ey <= py then draw_e() end
 mspr(sp,px,py,mir)
 if zone == 2 then
    mspr(sp,px-153,py,mir)
    mspr(sp,px+153,py,mir)
    mspr(sp,px,py-161,mir)
    mspr(sp,px,py+161,mir)
 end
 if ey > py then draw_e() end
end


function _draw()
 pal()
 pal(15,0)
 --backdrop
 rectfill(-8,-8,8*mapw+8,8*maph+8,zcolor[zone+1])
 --debug border
 --rect(-1,-1,8*mapw,8*maph,8)
 
 --main
 if zone == 0 then
    draw_title()
 else
    --draw back layer
    foreach(a_void,draw_void)
    if zone == 2 then
       if zlock < 9 then
          map(mapx,mapy,0,0,mapw,24)
       else
          circfill(144,184,11+1.5*sin(idle/100),1)
          foreach(a_ring,draw_ring)
          circfill(144,184,9+1.5*sin(idle/100),0)
          circ(144,184,10-idle/10,1)
          circ(144,184,10-((idle+50)%100)/10,1)
       end
    elseif zone == 3 then
       local rr = 6+flr(idle/50)
       wcirc(63,12,9,11)
       rectfill(54,12,73,25)
       wcirc(63,17,rr+1,3)
       wcirc(63,17,rr,1)
       spr(166,56,9,2,2)
    elseif zone == 4 then
       local xm = 4*mapw
       local ym = 4*maph
       local oscv = cos(idle/100)
       circfill(xm,ym,121-5.5*oscv,3)
       circfill(xm,ym,114-3.5*oscv,1)
       circ(xm,ym,119-5.5*oscv,11)
       circ(xm,ym,112-3.5*oscv,3)
    elseif zone == 5 then
       color(5)
       foreach(a_rects,draw_rects)
       map(16,40,176,-16,4,8)
    end
    if zone == 6 then
       draw_end()
    elseif zone != 2 and zone != 5 then
       map(mapx,mapy,0,0,mapw,maph)
    end
    --draw extra details
    if zone == 1 then
       rectfill(0,-8,8*mapw,-1,1)
       --clock
       wcirc(127,98,10,6)
       wcirc(127,98,8,7)
       spr(47,127,91,1,2)
       spr(47,121,99,1,1,true,true)
       --ticket
       if zvar2 == 0 then
          spr(48,30,296)
       --train
       elseif zvar2 >= 2 then
          map(0,46,335-zvar3*2,23,16,2)
       end
    elseif zone == 2 then
       --train
       if zvar3 < 150 then
          map(0,46,87-max(0,zvar3-40)*zvar3/30,7,16,2)
       end
       --column marking
       if zlock == 1 then
          spr(82,140,176,1,2)
       end
    elseif zone == 4 then
       --energy
       color(3)
       if idle < 50 then
          color(11)
       end
       if zlock > 0 then
          rectfill(214,126,217,129)
          rect(212,124,219,131)
       end
       if zlock > 1 then
          rectfill(126,38,129,41)
          rect(124,36,131,43)
       end
       if zlock > 2 then
          rectfill(126,214,129,217)
          rect(124,212,131,219)
       end
       if zlock > 3 then
          rectfill(38,126,41,129)
          rect(36,124,43,131)
          --center
          rect(125,125,130,130)
          rect(44,127,44+zvar3,128)
          rect(211-zvar3,127,211,128)
          rect(127,44,128,44+zvar3)
          rect(127,211-zvar3,128,211)
       end
       color(11)
       foreach(a_rects,draw_rects)
    elseif zone == 7 then
       spr(218,65,-2)
       spr(218,17,39)
       spr(218,105,85)
       spr(218,79,22)
       spr(218,34,109)
       local ff = flr(zvar2/4)
       local vflp = false
       if ff >= 6 then
          vflp = true
       end
       spr(192+ff%6,60,57,1,1,false,vflp)
    end
    --actors
    foreach(a_paper,draw_paper)
    foreach(a_tree,draw_tree1)
    foreach(a_gate,draw_gate)
    foreach(a_switch,draw_switch)
    foreach(a_tman,draw_tman)
    foreach(a_phone,draw_phone)
    foreach(a_eye,draw_eye)
    foreach(a_book,draw_book)
    foreach(a_quill,draw_quill)
    if zone == 5 then
       if zvar2 > 5 then
          if zvar2 > 70 then
             local yy = 55-zvar2/3
             local inc = 0.5*flr((idle%50)/25)
             wcirc(191,yy,5.5+inc,12)
             wcirc(191,yy,3.5+inc,6)
          elseif zvar2 > 20 then
             local scl = max(2,5.5*((zvar2-20)/50))
             wcirc(191,30,scl,12)
             scl = 3.5*((zvar2-20)/50)
             wcirc(191,30,scl,6)
          elseif zvar2 < 15 then
             local sp = 83+flr(zvar2/4)
             spr(sp,188,40)
          end
       else
          if zvar2 < 5 then
             spr(208,188,40)
          end
          draw_player()
       end
    elseif zone != 6 then
       draw_player()
    end
    --column top
    if zone == 3 and zvar2 > 0 then
       circfill(px+4,py+4,-320*sin(zvar3/120),2)
    elseif zone == 2 and zlock < 9 then
       spr(65+2*zvar2[zlock],136,168,2,1)
    end
    --more actors
    foreach(a_char,draw_char)
    foreach(a_wisp,draw_wisp)
    foreach(a_tree,draw_tree2)
    foreach(a_tree,draw_tree3)
    --camera
    camera(camx,camy)
    --dust
    if zone == 2 then
       map(32,24,camx-8,camy-idle2/2,18,24)
       map(32,24,camx-8,camy+192-idle2/2,18,24)
    elseif zone == 7 then
       local fade = ceil(idle2/5)-1
       if fade >= 0 then
          fillscreen(fade)
       end
    end
 end
 --static
 if zone == 3 and abs(zvar3-30) < 10 then
    rectfill(camx,camy,camx+128,camy+128)
 elseif zone == 5 then
    for i=0,125+flr(100*sin(idle/200)) do
       pset(camx+frnd(128),
            camy+frnd(128),
            grays[1+frnd(5)])
    end
 end
 --message
 if p_t > 0 then
    draw_popup()
 elseif pcanact then
    local yy = py-7-flr(idle/50)
    print("Ž",px,yy,0)
    rect(px+2,yy+1,px+4,yy+2)
    print("Ž",px,yy-1,7)
 end
 --overlays
 if news > 0 then
    draw_news()
 end
 if zone == 4 and zlock > 3 then
    --border
    local xmin = camx-1
    local ymin = camy-1
    local xmax = camx+128
    local ymax = camy+128
    rectfill(xmin,ymin,xmax,ymin+zvar2,11)
    rectfill(xmin,ymax-zvar2,xmax,ymax)
    rectfill(xmin,ymin,xmin+zvar2,ymax)
    rectfill(xmax-zvar2,ymin,xmax,ymax)
 end
 if zone == 7 and zlock > 1 then
    color(7)
    fillscreen(flr((zlock-1)/10))
 end
 if vision > 0 then
    draw_vision()
 end
 
 --debug
 --print(vision.." "..vwait,2,2+sin(idle/50),0)
 --print(stat(1),camx+100,camy+121,0)
 --print(nread.." "..safe,camx+2,camy+8,0)
 --print(mget((px+4)/8,(py+4)/8),camx+100,camy+115,0)
 --print(px..", "..py,camx+2,camy+2,7)
 --print(zvar1.." "..zvar2.." "..zvar3,camx+2,camy+2,8)
end


function draw_e()
 if ehere then
 			if etalked == false then
 			   canuse(ex,ey)
 			end
 			if frnd(max(1+efade/5,dist(px,py,ex,ey)/10)) == 0 then
       pal(15,0)
       spr(111,ex,ey-8,1,2)
    end
 end
end
__gfx__
00000000006660000066600000666000006660000006660000066600000666000006660000066600666666000066666666666600006666666666660000000000
000000000067760000677600006776000067760000667700006677000066770000667700006776006cccc660006cccc66cccc600006cccc66cccc60000000000
007007000067760000677600006776000067760000667700006677000066770000667700006776006cddcc66006cddc66cddc600006cddc66cddc60000000000
000770000067660000676600006766000067660000677000006770000067700000677000006676006cdddcc6606cddc66cddc600006cddc66cddc60000000000
000770000077770000777700007777000077770000077000000776000007700000077700067777606cddddcc666cddc66cddc600006cddc66cddc60000000000
007007000777777006777770077777700777776000076000007770000006700000677000067777606cdddddcc66cddc66cddc600006cddc66cddc60000000000
000000000777777006777700077777700077776000077000000777000007700000077600007777006cddcdddcc6cddc66cddc600006cddc66cddc60000000000
000000000070070000700600007007000060070000076000006007000006700000700600007007006cddccdddcccddc66cddc600006cddc66cddc60000000000
000000000000ddd000ddddddddddddd000ddddddddddddd06dddddddddddddddddddddd6111111116cddcccdddccddc66cddc600006cddc66cddc60000000000
0000000000ddd6dd0ddd6ddd6ddd6ddd0ddd6ddd6ddd6ddd6dddddddddddddddddddddd6111111116cddc6ccdddcddc66cddc660066cddc66cddc60000000000
0000077700066666006666666666666000666666666666606dddd1ddddddd1ddddddd1d6111111116cddc66ccdddddc66cddcc6666ccddc66cddc66666666666
000077777006010600600060106000600066601000106660d1111111111111111111111d111111116cddc666ccddddc66cdddccccccdddc66cddccccccccccc6
00007777706607060060006070600060006d607000706d606dddddddddddddddddddddd6111111116cddc6066ccdddc66cddddddddddddc66cddddddddddddc6
00007777766600060060006000600060006d600000006d606dddddddddddddddddddddd6111111116cddc60066ccddc66ccddddddddddcc66cddddddddddddc6
0007777776d600060060006000600060006d600000006d606d1ddddddd1ddddddd1dddd6111111116cccc600066cccc666cccccccccccc666cccccccccccccc6
00077777d6d6d0d60060006000600060006d600000006d60d1111111111111111111111d11111111666666000066666606666666666666606666666666666666
00077777d6d6ddd6006d0d6d0d6d0d60006d600000006d6000000000000000000000000000000000000000000445445d0000007000d000000007700000000000
000d777d66d66666066ddd6ddd6ddd60066d600000006d6000000700000000dddd0000000044444444444400044444550000707000d000000077770000000000
00ddddd66dd6ddd60666666666666666066d660000066d66007001000000dd1111dd00000444444444444440044444440070707006d000000677676000000000
01d66666dd66dd66166ddd6ddd6ddd66166dd66ddd66dd66001d6660000d111dd111d0000444544554454440044544440070707006d0000006d77d6000001110
0ddd6d66666ddd6606ddd6666666ddd606ddd6611166ddd60006ddd600d1111111111d00044544444444544004454444d6767676d7d00000066dd66000111d10
1d6666600066666006666600000666660666660ddd066666006dddd600d111ddd1111d000444444444444440044444440070707006d000000d6666d001101110
dd0d1d00000d1d0000d1d0000000d1d000d1d0011100d1d066ddddd60d1111d11d1111d0044444555544444004444455d6767676d70000000dddddd001000000
000ddd00000ddd0000ddd0000000ddd000ddd0000000ddd0dddddddd0d1d11d11d11d1d00445445dd54454400445445d006060600600000000dddd0055000000
000000000007000000077000000770000000000000000000000000000d1d11d1dd11d1d00445445dd5445440d544544000000000000000000000000055111000
000000007001007000777700007777000094994994994900020002000d111d1111d111d00444445555444440554444400d66666666666666666666d000001100
000000001d666d1000777700007777000942442442442490dddddddd00d11d1111d11d00044444444444444044444440d6dddddddddddddddddddd6d00000110
09e9e9e006ddd600007777000077770004424424424424400400040000d1111111111d0004454444444454404444544056dddddddddddddddddddd6500000010
0e8888906ddddd600777770000777770044244244244244000000000000d111dd111d00004445445544544404444544056dddddddddddddddddddd6500000111
098888e06d111d6000777700007777000442442442442440020002000000dd1111dd000004444444444444404444444056dddddddddddddddddddd65000001d1
0e9e9e906dddddd60070070000700700099999999999999066666666000000dddd0000000044444444444400554444405d66666666666666666666d500000111
00000000dddddddd007000000000070000442000000244000400040000000000000000000000000000000000d5445440d5dddddddddddddddddddd5d00000000
00000000000dddddddddd000000dddddddddd000000dddddddddd000000dddddddddd00000228200002222000028220000222200677770006777700067777000
000000670ddd66666666ddd00ddd66666666ddd00ddd66666666ddd00ddd66666666ddd00228e82002222220028e822002888820611170006111700068887000
00000166dd66666d666666dddd66666dd66666dddd66666dd66666dddd666666666666dd228e9e822288882228e9e82228e1de82688870006111700061117000
00001100d666666dd666666dd666666dd666666dd666666d6666666dd6666dd66dd6666d2289d18228e99e82281d98228e9119e8611170006888700061117000
00066000d6666666dd66666dd66666dddd66666dd6666ddd6d66666dd6666d6dd6d6666d228911828e91d9e82811982228e99e82611170006111700068887000
006dd600d666666dd666666dd6666dddddd6666dd666666d6666666dd66666d66d66666d228e9e8228e11e8228e9e822228888226d6d70006d6d70006d6d7000
05dddd50dd66666d666666dddd66666dd66666dddd66666dd66666dddd66666dd66666dd0228e82002888820028e82200222222066d6600066d6600066d66000
005555005ddd66666666ddd55ddd66666666ddd55ddd66666666ddd55ddd66666666ddd500228200002222000028220000222200000000000000000000000000
555dddddddddd5550000000000066600000666000006660000066600111111112222111112221111111222221122221111221110111111110000000110000000
5dd55555555555550000000000666600006666000066660000666600111111222112111112121111121211121121121122221110011122210000001110000000
5dddddddddddd5550000000000666600006666000066660000666600011111222112111112221211111211121121121121211100001121210000111111000000
5ddddddddddddd555500005500666600006666000066660000666600011111112222111011111111222211121122222222211100000122210001112211100000
5dd55dddddd55d55a500005a00766700007667000076670000766700001122211111110011122221211222221111112211111000000111110001112211111000
5dd555dddd555d555500005507777770077777600777777006777770001121211111110011121121211211111122211111100000000011210011111112221000
5ddddd5dd5dddd550000000007777770007777600777777006777700011122211111111011121121222212212121211111000000000001110111121112121100
5dddd5dddd5ddd550000000000700700006007000070070000700600011111111111111011122221111112211122211110000000000000111111111112221111
5ddddd5dd5dddd550000000040404040004000400040004000400040404040400040004000000000000000000003300000000000000000000000000000ffff00
05ddddddddddd550000000000404040404040404000404040004000404040404040404040000000000000000030033330030000000000300033003300f8ff8f0
05ddddddddddd55055555555400040004000400040004000400040004000400040004000000333000003b300033330300330333003330330003003000ffffff0
05ddd555555dd5505a5aa5a50404040404040404040400040004000404040404040404040033b330003bbb30000000300000000000000000303003030f2ff2f0
45dddddddddd555405555550404040400040004000400040004000404040004000404040003bbb3000bbbbb00000003000303333333303003330033300f22f00
4555dddddddd5554000000000404040404040404040400040404000404040404040404040033b330003bbb30033330300030300000030300030000300ffffff0
044555555555544000000000400040004000400040004000400040004000400040004000000333000003b30003003333003030000003030003333330ffffffff
000444444444400000000000040404040404040400040404000000040404040404040404000000000000000000033000000030000003000003000030f00ff00f
ccd0dddddddd0dcc000000000dddddd00333333000dddd0000333300bbb00bbbbbbbb0000ccc000c0000000000033000000030000003000003000030f0ffff0f
d0dddddddddddd0d0aaaaa00dddddddd333333330dddddd003333330b0b00b0bc000b0000c0c0cccc000000033330030003030000003030003333330f0f00f0f
000dddddddddd000afaaafa0dddddddd333333330dddddd003333330b0b00b0b00cbbbb0cc000c00cc00000003033330003030000003030003000030f0f00f0f
0ccddddddddddcc0aaaaaaa0dddddddd333333330dddddd0033333300cbccbc0000000bb0ccccc0cc00c000003000000003033333333030033300333f0f00f0f
0d00dddddddd00d0aaaaaaa00dddddd00333333000dddd000033330000c00c00000000b00000c000ccccc00003000000000000000000000030300303f0f00f0f
000cddcddcddc000afaaafa0000000000000000000000000000000000000000000cbbbb00000cc000c00ccc003033330033033300333033000300300f0f00f0f
00cd0cd00dc0dc00aafffaa00000000000000000000000000000000000000000c000b0000000000c0c0cc0c033330030003000000000030003300330f0f00f0f
00d00d0000d00d000aaaaa000000000000000000000000000000000000000000bbbbb000000000cccc0000cb0003300000000000000000000000000000f00f00
910000619191919191910043530000b2b30000435300919100000000000091916666564646464686363636367646464686363600000000000000000000000000
00000000f0f0e5a5a59595a5955b5ba5a5955bc5f0000000000000000000000000000000000000000000000000000000f0f0f0f0f0f06e6c6c7ef0f0f0f0f0f0
910000616171717191910000000000b2b300000000009191000092a2000091916656464686363636363636764656564636363600000000000000000000000000
00000000f0f0759595b5a595c5f0f0d55bc5f0f0f0000000000000000000000000000000000000000000000000000000f000006e6c7e6f00007f6e6c7e0000f0
910000e26171717191910043530000b2b300004353009191e200b2b300e291915646468636363636367646465656464636363600000000000000000000000000
00000000f0f075a5a5a59585f0f0f0f0f0f0f0f0000000000000000000000000000000000000000000000000000000006e6c7e6f007f000000006f007f6e6c7e
91000000435343539191000000000093a300000000009191000093a3000091914686363636363676464656565656468636367600000000000000000000000000
00000000f0f075b5b5959585f0f00000000000f0000000000000000000000000000000000000000000000000000000006f007f006e6c7e00006e6c7e006f007f
910000000092a20091919100e2000000000000e2009191914353f0f0435391913636363636764646565666665656463676464600000000000000000000000000
00000000f0f0d5a5a5959595f5f0f0f0000000f000000000000000000000000000000000000000000000000000000000f00000006f007f00006f007f000000f0
9100000000b2b3009191910000000092a20000000091919100000000f00091913636363636465656666656565646464646465600000000000000000000000000
00000000f0f0f075a5b5a5a5b55af5f0000000f0000000000000000000000000000000000000000000000000000000006e6c6c7e00000000000000006e6c6c7e
91e200000093a3e291919191910000b2b30000919191919100000000000091913636363676465656665656464646464646566600000000000000000000000000
00000000f000f0d595a5a59595a585f0000000f0000000000000000000000000000000000000000000000000000000006f00007f00000000000000006f00007f
91919191919191919191919191919191919191919191919191919191919191913676464646566656564646468636364656566600000000000000000000000000
00000000f000f0f0d595a59595a585f0000000f000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000f0
463636464636464636463646363636460e1d2d3e1000001100cc0cc00cc0cc007646565656565646464686363636364656566600000000000000000000000000
00000000f00000f0f07595a59595c5f0000000f01111111100ccbcc00ccbcc0000000000000000000000000000000000f0006e6c7e00004d5d00006e6c7e00f0
463646463636364636463646363646460e1d2d3e1111111100003000000300004656566656464686363636363636764646565600000000000000000000000000
00000000f0000000f07595959595f0f0000000f011122221cc0ccc00000cc0cc00000000000000000000000000000000f0006f007f00004e5e00006f007f00f0
363646463646364646364646363636460e1d2d3e11121121ccbc0c0cc0c0cbcc5666564646863636363636363636863646465600000000000000000000000000
00000000f0000000f0d5b5b59585f000000000f0111211210030ccbccbcc030000000000000000000000000000000000f00000000000004f5f000000000000f0
463636364646364646363646463636360e1d2d3e2212222100d0003003000d006656468636363636363636363636367646566600000000000000000000000000
00000000f0000000f0f075a59585f000000000f022111111000000d00d00000000000000000000000000000000000000f06e6c7e00000000000000006e6c7ef0
464636464636363646364636463636460e1d2d3e111111110000cc0cc0cc00006656463636363636363636363676465666665600000000000000000000000000
00000000f000000000f07595b585f000000000f011111112cc0c0cbccbc0c0cc00000000000000000000000000000000f06f007f00007c8c8c9c00006f007ff0
463636464636463646363646463636360e1d2d3e12211111ccbcc030030ccbcc5646863636363636363676464656566656564600000000000000000000000000
00000000f000000000f0d59595c5f000000000f012211111003000d00d00030000000000000000000000000000000000f00000000000acecfcbc0000000000f0
011121312131415121312131213121310e1e2e3e1111121100cc0cc00cc0cc004646363636363676464646565666665646468600000000000000000000000000
00000000f000000000f0f0d5c5f0f000000000f01111111100ccbcc00ccbcc0000000000000000000000000000000000f00000000000ed0000fd0000000000f0
021222322232425222322232223222320f1f2f3f1110011100003000000300004686363636764646565656666656464686363600000000000000000000000000
00000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0100000110000d000000d000000000000000000000000000000000000f0f0f0f0f0f0edccdcfdf0f0f0f0f0f0
0007700000077000000770000007700000077000000770000000000000000000000000000000000000001ffffff100000000000000000000fff0000000000fff
0077770000777700007777000077770000777700007777000000000000000000000000000000000000001ffffff100000000000000000000f00000000000000f
077777700777777007777770077777700777777007777770444444440000000000000000000000000000ffffffff000000000000000000000000000000000000
0777777007777770067777700d6777700cd677700dcd6770444444440000000000000000000000000000ffffffff000000000dddddd000000000000000000000
06dcd670076dcd600776dcd007776dc0077776d007777760444444440000000011111111000000000000ffffffff0000000dddccccddd0000000000000000000
077777700777777007777770077777700777777007777770444444440000001111111111110000000000ffffffff000000ddccc66cccdd000000000000000000
0077770000777700007777000077770000777700007777004444444400000111ffffffff111000000000ffffffff00000ddcc666666ccdd00000000000000000
00077000000770000007700000077000000770000007700044444444000011ffffffffffff1100000000ffffffff00000dcc66777766ccd00000000000000000
00000000777776cddc67777700000000000000077000000000000100000010000000010000000000000000000ccccc0008888800099999000000ffffffff0000
00000000777776cddc6777770000000000000007700000000000110000011000000011000000011000000000cccccc0088888800999999000000ffffffff0000
0cc00cc0777776cddc6777770067770000770777777077000001110000111000000111000000111000000000cccccc0088888800999999000000ffffffff0000
cccccccc777776cddc677777006dd70007777776777777700001110000111000000111000000111000077000cccccc0088888800999999000000ffffffff0000
0c0000c0777776cddc6777770066670006777776777777600001100000111000000110000001110000600700c6777d0086777200967774000000ffffffff0000
cccccccc777776cddc677777006dd700006677767777660000011000001100000001100000011000060000700ccccc0008888800099999000000ffffffff0000
0cc00cc0777776cddc67777700666600000774447777700000010000001100000001000000011000061111600000000000000000000000000000ffffffff0000
00000000777776cddc67777700000000006744744777770000010000000100000001000000010000006666000000000000000000000000000000ffffffff0000
07777777777776cccc67777777777770006474747477760000000000000000000000000000000000000000000000000000000000000000000000000000000000
077777777777766cc66777777777777000046474747660000000000000000000000fffffffffff00000fffffffffff00000fffffffffff000000000000000000
077777777777776666777777777777700004047474700000004444444444440000ffffffffffff0000ffffffffffff0000ffffffffffff000000000000000000
07777777777777777777777777777770000404747400000000444444444444000ffffffffffffff00ffffffffffffff00ffffffffffffff00000001111101010
0777777777777777777777777777777000040474746770000444444444444440fffffffffffffff0ff8ffffffffff8f0ff88ffffffff88f00000000000001010
0777777777777777777777777777777000040474747727000444444444444440fff8ffffffff8fffff888ffffff888ffff8f8ffffff8f8ff0000000010101010
0777777777777666666777777777777000040474747427004444444444444444fff888ffff888ffffff888ffff888ffffff888ffff888fff0000001010001010
07777777777666dddd6667777777777000040464644227004444444444444444ffffffffffffffffffffffffffffffffffffffffffffffff0000001010101010
677777777776ddd11ddd67777777777600044444442027000040020000200400ffffffffffffffffffffffffffffffffff8ffffffffff8ff0000001110101010
667777777776d111111d67777777776600040020046027000040020000200400ffffffffffffffffff8ffffffffff8ffff88ffffffff88ff0000000000101010
067777777776d111111d677777777760000400200460270000400200002004000ffffffffffff8f00ff8ffffffff88f00ff88fffff8888f00000001010101010
066777777776d111111d677777777660000400200460270000400200002004000ff8fffffff88ff00ff88ff88f8888f00fff8f888f88f8f00000001000101010
006677777776d111111d677777776600000400200400200000400200002004000ff88888ff88fff00ff888888888fff00ff888888888fff00000001110101110
000666777776d111111d677777666000000400200400200000400200002004000ffff8f8888fff000fff88f8888fff000fff88f8888fff000000000010100100
000006666776d511115d6776666000000004000004000000004000000000040000ffffffffffff0000ffffffffffff0000ffffffffffff000000001110100100
0000000066665555555566660000000000040000040000000040000000000400000ffffffffff000000ffffffffff000000ffffffffff0000000000000000000
__gff__
0000000000000000000000000000000100000000000001010101000000000000000000000000010000000000010101000001000001010100000000000000000000000000000000000000000000000000010100000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010100000000000101000000000000000000000001010101010100000000000000000000000001010101000000000000000000000000
__map__
17171717171717171717171717171717171717171717171717171717171717170000000000000000000000000000000000000000000000000000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
17171717171717171717171717171717171717171717171717171717171717170000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000f0000000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
00000000000000000000000000000000000000000000000000000000000000003636363636363636363636363636363636363636363636363636363636363636363636360f000000000f0f0f0f0f0f000000000f0000000000000000000000000f0f0f0f0f0f0f0f0f0f0f000000000000000000000f0f0f0f0f0f0f0f0f0f0f
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003c3e00000000000000000000000000000000000f000000000f5e5b5b5f0f000000000f0000000000000000000000000f0f0f0f0f0f0f0f0f00000000000000000000000000000f0f0f0f0f0f0f0f0f
36363636363636363636363636363636363636363636363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000f0000000f0f595b59580f0f0000000f0000000000000000000000000f0f0f0f0f0f0f00000000000000006c6d00000000000000000f0f0f0f0f0f0f
00000000002e3c3d3d3e2e000000000000000000002e3c3d3d3e2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000f5e59595b5a5f0f005e5f0f0000000000000000000000000f0f0f0f0f0f000000006c6e6d00007c7d00006c6e6d000000000f0f0f0f0f0f
19191919192e000000002e191919191919191919192e000000002e19191919190000000000000000000000000000000000000000000000000000000000000000000000000f0000000f5d59595a5a580f0057580f0000000000000000000000000f0f0f0f0f00000000006b0f7b0000000000006b0f7b00000000000f0f0f0f0f
19191919192e262e2e312e191919191919191919192e260f0f312e19191919190000000000000000000000000000000000000000000000000000000000000000000000000f0000000f0f57595959580f0f5d5c0f0000000000000000000000000f0f0f0f0000000000007c7e7d0000000000007c7e7d0000000000000f0f0f0f
19191919182e2e00002e2e161919191919191919182e000000002e16191919190000000000000000000000000000000000000000000000000000000000000000000000000f000000000f5db5595b595f0f0f000f0000000000000000000000000f0f0f0f0000000000000000000000000000000000000000000000000f0f0f0f
19191919180000000000001619191919191919191800000000000016191919190000000000000000000000000000000000000000000000000000000000000000000000000f000000000f0f0f5db559595f0f000f0000000000000000000000000f0f0f00000000000000000000000000000000000000000000000000000f0f0f
19171718000000272800000019191916181919190000002728000000161717190000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000f0f0f5d5b580f0f0f0000000000000000000000000f0f0f00006c6e6d000000000000000000000000000000006c6e6d00000f0f0f
19171718000000373800000019191617171819190000003738000000161717190000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000f0f57595f0f0f0000000000000000000000000f0f0000006b0f7b000000000000000000000000000000006b0f7b0000000f0f
19343500000000000000000019191617171819190000000000000000003435190000000000000000000000000000000000000000000000000000000000000000000000000f000f0f0f0f0f0f0f0f5e595a580f0f0000000000000000000000000f0f0000007c7e7d000000000f0000000000000f000000007c7e7d0000000f0f
19000000002e000000002e001617171717171718002e000000002e00000000190000000000000000000000000000000000000000000000000000000000000000000000000f0f0f5e5f0f5ea5a5a55959595c0f0f0000000000000000000000000f0f0000000000000000000000006b00007b0000000000000000000000000f0f
19343500000000292a0000001617171717171718000000292a000000003435190000000000000000000000000000000000000000000000000000000000000000000000000f0f5e5959a559595b595a5a580f0f0f0000000000000000000000000f0f00000000000000000000006e7d00007c6e00000000000000000000000f0f
19000000000f002b3b002e0000002e00002e0000002e002b3b002e00000000190000000000000000000000000000000000000000000000000000000000000000000000000f0f575a5a595bb5b5595a595c0f000f0000000000000000000000000f0000006c6d00000000000000000000000000000000000000006c6d0000000f
193435000000002b3b00000000000000000000000000002b3b000000003435190000000000000000000000000000000000000000000000000000000000000000000000000f0f575a5a595c0f0f5db55c0f0f000f0000000000000000000000000f0000007c7d00000000000000000000000000000000000000007c7d0000000f
19000000002e002b3b00000000292a0000292a000000002b3b002e00000000190000000000000000000000000000000000000000000000000000000000000000000000000f0f5d595a580f0f0f0f0f0f0f00000f0000000000000000000000000f0f00000000000000000000007e6d00006c7e00000000000000000000000f0f
19191919000000393a000000002b3b27282b3b00000000393a000000191919190000000000000000000000000000000000000000000000000000000000000000000000000f0f0f57595c0f0f0f0f0f0f0000000f0000000000000000000000000f0f0000000000000000000000006b00007b0000000000000000000000000f0f
191919190000000000000000002b3b37382b3b000000000000000000191919190000000000000000000000000000000000000000000000000000000000000000000000000f000f575b0f0f0f5ea55f0f0f0f000f0000000000000000000000000f0f0000006c6e6d000000000f0000000000000f000000006c6e6d0000000f0f
191919190000000000002e0000393a0000393a00002e000000000000191919190000000000000000000000000000000000000000000000000000000000000000000000000f0f0f57595f0f5e595959a55f0f0f0f0000000000000000000000000f0f0000006b0f7b000000000000000000000000000000006b0f7b0000000f0f
1919191800292a000000000000000000000000000000000000292a00161919190000000000000000000000000000000000000000000000000000000000000000000000000f0f5e595959a55b595a59595b5f0f0f0000000000000000000000000f0f0f00007c7e7d000000000000000000000000000000007c7e7d00000f0f0f
19191818002b3b0000001919190000292a00001919190000002b3b00161619190000000000000000000000000000000000505100000000000000000000000000000000000f0f5d595a5a5959b5b5595b59580f0f0000000000000000000000000f0f0f00000000000000000000000000000000000000000000000000000f0f0f
1918180000393a0000191919192e002b3b002e191919190000393a00001619190000000000000000000000000000000000606100000000000000000000000000000000000f0f0f5759595b5c0f0f5d5a5a580f0f0000000000000000000000000f0f0f0f0000000000000000000000000000000000000000000000000f0f0f0f
1918000000000000191919191900002b3b0000191919191900000000000019196463636367646566656565666564686363636300000000000000000000000000000000000f000f5db5b55c0f0f0f0f5759580f0f0000000000000000000000000f0f0f0f0000000000006c6e6d0000000000006c6e6d0000000000000f0f0f0f
1900000000000019191919191900002b3b0000191919191900000000000019196863636364656565646464656564636363636700000000000000000000000000000000000f000f0f0f0f0f0f000f5e5a5a580f0f0000000000000000000000000f0f0f0f0f00000000006b0f7b0000000000006b0f7b00000000000f0f0f0f0f
190000272800001919191919192e002b3b002e19191919190000292a000019196363636764656464686364656468636363676400000000000000000000000000000000000f00000000000000000f57595a5c0f0f0000000000000000000000000f0f0f0f0f0f000000007c7e7d00006c6d00007c7e7d000000000f0f0f0f0f0f
1900003738000019191919191900002b3b000019191919192e002b3b002e19196363636465646863636764656463636363646500000000000000000000000000000000000f5e5f00000000000f0f575a580f0f0f0000000000000000000000000f0f0f0f0f0f0f00000000000000007c7d00000000000000000f0f0f0f0f0f0f
1900000000002e19191919171800002b3b000016171919190000393a000019196363676464686363636465656463636367646500000000000000000000000000000000000f5d5c00000f0f0f0f5e5a5a580f0f0f0000000000000000000000000f0f0f0f0f0f0f0f0f00000000000000000000000000000f0f0f0f0f0f0f0f0f
19000000002e191919191817182e00393a002e161716191900000000000019196764646564636363676465646863636364656500000000000000000000000000000000000f000f0f0f0f5ea5a55b5a5b5b5f0f0f0000000000000000000000000f0f0f0f0f0f0f0f0f0f0f000000000000000000000f0f0f0f0f0f0f0f0f0f0f
190f0f1919191919191918002e0000000000002e0016191900002728000019196465656468636764646464686363636764656400000000000000000000000000000000000f000f5ea5a55a5b5b5b5a5b5a580f0f0f00000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f00000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
190000191919191919190000000000292a0000000000191900003738000019196566656467646464646863636363676464646800000000000000000000000000000000000f0f0f575a5b5a595a5a59595a59a55f0f00000000000000000000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f
__sfx__
001e00002f115331152d115311152f115331152d115311152f115331152d115311152f115331152d11531115371053c10535105391051b0001d0000200002000080001b0000c0000e00010000120001300004000
001e00000a7300a7300a7310f7310f7300f7310c7310c7300c7300c7300c7300c7300c7200c7200c7200c7100873008730087310d7310d7300d7310a7310a7300a7300a7300a7300a7300a7200a7200a7200a710
001e00000d8420d8420d8420d8420d8300d8300d8300d8300d8200d8200d8200d8200d8100d8100d8100d8100b8420b8420b8420b8420b8300b8300b8300b8300b8200b8200b8200b8200b8100b8100b8100b810
001e00000684206842068420684206830068300683006830068200682006820068200681006810068100681009842098420984209842098300983009830098300982009820098200982009810098100981009810
001e00000a7300a7300a7310f7310f7300f7310c7310c7300c7300c7300c7300c7300c7200c7200c7200c71008730087300873105731057300573107731077300773007730077300773007720077200772007710
00140000391053e105371053b105391053e105371053b105391053e105371053b105391053e105371053b105371053c10535105391051b0001d0000200002000080001b0000c0000e00010000120001300004000
001e00001680216802168021680216800168001680016800168001680016800168001680016800168001680014802148021480214802148001480014800148001480014800148001480014800148001480014800
001e0000118021180211802118021180011800118001180011800118001180011800118001180011800118000d8020d8020d8020d8020d8000d8000d8000d8000d8000d8000d8000d8000d8000d8000d8000d800
001900001a6441a6421a6401a64011632116321163011630096220962209620096200161201612016100161500000000000000000000000000000000000000000000000000000000000000000000000000000000
001900000475004750047520475204750047500475204752047500475004752047520475004750047520475201750017500175201752017500175001752017520175001750017520175201750017500175201752
00080000195451953419530195341253512524125251e5141e515115000f500017000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001400000175006750067500475001750067500675004750017500675006750047500175006750067500475001750057500575003750017500575005750037500175005750057500375001750057500575003750
001400002730024325243252432500300003000030020320203202632425321233252030022320243002730027300233252332523325000000000000000000000000000000000000000000000000000000000000
001400003630436305353143531535324353253533435335000000000000000000000000000000000000000000000000003531435315353253532500000000000000000000000000000000000000000000000000
011100000161401611096210962111631116311a6411a640116001160009602096020960009600016020160201600016000000000000000000000000000000000000000000000000000000000000000000000000
001900001761015611116110d61109611066110361101610016100361105611096110d6111161115611176101761015611116110d61109611066110361101610016100361105611096110d611116111561117610
0005000001210012100321127221042102722103211012100121001210032110e221042100e221032110121001210012100321127221042102722103211012100121001210032110e221042100e2210321101210
000a00001f5441f545245342453526524265252451424515005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
010a00000663006635046200462502610026150000000000000000000000000000000171001710017100171001722017220172201722017200172001720017200173201732017320173201730017300173001730
001400000174201742017400174001752017520175001750027620276202760027600277202772027700277003772037720377003770037720377203770037700477204772047600475004742047320472004710
001000000e7500e7500e7520e7420e7320e7220e7200e7200e7500e7500e7520e7420e7320e7220e7200e7200e7500e7500e7520e7420e7320e7220e7200e7200e7500e7500e7520e7420e7320e7220e7200e720
001000000c7500c7500c7520c7420c7320c7220c7200c7200c7500c7500c7520c7420c7320c7220c7200c72010750107501075210742107321072210720107201075010750107521074210732107221072010720
001000003e6503965129651186510765505602016000c7000e7000e7000e7020e7020e7020e7020e7000e7000e7000e7000e7020e7020e7020e7020e7000e7000e7000e7000e7020e7020e7020e7020e7000e700
000800000162306640016231a623026230864002623116230162306640016231a623026230864002623116230162306640016231a623026230864002623116230162306640016231a62302623086300262311620
000a00001944019440194301943019440194401943019430194401944019430194301944019440194301943019440194401943019430194401944019430194301944019440194301943019440194401943019430
000a00002244022450224602246022460224502244022440224402245022460224602246022450224402244022440224502246022460224602245022440224402244022450224602246022460224502244022440
000a00003347033470334703347033470334603344033470334703347033470334703347033460334403347033470334703347033470334703346033440334703347033470334703347033470334603344033470
000a00000b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b630
000c00000a6531a6430a0150a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000026755287552b755287002d7542d7550070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
001000002842428421284212841128421284212841128411284212842128411284152240022400224002240000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002373022730277302372022720277202371022710277102340000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000265342c5412e5512e5542e5622e5622e5642e5622e5622e5502e5452e5003b5003f5003f5000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001400000272002725027200272002740027400274002740035200352502720027200274002740027400274002720027250272002720027400274002740027400252002525027200272002740027400274002740
001400000172001725017200172001740017400174001740035200352501720017200174001740017400174001720017250172001720017400174001740017400252002525017200172001740017400174001740
001400002271422712227222271222722227322272222712227222271222722227322272222712227222271221712217122172221712217222173221722217122172221712217222173221722217122172221712
001400002271222712227222271222722227322272222712227222271222722227322272222712227222271224712247122472224712247222473224722247122472224712247222473224722247122472224715
001000000a1200a1200a1250a1000a1220a1220a122001000a1200a1200a1250a1000a1200a12009120091200612006120061250a100061220612206122001000612006120061250010006120061200812008120
001000000912009120091250a100091220912209122001000912009120091250a100091200912008120081200512005120051250a100051220512205122001000512005120051250010005120051200712007120
001000000961207612036120161201612026120461205612056120461202612016120161203612076120961209612076120361201612016120261204612056120561204612026120161201612036120761209612
001000000a1201003011035100200a1220f032100320f0200a1200f0300e0350f0200a1200a1200912009120061200c0300d0350c020061220b0320c0320b020061200b0300a0350b02006120061200812008120
00100000091200d7300e7350d720091220c7320d7320c720091200c7300b7350c7200912009120081200812005120077300873507720051220672207722067100512006710057150671005120051200712007120
000c0000215542a5512a5512855526554265352a5342a5312853526534265152a5142a5112851526514265153f5003f5003650036500375003950039500335003550036500385003a5003a5003b5003650037500
000c00001d470234712e2751d460234612e2651d450234512e2551d440234412e2451d430234312e2351d420234212e2251d410234112e2152370022700207001f7001d7001b7001a70017700137001270010700
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
0014000006534065510657109570095750655009550095550653009530095350651009510095150d5000f5000f5051e500265002e5002b500235002b50012500195001c500265002650014500245000000000000
__music__
00 08 09 43 44
03 41 09 43 44
03 41 42 43 0f
00 41 42 43 12
04 41 42 43 13
01 41 42 43 0b
00 41 42 0c 0b
00 41 42 43 0b
02 41 42 0d 0b
03 1b 42 43 18
03 1b 42 19 18
03 1b 1a 19 18
01 41 42 43 14
02 41 42 43 15
01 41 42 43 21
00 41 42 43 22
00 41 42 23 21
00 41 42 24 22
00 41 42 43 21
02 41 42 43 22
01 41 42 27 25
00 41 42 27 26
00 41 42 27 25
00 41 42 27 26
00 41 42 27 28
02 41 42 27 29
01 41 42 43 01
00 41 42 43 04
00 41 42 02 01
02 41 42 03 04
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
00 00 00 00 00
