pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--signed by '89
--made with ‡ by tim knauf
a={loaded={},_c={}}
a._c["utils"]=function()
function b(c)
local d, e = flr(c), ceil(c)
if (c-d<e-c) return d
return e
end
function f(g, c, h, i)
j = (#g * 4) - 1
print(g, c - j, h, i)
end
function k(g,l,m)
local n, o, p, q, c, h = 1, 1, 6, 0, 0, 0
local function r()
local s, t = {}, ""
local u, v
s.done = false
s.feed = function(w)
if w == ">" then
v = v or tonum(t)
u(v)
s.done = true
elseif w == "#" then
v = l[n]
n += 1
elseif w == "n" then
u = function()
h += p
c = q
end
elseif w == "x" then
u = function(v) c,q = v,v end
elseif w == "y" then
u = function(v) h = v end
elseif w == "h" then
u = function(v) p = v end
elseif w == "c" then
u = function(v) color(v) end
elseif w == "s" then
u = function(v) spr(v,c,h) end
elseif tonum(w) then
t = t..w
end
end
return s
end
local x, y
y = function(w)
if x then
x.feed(w)
if (x.done) x = nil
elseif w == "@" then
local z = m[o]
o += 1
for ba=1,#z do
local bb = sub(z, ba, ba)
y(bb)
end
elseif w == "<" then
x = r()
elseif w == " " then
c += 3
elseif w == "i" then
line(c, h, c, h+4)
c += 2
elseif w == "-" then
line(c, h+2, c+1, h+2)
c += 3
elseif w == ":" or w == "." or w == "!" then
print(w, c - 1, h)
c += 2
elseif w == "(" or w == "," then
print(w, c, h)
c += 3
elseif w == ")" then
print(w, c-1, h)
c += 2
elseif w == "'" then
line(c, h, c, h+1)
c += 2
else
print(w, c, h)
c += 4
end
end
for ba=1,#g do
local bb = sub(g, ba, ba)
y(bb)
end
end
function bc(d,e)
local bd = e - d
return rnd(bd) + d
end
function be(h,bf)
rect(2,h,61,bf+h,8)
rectfill(3,h+1,60,bf+h-1,0)
end
function bg(bh, bi)
rect(2,2,61,53,bh)
rectfill(3,3,60,52,bi)
end
function bj(bk)
return ""..b(bk*100)
end
function bl(bm, c, h, bn)
spr(bm + (bn and 1 or 0), c, h)
end
end
a._c["economy"]=function()
--constants as well as formulas for gameplay tuning
--(many of these now moved to constants file to get token count down)
bo = {
new_guitar = 200,
record = 20,
metronome = 50,
new_drum = 100,
flyer = 5
}
bp = {
new_guitar = 0.5,
new_drum = 0.3
}
function bq(br)
return br * 2
end
function bs(bt)
return ceil(bt * 0.75)
end
function bu(bv)
return -bv * 0.3
end
function bw(bx, by)
local bz = 10
local ca = 1 / bz
bx = min(bx, bz)
by = min(by, bz)
local cb = bx * ca
local cc = -cb * (cb-2)
local ce = by * ca
local cf = -ce * (ce-2)
local cg = (cc * 0.3) + (cf * 0.7)
return min(1, cg)
end
function ch(ci, cj)
return sqrt(ci * cj)
end
function ck(cl,cm)
return cl * (5 + flr(cm * 0.1))
end
function cn(cm)
return flr(cm * 0.1)
end
function co()
return 7 + flr(rnd(5))
end
function cp(bv, cq)
return sqrt(bv * cq)
end
function cr(cs, ct)
local cu = bc(5,10)
return min(cs, flr(cu + (cs * ct)))
end
function cv(cw, cx)
if (cw <= 0.05) return 0.05
local e = min(cw, 1.0)
local d = 0.05
if (cx == 0) d = min(e,0.3)
return bc(d, e)
end
end
a._c["music_player"]=function()
return function()
local cy, cz, da = 0, 0, 16
local function db(dc)
if cy == dc then
return
elseif dc == 0 then
reload(0x3100,0x3100,0x1200)
else
memcpy(0x3100,0x4300,0x0d00)
end
cy = dc
end
local function dd(de, df)
df = df or 0
if (type(de) == "number") de = {index=de}
de.cy = de.cy or df
de.da = de.da or 16
db(de.cy)
da = de.da
cz = 0
music(de.index)
end
return {
writing = function(dg)
dd(dg.writing, 1)
end,
practising = function(dg)
dd(dg.practising)
end,
gigging = function(dg)
dd(dg.gigging)
end,
listening = function(dg)
dd(dg)
end,
victory = function()
dd(34)
end,
success = function()
dd(35)
end,
update = function()
cz += 1
end,
beat = function()
return flr(cz / da)
end,
}
end
end
a._c["app"]=function()
return function()
local dh = {
[0] = di"title",
[2] = di"won",
[1] = di"game",
}
local dj
local dk = {
cy = 99,
update = function()
dj.update()
end,
draw = function()
dj.draw()
end,
}
dk.init = function()
memcpy(0x4300,0x3000,0x0100)
memcpy(0x4400,0x2400,0x0c00)
poke(0x5f2c,3)
cls()
dk.db(0)
end
dk.db = function(dc)
dj = dh[dc](dk)
dk.cy = dc
dj.init()
end
return dk
end
end
a._c["title"]=function()
return function(dl)
local cy, cz
local function db(dc)
if (dc == 0) cz = 80
cy = dc
end
local function dm(s, dn, w)
s -= 1
return w * (s * s * (2.70158 * s + 1.70158) + 1) + dn
end
local function dp(s, dn, w)
if s < 0.3636363636363636 then
return w * (7.5625 * s * s) + dn
elseif s < 0.727272727272727 then
s = s - 0.5454545454545454
return w * (7.5625 * s * s + 0.75) + dn
elseif s < 0.909090909090909 then
s = s - 0.818181818181818
return w * (7.5625 * s * s + 0.9375) + dn
else
s = s - 0.954545454545454
return w * (7.5625 * s * s + 0.984375) + dn
end
end
local function dq()
bl(14,13,2,cz % 240 < 60)
bl(10,56,23,cz % 220 > 176)
k"<x56><y31><s26><c8><x1><y5>get<x22>signed <c5>by<x30><y15>(and save<n><x30><c12>johnny<n><x28>gherkin<n><x38><c5>from<n><x36><c4>military<n><x37>school)<x9><y58><c7>begin<x38>credits<x30><y55><s8>"
spr(4,2,13,3,2)
pset(55,25,12)
local dr = 40
local ds = (cz % 400) / 40
if ds < 1.0 then
dr = dm(ds,40,-12)
elseif ds < 2.0 then
ds -= 1.0
dr = dp(ds,28,12)
end
spr(47,1,dr,1,2)
end
local function dt()
k"<x1><y0><c8>signed by '89<n> <c14>made with <c8>\135<n>  <c6>by <c11>tim knauf<n><y21><c8>thanks testers!<n> <c14>sharon knauf<n>  <c12>peter curry<n>   <c14>craig warne<n>    <c12>jay + zoe<n>     <c14>annie kyles<n><c5><y58>ver 1.1<x40><y55><s8><x48><y58><c7>back"
end
local function du()
bl(10,55,1,cz % 220 > 176)
pset(54,3,12)
k"<x55><y9><s26><<x1><y1><c12>johnny<n>gherkin's <c7>dad<n>will send him<n>to <c4>military<n>school <c7>if he<n>doesn't shape up.<n><c6>he's not cut out<n>for the tough<n>military life.<x9><y58><c7>oh dear"
end
local function dv()
k"<x55><y1><s208><x1><c7>rumour has<n>it that a<n><c2>'fony' music<n>label rep<n><c7>will be in<n>town during 1988,<n><c10>checking out<n>any band <c7>with<n>over <c2>200 fans.<x9><y58><c7>tell me more"
end
local function dw()
bl(14,55,1,cz % 240 < 60)
k"<x1><y1><c8>petra<c7> is<n>getting her<n>school band<n>back together.<n><c12>johnny:<c7> bass.<n><c3>vin:<c7> skins.<n><c14>jen<c7> on vox.<n><c8>petra<c7> on axe.<n><c6>we can save him...<x9><y58><c7>...together!"
local dx = cz / 16
palt(7,true)
spr(16+(dx%2),55,35)
palt()
spr(1+(dx%2),48,40)
spr(32+(dx%2),41,33)
spr(48+(dx%4),49,26)
end
return {
init = function()
db(0)
end,
update = function()
cz += 1
if cy == 0 then
if btnp(4) then
db(2)
elseif btnp(5) then
db(1)
end
elseif cy == 1 then
if (btnp(5)) db(0)
elseif cy == 2 then
if (btnp(4)) db(3)
elseif cy == 3 then
if (btnp(4)) db(4)
elseif cy == 4 then
if (btnp(4)) dl.db(1)
end
end,
draw = function()
cls()
if (cy == 0) dq()
if (cy == 1) dt()
if (cy == 2) du()
if (cy == 3) dv()
if (cy == 4) dw()
if (cy ~= 1) spr(7,1,55)
end,
}
end
end
a._c["won"]=function()
return function(dl)
return {
init = function()
cls()
spr(204,33,23,4,4)
rectfill(1,46,25,52,12)
k"<h7><x1><y1><c14>congratulations!<n><y9><c7>johnny's avoided<n>the military.<n>bring on<n>the<n>future:<x6><y47><c14>1989<x9><y58><c7>radical!<x1><y55><s7>"
dy.victory()
end,
update = function()
if (btnp(4)) dl.db(0)
end,
draw = function() end,
}
end
end
a._c["game"]=function()
return function(dl)
local dz = di"inventory"
local ea = di"progress"
local eb = di"ui"
local ec = di"avatar"
local ed = di"locations/map"
local ee = di"locations/garage"
local ef = di"locations/bedroom"
local eg = di"locations/shop"
local eh = di"locations/venue"
local ei = di"timed_action"
local ej = di"action_box"
local ek = di"flyer_slot"
local el = {
gig_summary = di"summaries/gig",
rested_summary = di"summaries/rested",
song_summary = di"summaries/song",
practise_summary = di"summaries/practise",
bought_flyer_summary = di"summaries/bought_flyer",
bought_record_summary = di"summaries/bought_record",
bought_metronome_summary = di"summaries/bought_metronome",
bought_guitar_summary = di"summaries/bought_guitar",
bought_drum_summary = di"summaries/bought_drum",
listen_summary = di"summaries/listen",
tim_k_dialogue = di"dialogues/tim_k",
label_rep_dialogue = di"dialogues/label_rep",
johnny_dialogue = di"dialogues/johnny",
jen_dialogue = di"dialogues/jen",
vin_dialogue = di"dialogues/vin",
crowd_module = di"crowd",
}
local em = {
[0] = ed,
[1] = ee,
[2] = eh,
[4] = ef,
[5] = eg
}
el.flyer_slots = {
ek(el,51,10,1001),
ek(el,20,26,1002),
ek(el,59,43,1003),
}
local en, eo
local function ep(c,h,eq,er)
local es, et, eu, ev = eq - 4, er - 4, eq + 5, er + 5
return c >= es and c <=eu and h >= et and h <= ev
end
el.change_location = function(ew)
el.last_location = en
el.action_boxes = {}
if ew == 0 then
el.avatar.change_style(0)
else
el.avatar.change_style(1)
end
eo = em[ew](el)
en = ew
palt()
cls()
eo.init()
end
el.count_filled_flyer_slots = function()
local cl = 0
for ex in all(el.flyer_slots) do
if (ex.filled()) cl += 1
end
return cl
end
el.reset_flyers = function()
for ex in all(el.flyer_slots) do
ex.clear()
end
end
el.init = function()
el.inventory = dz(el)
el.ds = ea(el)
el.ui = eb(dl,el)
el.ui.init()
el.avatar = ec(el)
el.avatar.init()
el.change_location(0)
el.show_dialogue(el.tim_k_dialogue)
end
el.update = function()
el.inventory.update()
eo.update()
if el.timed_action then
el.timed_action.update()
if (el.timed_action.finished) el.timed_action = nil
else
el.highlighted_box = nil
for ey,ez in pairs(el.action_boxes) do
ez.highlight = ez.inside(el.avatar.c,el.avatar.h)
if (ez.highlight) el.highlighted_box = ez
end
end
el.ui.update()
end
el.draw = function()
eo.draw_under()
el.ui.draw_under()
eo.draw_over()
el.ui.draw_over()
end
el.register_action = function(c,h,fa,fb,fc,fd)
el.action_boxes[fa] = ej(c,h,fa,fb,fc,fd)
end
el.unregister_action = function(fa)
if (highlighted_box == el.action_boxes[fa]) highlighted_box = nil
el.action_boxes[fa] = nil
end
el.start_timed_action = function(fc,fe,ff,fg)
el.timed_action = ei(fc,fe,ff,fg)
end
el.show_summary = function(fh, fi, fj)
el.ui.show_summary_panel(fh(el, fi, fj))
end
el.show_dialogue = function(fh, fj)
el.ui.show_dialogue(fh(el, fj))
end
return el
end
end
a._c["inventory"]=function()
return function(fk)
local fl = di"fanbase"
local fm = di"collections/random_bag"
local fn = di"songs"
local ba = {}
ba.bv = {
bk = 0,
modify = function(fo) ba.bv.bk = min(ba.bv.bk + fo, 1.0) end,
g = function() return bj(ba.bv.bk) end,
}
ba.money = {
bk = 1,
modify = function(fo) ba.money.bk = max(ba.money.bk + fo, 0.0) end,
g = function() return "$"..flr(ba.money.bk) end,
}
ba.listening_songs = fm{fn.hyper, fn.tipsy_groove, fn.wistful}
local bx = fm{fn.originalle, fn.hopeful, fn.twin_guitars, fn.tremolo_bounce}
local by = fm{fn.chirpy, fn.danger, fn.epic}
ba.fn = {
value_ok = 0,
value_rad = 0,
songbook = fm(),
setlist = fm(),
write_ok = function()
local dg = bx.pop()
ba.fn.songbook.add_on_top_if_not_present(dg)
ba.fn.setlist.add_on_top_if_not_present(dg)
return dg
end,
increment_ok = function() ba.fn.value_ok += 1 end,
write_rad = function()
local dg = by.pop()
ba.fn.songbook.add_on_top_if_not_present(dg)
ba.fn.setlist.add_on_top_if_not_present(dg)
return dg
end,
increment_rad = function() ba.fn.value_rad += 1 end,
string_ok = function() return ""..ba.fn.value_ok end,
string_rad = function() return ""..ba.fn.value_rad end,
quality = function() return bw(ba.fn.value_ok, ba.fn.value_rad) end
}
ba.carried_flyers = 0
ba.equipment = {
new_guitar = false,
new_drum = false,
metronome = false,
record = false
}
ba.instruments = {
quality = function()
local fp = 0.2
if (ba.equipment.new_guitar) fp += bp.new_guitar
if (ba.equipment.new_drum) fp += bp.new_drum
return fp
end,
g = function() return bj(ba.instruments.quality()) end
}
ba.cm = {
fanbase = fl(fk),
g = function() return ""..ba.cm.fanbase.total_fans() end,
}
ba.cw = {
bk = 0,
modify = function(fo) ba.cw.bk = max(min(ba.cw.bk+fo,1.0),0.0) end,
g = function() return bj(ba.cw.bk) end
}
ba.cq = {
bk = function()
return ch(ba.fn.quality(), ba.instruments.quality())
end,
}
ba.update = function()
ba.cm.fanbase.update()
end
return ba
end
end
a._c["fanbase"]=function()
return function(fk)
local fq, fr, fs = 0, 2, false
local ft, fu
local fv = 0
local function total_fans()
return fr
end
local function fw()
if fq > 0 then
fq -= 1
fr += 1
end
end
return {
begin_gig = function()
fq += co()
fq += ck(fk.count_filled_flyer_slots(),total_fans())
fq += cn(total_fans())
local fx = total_fans() + fq
local ct = cp(fk.inventory.bv.bk, fk.inventory.cq.bk())
local fy = cr(fq, ct)
ft = total_fans() + fy
fu = 992 / fy
fv = fu
fs = true
local fz = bs(fx)
local ga = fz > 0 and not fk.ds.location_unlocks.shop
return {
ct = ct,
fy = fy,
bt = fx,
fz = fz,
ga = ga
}
end,
end_gig = function()
fr = ft
fq = 0
fs = false
end,
update = function()
if fs then
fv -= 1
if fv <= 0 then
fw()
fv = fu
end
end
end,
total_fans = total_fans,
}
end
end
a._c["collections/random_bag"]=function()
return function(gb)
local gc = {}
local gd = nil
gb = gb or {}
local function ge()
for ba=1,#gb do
local gf = flr(rnd(ba)) + 1
if (gf ~= ba) gc[ba] = gc[gf]
gc[gf] = gb[ba]
end
if (#gc > 1 and gc[#gc] == gd) gc[1],gc[#gc] = gc[#gc],gc[1]
end
return {
add_on_top_if_not_present = function(gg)
for ba=1,#gb do
if (gb[ba] == gg) return
end
gb[#gb+1] = gg
gc[#gc+1] = gg
end,
pop = function()
if (#gc == 0) ge()
local gg = gc[#gc]
gc[#gc] = nil
if (#gc == 0) gd = gg
return gg
end,
}
end
end
a._c["songs"]=function()
return {
hyper = {
index=10,cy=0,da=22
},
tipsy_groove = {
index=12,cy=1
},
wistful = {
index=14,cy=1
},
originalle = {
writing = 6,
practising = 5,
gigging = 1
},
hopeful = {
writing = 2,
practising = 0,
gigging = 9
},
twin_guitars = {
writing = 5,
practising = 7,
gigging = 16
},
tremolo_bounce = {
writing = 0,
practising = 28,
gigging = 26
},
chirpy = {
writing = 4,
practising = 29,
gigging = 12
},
danger = {
writing = {index=8,da=20},
practising = 31,
gigging = 20
},
epic = {
writing = 10,
practising = 33,
gigging = 24
},
}
end
a._c["progress"]=function()
return function(fk)
return {
location_unlocks = {
bedroom = true,
garage = false,
_map = true,
shop = false,
venue = false,
},
talked_to_johnny = false,
talked_to_jen = false,
talked_to_vin = false,
performed_gig = false,
bought_first_flyer = false,
listened_to_record = false,
played_rad_song = false,
played_new_drum = false,
label_rep_will_attend = false,
label_rep_has_attended = false,
}
end
end
a._c["ui"]=function()
return function(dl,fk)
local gh = di"collections/stack"
local gi = gh()
local cz = 0
local gj, gk
local function gl()
return gi.peek()
end
local function gm(gn)
if (gn.highlight) pal(14,8)
local go = flr((cz/12)%4)
spr(37+go%2,gn.c-4,gn.h-4,1,1,go == 2, go == 3)
pal()
end
local function gp()
if gl() == 3 then
spr(7,1,55)
k("<x9><y58><c7>@", nil, {gj.button_text})
elseif gl() == 2 then
spr(7,1,55)
k("<x9><y58><c7>@", nil, {gk.button_text})
end
spr(8,49,55)
local gq
if gl() == 1 then
gq = 123
else
gq = 124
local gn = fk.highlighted_box
if gl() == 0 and gn ~= nil and fk.timed_action == nil then
spr(7,1,55)
k("<x1><y46><c6>@<x9><y58><c7>@", nil, {gn.fc,gn.fb})
end
end
palt(0,false)
palt(10,true)
spr(gq,56,56)
palt()
end
local function gr(h,de)
for ba=1,#de,2 do
f(de[ba](),60,h,de[ba+1])
h += 6
end
end
local function gs()
local ba = fk.inventory
rect(1,5,62,51,11)
rectfill(2,6,61,50,0)
k"<x4><y8><c3>money:<n><c2>fans:<n><c9>ok songs:<n><c8>rad songs:<n><c11>tightness:<n><c14>instruments:<n><c12>inspiration:"
gr(8, {
ba.money.g,3,
ba.cm.g,2,
ba.fn.string_ok,9,
ba.fn.string_rad,8,
ba.bv.g,11,
ba.instruments.g,14,
ba.cw.g,12})
end
local function gt(gu)
if (gu) k("<x2><y52><c7>@", nil, {fk.timed_action.fc})
rect(2,58,45,62,8)
local j = 41 * fk.timed_action.ratio()
rectfill(3,59,4+j,61,8)
end
return {
show_dialogue = function(gv)
gi.push(2)
gk = gv
end,
show_summary_panel = function(gv)
if gl() == 1 then
gi.push_under(3)
else
gi.push(3)
end
gj = gv
end,
init = function()
gi.push(0)
end,
update = function()
cz += 1
if btnp(5) then
if gl() == 1 then
gi.pop()
else
gi.push(1)
end
elseif btnp(4) then
if gl() == 0 and fk.timed_action then
elseif gl() == 0 and fk.highlighted_box and fk.highlighted_box.fd then
fk.highlighted_box.fd()
elseif gl() == 2 then
gi.pop()
local fj = gk.fj
gk = nil
if (fj) fj()
elseif gl() == 3 then
gi.pop()
local fj = gj.fj
gj = nil
if (fj) fj()
end
end
end,
draw_under = function()
if gl() == 0 and not fk.timed_action then
for ey,ez in pairs(fk.action_boxes) do
gm(ez)
end
end
end,
draw_over = function()
gp()
if gl() == 0 then
if (fk.timed_action) gt(true)
elseif gl() == 1 then
if (fk.timed_action) gt(false)
gs()
elseif gl() == 2 then
gk.draw()
elseif gl() == 3 then
gj.draw()
end
end,
filtered_btn = function(index)
if (gl() == 0) return btn(index)
return false
end,
}
end
end
a._c["collections/stack"]=function()
return function()
local gw = {}
return {
push = function(gg)
gw[#gw+1] = gg
end,
push_under = function(gg)
local gx = gw[#gw]
gw[#gw] = gg
gw[#gw+1] = gx
end,
pop = function()
local gg = gw[#gw]
gw[#gw] = nil
return gg
end,
peek = function()
return gw[#gw]
end,
}
end
end
a._c["avatar"]=function()
return function(fk)
local gy, gz, ha, hb, hc, hd
local he, hf = {1,2,3,4}, {0,1,0,2}
local dk = {
change_style = function(hg)
if hg == 0 then
gy = 133
hd = hf
else
gy = 128
hd = he
end
hc = hg
end,
}
local function db(cy)
gz = gy + (dk.direction * 16)
ha, hb = 0, 0
dk.cy = cy
end
local function hh(direction)
gz = gy + (direction * 16)
ha, hb = 0, 0
dk.direction = direction
end
dk.set_starting_position = function(c,h,direction)
dk.c, dk.h = c, h
db(0)
hh(direction)
end
dk.init = function()
dk.change_style(0)
dk.c, dk.h, dk.direction = 32, 32, 1
db(0, 1)
end
dk.update = function()
local hi, hj, hk = 0, 0, dk.direction
local hl = fk.ui.filtered_btn
if (hl(0)) hi, hk = 0xffff, 0
if (hl(1)) hi, hk = 1, 1
if (hl(2)) hj, hk = 0xffff, 2
if (hl(3)) hj, hk = 1, 3
if hi == 0 and hj == 0 then
if (dk.cy ~= 0) db(0)
else
if (dk.cy ~= 1) db(1)
end
if hk ~= dk.direction then
hh(hk)
elseif hi ~= 0 or hj ~= 0 then
ha = (ha + 0.125) % #hd
hb = hd[flr(ha)+1]
end
local hm = dk.c + (hi * 0.5)
local hn = dk.h + (hj * 0.5)
if (hm < 1 or hm > 63) hm = dk.c
if (hn < 2 or hn > 63) hn = dk.h
clip()
if pget(hm+64,hn) ~= 0 then
dk.c = hm
dk.h = hn
elseif pget(dk.c+64,hn) ~= 0 then
dk.h = hn
elseif pget(hm+64,dk.h) ~= 0 then
dk.c = hm
end
clip(0,0,64,64)
end
dk.draw = function()
spr(gz+hb,dk.c-4,dk.h-7)
end
return dk
end
end
a._c["locations/map"]=function()
return function(fk)
return {
init = function()
map(56,0,64,0,8,8)
clip(0,0,64,64)
local ho = fk.ds.location_unlocks
local hp = fk.avatar.set_starting_position
local hq = fk.register_action
local hr = fk.change_location
if fk.last_location == 2 then
hp(39,50,0)
elseif fk.last_location == 1 then
hp(35,12,1)
elseif fk.last_location == 4 then
hp(11,35,1)
elseif fk.last_location == 5 then
hp(23,53,1)
else
hp(34,36,3)
end
if ho.garage then
hq(28,11,1,"enter","<n><c10>jen's <c6>garage", function()
hr(1)
end)
end
if ho.venue then
hq(47,51,2,"enter","<n><c14>gus's <c6>venue", function()
hr(2)
end)
end
if ho.bedroom then
hq(4,35,4,"enter","<n><c8>petra's <c6>house", function()
hr(4)
end)
end
if ho.shop then
hq(17,51,5,"enter","<n><c10>music <c6>store", function()
hr(5)
end)
end
for ex in all(fk.flyer_slots) do
ex.register_action()
end
end,
update = function()
fk.avatar.update()
end,
draw_under = function()
palt(0,false)
map(16,0,0,0,8,8)
palt()
for ex in all(fk.flyer_slots) do
ex.draw()
end
end,
draw_over = function()
fk.avatar.draw()
map(96,0,0,0,8,8)
end,
}
end
end
a._c["locations/garage"]=function()
return function(fk)
local hs = fk.inventory
local ht = fk.ds
local hu = {0,1,2,1}
local cy
local cz = 1
local function hv()
fk.register_action(36,38,13,"chat","<n><c14>jen", function()
fk.show_dialogue(fk.jen_dialogue, function()
ht.talked_to_jen = true
fk.unregister_action(13)
end)
end)
end
local function hw()
fk.register_action(42,34,14,"chat","<n><c3>vin", function()
fk.show_dialogue(fk.vin_dialogue, function()
ht.talked_to_vin = true
fk.unregister_action(14)
end)
end)
end
return {
init = function()
map(40,0,64,0,8,8)
clip(0,0,64,64)
cy = 1
fk.avatar.set_starting_position(53,44,0)
fk.register_action(20,35,11,"practise","<n><c8>petra's <c6>spot", function()
local hx = hs.bv.bk
local hy = 0.2
if (hs.equipment.metronome) hy = bq(hy)
local hz = min(1.0,hx + hy)
local ia = hz - hx
fk.start_timed_action("practising",480, function()
hs.bv.modify(hy/480)
end, function()
hs.bv.bk = hz
local fi = {tightness_increase=ia,ga=false}
if not ht.location_unlocks.venue then
ht.location_unlocks.venue = true
fi.ga = true
end
if hs.fn.value_rad > 0 and not ht.played_rad_song then
ht.played_rad_song = true
if (not ht.talked_to_jen) hv()
end
if hs.equipment.new_drum and not ht.played_new_drum then
ht.played_new_drum = true
if (not ht.talked_to_vin) hw()
end
cy = 1
fk.show_summary(fk.practise_summary, fi)
end)
dy.practising(hs.fn.songbook.pop())
cy = 2
end)
fk.register_action(60,44,10,"exit","", function()
fk.change_location(0)
end)
if (ht.played_rad_song and not ht.talked_to_jen) hv()
if (ht.played_new_drum and not ht.talked_to_vin) hw()
if ht.performed_gig and not ht.talked_to_johnny then
fk.register_action(48,37,12,"chat","<n><c12>johnny", function()
fk.show_dialogue(fk.johnny_dialogue, function()
ht.talked_to_johnny = true
fk.unregister_action(12)
end)
end)
end
end,
update = function()
cz += 1
if (cy == 1) fk.avatar.update()
end,
draw_under = function()
palt(0,false)
map(0,0,0,0,8,8)
palt(15,true)
map(80,0,0,0,8,8)
palt()
end,
draw_over = function()
if cy == 1 then
if (hs.equipment.metronome) spr(187,14,15)
palt(7,true)
palt(0,false)
spr(23,31,28)
palt()
local ib = 9
if (hs.equipment.new_guitar) ib = 3
spr(ib,10,27)
if (hs.equipment.new_drum) pal(13,9)
spr(54,27,16)
pal()
bl(34,44,29,cz % 440 > 396)
bl(52,39,25,cz % 480 < 60)
bl(18,34,31,cz % 472 > 160 and cz % 472 < 235)
fk.avatar.draw()
else
local beat = dy.beat()
if (hs.equipment.metronome) spr(186+hu[(beat%4)+1],14,15)
palt(7,true)
palt(0,false)
spr(16+(beat%2),31,28)
palt()
if hs.equipment.new_guitar then
pal(11,8)
pal(13,10)
end
spr(1+(beat%2),19,26)
pal()
spr(32+(beat%2),37,20)
if (hs.equipment.new_drum) pal(13,9)
spr(48+(beat%4),27,16)
pal()
end
end,
}
end
end
a._c["locations/bedroom"]=function()
return function(fk)
local cy
return {
init = function()
map(64,0,80,16,4,4)
clip(0,0,64,64)
local hs = fk.inventory
local ht = fk.ds
local hq = fk.register_action
cy = 1
fk.avatar.set_starting_position(37,42,2)
hq(37,48,40,"exit", "", function()
fk.change_location(0)
end)
hq(26,33,41,"write song", "<n><c9>acoustic guitar", function()
local ic = min(hs.cw.bk, cv(hs.cw.bk, hs.fn.value_rad))
local id = max(0, hs.cw.bk - ic)
local fi = {cc=false,cf=false,ga=false,ic=ic}
local dg
if ic >= 0.3 then
fi.cf = true
dg = hs.fn.write_rad()
else
fi.cc = true
dg = hs.fn.write_ok()
end
if (not ht.location_unlocks.garage) fi.ga = true
fk.start_timed_action("writing song",480, function()
hs.cw.modify(-ic/480)
end, function()
hs.cw.bk = id
if (fi.cf) hs.fn.increment_rad()
if (fi.cc) hs.fn.increment_ok()
if (fi.ga) ht.location_unlocks.garage = true
cy = 1
fk.show_summary(fk.song_summary, fi)
end)
dy.writing(dg)
cy = 2
end)
if hs.equipment.record then
hq(43,31,42,"listen","<n>new <c10>record", function()
local hy = 0.5
local cg = min(1.0, hy + hs.cw.bk)
local fi = {
first_time = not ht.listened_to_record,
muse_increase = cg - hs.cw.bk
}
fk.start_timed_action("getting inspired",480, function()
hs.cw.modify(hy/480)
end, function()
hs.cw.bk = cg
ht.listened_to_record = true
cy = 1
fk.show_summary(fk.listen_summary, fi)
end)
dy.listening(hs.listening_songs.pop())
cy = 3
end)
end
end,
update = function()
if (cy == 1) fk.avatar.update()
end,
draw_under = function()
rectfill(0,0,63,63,0)
palt(0,false)
map(24,0,16,16,4,4)
palt()
end,
draw_over = function()
if (cy != 2) spr(203,24,24)
if cy == 1 then
fk.avatar.draw()
elseif cy == 2 then
spr(140+(dy.beat()%4),26,26)
elseif cy == 3 then
local ie = 139
if (dy.beat() % 2 == 0) ie = 180
spr(ie,39,24)
end
end,
}
end
end
a._c["locations/shop"]=function()
return function(fk)
local hs = fk.inventory
local ig, ih = hs.equipment, hs.money
local function ii(c,h,fa,ij,fc,ik)
if not ig[fa] then
local il = bo[fa]
local fb, fd
if ih.bk >= il then
fb = "buy $"..il
fd = function()
ih.modify(-il)
ig[fa] = true
fk.unregister_action(ij)
dy.success()
fk.show_summary(ik)
end
else
fb = "need $"..il
end
fk.register_action(c,h,ij,fb,fc,fd)
end
end
local function im()
fk.unregister_action(55)
local fb,fc,fd
if hs.carried_flyers > 0 then
if hs.carried_flyers == 1 then
fc = "<n>have <c15>1 flyer"
else
fc = "<n>have <c15>"..hs.carried_flyers.." flyers"
end
fb = "another $"..bo.flyer
else
fc = "advertise next<n>gig with <c15>flyers!"
fb = "print $"..bo.flyer
end
if hs.carried_flyers >= 3 then
fb = "that'll do"
fd = nil
elseif ih.bk >= bo.flyer then
fd = function()
ih.modify(-bo.flyer)
hs.carried_flyers += 1
im()
if not fk.ds.bought_first_flyer then
fk.show_summary(fk.bought_flyer_summary)
fk.ds.bought_first_flyer = true
end
end
else
fb = "need $"..bo.flyer
fd = nil
end
fk.register_action(12,42,55,fb,fc,fd)
end
return {
init = function()
map(72,0,64,0,8,8)
clip(0,0,64,64)
fk.avatar.set_starting_position(33,54,2)
ii(12,28,"new_guitar",51,"<c8>pink <c10>'fibson'<n><c6>2nd-hand guitar!",fk.bought_guitar_summary)
ii(28,29,"metronome",52,"<y40><c2>'cox' metronome:<n><c11>double tightness<n><c6>each practise!",fk.bought_metronome_summary)
ii(44,29,"new_drum",53,"<c9>sunburst 'budwig'<n><c6>snare drum!",fk.bought_drum_summary)
ii(60,29,"record",54,"<c10>new l.p.: <c6>listen<n>to <c12>get inspired!",fk.bought_record_summary)
im()
fk.register_action(35,60,50,"exit","", function()
fk.change_location(0)
end)
end,
update = function()
fk.avatar.update()
end,
draw_under = function()
palt(0,false)
map(32,0,0,0,8,8)
if (ig.metronome) spr(80,24,16)
if (ig.new_drum) spr(80,40,16)
if (ig.record) spr(80,55,16)
palt()
if (not ig.new_guitar) spr(229,8,10,1,2)
end,
draw_over = function()
fk.avatar.draw()
end,
}
end
end
a._c["locations/venue"]=function()
return function(fk)
local ht, hs = fk.ds, fk.inventory
local cy, io
local cz = 0
local function ip()
cls()
map(ht.label_rep_has_attended and 112 or 48,0,64,0,8,8)
clip(0,0,64,64)
end
return {
init = function()
ip()
local hq, iq, hp = fk.register_action, fk.unregister_action, fk.avatar.set_starting_position
cy = 1
hp(28,54,2)
hq(11,44,22,"play show","<n>owner <c14>gus", function()
if (ht.label_rep_will_attend) ht.label_rep_has_attended = true
local fi = hs.cm.fanbase.begin_gig()
io = fk.crowd_module(fk)
local ir = hs.money.bk + fi.fz
local cz = 0
fk.start_timed_action("playing show",992, function()
hs.money.modify(fi.fz/992)
cz += 1
if (cz > 256) fk.timed_action.fc = ""
end, function()
hs.cm.fanbase.end_gig()
fk.reset_flyers()
hs.money.bk = ir
local is = bu(hs.bv.bk)
if (not ht.location_unlocks.shop) ht.location_unlocks.shop = fi.ga
if (not ht.label_rep_will_attend) ht.label_rep_will_attend = hs.cm.fanbase.total_fans() >= 200
cy = 1
io = nil
local fj
if ht.label_rep_has_attended then
ip()
hp(11,54,1)
iq(22)
iq(20)
iq(23)
hq(28,48,12,"chat","<n><c12>johnny", function()
fk.show_dialogue(fk.johnny_dialogue)
end)
hq(53,52,21,"negotiate","<n><c2>label rep", function()
local fj = function()
dl.db(2)
end
fk.show_dialogue(fk.label_rep_dialogue, fj)
end)
else
fj = function()
hs.bv.modify(is)
fk.change_location(0)
fk.show_summary(fk.rested_summary,{is=is})
end
end
ht.performed_gig = true
if (hs.fn.value_rad > 0) ht.played_rad_song = true
if (hs.equipment.new_drum) ht.played_new_drum = true
fk.show_summary(fk.gig_summary, fi, fj)
end)
dy.gigging(hs.fn.setlist.pop())
io.init(fi)
cy = 2
end)
hq(28,60,20,"exit","", function()
fk.change_location(0)
end)
if ht.label_rep_will_attend and not ht.label_rep_has_attended then
hq(53,52,23,"chat","<n><c2>label rep", function()
fk.show_dialogue(fk.label_rep_dialogue,nil)
end)
end
end,
update = function()
cz += 1
if (cy == 1) fk.avatar.update()
if (cy == 2) io.update()
end,
draw_under = function()
palt(0,false)
palt(15,true)
for c=0,48,16 do
for h=0,48,16 do
map(8,6,c,h,2,2)
end
end
map(8,0,3,0,7,5)
if cy == 2 then
map(88,0,3,0,7,5)
else
spr(189,0,38)
end
palt()
if (cy == 2) io.draw()
end,
draw_over = function()
palt(0,false)
palt(7,true)
spr(66,10,0,1,2)
spr(66,52,0,1,2)
if (ht.label_rep_will_attend) spr(192,56,45)
palt()
if cy == 1 then
if ht.label_rep_has_attended then
bl(34,25,39,cz % 440 > 396)
bl(52,20,35,cz % 480 < 60)
bl(18,15,41,cz % 472 > 160 and cz % 472 < 235)
end
fk.avatar.draw()
else
local beat = dy.beat()
palt(7,true)
palt(0,false)
spr(16+(beat%2),31,23)
palt()
if hs.equipment.new_guitar then
pal(11,8)
pal(13,10)
end
spr(1+(beat%2),17,20)
pal()
spr(32+(beat%2),44,17)
if (hs.equipment.new_drum) pal(13,9)
spr(48+(beat%4),25,6)
pal()
end
end,
}
end
end
a._c["timed_action"]=function()
return function(fc, fe, ff, fg)
local it = 0
local dk = {
fc = fc,
finished = false,
ratio = function()
return min(it,fe) / fe
end,
}
dk.update = function()
if not dk.finished then
it += 1
if it >= fe then
dk.finished = true
if (fg) fg()
elseif (ff) then
ff()
end
end
end
return dk
end
end
a._c["action_box"]=function()
return function(c,h,fa,fb,fc,fd)
local dn = {
c = c,
h = h,
fa = fa,
fb = fb,
fc = fc,
fd = fd,
highlight = false,
}
dn.es = dn.c - 5
dn.et = dn.h - 5
dn.eu = dn.c + 5
dn.ev = dn.h + 5
dn.inside = function(iu, iv)
return iu>=dn.es and iu<=dn.eu and iv>=dn.et and iv<=dn.ev
end
return dn
end
end
a._c["flyer_slot"]=function()
return function(fk,c,h,ij)
local filled = false
return {
register_action = function()
local hs = fk.inventory
local iq = fk.unregister_action
if (filled or hs.carried_flyers == 0) return
fk.register_action(c+1,h+4,ij,"afix <c15>flyer","<n>nice empty wall",function()
filled = true
hs.carried_flyers -= 1
if hs.carried_flyers == 0 then
iq(1001)
iq(1002)
iq(1003)
else
iq(ij)
end
end)
end,
draw = function()
if (filled) spr(69,c,h)
end,
filled = function()
return filled
end,
clear = function()
filled = false
end,
}
end
end
a._c["summaries/gig"]=function()
return function(fk, fi, fj)
local function iw(quality)
if (quality <= 0.25) return "not bad!"
if (quality <= 0.5) return "good show!"
if (quality <= 0.75) return "great gig!"
return "fantastic!"
end
local ix = iw(fi.ct)
local iy = "1 attendee"
if (fi.bt != 1) iy = ""..fi.bt.." attendees"
local iz = "+1 fan"
if (fi.fy != 1) iz = "+"..fi.fy.." fans!"
local ja = "$"..fi.fz.." earned"
return {
draw = function()
local ht = fk.ds
local bf = 40
local h = 14
local jb = 0
if fi.ga or ht.label_rep_will_attend or ht.label_rep_has_attended then
bf = 52
h = 2
jb = 1
end
be(h,bf)
spr(14,50,h+4+jb)
if fi.ga then
k("<x7><y#><c2>@<n><c3>@<n><y#><c14>music shop<n><c7>now available!", {h+4, h+20}, {iz, ja})
map(16,4,7,h+32,4,2)
map(96,4,7,h+32,4,2)
elseif ht.label_rep_has_attended then
k("<x49><y#><s208><x7><y#><c2>@<n><c3>@<n><c10>@<n><y#><c7>the label<n>rep came.<n>she looks<n>impressed!", {h+27, h+4, h+25}, {iz, ja, iy})
elseif ht.label_rep_will_attend then
k("<x49><y#><s208><x7><y#><c2>@<n><c3>@<n><c10>@<n><y#><c2>@ fans!<n><c7>label rep<n>will attend<n>the next gig!", {h+27, h+4, h+25}, {iz, ja, iy, fk.inventory.cm.g()})
else
k("<x7><y#><c11>@<n><y#><c10>@<n><c2>@<n><c3>@", {h+6, h+18}, {ix, iy, iz, ja})
end
end,
button_text = "radical!",
fj = fj,
}
end
end
a._c["summaries/rested"]=function()
return function(fk, fi, fj)
local bv = fk.inventory.bv.g()
return {
draw = function()
be(13,42)
k("<x50><y17><s14><x7><c7>the band<n>had a well-<n>earned rest.<n><c11>tightness<n><c7>dropped a<n>little, to <c11>@<c7>.", {}, {bv})
end,
button_text = "sure",
fj = fj,
}
end
end
a._c["summaries/song"]=function()
return function(fk, fi, fj)
local ic = bj(fi.ic)
local jc = "an <c9>ok song<c7>!"
if (fi.cf) jc = "a <c8>rad song<c7>!"
return {
draw = function()
local bf, h, jd
if fi.ga then
bf = 52
h = 2
jd = h+20
elseif fi.ic > 0 then
bf = 30
h = 25
jd = h+16
else
bf = 18
h = 36
end
be(h,bf)
local je = "<x50><y#><s14><x7><y#><c7>you wrote<n>@<n>"
if fi.ga then
je = je.."<y#><c11>band practise<n><c7>now available!"
map(16,0,7,h+32,4,2)
map(96,0,7,h+32,4,2)
elseif fi.ic > 0 then
je = je.."<y#>(used <c12>@<n>inspiration<c7>)"
end
k(je, {h+5, h+4, jd}, {jc, ic})
end,
button_text = "cool!",
fj = fj,
}
end
end
a._c["summaries/practise"]=function()
return function(fk, fi, fj)
local hy = bj(fi.tightness_increase)
local cg = fk.inventory.bv.g()
return {
draw = function()
local bf = 24
if (fi.ga) bf = 52
local h = 31
if (fi.ga) h = 2
be(h,bf)
local je = "<x50><y#><s14><x7><y#><c7>band<n><c11>tightness<n>+@<c7>! (now <c11>@<c7>)"
if fi.ga then
je = je.."<n><y#><c2>gig available!"
map(20,4,7,h+32,5,2)
map(100,4,7,h+32,5,2)
end
k(je, {h+5, h+4, h+26}, {hy, cg})
end,
button_text = "nice!",
fj = fj,
}
end
end
a._c["summaries/bought_flyer"]=function()
return function(fk, fi, fj)
return {
draw = function()
be(9,45)
map(20,0,7,13,4,2)
spr(69,26,23)
k"<y13><x41><s55><x50><s10><y22><x42><s14><x50><s36><x7><y30><c7>get more<n><c10>attendees <c7>at<n>next gig:<n>put up <c15>flyers!"
end,
button_text = "easy!",
fj = fj,
}
end
end
a._c["summaries/bought_record"]=function()
return function(fk, fi, fj)
return {
draw = function()
be(2,52)
map(26,0,7,6,2,2)
k"<x50><y7><s14><x7><y23><c5>record player<n><c7>available!<n>get <c12>inspired<c7>,<n>maybe write a<n><c8>rad song<c7>!"
end,
button_text = "exciting!",
fj = fj,
}
end
end
a._c["summaries/bought_metronome"]=function()
return function(fk, fi, fj)
return {
draw = function()
be(2,52)
map(0,1,7,6,4,2)
sspr(48,24,5,8,34,14)
pset(51,8,10)
k"<x21><y13><s187><y6><x41><s55><x50><s10><y15><x42><s14><x50><s36><x7><y23><c2>metronome<n><c7>ready to go.<n>get <c11>double<n>tightness <c7>at<n>band practise!"
end,
button_text = "tight!",
fj = fj,
}
end
end
a._c["summaries/bought_guitar"]=function()
return function(fk, fi, fj)
local hy = bj(bp.new_guitar)
local cg = fk.inventory.instruments.g()
return {
draw = function()
be(2,52)
palt(0,false)
map(0,3,7,6,3,2)
palt(15,true)
map(80,3,7,6,3,2)
palt()
spr(3,17,9)
k("<x50><y7><s14><x7><y23><c8>fibson guitar<n><c7>is all yours!<n>quality of<n><c14>instruments<n>+@<c7>! (now <c14>@<c7>)", {}, {hy, cg})
end,
button_text = "wicked!",
fj = fj,
}
end
end
a._c["summaries/bought_drum"]=function()
return function(fk, fi, fj)
local hy = bj(bp.new_drum)
local cg = fk.inventory.instruments.g()
return {
draw = function()
be(9,45)
map(3,2,7,13,2,1)
pal(13,9)
spr(54,11,12)
pal()
k("<x50><y13><s55><x7><y23><c9>budwig snare<n><c7>ready for <c3>vin!<n><c7>quality of<n><c14>instruments<n>+@<c7>! (now <c14>@<c7>)", {}, {hy, cg})
end,
button_text = "ensnaring!",
fj = fj,
}
end
end
a._c["summaries/listen"]=function()
return function(fk, fi, fj)
local hy = bj(fi.muse_increase)
local cg = fk.inventory.cw.g()
return {
draw = function()
local bf = 30
local h = 25
local je = "<x50><y#><s14><x7><y#><c12>inspired<n><c7>by music!<n><c12>inspiration<n>+@<c7>! (now <c12>@<c7>)"
if fi.first_time then
bf = 42
h = 13
je = "<x50><y#><s14><x7><y#><c12>inspired<n><c7>by music!<n>increased<n>chance of<n>writing a<n><c8>rad song!"
end
be(h,bf)
k(je, {h+5, h+4}, {hy, cg})
end,
button_text = "rockin'!",
fj = fj,
}
end
end
a._c["dialogues/tim_k"]=function()
return function(fk, fj)
return {
draw = function()
bg(13,0)
palt(10,true)
spr(124,50,6)
palt()
k"<x6><y8><c7>i'm <c13>tim k<c7>,<n>game dev<n>and your<n>assistant.<n>press    any<n>time for band<n><c11>statistics!<x28><y29><s8>"
end,
button_text = "will do!",
fj = fj,
}
end
end
a._c["dialogues/label_rep"]=function()
return function(fk, fj)
local jf = fk.ds.label_rep_has_attended
local button_text = "'you will.'"
if (jf) button_text = "'make it 3.'"
return {
draw = function()
bg(2,15)
palt(0,false)
spr(208,50,6)
palt()
if not jf then
k"<x6><y8><c2>'i've heard<n>the buzz<n>about you,<n>but i need to<n>see those<n>fans rocking<n>out to a show.'"
else
k"<x6><y8><c2>'you kids<n>have a lot<n>of fans here.<n>we'd like to<n>sign you for a<n>2 album deal.<n>agreed?'"
end
end,
button_text = button_text,
fj = fj,
}
end
end
a._c["dialogues/johnny"]=function()
return function(fk, fj)
local je = "<x50><y6><s10><x6><y8><c12>playing<n>bass <c5>again<n>feels good,<n><c8>petra<c5>. thanks<n>for getting<n>the band back<n>together."
local button_text = "'no prob.'"
if fk.ds.label_rep_has_attended then
je = "<x50><y6><s10><x6><y8><c5>the label <n>rep is here!<n>think she'll<n>offer a<n><c2>record deal<c5>?<n>you've earned<n>it, petra."
button_text = "'you too.'"
end
return {
draw = function()
bg(12,15)
pset(49,8,12)
k(je)
end,
button_text = button_text,
fj = fj,
}
end
end
a._c["dialogues/jen"]=function()
return function(fk, fj)
return {
draw = function()
bg(14,15)
k"<x50><y6><s36><x6><y8><c5>ha, not to<n>be vain, but<n>your new<n><c8>rad song<n><c5>really shows<n>off <c14>my voice<c5>.<n>bitchin'!"
end,
button_text = "'go girl!'",
fj = fj,
}
end
end
a._c["dialogues/vin"]=function()
return function(fk, fj)
return {
draw = function()
bg(3,15)
k"<x50><y6><s55><x6><y8><c5>this <c9>new<n>snare <c5>is so<n>tasty, i could<n>eat it for<n>breakfast.<n>...mmm, and now<n>i'm hungry."
end,
button_text = "'me too.'",
fj = fj,
}
end
end
a._c["crowd"]=function()
return function(fk)
local fm = di"collections/random_bag"
local jg = fm{
{ie=96},
{ie=96, w=40},
{ie=98},
{ie=98, w=44},
{ie=100},
{ie=100, w=45},
{ie=112},
{ie=112, w=43},
{ie=112, w=46},
{ie=114},
{ie=114, w=41},
{ie=114, w=47},
{ie=116},
{ie=116, w=42},
}
local jh, ji
local io, jj, jk = {}, 0, -1
do
local function jl(jm,c,h)
if (fk.ds.label_rep_will_attend and c > 51 and h > 40 and h < 49) return
add(jm,{c=c,h=h,u=rnd(1)<0.5})
end
local jm, jn = {}, true
for h=36,56,4 do
jn = not jn
for c=3,52,6 do
c += rnd(4)
local jo = 0
if (jn) jo = -4
jl(jm,c+jo,h+rnd(2))
end
end
ji = #jm
jh = fm(jm)
end
return {
init = function(fi)
for dk=1,min(ji,fi.bt) do
add(io, jh.pop())
end
for ba=1,#io do
local gf = ba
while gf > 1 and io[gf-1].h > io[gf].h do
io[gf],io[gf-1] = io[gf-1],io[gf]
gf -= 1
end
end
for w in all(io) do
w.s = jg.pop()
end
end,
update = function()
local beat = flr(dy.beat() * 0.25)
if beat ~= jk then
local jp = ceil(#io / 8)
jj = min(jj + jp, #io)
jk = beat
end
end,
draw = function()
for ba=1,jj do
local jq = io[ba]
local w = jq.s.w
if w then
for c=40,46,2 do
pal(sget(c,w), sget(c+1,w))
end
end
spr(jq.s.ie + dy.beat() % 2,jq.c,jq.h,1,1,jq.u)
pal()
end
end,
}
end
end
function di(v)
local jr=a.loaded
if (jr[v]==nil) jr[v]=a._c[v]()
if (jr[v]==nil) jr[v]=true
return jr[v]
end
di"utils"
di"economy"
local js = di"music_player"
local jt = di"app"
function _init()
if (stat(6) == "export") then
cd"signed"
cd"export"
export"signed89.js"
elseif(stat(6) == "png") then
cd"signed"
cd"export"
save"signed89.png"
else
dy = js()
dl = jt()
dl.init()
end
end
function _update60()
dy.update()
dl.update()
end
function _draw()
dl.draw()
end
__gfx__
00000000000000000008000000008600eeeee00eeeee00000eeee000000000000000000000004a0000cccc0000cccc000000aa00888880000880000008800000
00000000000800000008880000008700e88820e888882000e888820000000000000000000000400000cccc0000cccc000000a000800080000888880008888800
00700700000888000004440000008000e8882e888288820e88888820000000000000000000004000cccccc00cccccc000000a000800080000888880008888800
000770000bb444000bb444000080a8000e820e8820e882e88222882008aaa8000babab0000b05b000555550005555500000aa008800880000224220002242200
00077000004dbc00004dbcc00088a800e8200e8820e882e88200e8828888a880bbababb000bb5b0004794700074974000ddaadd88dd88ddd0374374007347340
00700700000bdcb0000bd4b0008aa800e8000e888e8882e88200e882888a8880bbbabbb0000b5b0009999990099999900dd55dd55dd55ddd044444a0044444a0
00000000000cc400000ccb00006a800000000e88888820e88eee888288a88880bbababb000babb0009dd990009dd99000ddddddddddddddd0488440004884400
00000000000808000008080000088000000000e8888820e88888888208aaa8000babab00000bb000009999000099990000555555555555500044400000444000
77777777777aa77700aa000000aa0000000000e88288200e8888882077777777ffffffff6666666605dddd505555333344ccccccccccccc37770000007777777
777aa77777a9aa770aa9a0000aa9a00000000e8820e88200000e882077777777ffffffffffffffffd55d555044453333d3ccccccccccccc37770000007777777
7709aa7777099aa70a99a0000a99a00000000e8820e88200eee8882077077777ffffffffffffffffddddddd04445333363ccccccccccccc37770000007777777
70a99a77707ee9a7aaee0c00aaeec00000000e888e88820e8888820070777777ffffffffffffffffddddddd05555333363cccdddddddccc37770000007777777
757eeaa7757ee77700ee090000ee9000000000e88888200e8888200075777777ffffffffffffffffddddddd04445333363cccdeedeedccc37770000007777777
75eeee7775eeee770eeee0000eeee00000000002222200002222000075777777ffffffffffffffffddddddd04445333363cccdeedeedccc37770000007777777
75eeee7775edee770eeee0000eeee000000000000000000000000000757777775555555555555555000000005555333363cccdeedeedccc37770000007777777
555dd7775557d77700dd000000dd00000000000000000000000000005557777766666666666666660000000044453333ffffffffffffffff7770000007777777
00000000000cc0000000cc000000cc0000aaa000ee00ee000ee00ee0555fffff3773d555555533336666ffffffff666633333cc33cccc3b3333333330044a000
000cc000000cccc000cccc0000cccc000aaaa0000000000e00000000445fffff3773d44444453333ffffffffffffffff33b3ccccccccccbbffffffff00444000
000cccc0000990000000990000009900a6696a000000000ee000000e445fffff3776d44444453333ffffffffffffffff39bccccccc66cc4bf5557555004da000
00099090000990900000990000079900ac79c7a0e0000000e000000e555fffff6776d55555553333ffffffffffffffff3bccccccccccc343f5557555005d0000
00d4440000d444000007dd000009dd00099999a0e000000000000000445fffff6773d44444453333ffffffffffffffff3ccc9cbc9cccccc3f5557555004d0000
00d440000dd940000009dd000000dd0009889aa00000000e00000000445fffff3773d44444453333ffffffffffffffff33ccb3b3bcccdd33f5555555005d0000
0019100000141000000011000000110000999aaa0000000ee000000e555fffff3773d55555553333ffffffffffffffff3333333333333333f5555555004d0000
006060000060600000006600000066000eeeeeaaee00ee00e00ee00e55ffffff3763355555533333ffffffffffffffff3333333333333333fff555ff005d0b00
0000000000555000000000000055500000555000000000000000000055555000fffff55ffffffd55555fffff6666666605000550ffffffff40000000004d0b30
0055500000044407005550000004440700044400005550000000000055555500fffff55ffffffd44445fffffdddddddd05600060ffffffff40000000a05dbb30
0774440007744470a00444070774447000044400000444000000000001141100ffff5ff5fffffd44445fffff7777777700000000ffffffff00000000bbbdbb00
aaa44470aaa333000a744470aaa333000003330000944400aaa0000002742700fffffffffffffd55555fffffdddddddd00505050ffffffff00000000bbdbbb00
06022ddd06022ddd06a22ddd06022ddd009333000043330006022ddd04444490fffffffffffffd44445fffff7777777705050500ffffffff000000000bbdbb30
062222dd062222dd062222dd062222dd0043330000033300062222dd04224400fffffffffffffd44445fffffdddddddd00505050ffffffff00000000badbbb30
06222260062222600622226006222260000e0e00000e0e000622226000444000fffffffffffffd55555fffffffffffff05050500ffffffff00000000bbaaab30
06022060060220600602206006022060000c0c00000c0c000602206000333300fffffffffffffd44445fffffffffffff00000000ffffffff000000000bbbbb00
111111111111111165555555dddd1dddffffffff88800000fffffffff555755555555555555555f3333333333a76776767677676767767d366666d5555566666
111111116666666665050500dddd1dddfffff611ffe00000fffffffff5555555555555555555555f333333333a76776767677676767767d3dddddd44445ddddd
111111111111111160505050dddd1dddfffff611cff00000fffffffff555555555555555555555553333333336667766666776666677666377777d4444577777
111111110000000065050500dddd1dddfffff61133300000fffffffff5557555755775577555555533333333332666622266662226666233dddddd55555ddddd
11111111000000006050505055555dddf111061100000000fffffffff555755555555555555755553333333333332222222222222222333377777d4444577777
11111111000000006505050055555dddf11106110000000011111111f5555555555555555555555533333333333354444444444444453333dddddd44445ddddd
11111111000000006050505055555555f11106110000000011111111f55555555555555555555555333333333333d5555555555555553333fffffd55555fffff
11111111000000006505050055555555f11106110000000011111111f5557555ffffffff55557555333333333333d4444444444444453333fffffd44445fffff
dddddddd000000006050505077777000f1110611b63498f944444444555575553f55555555557555d33333333333d555f3333333333333336666666666666666
dddddddd000000006505050077777000f11106160fa094c0d9dddddd55555555f555555555555555d33333333333d444f333333333333333dddddddddddddddd
dddddddd000000005000000077777000f1110611ae4fc1e96966666655555555f555555555555555d33333333333d444f3333333333333337777777777777777
dddddddd777770007770077777777000f111100096e0206ec96cc6ccd555d555f555755755557555d33333333333d555fee3e99aaab3bcc3dddddd5555dddddd
dddddddd777770007770077777777000f111100042c9ea78c96cc6cc5555d555f555555555557555d33333333333d444fee3e93aaab3bc337777775555777777
dddddddd777770007655550777777000f1111000e14f3c716966666655555555f555555555555555d33333333333d444fee3e99aaab3bcc3dddddddddddddddd
dddddddd777770007000000777777000f000000094e12c6869966666555555553f55555555555555d33333333333d555feeee93a3abbbc33ffffffffffffffff
dddddddd777770007777777700000000f0000000a9c89f1cffffffffd555d55533fffffff5557555d33333333333d444f3eee99a3abbbcc3ffffffffffffffff
00000000000000000000000000000000000ee000000ee00000000000333333335555555500000000333333333333d555f44e499a4abbbcc43aa3bb9333333333
00000f00000bbf00040440000004404000eee00000eee00000000000777777765555555500000000333333333333d444f444444444444444abbbbbb366666666
000bb900000339000084480000844800000440000004440000000000222222225555555500000000333333333333d444f555555555555553bbbbbbb366666666
0099990000999900000cc040040cc00004333300003333000000000046655664d55dd55d00000000333333333333d555fdddd5d5ddddddd3bbb222bb66666666
00f9900000f99000000ee000000ee0000003340000433000000000004ffffff45555555500000000333333333333d444fddd55555dddddd53b244bbd22222222
000cc000000cc00000eeee0000eeee0000077000000770000077770046fffff455555555eeeeeee0333333333333d444fddd56565dddddd53344bb3325525552
000cc000000cc00000eeee0000eeee000007700000077000007777004666fff455555555eeeeeee0333333333373d555fddd56565dddddd5333444334cc4ccc4
00044000000440000007700000077000000606000006600000777700ffffffffdddddddddddddd00ffffffff3773d444ffffffffffffffff3334443344444444
000990000009900000000000000aa0000000000000000000eeeeeeeeeeeeeeee33333333d555d55533333333aaaaaaaaaaa44a4a66666666337777734ccc4cc4
0099900000999000000aa000000aa000000aa000000aa000eeeeeeeeeeeeeeee33333333d555555533333333aaaafaaaaa44444a35555555365555554ccc4cc4
0999900000999900000aa000000990000aaa4000000aaa00ddddddddddddddd3f3333333d5555555eb3e3333aaaafaaaa44ff44a3d6666663ddd55d544444444
0999e0000009990000cccc0000cccc0000aa4000000aaa0066ccdcc66666cc63f3333333d555d5553bbb3333aafffddda4dddf4a3d6666dd3dddddd54cc4ccc4
00eeef00000ee00000cccc0000cccc00004cc000000cc40066ccdcc66556cc63f3333333d555d55533b333e3aafffddda43f3f4a5d6666663d55ddd54cc4ccc4
0f02200000f220000091190000911900000cc400004cc00076767676777d7673f3333333d55555553333333baafffdddaafffffa5d6dd6663dddddd544444444
0062200000022200000110000001100000ccc000000ccc0076767676777d7373f3333333d55555553333333baaaaaaaaaaffffaa5d6666663355555344444444
00006000000660000007700000077000000ee000000ee000ffffffffffffffffffffffffd555d555ffffff33aaaaaaaaaddffddaffffffffffffffffffffffff
00080000000800000008000000080000000800000000000000000000000000006666666600000000000007770000000000000000000800000008000000080000
00088800000880000008800000088000000880000000000000000000000000006666666600000000000007770008000000080000000888000008880000088800
00044400000440000004400000044000000440000000000000000000000000002222222300000000000007770008880000088800000444000004440000044400
0004440000044000000440000004400000044000000000000000000000000000c4444c4300000000000007770004440009944400049444000494440009944400
000ccc00000cc000000cc000000cc000000cc000000800000008000000080000c4554c43777777770000077700044400004999c0009999c0009999c0004999c0
004ccc00004cc000000c4000000cc4000004c000000440000004400000044000c4554c437777777700000777004ccc40000999c000099490000999c000099490
000cc400000cc000000cc000000cc000000cc000000cc000000cc000000cc000445544437777777700000777000ccc00000c9490000c9990000c9490000c9990
000808000000800000080000000080000008800000088000000800000000800033ffffff77777777000007770008080000080800000808000008080000080800
00000800000008000000080000000800000008000000000000000000000000000000000033bb3339000000000000000000000000077777770000000000000000
0008880000008800000088000000880000008800000000000000000000000000000777773bbbb33b000000000000000000000000077777770000000000000000
0004440000004400000044000000440000004400000000000000000000000000000777773bb23333000000000000000000000000077777770000000000000000
00044400000044000000440000004400000044000000000000000000000000000007777733243393eeeeeeeeeeeeeeeeeeeeeeee077777776666666666000000
000ccc000000cc000000cc000000cc000000cc0000008000000080000000800000077777334433b3eeeeeeeeeeeeeeeeeeeeeeee077777776666666666000000
000ccc400000cc4000004c000004cc000000c40000044000000440000004400000077777333333330dddddddddddddddddddddd0077777776666666666000000
0004cc000000cc000000cc000000cc000000cc00000cc000000cc000000cc000000777773333333306666666666666666666666007777777dddddddddd000000
00080800000080000000080000008000000088000008800000008000000800000007777733333333066cccc6cccc6cccc6cccc6077777777d5555d555d000000
00000800000008000000080000000800000008000000000000000000000000000007777777777000f66cccc6cccc6cccc6cccc63700000006cccc6ccc6000000
00088800000888000008880000088800000888000000000000000000000000000007777777777000f66666666666666666666663700000006cccc6ccc6000000
00088800000888000008880000088800000888000000000000000000000000000007777777777000f66ee666666666666666dd637000000066666666660000b0
00044400000444000004440000044400000444000000000000000000000000000007777777777000f66ee6666ee666dd6666dd63700000006ccc6cccc600eb00
000ccc00000ccc00000ccc00000ccc00000ccc000000800000008000000080000007777777777777f6666dd66ee666dd66ee6663700000006ccc6cccc6000b00
004ccc40000ccc40004ccc40004ccc00004ccc400008800000088000000880000007777777777777f6666dd66666666666ee6663700000006666666666000000
000ccc000008cc00000ccc00000cc800000ccc00000cc000000cc000000cc0000007777777777777f66666666666666666666663700000006cc6cc6cc6000000
00080800000008000008080000080000000808000008800000008000000800000000000077777777f33333333333333333333333777777776cc6cc6cc6d66666
000800000008000000080000000800000008000000000000000000000000000077777777ffffff33000000000000600000000000ffeeeeff6666666666555555
000888000008880000088800000888000008880000000000000000000000000077777777ccfccf33004444400044744000444440ffe999ffeeeeeeeeee5ddddd
000444000004440000044400000444000004440000000000000000000000000077777777ccfccf33064444400044744000444446feea99ffeeeeeeeeee5ddddd
000444000004440000044400000444000004440000000000000000000000000077777777efefff93007444600064746000644470fff000ff66666666665dd55d
000ccc00000ccc00000ccc00000ccc00000ccc0000080000000800000008000077777777bbff9fb30d47442d0d44742d0d44472dfff0009f6cc6ccdcc65ddddd
004ccc00000cc400004ccc400004cc00004ccc40000440000004400000044000777777773b33b3330dd462dd0dd462dd0dd462ddfff900ff6cc6ccdcc6555ddd
000cc400000ccc00000ccc00000ccc00000ccc00000cc000000cc000000cc0007777777733333333055555550555555505555555fff5f5ff66699999995ddddd
00080800000800000008080000000800000808000008800000080000000080000000000033333333050000050500000505000005fff7f7ffffffffffffffffff
7774447777744477eeee6666eeee6666eeeeeeeeeeeeeeee777770004444444444444fff5f44ff5ff444444400000000000ffffffffffffffffffffffffff000
777ff477777ff477eeee6666eeee6666eeeeeeeeeeeeeeee777770004000000044444fff5f44ff5ff4000ee400000000000f22222522252522f225222522f000
777ff84777cff847eeee6666eeee6666eeeeeeeeeeeeeeee777770004088eee04eea4fff5fccf65ff4e000e400690000000f2ff5f52f2f2f2225252fff2ff000
7770204777f02047eeee6666eeee6666eeeeeeeeeeeeeeee7777700040f8800046aa4fff5fccf65ff4e4940400090000000f2225222f2f2f2f25f5222f2ff000
77702f7777702f77eeee6666ddddddddddddddddeeeeeeee7777700040cfc8e04bbc4fff5fccf65ff4e9990400099000000ffffffffffffffffffffffffff000
7750007777700077eeee6666555555d5555555d5eeeeeeee7777700040fff0004bcc4fff5fccf65ff444444400949000000ffffffffffffffffffffffffff000
7750707777707077eeee666655555d5555555d55eeeeeeee777770004222220044444fff5f44f65ff455555400944000000fff55f5555f555ff555f555fff000
7772727777727277eeee66665555555555555555eeeeeeee777777774444444444444499999999911160600400090000000ffffffffffffffffffffffffff000
777444770000000055555555dd666666666666dd777777706666666666666666666666444444444555555550fffffd55000ffffffffffffffffffffffffff000
744444470000000055555555dd666666666666dd777777706cccc66665555552555525ddddddddd191991910fffffd44000fff5555f5f55ff555f555fffff000
7ddfdd470000000055555555dd666666666666dd777777706ccc9c6665555525255552f7eefeeef111111116fffffd44000ffffffffffffffffffffffffff000
7c7fc7470000000055555555dd666666666666dd7777777066999ac662555552555555feeefeeef255552556fffffd55000ffffffffffffffffffffffffff000
7fffff840000000055555555dd666666666666dd77777770dd999cdd65555555555555111111110555525256fffffd44000fff555f5f55555ff555f55ffff000
7f22ff440000000055555555dd666666666666dd7777777055000cc565552555555055111111110555552556fffffd44000ffffffffffffffffffffffffff600
77fff7440000000055555555dd666666666666dd777777705000005565525255555055111111110555555556fffffd55000ffffffffffffffffffffffffff600
700200447777777055555555dd666666666666dd777777705000005565552555550502dddddddd5255555556ffffff55000fff55f555f5555555ff5555fff600
55555555cccccccc66666666dddddddddddddddd007666009dddd9dd6555555525552511111111052555525670000000000ffffffffffffffffffffffffff600
555d5555cccccccc66666666ddddddddd777777d076000c0dddddddd65555552525555444444444255552526700000000006fffffffffffff666666666666d00
55d55555cccccccc66666666dddd6ddd7ffffff67000000cdddddddd6555555525555545500000455555525670000000000666655565555555ff5555555fff00
777777755555555566666666dd44744d966666697000860cdddddddd65552555555555555552525555555556700000000006ffffffffffffffffffffffffff00
7777777755555555dddddddddd44744dd999999d7000870cdddddddd65525255555555255555255555555556700000000006ffffffffffffffffffffffffff00
6666e86655555555555555d5dd64746dd99999957000800cdddddddd65552555555552525555555555555256700000000006fff5555f55ff5555555555ffff00
66666666dddddddd55555d55dd44742dd76666656000800cdddddddd65555555525555255555555255552526700000000000ffffffffffffffffffffffffff00
dddddddddddddddd55555555ddd462dddd55555d6080a80cdddddddd62555555252555555525552525555256700000000000ffff88ffffeeefffffffffffff00
66656665dddddddddddddddd55555555dddddddd6088a80cf888888865555555525555555252555255555556000000000000fffff88ffffeffefffffffffff00
666565d5dddddddddd000ddd555d5555dddddddd608aa80cf206206265555255555555555525555555555556000000000000fff8dddfffddedffffffff2fff00
6665666500000000d00000dd55d5555500000000606a800cf222222265552525555555525555555555555526000000000000fffffffffffffffffff2f22fff00
66656665511111110008000d55555555111111116648840cf505050565555255552555252555555525555256000000000000ffffcfffff3ff33fff2222ffff00
666566655111111100ada00d55555555111111110c4444c0f250505265555555525255525555555252555526000000000000fffccfcfff3f33fff2f222ffff00
22222225511111110008000d555555d51111111104cccc40f205050262555555552555555552555525555556000000000000fffdcddfff3dd3ffdd2dddddff00
55555d5555555d55d000005d55555d5555555d5500444400f222222265255555555555555525255555555556000000000000fffffffffffffffff2ffffffff00
5555555555555555dd0005dd555555555555555500000000ffffffff66666666666666666552555556666666777777770000ffffffffffffffffffffffffff00
__gff__
08090a0b08098a0c0d0f10530e1192541314c344151796441819434418199a441b5d43441c50c3441d1e1f632021a22305060744245ee025020304260227a82941424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344
4142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344414243444142434441424344
__map__
4b4c4c4c4c4c4c4d0046464646464600767677677a6e2c2dc7c8c9ca00000000c5c5c2d4e1e1e1d300000000000000000000000000000000fbfbfbfbfb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5b4f3b5e5f3b4e1b00404040404040004848484849787e6ad7d8d9da00000000c4c4c3e2d6e2e2e2000000000000000000000000000000003d3d3d3d3dadfbfb98000051000000000000000000000000000000000000000000000000003c0000699e9f0000000000000000000000000000000000000000000000000000000000
5b3a3d3d3d3d391b0040404040404000b94a4a6f47484848e7e8e9ea00000000f3f3f3e3e6e450f200000000000000000000000000000000000000001f3d3d3dcca989cf00000000000000000000000000000000003c000000f600000000000000aeaf00009a9b9c000000000000000000000000000000000000000000000000
6b3a3d3d3d3d391b444040404040400088bebf7f47aaabacf7f8f9fa00000000f3f3f3f1f4f4f4f400000000000000000000000000000000fbfbfbfb9deb0000a8b83d53000000003d3dc6fbfbfbfbd10000f6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28273d3d3d3ddb29544141414141410058484848595c5d990000000000000000e0f3f3f3f3f3f3f30000cccf0066000000000000000000003d3d3d3d3deb0000000041000000000000cc3d3d3d3d3dd500380000000000000000000000000000000c0d0000000000000000000000000000000000000000000000000000000000
19181818181818190000000000000000561c1d2e476c6d7d0000000000000000f0f3f3f3f3f3f3f33d3d3d3d3d3d3d3d001f3d3d3d3d3d00fbfbfb9d3dadfbfb000000000000000000cc3d3d3d3d3dd50000000000000000000000000000000000000000003e0000000000000000000000000000cc3d3d000000000000000000
d2d2d2d2d2d2d2d2d25000000000000068686868576868680000000000000000f3f3f3f3f3f3f3f33d3d3d3d3d3d3d3d3d3d3d3d3d3d3d003d3d3d3d3d3d3d3d00000000000000003d3d3d3d3d3d3dd500000000000000000000000000000000000000000000000000000000000000009b9b9b3d3d3d3d000000000000000000
d2d2d2d2d2d2d2d250d20000000000004a4a4a4a795a4a4a0000000000000000f3f3f3f3f3f3f3f33d3d3d3d3d3d3d3d3d3d3d3d3d3d3d3d000000001feb000000000000000000003d3d3d3d3d3d3dd500000000000000000000000000000000000000000000000000000000000000003d3d3d3d3d3d3d3d0000000000000000
580e580e580e580e585e580058005800580a580a580a580a585a580058005800580658065806580658565800580058005802580258025802585258005800580001040000184e181e181c181c181c181a181a181a181a181a181a181a181a181a181a181a18281828182818281826182618261826182418241824182418121812
18121852010300000c3e0000000000000c30000090078057900190019009805900000000000000000c3e000000000000000000000c3000000c3e00009007805700000000000000000108002007000700070007000708070807280728000000000720070a070a0000070a072800000000000000000928092809200928001a000a
09000c080008002000280028011000201f52180217541304175418041f5213041f5218021752130418521f021754130415041504181418241c061c262126212624521f021b54180418521b021f542404011000200c3a490e45064908a857450c440642080c3a420e44164408a857450c452645280c3a440a9851440ca8570c3a
440c44180c3a420a42184228a857410a412a412a011000005a005a025a005a045a065a265d185d285504552055005524551655265518552857125722571457245c165c265c185c285c105c225c105c245d105d265d185d28011000001d021d201d041d201d061d26211821281a001a041a001a241a161a261a181a281c121c22
1c141c241f161f261f181f282110212221102124221022262218222801100000508a508a508a508a508a508a508a508a50b8508850885088508850885088508855885588558855885588558857885788578857885788578857885788578857880110000050805780578a578a578a578a578a578a578a57b85788578857885788
578857885c885c885c885c885c885c885e885e885e885ea85ea85ea85ea85ea85e885e88011000000080088008800880608a608a608a608a608a608a60b860886088608860886088658a658a658a658a658a658a6788678867886788678867886788678867886788011000000000048004800480048004806888688868a868a8
68a868a868a868a868a868a868ba688a6a9a6a8a6a8a6a8a6a8a6a8a6aba6a8a6c9a6c8a6cba6caa6caa6caa011000006c8a6dba6d8a6d8a6db86d886da86da86db86d886c9a6c8a6aaa6aaa688a688a68ba688a6a8a6a8a6c9a6c8a6a8a6aaa6aaa6aaa6aaa6ada000000000000000001100000448a448a448a448a63886388
65b865886088608860a860a860a860a84588458845884588458845886688668866a666a666a666a645b8458845b8458845884588011000004c8a4c8a4c8a4c8a698869886bb86b884c884c884c884c884c884c884e8a4e8a4e8a4e8a4e8a4e8a4e8a4eaa4eaa4eaa4eb84e884e884e884e844ea44ea44ea40110000050804b8a
4b8a4b8a4b8a4b8a4b8a4b8a4bb84b884b884b884b884b884b884b8868c86888688868a84c884c884cb84c884c884ca84ca84ca84ca84ca84c884c880110000000800880548a548a548a548a548a548a54ba548a548a548a548a548a548a548a558a558a558a558a558a558a55b8558855885588558855885588558855885588
0110000050805f805fca5f8a5f8a5f8a5f8a5f8a6988698869a869a869a869a85f885f8861886188618861886188618861b861886188618861b861886184618461a461a40110000000805b805bca5b8a5b8a5b8a5b8a5b8a5bb85b885b885b885b885b885b885b8868c86888688868a86688668866a666a666a666a66a846a84
6a846a846aa46aa401100000428842b8618861a861a861a85faa5faa498a49ba498a49ba65aa65aa65aa65aa4c884c884ca84ca85f8a5e9a5eaa648a498a49aa49aa49aa49ba49aa49aa49aa01200000b05108805e8a5eaa4c884c885caa5caa5caa5caa5caa5caa5cb85ca85ca85cb85ca8648a638861984e8a4e8a4eaa4eaa
668a668a679a67b867a867a867a867a801200000518a51b851b851ba518a51b851b851ba4d984db64db64db84d884db64db64db84cb84cb64cb64cb84c884cb64cb64cb654b854b854b854b8539853b853b853d8012000006d806c826cb26cb26c826cb26cb26cb26cd2698269b269b4698469b269b269b469a4688468b468b4
688468b468b468a468d6708670b670b670a66e866ea66ea60120000058c2589458b458b4628262b262b262b260c2608260b260b46e846eb26eb260c460b45f845fb45fb45f845fb45fb45f845fd65b865bb65bb65ba65a965ab65aa601200000458a45aa518a5880518a5880518a5880518a51aa51aa51aa40804080458a45aa
4b884ba8578a40804080578a40804080578a4a804a88568a568a549a54da40800110000045805d80588a5880588a5880588a5a80588a58aa58aa58aa58da4080408040804b804ba0528a40804080528a40804080528a4a805180518a518a4f9a4f8a4080011000004580588a5da458805d8458805d8458805d845da45da45da4
5da45dd4408040804b804ba063844080408063844080408063844a804a8062846284609460a460a4011000005188548a54aa5188548a54aa5188548a54aa5188548a54aa518851a851a851a84f88538a53aa4f88538a53aa4f88538a53aa4f88538a53aa548a53ba4f884fa8011400005188548a54aa5188548a54aa5188548a
54aa5188548a54aa568854b8518851a851a851a851a851a800000000000000000000000000000000000000000000000001140000538a538a538a538a538a538a538a538a538a538a53ba538a538a538a538a538a588a588a588a588a588a588a588a588a588a588a58ba588a588a588a588a588a01100000000000005a885a88
5a885a885a885a885a885a885ab85a885a885a885a885a885a8000005f885f885f885f885f885f885f885f885fb85f885f885f885f885f8a011000002400240000000000638663866386638663a663a663b66386638663866386638663a663a60000000068866886688668866886688668b66886688668866886688601100000
548a548a548a548a548a548a548a548a548a548a54ba548a548a548a548a548a538a538a538a538a538a538a538a538a538a538a538a0000000000000000000001100000000000005b885b885b885b885b885b885b885b885bb85b885b885b885b885b885a885a885a885a885a885a885a885a885a885a885a88000000000000
0000000001100000698069a069a069a0648664866486648664a664a664b66486648664866486648663866386638663a663a663a663a663a663a663a663a6000000000000000000000110000069866986698669a669a6588069866986698669a669a669a6000000006b866b866c966c866c866ca66e866e866e866ea66f8a709a
708a708a70aa70aa70aa70aa011000000c3a42080000420aa8574504451a452a0c3a49004906491aa857450a470645280c3a44080000440aa8574706481a482a0c3a482a471a470aa8574408043a400a01100000a10ea15e9f0c9f509d0a9d5a9c0880009f0880009d0a8000a10c8000a200a20e9a009d729f0aa40080009f08
800080009f0a800000000000a10aa12aa12aa15a011000002bc22b822b822b8228822884288428842884288428a428a428a428a428a428a424c42484248424842684268426842684298429842984298429a229a229a229a20110000007000700070007000708070807280728000000000720070a070a0000070a072800000000
0000000004280428092004280b0a0b0a090009080b1800200b280b28011000201f52180217541304175418041f5213041f5218021752130418521f02175413041c041c041f141f24230623242822282217521b021e54150423521b021e542104011000202484248424a424a41fa41fa21fb21f821fa21fd213d013d013a013d0
1380138000000000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000
__sfx__
010c00000c053162000e2000e2001d63011200112021a2000c053182001c033102001d630132000c0531c2000c033393000c043353000c053393000c063293000c063292021d3011d3001d6001d6001d6001d600
01080010181700c1301c1601cb001f1311f1321f1321f10224170000001f1300000018160000001c1200000018150131201814018102001000010000100001000010000100001000010000100001000010000100
010800001837000300183600030018350003001834000300183300030018320003001831000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
01080010181700c1301c1600c1001f1500c1001814018102181701f130181601c1201815013120181401810200100001000010000100001000010000100001000010000100001000010000100001000010000100
01080010181700c1301b1600c1001f1500c1001814018102181701f130181601b1201815013120181401810200000000000000000000000000000000000000000000000000000000000000000000000000000000
010800081815018120181501812018150181201815018120181001810118101181010010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011000001805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0120000030a3030a3230a2230a2332a2132a2032a2232a2335a1035a1235a1235a1338a2138a2038a2238a2338a2138a2038a2238a233aa213aa203aa223aa2324a2124a2024a2224a231da211da201da221da23
0120000026024260412604200000260302604126042240302803028051280521f0441f042000001c0302004120040200422004220052200022205122052220621f0301f0401f0521f0521f0521f0550000000000
012000001cb401cb401cb301cb301cb201cb201cb101cb101db401db401db301db301db201db201db101db1018c4018c4018c3018c3018c2018c2018c1018c101ab401ab401ab301ab301ab201ab201ab101ab10
010800200c0730d0000100000600006000060000600036001f6101f61500600006000060000600096003d6040c0730d000010000a0030a003006000a073006001f6101f61500600006000c0030c0030c0030c003
011000200500005000050500500005050050000505005000050500000000000000000000000000000000000000000000000b04005000050000b0400b000050000b040050000b0000a0500a052000510000000000
00200020201002011023130251212012220102201022010228130261002612000100001000010000100001002010024110291301f1211d1322010220102201001c1301c1001a1320010000100001000010000100
011000100c053000000c0030c05300000000001d6250c0030c05300000000001d6250c05300000000000c03300000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000110462005022120241202212027000271202700029000291201d1211d113220032c0002c0002c040000002c040000002c0002c0402c04200000000002e0302e03030031300352b0302b0422b0422b045
011000002b0022b005110202002022120241102211027000271102700029000291101d1111d113220032c0002c0002c010000002c010000002c0002c0102c0152601026010270112701522010220202202022025
011000002412024122000001d11020122000001d11020122000001d1102012200000271102711225120251222412124122000001d1201f12200000181201b122000001d1201f1220000020120201222213122132
0110000024500305202450200500305203052224500005000050030520245023050030520315213152500500225002e52022502005002e5202e52222500005003052030522315213152231522315223152524500
011000000c4200c4220c4220c4220c4220c4220c4220c4220a4210a4220a4220a4220a4220a4220a4220a42208420084220842208422084220842208422084220742107422074220743107432074320743207432
011000000543005432054320543205432054320543205432054210542205422054220542205422054220542205420054220542205422054220542205422054220542105422054220542205422054220542205425
012000001fa1021a131fa131fa1018a101fa131ca131fa101fa101fa101fa1024a1024a1024a132ba212ca202ca202ca202ca132ca1229a2129a2329a2029a222ba102ba102ba132ca112ca232ea212ea2330a31
01200000290242904129042000002903029051290522b0302c0412c0422e0402e04000000000002b0302f03130040300423004230042310513105238030380323704037042370523603137051370313705237055
012000000514505155021050515502105051450515502105011450115502105011550210501145011550210508145081550210508155021050d1450d155021050714507155021050715502105071550715502105
012000101c9401c9411c9311c9311c9211c9211c9111c91115940159411593115931179401794117931179311c9001c9001c9001c9001c9001c9001e9001e9001e9001e9021e9021e9021e9021e9021e9001e900
0120021217b0017b001c9301c9311c9211c9211c9111c9111c9111c91515930159311592115921179301793117921179211cb001cb001cb001cb001cb001cb001cb001cb0015b0015b0015b0015b0017b0017b00
011000200c0530415004152041521d6550410004150041520c0530415004152209001d655041500c0530c0030c0530915009152091521d6550410009150091520c0530b1500b152209001d6550b1500b1520b152
012000000cd0328d1428d1028d1028d1028d2128d2028d202ad212ad202ad202cd202cd202cd222cd222cd222d1102d1052d1102d1052d1102c1112ad3028d3028d302ad302cd212ad202ad222ad222ad222ad22
010c000016250162500e2300e2301124011240112421a2501a2021825010240102401325013250132521c26032357393473c357353673435739347303572936729270292621d3411d3301d3301d3321d33211021
0120000007145071550210507155021050714507155021050014500155021050015502105001450015502105081450815502105081550210508145081550210507145071550210507155021050b1540f15502105
014000001cb401cb301cb201cb101db401db301db201db1018c4018c3018c2018c101ab401ab301ab201ab101cb401cb301cb201cb101db401db301db201db101dc401dc301dc201dc1021b4021b302db232db10
0020002004040040400400004030040501db00050001db0005040050400400005030050501db00050001db00000500c020000500c020000500c020000500c0200204002040040000203002050000000000000000
011600200c05300000000001f6350c043000002f713000000c05300000000001f6350c043000002f7130c0430c05324625000001f6350c043000001f605246350c0331f6050c043000000c053000000c0631f635
0116002017220102001723010220172400e20017252002001823000200182301022018240182401a2511a2521c250182001c240132201f2402323024251152421722013220152311023017230152201322012222
01160000000000b56000500005000b5600b2300b23200500005000057000500005000057000240002420050000000045400050004552005000456000500045720220502220022250223202235022450225502255
011600002f5173251034510395102f5202f52234520395103951230510345103751039521395223451037510375103752037522375323b5313b5423b5233b503325272f520305202b5202d5302f530345302f530
01160000305202f5202b5201c5202b520285202f522305202b5412b5422b542245413754037542375423754500000000000000000000000000000000000000000000000000000000000000000000000000000000
0116002017220102001723010220172400e2001725200200132300020013230102200724007251072521320218200000000000000000000000000000000000000000000000000000000000000000000000000000
01160000000000b56000500005000b5600b2300b23200500005000057000500005000057000240002620020200200005000000000000000000000000000000000000000000000000000000000000000000000000
011600200c053000000c0531f6050c043000000c053000000c05300000000001f6350c043000001f6350c05300000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c053000000000017625000000000018023000000c053000000000017625000000000018023000000c053000000000017625000000000018023000000c053000000000017625000000c0531762518003
0110000002150021000010002150001000217502150001000010000150001000015000100001750015000100091400910000100091400010009165091400010009100041400f100041400e100041650414000100
0110000000000000000000000000265262d516325262a5163b500395003b5003c500240262b01630026280163b5003950037500365002d0262801639026250163c5003e5003f5003e500265002d500325002a500
0110000000150021000010000150001000017500150001000010002150001000215000100021750215000100091400910000100091400010009165091400010009100091500f1400f1420e131001000c14000100
0110000000000000000000000000240262b01630026280163b500395003b5003c500265262d516325262a5163b5003950037500365002d0262801639026250163c5003e5003f5003e5002d000280003900025000
01100000240002b00030000391203b531395203b530365203652236505325003c1203b53139520375303c5203c52228000390003c1203c5323e5203f5303e520365303653234520345223452230110000003b110
01100000240003912039530395323b530395203b5303c5203c5222d500325003c1203b5313952037530365203652228000390003c1203c5323e5203f5303e5203654036542375403754239530395323c5313c532
011000100c05332005320253501124623000000c043000000c06300000320050000024623000000c0530000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000000000000050550505000000000000000000000050550505000000000000000005055050500000000000000000d0450d040000000000000000000000d0450d0400000000000000000d0450d04000000
0110000000000000000c0450c040100000000000000000000c0450c0400000000000000000c0450c0400000000000000000805508050000000000000000000000705507050000000000000000070550705000000
011000001d4201f4101f4101f4121f4121f4102041020410204102041020412204151d4001d4001d400000001f41020410204102041220412204102241022410224122241222412224121d4111d4121d41520400
0110000020410224102241022412224122241024410244102441024410244122441224415000001d4000000022410224102441024412244122441018410184102741127412274122741220411204122041520405
011000002041022410224102241222412224102441124410244102441024412244150000000000000000000024410244102440022410224102240020410204122241122410000002041020410285001f4101f410
01100000244102741027410274122741227410294112941029410294102c4112c4122c4150000000000000002c4102c4102440029410294102240027410274122941129410000002741027410274122241022410
011000200c0530505000000000001562503040030420c0030c04305050000001560515625000000c003000000c0530c0030a04000000156250c033010300c0030c05300040100241104115625110500c00311040
011000001d11020122000001d11020122000001d11020122000001d11020122000001d1101d11220120201221b1111f122000001b1101f122000001b1101f122000001b1101f122000001b1101b1121f1201f122
01100000247002472024702000002472024722247000000000000247202470224720247022472024700000002270022720227020000022720227222270000000227001f7201f7222272122702227202272200000
011000200c0530505000000000001562503040030420c0030c0430505000000156250a060000000c033000000c0530c0430a04000000156250c033010300c0030c05300040100241104115625110500c00311040
010c00000a4300a43002430024300543105430054320a4300044000440044400444007440074400744200440054500040005450004000545000400054500040005440054400a4310a43011431114301143011432
010e00001e2201e2222123121232262402624026242262420c0430c03328625021050c033000000c0030c03300200002000020000200002000020000200002000020000200002000020000200002000000000000
010e00002a3102a3122d3212862532330323353231032312000003231032312000003231032312000003231032312002000020000200002000020000200002000020000200002000020000200002000020000000
010e00000c04306130091300913002140021000210202142021400214002142021450020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200
012000001fa0021a031fa031fa0018a001fa031ca031fa001fa001fa001fa0024a0024a0024a032ba012ca002ca002ca002ca032ca0229a0129a0329a0029a022ba002ba002ba032ca012ca032ea012ea0330a01
0110000024000240002400024000300002400030000240003c0003c0031f0001d000170001500014000140011400014002190021d002230012b0022c0002d0022c000290022700222001200011f0011f00225005
01040000106000c0030a600010030c60302003086000400315600010030f600051030d6000110307600021030c6030200301103011030210308103081030210308600040030d1030d10302103071030710315600
__music__
04 0c 09 0a 1e
00 0a 0b 43 44
00 0a 0b 43 44
00 0a 0b 43 44
04 0a 0b 0e 0f
00 0a 0b 43 44
04 0a 0b 43 44
00 2e 2f 43 44
04 2e 30 43 44
04 0c 1d 0a 1e
00 1f 20 21 22
04 26 24 25 23
00 27 28 29 44
00 27 2a 2b 44
00 27 28 29 2c
04 27 2a 2b 2d
00 2e 2f 43 44
00 2e 30 43 44
00 2e 2f 31 32
04 2e 30 33 34
00 35 36 37 44
00 38 10 11 44
00 35 36 37 12
04 38 42 43 13
00 08 0d 1c 14
04 15 0d 16 07
00 17 42 19 44
04 17 18 19 1a
04 17 42 19 44
00 27 28 29 44
04 27 2a 2b 44
00 35 36 37 44
04 38 10 11 44
04 08 0d 1c 14
04 00 1b 39 44
00 3a 3b 3c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
