pico-8 cartridge // http://www.pico-8.com
version 11
__lua__
-- hallowe3n - a point+click game
-- paul nicholas
a=true
verbs={
{{b="open"},c="open"},
{{d="close"},c="close"},
{{e="give"},c="give"},
{{f="pickup"},c="pick-up"},
{{g="lookat"},c="look-at"},
{{i="talkto"},c="talk-to"},
{{j="push"},c="push"},
{{k="pull"},c="pull"},
{{l="use"},c="use"}
}
verb_default={
{m="walkto"},c="walk to"
}
function n()
verb_maincol=13
verb_hovcol=8
verb_shadcol=0
verb_defcol=8
end
o=false
p={
data=[[
				name=p
				x=0
				y=0
				w=0
				h=0
			]],
draw=function(q)
pal(9,flr(rnd(2))==0 and 9 or 0)
r(13,true)
map(100,2,2,14,2,2)
map(100,4,3,27,2,1)
end,
}
s={
data=[[
				name=t
				x=0
				y=0
				w=0
				h=0
			]],
draw=function(q)
if(not t.u) print("hallow  n",26,22,9) print("e3",50,22,7)
end,
}
t={
data=[[
			map = {0,0}
		]],
objects={
},
enter=function(q)
cls()
poke(0x5f2c,3)
music(0)
v(
3,
function()
if not q.u then
ba("liquidream;presents",32,24,9,1,false,200)
bb(60)
bc(p,5,5,t)
bb(130)
bc(s,5,5,t)
bb(125)
while true do
ba("press start",34,45,7,1,false,50)
bb(50)
end
else
bc(p,5,5,t)
ba("the end?",30,24,8,0,true,250)
bd(be)
while true do
bb(10)
end
end
end,
function()
if not q.u then
bf(bg)
end
end)
end,
}
bh={
data=[[
					name = ward
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
init=function(q)
q.target_door=bi
end
}
bj={
data=[[
					map = {112,0,127,7}
					col_replace = {11,0}
				]],
objects={
bh,
},
enter=function(q)
if not q.bk then
q.bk=true
poke(0x5f2c,0)
bl(30)
v(
3,
function()
bm"ouch! my head hurts...:where am i?:i don't remember how i got here!"
end
)
end
end,
}
bn={
data=[[
					name = reception
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
init=function(q)
q.target_door=bo
end
}
bi={
data=[[
					name=correction cell
					state=state_open
					x=272
					y=16
					w=1
					h=3
					use_dir = face_back
					classes = { class_door }
				]],
init=function(q)
q.target_door=bh
end
}
bp={
data=[[
					map = {88,8,127,15}
					col_replace = {11,0}
				]],
objects={
bn,
bi,
},
enter=function(q)
bq(function()
if br.in_room==q then
bl(36)
br.walk_speed=1
bs(br,30,52)
bc(br,0,0,be)
end
end)
bq(function()
if br.in_room==q then
bl(36)
end
while true do
q.col_replace=o and{13,0} or nil
bb()
end
end)
end,
}
bt={
data=[[
					name=radio
					x=64
					y=24
					w=1
					h=1
					state = state_here
					state_here = 174
					use_pos = {72,48}
					use_dir = face_back
					col = 8
					col_replace = {8,0}
				]],
verbs={
g=function(q)
bm"it's a radio"
end,
l=function(q)
if not q.bu then
q.col_replace=nil
bm(bt,"\"...serial killer is on the loose:if you see anything suspicious:contact fbi agents;ray and reyes on 555...\":*pop*:*silence*")
q.bu=true
q.col_replace={8,0}
bv(bg,"anim_face","face_front")
bm"the radio just when dead:i wonder if that person i saw was the killer?"
else
bm"it's completely broken:i'll have to find the phone number to call another way..."
end
end
}
}
bw={
data=[[
					name = outside
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
init=function(q)
q.target_door=bx
end
}
bo={
data=[[
					name = ward
					state=state_open
					x=112
					y=16
					w=1
					h=4
					use_pos = pos_left
					use_dir = face_right
					classes = { class_door }
				]],
init=function(q)
q.target_door=bn
end
}
by={
data=[[
					map = {112,16,127,23}
					col_replace = {11,0}
				]],
objects={
bw,
bo,
bt,
},
}
bz={
data=[[
					name = front door
					state=state_closed
					x=88
					y=8
					w=1
					h=3
					state_closed=78
					flip_x = true 
					classes = {class_openable,class_door}
					use_dir = face_back
				]],
init=function(q)
q.target_door=ca
end
}
bx={
data=[[
					name = reception
					state=state_open
					x=944
					y=8
					w=1
					h=3 
					classes = {class_door}
					use_dir = face_back
				]],
init=function(q)
q.target_door=bw
end
}
cb={
data=[[
				name=dead body
				state=state_here
				x=0
				y=0
				w=4
				h=1
				state_here=202
				trans_col = 11
				use_pos = pos_left
				use_dir = face_front
			]],
verbs={
g=function(q)
if(q.in_room==cc) bm"his name tag says \"vitaliy\":looks like he was going to a party...:sadly, he didn't make it"
if(q.in_room==cd) bm"she's...:...dead!"
end
}
}
ce={
data=[[
					name = sign
					state=state_here
					x=832
					y=24
					w=5
					h=1
					use_pos = {857,42}
				]],
draw=function(q)
cf("hospital",q.x+5,q.y+17,8,0,true)
end,
verbs={
g=function(q)
bm"\"smith's grove mental hospital\":doesn't sound like a friendly place to me!"
end
}
}
cg={
data=[[
					name = sign
					state=state_here
					x=209
					y=24
					w=5
					h=1
					use_pos = {230,42}
				]],
draw=function(q)
print("welcome",q.x+5,q.y+17,0)
end,
verbs={
g=function(q)
bm"\"welcome to haddonfield\""
end
}
}
ch={
data=[[
					name = sign
					state=state_here
					x=270
					y=16
					w=1
					h=3
					classes = {class_untouchable}
				]],
draw=function(q)
srand(0)
palt(0,false)
palt(11,true)
for ci=1,100 do
spr(12,q.x+rnd(500),q.y+rnd(10),1,4,flr(rnd(2))==0)
end
end,
}
cc={
data=[[
					map = {0,24,127,31}
					col_replace = {11,0}
				]],
objects={
bz,
bx,
cb,
ce,
cg,
ch,
},
enter=function(q)
bc(cb,495,54,cc)
cb.flip_x=true
end,
}
ca={
data=[[
					name = outside
					state = state_closed
					x=8
					y=16
					z=1
					w=1
					h=4
					trans_col = 1
					state_closed=79
					classes = {class_openable,class_door}
					use_pos = pos_right
					use_dir = face_left
				]],
init=function(q)
q.target_door=bz
end
}
cj={
data=[[
					name=living room
					state=state_open
					x=40
					y=16
					w=1
					h=3
					use_dir = face_back
				]],
verbs={
m=function(q)
ck(q,cl)
end
}
}
cm={
data=[[
					name=upstairs
					state=state_open
					x=120
					y=0
					w=3
					h=2
					use_pos = pos_center
					use_dir = face_back
				]],
verbs={
m=function(q)
ck(q,cn)
end
}
}
co={
data=[[
					name=basement
					state=state_open
					x=144
					y=16
					w=1
					h=3
					use_dir = face_back
					classes = {class_door}
				]],
init=function(q)
q.target_door=cp
end
}
cq={
data=[[
					name = kitchen
					state = state_open
					x=176
					y=16
					w=1
					h=4
					use_pos = pos_left
					use_dir = face_right
				]],
verbs={
m=function(q)
ck(q,cr)
end
}
}
cs={
data=[[
					name = broken mirror
					state=state_here
					x=56
					y=16
					w=1
					h=4
				]],
verbs={
g=function(q)
bm"the mirror has been smashed...:but why?"
end
}
}
ct={
data=[[
				name = telephone
				state = state_here
				state_here = 115
				x = 120
				y = 24
				w = 1
				h = 1
				col = 8
				use_pos = {122,43}
				use_dir = face_back
			]],
verbs={
f=function(q)
cu(q)
end,
l=function(q)
cu(q)
end,
i=function(q)
cu(q)
end,
}
}
function cu(q)
v(
1,
function()
bm"who should i dial?"
end)
while(true) do
cv({
((cw.cx and not q.cy) and"dial the police on 555-57458"or""),
(q.cz and""or"dial voicemail"),
(cw.da and"dial hint-line 3000"or""),
"hang up"
})
db(verb_maincol,verb_hovcol)
while not dc do bb() end
dd()
v(
1,
function()
if(dc.de!=4) bm"dialing..."
if dc.de==1 then
bm"hello, i'm at the doyle's house:the killer has definitely been here...:there are bodies everywhere!"
bm(ct,"\"ok, stay where you are, we're on our way\":\"but be careful, the killer could still be in the house!\"")
bf(df)
bb(100)
df.state="state_open"
bl(36)
bb(100)
bf(bg)
q.cy=true
elseif dc.de==2 then
bm(ct,"\"you have 1 saved message\":\"message 1...\":\"laurie? laurie are you there?! get out now! the killer is heading your wa-\":*click*:*dialtone...*")
elseif dc.de==3 then
bm(ct,"\"welcome to the hintline 3000\"")
if not cw.cx then
bm(ct,"\"having telly trouble?\":\"have you tried looking upstairs for a hanger?\"")
else
bm(ct,"\"our lines are closed now;you're on your own!\"")
end
elseif dc.de==4 then
dg()
return
end
end)
dh()
end
end
di={
data=[[
				map = {0,16,23,23}
				col_replace = {11,0}
			]],
objects={
ca,
cj,
cm,
co,
cq,
ct,
cs,
},
enter=function(q)
dj=true
bq(function()
if bg.y<10 then
bs(bg,80,42)
end
end)
end,
exit=function(q)
dj=false
end,
}
cp={
data=[[
					name=hallway
					state=state_open
					x=56
					y=0
					w=3
					h=2
					use_pos = pos_center
					use_dir = face_back
				]],
verbs={
m=function(q)
ck(q,co)
end
}
}
cd={
data=[[
				map = {40,16,55,23}
				col_replace = {11,0}
			]],
objects={
cp
},
enter=function(q)
dj=true
bc(cb,60,46,q)
cb.dk=false
bq(function()
if not q.dl then
bl(35)
q.dl=true
end
bs(bg,40,42)
end)
end,
exit=function(q)
dj=false
end,
}
cl={
data=[[
					name=hallway
					state=state_open
					x=8
					y=24
					w=1
					h=3
					use_pos = pos_right
					use_dir = face_left
				]],
verbs={
m=function(q)
ck(q,cj)
end
}
}
cw={
data=[[
					name=tv
					x=88
					y=30
					w=2
					h=1
					z=-1
					state=1
					use_pos={88,40}
					use_dir = face_back
				]],
scripts={
},
draw=function(q)
if cw.cx then
rectfill(q.x+2,q.y+16,q.x+12,q.y+24,o and 0 or verb_hovcol)
else
for dm=1,100 do
pset(q.x+rnd(10)+2,q.y+rnd(10)+16,(flr(rnd(2))==0) and 0 or verb_maincol)
end
end
end,
verbs={
g=function(q)
q.da=true
if q.cx then
bm"\"...the killer is still at large:he is wearing a white mask:the number to dial is;555-57458\":\"we now return to our feature film...\":john carpenter's \"the thing\""
else
bm"the aerial is missing:i need to find some wire:...or a hanger"
end
end
}
}
dn={
data=[[
				map = {24,16,39,23}
				col_replace = {11,0}
			]],
objects={
cl,
cw,
dp,
},
}
cr={
data=[[
					name = hall
					state=state_open
					x=8
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
init=function(q)
q.target_door=cq
end
}
dq={
data=[[
					name = pantry
					state = state_closed
					x=112
					y=16
					w=1
					h=4
					trans_col = 1
					state_closed=79
					flip_x=true
					classes = {class_openable,class_door}
					use_pos = pos_left
					use_dir = face_right
				]],
init=function(q)
q.target_door=dr
end
}
ds={
data=[[
					map = {56,16,71,22}
					col_replace = {11,0}
				]],
objects={
cr,
dq,
},
enter=function(q)
if not q.dt then
q.dt=true
bq(function()
v(
3,
function()
bl(36)
bb(50)
bm"oh my..."
bb(20)
bm"what happened?!"
end
)
end)
end
end,
}
dr={
data=[[
					name = kitchen
					state=state_open
					x=32
					y=16
					w=1
					h=4
					use_pos = pos_right
					use_dir = face_left
					classes = { class_door }
				]],
init=function(q)
q.target_door=dq
end,
}
du={
data=[[
					name=body
					state=state_here
					x=72
					y=16
					w=2
					h=3
					z=-1
					state_here=206
					trans_col = 11
					use_pos = {64,44}
					use_dir = face_right
				]],
verbs={
g=function(q)
bm"he's definitely dead!"
end
}
}
dv=42
dw={
data=[[
					name=pool of blood
					x=64
					y=48
					w=3
					h=1
					z=-1
					state=1
					use_pos = {64,44}
					use_dir = face_front
				]],
draw=function(q)
spr(206)
if(dv<70) pset(77,dv,8)
dv+=1.5
if(dv>150) dv=42
end,
verbs={
g=function(q)
bm"ugh... gross!"
end
}
}
dx={
data=[[
					map = {72,16,87,22}
					col_replace = {11,0}
				]],
objects={
dr,
du,
dw,
},
enter=function(q)
if not q.dy then
q.dy=true
bq(function()
v(
3,
function()
bl(35)
bb(50)
bm(bg,"*gulp*",false,150)
end)
end)
end
end,
}
cn={
data=[[
					name=hall
					state=state_open
					x=124
					y=56
					w=3
					h=2
					use_pos = pos_center
					use_dir = face_front
					classes = { class_door }
				]],
init=function(q)
q.target_door=cm
end
}
dz={
data=[[
					name=spare room
					state=state_open
					x=48
					y=16
					w=1
					h=3
					use_dir = face_back
					classes = {class_door}
				]],
init=function(q)
q.target_door=ea
end
}
eb={
data=[[
					name=small bedroom
					state=state_open
					x=120
					y=16
					w=1
					h=3
					use_dir = face_back
					classes = {class_door}
				]],
init=function(q)
q.target_door=ec
end
}
df={
data=[[
					name = master bedroom
					state = state_closed
					x=160
					y=16
					w=1
					h=4
					trans_col = 1
					state_closed=79
					flip_x=true
					use_pos = pos_left
					use_dir = face_right
				]],
verbs={
m=function(q)
if q.state=="state_open"then
ck(q,ed)
else
bm"the door is closed"
end
end
}
}
ee={
data=[[
					map = {0,8,21,15}
				]],
objects={
cn,
dz,
eb,
df
},
}
ea={
data=[[
					name=landing
					state=state_open
					x=8
					y=24
					w=1
					h=3
					use_pos = pos_right
					use_dir = face_left
					classes = {class_door}
				]],
init=function(q)
q.target_door=dz
end
}
ef={
data=[[
				map = {40,8,55,15}
				col_replace = {11,0}
			]],
objects={
ea,
},
enter=function(q)
if not q.dt then
q.dt=true
bl(36)
end
end,
}
ec={
data=[[
				name=landing
				state=state_open
				x=8
				y=24
				w=1
				h=3
				use_pos = pos_right
				use_dir = face_left
				classes = {class_door}
			]],
init=function(q)
q.target_door=eb
end
}
function eg(q)
if q.state=="state_closed"then
bm"the door is closed"
else
bm"i can't fit in there!"
end
end
eh={
data=[[
					name = wardrobe
					state = state_closed
					x=32
					y=16
					z=1
					w=1
					h=3
					state_closed=78
					classes = {class_openable,class_door}
					use_pos = {28,40}
					use_dir = face_back
					flip_x = true
					trans_col = 1
				]],
verbs={
m=eg
}
}
ei={
data=[[
					name = wardrobe
					state = state_closed
					x=48
					y=16
					z=1
					w=1
					h=3
					state_closed=78
					classes = {class_openable,class_door}
					use_pos = {44,40}
					use_dir = face_back
					flip_x = true
					trans_col = 1
				]],
verbs={
m=eg
}
}
ej={
data=[[
				name = wire hanger
				state = state_here
				state_here = 143
				x = 48
				y = 17
				w = 1
				h = 1
				z = 10
				classes={class_pickupable}
				use_pos = {44,40}
				use_with=true
			]],
dependent_on=ei,
dependent_on_state="state_open",
verbs={
g=function(q)
bm"it's a wire coat hanger"
end,
f=function(q)
ek(q)
end,
l=function(q,el)
if(el==cw) then
bc(q,-9,0,be)
v(
3,
function()
bm"ok, let's see if we can fix this..."
bc(br,12,50,dn)
bl(36)
bb(300)
bl(40)
br.walk_speed=0.1
bs(br,50,58)
em(br)
bm"almost got it..."
bs(br,84,45)
em(br)
bc(br,0,0,be)
cw.cx=true
dn.col_replace={11,13}
bl(30)
bm"fixed it!"
cw.verbs.g(cw)
end
)
end
end,
}
}
en={
data=[[
				map = {24,8,39,15}
				col_replace = {11,0}
			]],
objects={
ec,
eh,
ei,
ej,
},
}
ed={
data=[[
					name=landing
					state=state_open
					x=8
					y=24
					w=1
					h=3
					use_pos = pos_right
					use_dir = face_left
				]],
verbs={
m=function(q)
ck(q,df)
end
}
}
eo={
data=[[
					map = {56,8,71,15}
				]],
objects={
ed,
},
enter=function(q)
bq(function()
v(
3,
function()
bb(100)
bm"look, an unbroken mirror!"
bs(bg,60,42)
em(bg)
bd(ep,1)
end
)
end)
end,
}
eq={
data=[[
				name=
				x=8
				y=2
				w=3
				h=3
				z=-1
			]],
draw=function(q)
local col=er[es]
rect(35-et/2,10,105-et/2,69,er[es+1])
rect(32-et/2,7,108-et/2,72,er[es+1])
clip(35-et/2,10,70,70)
palt(11,true)
pal(8,col)
pal(9,0)
map(105,0,29.9+et,20,6,6)
clip()
palt(11,true)
pal(13,0)
pal(9,0)
pal(8,col)
palt(0,false)
map(105,0,30-et,20,6,8)
end,
}
ep={
data=[[
			map = {0,0}
		]],
objects={
eq,
},
enter=function(q)
er={13,13,8,12,13,13,13,1,2,13}
eu=1
es=1
et=0
v(
3,
function()
bb(100)
ba("oh my god...",64,3,8,1)
while et<19.9 do
et+=.125
bb()
end
bl(35)
ba("i'm the killer!",64,3,8,1,true,200)
bb(50)
ba("now i remember,;i went back to the hospital",64,3,8,1,false)
ba("i used shock therapy;to forget...",64,3,8,1,false)
ba("to forget what i did",64,3,8,1,false)
sfx(63)
bq(function()
while true do
eu+=1
if eu>2 then
eu=0
es+=1
if(es>#er) es=1
end
bb()
end
end,true)
ba("oh no...;what have i done?",64,3,8,1,false)
ba("i've lead them right to me!",64,3,8,1,false)
bb(130)
t.u=true
bd(t)
end)
end,
}
be={
data=[[
			map = {0,0}
		]],
objects={
p,
s,
},
}
rooms={
be,
t,
bj,
bp,
by,
cc,
di,
cd,
dn,
ds,
dx,
ee,
ef,
en,
eo,
ep
}
ev={
data=[[
			name = humanoid
			w = 1
			h = 4
			idle = { 193, 197, 199, 197 }
			talk = { 218, 219, 220, 219 }
			walk_anim_side = { 196, 197, 198, 197 }
			walk_anim_front = { 194, 193, 195, 193 }
			walk_anim_back = { 200, 199, 201, 199 }
			col = 8
			trans_col = 11
			col_replace = {8,13}
			walk_speed = 0.5
			frame_delay = 5
			classes = {class_actor}
			face_dir = face_front
		]],
ew={
},
verbs={
}
}
br={
data=[[
			name = ghost?
			w = 1
			h = 4
			idle = { 193, 193, 193, 193 }
			talk = { 218, 218, 218, 218 }
			walk_anim_side = { 194, 197, 195, 196 }
			walk_anim_front = { 194, 197, 195, 196 }
			walk_anim_back = { 194, 197, 195, 196 }
			col = 8
			trans_col = 11
			col_replace = {13,0}
			walk_speed = 0.1
			frame_delay = 2
			classes = {class_actor}
			face_dir = face_front
		]],
}
actors={
ev,
br
}
function startup_script()
n()
bg=ev
bd(t,1)
bc(bg,82,44,bj)
bc(br,272,50,bp)
ex=0
ey=0
bq(ez,true)
end
function ez()
while true do
ex+=1
if ex>=ey then
o=flr(rnd(2))==0
ex=0
ey=rnd(5)+3
end
bb()
end
end
fa=-1
function bl(fb)
if(fb!=fa) music(fb)
end
function fc(fd) if fd then
fe=1 end ff=fd end function fg(fh) local fi=nil if fj(fh.classes,"class_talkable") then
fi="talkto"elseif fj(fh.classes,"class_openable") then if fh.state=="state_closed"then
fi="open"else fi="close"end else fi="lookat"end for fk in all(verbs) do fl=get_verb(fk) if fl[2]==fi then fi=fk break end
end return fi end function fm(fn,fo,fp) local fq=fj(fo.classes,"class_actor") if fn=="walkto"then
return elseif fn=="pickup"then if fq then
bm"i don't need them"else bm"i don't need that"end elseif fn=="use"then if fq then
bm"i can't just *use* someone"end if fp then
if fj(fp.classes,class_actor) then
bm"i can't use that on someone!"else bm"that doesn't work"end end elseif fn=="give"then if fq then
bm"i don't think i should be giving this away"else bm"i can't do that"end elseif fn=="lookat"then if fq then
bm"i think it's alive"else bm"looks pretty ordinary"end elseif fn=="open"then if fq then
bm"they don't seem to open"else bm"it doesn't seem to open"end elseif fn=="close"then if fq then
bm"they don't seem to close"else bm"it doesn't seem to close"end elseif fn=="push"or fn=="pull"then if fq then
bm"moving them would accomplish nothing"else bm"it won't budge!"end elseif fn=="talkto"then if fq then
bm"erm... i don't think they want to talk"else bm"i am not talking to that!"end else bm"hmm. no."end end function fr(fs) ft=fu(fs) fv=nil fw=nil end function bf(fx) fy(fz) fw=fx fv=nil fz=function() while fw do if fw.in_room==ga then
ft=fu(fw) end yield() end end bq(fz,true) if fw.in_room!=ga then
bd(fw.in_room,1) end end function gb(fs) fv=fu(fs) fw=nil fz=function() while(true) do if ft==fv then
fv=nil return elseif fv>ft then ft+=0.5 else ft-=0.5 end yield() end end bq(fz,true) end function gc() while gd(fz) do yield() end end function v(type,ge,gf) gg={gh=type,gi=cocreate(ge),gj=gf,gk=fw} add(gl,gg) gm=gg bb() end function cv(gn) for go in all(gn) do gp(go) end end function gp(go) if not gq then gq={gr={},gs=false} end
gt=gu(go,32) gv=gw(gt) gx={de=#gq.gr+1,go=go,gt=gt,gy=gv} add(gq.gr,gx) end function db(col,gz) gq.col=col gq.gz=gz gq.gs=true dc=nil end function dd() gq.gs=false end function dh() gq.gr={} dc=nil end function dg() gq=nil end function ha(fh) local hb=fh.use_pos local x=fh.x local y=fh.y if type(hb)=="table"then
x=hb[1] y=hb[2] elseif hb=="pos_left"then if fh.hc then
x-=(fh.w*8+4) y+=1 else x-=2 y+=((fh.h*8)-2) end elseif hb=="pos_right"then x+=(fh.w*8) y+=((fh.h*8)-2) elseif hb=="pos_above"then x+=((fh.w*8)/2)-4 y-=2 elseif hb=="pos_center"then x+=((fh.w*8)/2) y+=((fh.h*8)/2)-4 elseif hb=="pos_infront"or hb==nil then x+=((fh.w*8)/2)-4 y+=(fh.h*8)+2 end return{x=x,y=y} end function bv(fx,hd,he) hf={"face_front","face_left","face_back","face_right"} if hd=="anim_face"then
if type(he)=="table"then
hg=atan2(fx.x-he.x,he.y-fx.y) hh=93*(3.1415/180) hg=hh-hg hi=hg*360 hi=hi%360 if hi<0 then hi+=360 end
he=4-flr(hi/90) he=hf[he] end face_dir=hj[fx.face_dir] he=hj[he] while face_dir!=he do if face_dir<he then
face_dir+=1 else face_dir-=1 end fx.face_dir=hf[face_dir] fx.flip=(fx.face_dir=="face_left") bb(10) end end end function hk(hl,hm) if hl.state=="state_open"then
bm"it's already open"else hl.state="state_open"if hm then hm.state="state_open"end
end end function hn(hl,hm) if hl.state=="state_closed"then
bm"it's already closed"else hl.state="state_closed"if hm then hm.state="state_closed"end
end end function ck(ho,hp,hq) if hp==nil then
hr("target door does not exist") return end if ho.state=="state_open"then
hs=hp.in_room if hs!=ga then
bd(hs,hq) end local ht=ha(hp) bc(bg,ht.x,ht.y,hs) hu={face_front="face_back",face_left="face_right",face_back="face_front",face_right="face_left"} if hp.use_dir then
hv=hu[hp.use_dir] else hv=1 end bg.face_dir=hv bg.flip=(bg.face_dir=="face_left") else bm("the door is closed") end end function hw(hx,hy) if hy==1 then
hz=0 else hz=50 end while true do hz+=hy*2 if hz>50
or hz<0 then return end if hx==1 then
ia=min(hz,32) end yield() end end function bd(hs,hx) if hs==nil then
hr("room does not exist") return end fy(ib) if hx and ga then
hw(hx,1) end if ga and ga.exit then
ga.exit(ga) end ic={} id() ga=hs if not fw
or fw.in_room!=ga then ft=0 end ie() if hx then
ib=function() hw(hx,-1) end bq(ib,true) else ia=0 end if ga.enter then
ga.enter(ga) end end function ig(fn,ih) if not ih
or not ih.verbs then return false end if type(fn)=="table"then
if ih.verbs[fn[1]] then return true end
else if ih.verbs[fn] then return true end
end return false end function ek(fh,fx) fx=fx or bg add(fx.ii,fh) fh.owner=fx del(fh.in_room.objects,fh) end function bq(ij,ik,il,im) local gi=cocreate(ij) local scripts=ic if ik then
scripts=io end add(scripts,{ij,gi,il,im}) end function gd(ij) for ip in all({ic,io}) do for iq,ir in pairs(ip) do if ir[1]==ij then
return ir end end end return false end function fy(ij) ir=gd(ij) if ir then
del(ic,ir) del(io,ir) end end function bb(is) is=is or 1 for x=1,is do yield() end end function it() while iu!=nil do yield() end end function bm(fx,go,iv,iw) if type(fx)=="string"then
go=fx fx=bg end ix=fx.y-(fx.h)*8+4 iy=fx ba(go,fx.x,ix,fx.col,1,iv,iw) end function ie() iu,iy=nil,nil end function ba(go,x,y,col,iz,iv,iw) local col=col or 7 local iz=iz or 0 if iz==1 then
ja=min(x-ft,127-(x-ft)) else ja=127-(x-ft) end local jb=max(flr(ja/2),16) local jc=""for jd=1,#go do local je=sub(go,jd,jd) if je==":"then
jc=sub(go,jd+1) go=sub(go,1,jd-1) break end end local gt=gu(go,jb) local gv=gw(gt) jf=x-ft if iz==1 then
jf-=((gv*4)/2) end jf=max(2,jf) ix=max(18,y) jf=min(jf,127-(gv*4)-1) iu={jg=gt,x=jf,y=ix,col=col,iz=iz,jh=iw or(#go)*8,gy=gv,iv=iv} if#jc>0 then
ji=iy it() iy=ji ba(jc,x,y,col,iz,iv) end it() end function bc(fh,x,y,jj) if jj then
if not fj(fh.classes,"class_actor") then
if fh.in_room then del(fh.in_room.objects,fh) end
add(jj.objects,fh) fh.owner=nil end fh.in_room=jj end fh.x,fh.y=x,y end function jk(fx) fx.jl=0 id() end function bs(fx,x,y) local jm=jn(fx) local jo=flr(x/8)+ga.map[1] local jp=flr(y/8)+ga.map[2] local jq={jo,jp} local jr=js(jm,jq) fx.jl=1 for jt in all(jr) do local ju=(jt[1]-ga.map[1])*8+4 local jv=(jt[2]-ga.map[2])*8+4 local jw=sqrt((ju-fx.x)^2+(jv-fx.y)^2) local jx=fx.walk_speed*(ju-fx.x)/jw local jy=fx.walk_speed*(jv-fx.y)/jw if fx.jl==0 then
return end if jw>5 then
fx.flip=(jx<0) if abs(jx)<0.4 then
if jy>0 then
fx.jz=fx.walk_anim_front fx.face_dir="face_front"else fx.jz=fx.walk_anim_back fx.face_dir="face_back"end else fx.jz=fx.walk_anim_side fx.face_dir="face_right"if fx.flip then fx.face_dir="face_left"end
end for jd=0,jw/fx.walk_speed do fx.x+=jx fx.y+=jy yield() end end end fx.jl=2 end function em(fx) fx=fx or bg while fx.jl!=2 do yield() end end function ka(fo,fp) if fo.in_room==fp.in_room then
local jw=sqrt((fo.x-fp.x)^2+(fo.y-fp.y)^2) return jw else return 1000 end end kb=16 ft,fv,fz,fe=0,nil,nil,0 kc,kd,ke,kf=63.5,63.5,0,1 kg={7,12,13,13,12,7} kh={{spr=208,x=75,y=kb+60},{spr=240,x=75,y=kb+72}} hj={face_front=1,face_left=2,face_back=3,face_right=4} function ki(fh) local kj={} for iq,fk in pairs(fh) do add(kj,iq) end return kj end function get_verb(fh) local fn={} local kj=ki(fh[1]) add(fn,kj[1]) add(fn,fh[1][kj[1]]) add(fn,fh.c) return fn end function id() kk=get_verb(verb_default) kl,km,kn,ko,kp=nil,nil,nil,false,""end id() iu=nil gq=nil gm=nil iy=nil io={} ic={} gl={} kq={} ia,ia=0,0 kr=0 function _init() if a then poke(0x5f2d,1) end
ks() bq(startup_script,true) end function _update60() kt() end function _draw() ku() end function kt() if bg and bg.gi
and not coresume(bg.gi) then bg.gi=nil end kv(io) if gm then
if gm.gi
and not coresume(gm.gi) then if gm.gh!=3
and gm.gk then bf(gm.gk) bg=gm.gk end del(gl,gm) if#gl>0 then
gm=gl[#gl] else if gm.gh!=2 then
kr=3 end gm=nil end end else kv(ic) end kw() kx() ky,kz=1.5-rnd(3),1.5-rnd(3) ky=flr(ky*fe) kz=flr(kz*fe) if not ff then
fe*=0.90 if fe<0.05 then fe=0 end
end end function ku() rectfill(0,0,127,127,0) camera(ft+ky,0+kz) clip(0+ia-ky,kb+ia-kz,128-ia*2-ky,64-ia*2) la() camera(0,0) clip() if lb then
print("cpu: "..flr(100*stat(1)).."%",0,kb-16,8) print("mem: "..flr(stat(0)/1024*100).."%",0,kb-8,8) end if lc then
print("x: "..flr(kc+ft).." y:"..kd-kb,80,kb-8,8) end ld() if gq
and gq.gs then le() lf() return end if kr>0 then
kr-=1 return end if not gm then
lg() end if(not gm
or gm.gh==2) and kr==0 then lh() else end if not gm then
lf() end end function kw() if gm then
if(btnp(5) or stat(34)>0)
and gm.gj then gm.gi=cocreate(gm.gj) gm.gj=nil return end return end if btn(0) then kc-=1 end
if btn(1) then kc+=1 end
if btn(2) then kd-=1 end
if btn(3) then kd+=1 end
if btnp(4) then li(1) end
if btnp(5) then li(2) end
if a then
lj,lk=stat(32)-1,stat(33)-1 if lj!=ll then kc=lj end
if lk!=lm then kd=lk end
if stat(34)>0 then
if not ln then
li(stat(34)) ln=true end else ln=false end ll=lj lm=lk end kc=mid(0,kc,127) kd=mid(0,kd,127) end function li(lo) local lp=kk if not bg then
return end if gq and gq.gs then
if lq then
dc=lq end return end if lr then
kk=get_verb(lr) elseif lt then if lo==1 then
if(kk[2]=="use"or kk[2]=="give")
and kl then km=lt else kl=lt end elseif lu then kk=get_verb(lu) kl=lt ki(kl) lg() end elseif lv then if lv==kh[1] then
if bg.lw>0 then
bg.lw-=1 end else if bg.lw+2<flr(#bg.ii/4) then
bg.lw+=1 end end return end if kl!=nil
then if kk[2]=="use"or kk[2]=="give"then
if km then
elseif kl.use_with and kl.owner==bg then return end end ko=true bg.gi=cocreate(function() if(not kl.owner
and(not fj(kl.classes,"class_actor") or kk[2]!="use")) or km then lx=km or kl ly=ha(lx) bs(bg,ly.x,ly.y) if bg.jl!=2 then return end
use_dir=lx if lx.use_dir then use_dir=lx.use_dir end
bv(bg,"anim_face",use_dir) end if ig(kk,kl) then
bq(kl.verbs[kk[1]],false,kl,km) else if fj(kl.classes,"class_door") then
if kk[2]=="walkto"then
ck(kl,kl.target_door) elseif kk[2]=="open"then hk(kl,kl.target_door) elseif kk[2]=="close"then hn(kl,kl.target_door) end else fm(kk[2],kl,km) end end id() end) coresume(bg.gi) elseif kd>kb and kd<kb+64 then ko=true bg.gi=cocreate(function() bs(bg,kc+ft,kd-kb) id() end) coresume(bg.gi) end end function kx() if not ga then
return end lr,lu,lt,lq,lv=nil,nil,nil,nil,nil if gq
and gq.gs then for ip in all(gq.gr) do if lz(ip) then
lq=ip end end return end ma() for fh in all(ga.objects) do if(not fh.classes
or(fh.classes and not fj(fh.classes,"class_untouchable"))) and(not fh.dependent_on or fh.dependent_on.state==fh.dependent_on_state) then mb(fh,fh.w*8,fh.h*8,ft,mc) else fh.md=nil end if lz(fh) then
if not lt
or(not fh.z and lt.z<0) or(fh.z and lt.z and fh.z>lt.z) then lt=fh end end me(fh) end for iq,fx in pairs(actors) do if fx.in_room==ga then
mb(fx,fx.w*8,fx.h*8,ft,mc) me(fx) if lz(fx)
and fx!=bg then lt=fx end end end if bg then
for fk in all(verbs) do if lz(fk) then
lr=fk end end for mf in all(kh) do if lz(mf) then
lv=mf end end for iq,fh in pairs(bg.ii) do if lz(fh) then
lt=fh if kk[2]=="pickup"and lt.owner then
kk=nil end end if fh.owner!=bg then
del(bg.ii,fh) end end if kk==nil then
kk=get_verb(verb_default) end if lt then
lu=fg(lt) end end end function ma() kq={} for x=-64,64 do kq[x]={} end end function me(fh) ix=-1 if fh.mg then
ix=fh.y else ix=fh.y+(fh.h*8) end mh=flr(ix) if fh.z then
mh=fh.z end add(kq[mh],fh) end function la() if not ga then
print("-error-  no current room set",5+ft,5+kb,8,0) return end rectfill(0,kb,127,kb+64,ga.mi or 0) for z=-64,64 do if z==0 then
mj(ga) if ga.trans_col then
palt(0,false) palt(ga.trans_col,true) end map(ga.map[1],ga.map[2],0,kb,ga.mk,ga.ml) pal() else mh=kq[z] for fh in all(mh) do if not fj(fh.classes,"class_actor") then
if fh.states
or(fh.state and fh[fh.state] and fh[fh.state]>0) and(not fh.dependent_on or fh.dependent_on.state==fh.dependent_on_state) and not fh.owner or fh.draw then mm(fh) end else if fh.in_room==ga then
mn(fh) end end mo(fh) end end end end function mj(fh) if fh.col_replace then
mp=fh.col_replace pal(mp[1],mp[2]) end if fh.lighting then
mq(fh.lighting) elseif fh.in_room and fh.in_room.lighting then mq(fh.in_room.lighting) end end function mm(fh) mj(fh) if fh.draw then
fh.draw(fh) else mr=1 if fh.repeat_x then mr=fh.repeat_x end
for h=0,mr-1 do local ms=0 if fh.states then
ms=fh.states[fh.state] else ms=fh[fh.state] end mt(ms,fh.x+(h*(fh.w*8)),fh.y,fh.w,fh.h,fh.trans_col,fh.flip_x) end end pal() end function mn(fx) mu=hj[fx.face_dir] if fx.jl==1
and fx.jz then fx.mv+=1 if fx.mv>fx.frame_delay then
fx.mv=1 fx.mw+=1 if fx.mw>#fx.jz then fx.mw=1 end
end mx=fx.jz[fx.mw] else mx=fx.idle[mu] end mj(fx) mt(mx,fx.hc,fx.mg,fx.w,fx.h,fx.trans_col,fx.flip,false) if iy
and iy==fx and iy.talk then if fx.my<7 then
mx=fx.talk[mu] mt(mx,fx.hc,fx.mg+8,1,1,fx.trans_col,fx.flip,false) end fx.my+=1 if fx.my>14 then fx.my=1 end
end pal() end function lg() mz=""na=verb_maincol nb=kk[2] if kk then
mz=kk[3] end if kl then
mz=mz.." "..kl.name if nb=="use"then
mz=mz.." with"elseif nb=="give"then mz=mz.." to"end end if km then
mz=mz.." "..km.name elseif lt and lt.name!=""and(not kl or(kl!=lt)) and(not lt.owner or nb!=get_verb(verb_default)[2]) then mz=mz.." "..lt.name end kp=mz if ko then
mz=kp na=verb_hovcol end print(nc(mz),nd(mz),kb+66,na) end function ld() if iu then
ne=0 for nf in all(iu.jg) do ng=0 if iu.iz==1 then
ng=((iu.gy*4)-(#nf*4))/2 end cf(nf,iu.x+ng,iu.y+ne,iu.col,0,iu.iv) ne+=6 end iu.jh-=1 if iu.jh<=0 then
ie() end end end function lh() jf,ix,nh=0,75,0 for fk in all(verbs) do ni=verb_maincol if lu
and fk==lu then ni=verb_defcol end if fk==lr then ni=verb_hovcol end
fl=get_verb(fk) print(fl[3],jf,ix+kb+1,verb_shadcol) print(fl[3],jf,ix+kb,ni) fk.x=jf fk.y=ix mb(fk,#fl[3]*4,5,0,0) mo(fk) if#fl[3]>nh then nh=#fl[3] end
ix+=8 if ix>=95 then
ix=75 jf+=(nh+1.0)*4 nh=0 end end if bg then
jf,ix=86,76 nj=bg.lw*4 nk=min(nj+8,#bg.ii) for nl=1,8 do rectfill(jf-1,kb+ix-1,jf+8,kb+ix+8,verb_shadcol) fh=bg.ii[nj+nl] if fh then
fh.x,fh.y=jf,ix mm(fh) mb(fh,fh.w*8,fh.h*8,0,0) mo(fh) end jf+=11 if jf>=125 then
ix+=12 jf=86 end nl+=1 end for jd=1,2 do nm=kh[jd] if lv==nm then pal(verb_maincol,verb_hovcol) end
mt(nm.spr,nm.x,nm.y,1,1,0) mb(nm,8,7,0,0) mo(nm) pal() end end end function le() jf,ix=0,70 for ip in all(gq.gr) do if ip.gy>0 then
ip.x,ip.y=jf,ix mb(ip,ip.gy*4,#ip.gt*5,0,0) ni=gq.col if ip==lq then ni=gq.gz end
for nf in all(ip.gt) do print(nc(nf),jf,ix+kb,ni) ix+=5 end mo(ip) ix+=2 end end end function lf() col=kg[kf] pal(7,col) spr(224,kc-4,kd-3,1,1,0) pal() ke+=1 if ke>7 then
ke=1 kf+=1 if kf>#kg then kf=1 end
end end function mt(nn,x,y,w,h,no,flip_x,np) r(no,true) spr(nn,x,kb+y,w,h,flip_x,np) end function r(no,fd) palt(0,false) palt(no,true) if no and no>0 then
palt(0,false) end end function ks() for jj in all(rooms) do nq(jj) if(#jj.map>2) then
jj.mk=jj.map[3]-jj.map[1]+1 jj.ml=jj.map[4]-jj.map[2]+1 else jj.mk=16 jj.ml=8 end for fh in all(jj.objects) do nq(fh) fh.in_room=jj fh.h=fh.h or 0 if fh.init then
fh.init(fh) end end end for nr,fx in pairs(actors) do nq(fx) fx.jl=2 fx.mv=1 fx.my=1 fx.mw=1 fx.ii={} fx.lw=0 end end function mo(fh) local ns=fh.md if nt
and ns then rect(ns.x,ns.y,ns.nu,ns.nv,8) end end function kv(scripts) for ir in all(scripts) do if ir[2] and not coresume(ir[2],ir[3],ir[4]) then
del(scripts,ir) ir=nil end end end function mq(nw) if nw then nw=1-nw end
local jt=flr(mid(0,nw,1)*100) local nx={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14} for ny=1,15 do col=ny nz=(jt+(ny*1.46))/22 for iq=1,nz do col=nx[col] end pal(ny,col) end end function fu(fs) if type(fs)=="table"then
fs=fs.x end return mid(0,fs-64,(ga.mk*8)-128) end function jn(fh) local jo=flr(fh.x/8)+ga.map[1] local jp=flr(fh.y/8)+ga.map[2] return{jo,jp} end function oa(jo,jp) local ob=mget(jo,jp) local oc=fget(ob,0) return oc end function gu(go,jb) local gt={} local od=""local oe=""local je=""local of=function(og) if#oe+#od>og then
add(gt,od) od=""end od=od..oe oe=""end for jd=1,#go do je=sub(go,jd,jd) oe=oe..je if je==" "
or#oe>jb-1 then of(jb) elseif#oe>jb-1 then oe=oe.."-"of(jb) elseif je==";"then od=od..sub(oe,1,#oe-1) oe=""of(0) end end of(jb) if od!=""then
add(gt,od) end return gt end function gw(gt) gv=0 for nf in all(gt) do if#nf>gv then gv=#nf end
end return gv end function fj(fh,oh) for oi in all(fh) do if oi==oh then
return true end end return false end function mb(fh,w,h,oj,ok) x=fh.x y=fh.y if fj(fh.classes,"class_actor") then
fh.hc=x-(fh.w*8)/2 fh.mg=y-(fh.h*8)+1 x=fh.hc y=fh.mg end fh.md={x=x,y=y+kb,nu=x+w-1,nv=y+h+kb-1,oj=oj,ok=ok} end function js(ol,om) local on,oo,op,oq,os={},{},{},nil,nil ot(on,ol,0) oo[ou(ol)]=nil op[ou(ol)]=0 while#on>0 and#on<1000 do local ov=on[#on] del(on,on[#on]) ow=ov[1] if ou(ow)==ou(om) then
break end local ox={} for x=-1,1 do for y=-1,1 do if x==0 and y==0 then
else local oy=ow[1]+x local oz=ow[2]+y if abs(x)!=abs(y) then pa=1 else pa=1.4 end
if oy>=ga.map[1] and oy<=ga.map[1]+ga.mk
and oz>=ga.map[2] and oz<=ga.map[2]+ga.ml and oa(oy,oz) and((abs(x)!=abs(y)) or oa(oy,ow[2]) or oa(oy-x,oz) or dj) then add(ox,{oy,oz,pa}) end end end end for pb in all(ox) do local pc=ou(pb) local pd=op[ou(ow)]+pb[3] if not op[pc]
or pd<op[pc] then op[pc]=pd local h=max(abs(om[1]-pb[1]),abs(om[2]-pb[2])) local pe=pd+h ot(on,pb,pe) oo[pc]=ow if not oq
or h<oq then oq=h os=pc pf=pb end end end end local jr={} ow=oo[ou(om)] if ow then
add(jr,om) elseif os then ow=oo[os] add(jr,pf) end if ow then
local pg=ou(ow) local ph=ou(ol) while pg!=ph do add(jr,ow) ow=oo[pg] pg=ou(ow) end for jd=1,#jr/2 do local pi=jr[jd] local pj=#jr-(jd-1) jr[jd]=jr[pj] jr[pj]=pi end end return jr end function ot(pk,fs,jt) if#pk>=1 then
add(pk,{}) for jd=(#pk),2,-1 do local pb=pk[jd-1] if jt<pb[2] then
pk[jd]={fs,jt} return else pk[jd]=pb end end pk[1]={fs,jt} else add(pk,{fs,jt}) end end function ou(pl) return((pl[1]+1)*16)+pl[2] end function hr(go) ba("-error-;"..go,5+ft,5,8,0) end function nq(fh) local gt=pm(fh.data,"\n") for nf in all(gt) do local pairs=pm(nf,"=") if#pairs==2 then
fh[pairs[1]]=pn(pairs[2]) else printh(" > invalid data: ["..pairs[1].."]") end end end function pm(ip,po) local pp={} local nj=0 local pq=0 for jd=1,#ip do local pr=sub(ip,jd,jd) if pr==po then
add(pp,sub(ip,nj,pq)) nj=0 pq=0 elseif pr!=" "and pr!="\t"then pq=jd if nj==0 then nj=jd end
end end if nj+pq>0 then
add(pp,sub(ip,nj,pq)) end return pp end function pn(ps) local pt=sub(ps,1,1) local pp=nil if ps=="true"then
pp=true elseif ps=="false"then pp=false elseif pu(pt) then if pt=="-"then
pp=sub(ps,2,#ps)*-1 else pp=ps+0 end elseif pt=="{"then local pi=sub(ps,2,#ps-1) pp=pm(pi,",") pv={} for fs in all(pp) do fs=pn(fs) add(pv,fs) end pp=pv else pp=ps end return pp end function pu(mp) for pw=1,13 do if mp==sub("0123456789.-+",pw,pw) then
return true end end end function cf(px,x,y,py,pz,iv) if not iv then px=nc(px) end
for qa=-1,1 do for qb=-1,1 do print(px,x+qa,y+qb,pz) end end print(px,x,y,py) end function nd(ip) return 63.5-flr((#ip*4)/2) end function qc(ip) return 61 end function lz(fh) if not fh.md
or gm then return false end md=fh.md if(kc+md.oj>md.nu or kc+md.oj<md.x)
or(kd>md.nv or kd<md.y) then return false else return true end end function nc(ip) local pw=""local nf,mp,pk=false,false for jd=1,#ip do local mf=sub(ip,jd,jd) if mf=="^"then
if mp then pw=pw..mf end
mp=not mp elseif mf=="~"then if pk then pw=pw..mf end
pk,nf=not pk,not nf else if mp==nf and mf>="a"and mf<="z"then
for ny=1,26 do if mf==sub("abcdefghijklmnopqrstuvwxyz",ny,ny) then
mf=sub("ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\",ny,ny) break end end end pw=pw..mf mp,pk=false,false end end return pw end
__gfx__
00000000bb8000dddddddddd090ddddddddddd8bbbb8b00000000000bbb80000d0d0d0d0ddddddd000000dddddd00000bd0bbd0b000000000dddddd000000000
00000000bbb000dddddddddd9990ddddddddd08bbbb8b800000000ddb88000000d0d0d0dd0d0d0d00000dddddddd0000bbd0d0d000000000d000000d00000000
00700700bbb0000dddddddd09990dddddddddd8bbbbbb800000000dd80000000ddd0d0d0d0d0d0d0000ddd0000ddd000d0bd0d0b0000000d00000000d0000000
00077000bbb8080dd0ddddddd99ddddddddddd8bbbbbbb8000000000000000000d0d0d0dd0d0d0d00dddd000000dddd0bd0dd0bd000000d000d00d000d000000
00077000bbb88000dd000ddddddddd0dddddd0bbbbbbbb800000000d00000000d0d0d0d0d0d0d0d0dddd00d00000ddddbbdd0bd0000000d0000000000d000000
00700700bbb80000dd00ddddddddddd00dddd00bbbbbbb8000000ddd000000000d0ddd0dd0d0d0d0dd000d00d00000ddd0bd0d0b000000d000d00d000d000000
00000000bbbb0000dddddddd000ddddddddd08b8bbbbbb8000dddddd00000000d0d0d0d0d0d0d0d0dd00d00d000000ddbd0dd0bb000000d0000000000d000000
00000000bbbb80000ddddd0000000ddddddd0bbbbbbbbb800dddddd0000000000d0d0d0dddddddd0dd0000d0000000ddbbdd0bbb000000d00dddddd00d000000
bbbbbbbbbb0000ddddddddddddddddddddddd00bbbbbb800dddd0bbb00008bbb0d0d0d0d00000800dd000d000000d0ddd0bd0dd00000000dddddddddd0000000
bbbbbbbbb08000ddddddddddddddddddddddd008bbbb8000ddd08bbb0000088bdddddddd00800800dd00d000000d00ddbdddd00b0000000dddddddddd0000000
bbbbbbbbb000000ddddd9999dddd99ddddddd00bbbb80000d0008bbb00000008d0d0d0d000800800dd00000000d000ddd0bd0bdd0000000d00000000d0000000
bbbbbbbbb800000ddd999999dddd99990dddd00bbbb80000000d8bbb00000000dddddddd00800000dd0000000d0000ddbd0ddd000000000d00000000d0000000
bbbbbbbbb800000dd999999ddddd99990dddd00bbb80000000dd8bbb000000000d0d0d0d00000800dd000000d000d0ddbbdd00bb0000000d00000000d0000000
bbbbbbbbb880800dd9999dddddddd99900dddd8b8800000000dd8bbb00000000dddddddd00800000dd000000000000ddd0bd0bdd0000000d00000000d0000000
bbbbbbbbbb80880ddddddddddddddddddddddd0b0000000000dd8bbb00000000d0d0d0d000000000ddddddddddddddddbd0ddd000000000d00000000d0000000
bbbbbbbbbb0000dddddddddddddddddddddddd8b0000000000dd8bbb00000000dddddddd00800000ddddddddddddddddbbdd00bb0000000d00000000d0000000
00000000bbbbb000000ddddddddddddd00000bbb0ddd00ddddddd8bb90000000d0dd00d00dddddddddddddddddddddd0bbbd0bbd000000000dddddd000000000
08000000bbbb80000dddddddddddddddd0000bbb00ddddd0ddddd08b090000000d0d000d0dddddddddddddddddddddd0d0bd0bbd000000ddd000000ddd000000
08000000bbb80000dddddddddddddddddd000b8b0000dd00dddd000800909009d0dd00d00dddddddddddddddddddddd0bddd0bdd00000d000000000000d00000
08000080bb000000ddddddddddddddddddd080bb0000000dddddd000009999990d0d000d0dddddddddddddddddddddd0bb0d0dd00000d00000d00d00000d0000
008000808b00000dddddddddddddddddddd000bb000000dddddd000000099999d0dd00d00dddddddddddddddddddddd0bbbddd0b000000000000000000000000
00088080b000000ddddddddddddddddddddd00bb00000000ddd00000000090090d0d000d0dddddddddddddddddddddd0d0bd0bbb0ddd0000000000000000ddd0
00000880b00000dddddddddddddddddddddd00bb00000000dd00000000000000d0dd00d00dddddddddddddddddddddd0bd0d0bbbd000d00000d00d00000d000d
00888880bb0000ddddddddddddddddddddddd0b80000000000000000000000000d0d0d0d000000000000000000000000bbdd0bbbd0000d000000000000d0000d
bbbbbbbbbbbbbbbbbbbbbb0008088bbbbbbbbbbbddddd00dbbbbbbbb0000000000000000008888000000080000008000bbbd0bbd0d000d000000000000d000d0
bbbbbbbbbbbbbbbbbbbb8bb000000bbbbbbbbbbb000dddddbbbbbbbb0000000900800000008008000880880000008000bbbd0dd000d000000000000000000d00
bbbbbbbbbbbbbbbbbbb80000000008bbbbbbbbbb0000ddddbbbbbbbb0090099000800000008008000808080000008000bbbdd0bb00d00dddddddddddddd00d00
bbbbbbbbbbbbbbbbbb00000000000008bbbbbbbbddd000008bbbbbbb9999990000800000008008000808080000080000bbbd0bbb00d0d00000000000000d0d00
bbbbbbbbbbbbbbbbb8000000000000000bbbbbbbdddd00008bbbbbbb9999900000800000008880000800080000080000bbbd0bbb00d0d00000000000000d0d00
bbbbbbbbbbbbbbbb0000000000000000008bbbbb000000008bbbbbbb0090000000800000008000000800080000000000bbbd0bbb00d0dddddddddddddddd0d00
bbbbbb88bbbbbb0000000000000000000008bbbb0000000008bbbbbb0000000000808800008000000800080000000000bbbbbbbb00d000000000000000000d00
bbbb8800bbbbbb00000000ddddddd0000008bbbb000000000088bbbb0000000000880000008000000800000000800000bbbbbbbb00d000000000000000000d00
00000000000000000000000000000000dddddddddddddddddddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000
000dddd00000000000000000000000000000000000000000d000000dd000000d0000000000000000000000000000000000000000000000000dddddd00dddddd0
dd0000000000000000000000000000000dd0dd0dd0dd0d00d000000dd000000d0000800000000000000000888008888888880000000000000d0000d00d0000d0
000dddd000000000dddddd00000000000dd0dd0dd0dd0d00d000000dd000000d0000000000080000000888888888888888888800000000000d0000d00d0000d0
dd0dddd00000000dd0d0d0dd000000000000000000000000d000000dd000000d0000000000000000800888888888888888888888000000000d0000d00d0000d0
dd0dddd0000000d0d0d0d0d0d00000000d0dd0dddd0dd000d000000dd000000d0080000000000000000000888888888888888800000000000d0000d00d0000d0
00000000000000d0d00000d0d00000000d0dd0dddd0dd000d000000dd000000d0000000000000000000000000000088880000000000008800d0000d00d0000d0
dddddddd000000d00ddddd00d00000000000000000000000dddddddddddddddd0000000000000000000080800000000000000000000008000d0000d00d0000d0
0000000000000000ddddddd0000000000dd0dd0000dd0d00d00000dddd00000d0000000000000000dddddddd0d00000000000000dddddddd0d0000d00d0000d0
0000d000000000ddddddddddd00000000dd0dd0000dd0d00d0000d0dd0d0000d0000000000000000dddddddd0dd0d00000000000dd8d8ddd0dddddd00d0000d0
d000dd0000000d00000000000d0000000000000000000000d0000d0dd0d0000d0000000000000000dddddddd0d0dd00000000000d88ddddd000000000d00ddd0
d0d0dd000000d0000000000000d000000d0dd0d00d0dd000d000000dd000000d000000bbbbbbb0000000000000dd00000000d000d888dddd000000000ddd0000
d0d0d0d00000000000000000000000000d0dd0d00d0dd000d000000dd000000d0000000b000b0000dddddddd0ddd0000000ddd00d888dddd0dd0000000000000
d0d0d0d00000ddddddddddddddd000000000000000000000d000000dd000000d00000000b0b00000dddddddd0dd000d00000d000d888dddd0dd0000000000000
d0d0d00d000dd0d0d0d0d0d0d0dd00000dd0dd0000dd0d00dddddddddddddddd0dddddddddddddd0dddddddd0dd00ddd00000000dd88dddd000000000dd00000
d0d0d00d00d0d0d0d0d0d0d0d0d0d0000dd0dd0000dd0d0000000000000000000dd00000000dd0d0000000000000000000000000dd8ddddd0dddddd00dd00000
0000000000d0d0d0d0d0d0d0d0d0d000ddddddddddddddd000000000000000000d0000000000ddd00d000d000000000000000000dd8ddddd0d0000d000000000
dddddddd00d0d0d0d0d0d0d0d0d0d00000000000d00d00d0dddddddddddddddd0d0000000000d0d0ddd0d000000000d000000000dd8ddddd0d0000d00000ddd0
0000000000d0ddddddddddddddd0d000d0dd0dd0d00d00d000000000000000000d0000000000ddd00dddd0000000d00d00000000dd8ddddd0d0000d00ddd00d0
ddddddd000d0d0d0d0d0d0d0d0d0d000d0dd0dd0d00d00d0000dddddddddd0000d0000000000ddd00000d0ddddd0000d000d0000dddddddd0d0000d00d0000d0
d00000d000d0d0d0d0d0d0d0d0d0d00000000000d00d00d0000d00000000d0000d0000000000ddd00000ddd00dd00d0000000000dd8ddddd0d0000d00d0000d0
d00000d000d0ddddddddddddddd0d0000dd0dd0dd00d00d0000d000dd000d0000d0000000000ddd00dd0d0000000dd0000000000dddddddd0d0000d00d0000d0
d00000d000d00000000000000000d0000dd0dd0dd00d00d0000d00000000d0000dd00000000dddd0ddddd0d0000dd00000000000dd8ddddd0dddddd00d0000d0
d00000d000d00000000000000000d00000000000ddddddd0000dddddddddd0000dddddddddddddd0d000dddd0d00d00000000000dddddddd000000000d0000d0
d00000d0000008000000880000000000ddddddd000000000000d00000000d000d000000dd0dd00d00000d00d0000000000000000000000000dd0dd0d0d0000d0
d00000d0008008000088000000888800d00000d0dddddddd000d00000000d000d000000d0d0d0d0d0000d00000dddd000000000000000000000000000d000dd0
d00000d0008008000080000008800880d00d00d000000000000d00000000d000d000000dd0dd00d0000000000dd00dd00000000000ddd000d0dd0dd00d0dd000
d00000d0008088000080000008088080ddddddd0000ddddd000d00000000d000d000000d0d0d0d0d0ddddddd0d0dd0d00000000000d8d000d0dd0dd00dd00000
d00000d0008808000088800000800800d00000d0000d0000000d00000000d000d000000dd0d0d0d000ddddd000d00d000000000000d0d0000000000000000000
d00000d0008008000080000008800880d00000d0000d000d000d00000000d000d000000d0d0d0d0d00ddddd00dd00dd00000000000ddd0000dd0dd0d00000000
ddddddd0008008000080080008888880d00000d0000d0000000dddddddddd000ddddddddd0d0d0d000ddddd00dddddd00d0d0000000000000dd0dd0d00000000
00000000008000000088800000000000ddddddd0000ddddd0000000000000000000000000d0d0d0d000ddd0000000000d000d0d0000000000000000000000000
dddddd0000ddddddddddddd0dddddddd0000000d0d000000ddddddddaaaaaaaaddddddddd0d0d0d000000000dddd00000dddddd00dddddd000000000000dd000
dddd00000000dddddddddd0d0ddddddd00000d00000d0000ddddddddaaaaaaaadddddddd0d0d0d0d00000000dddd00000dddddd00d00d0d00000000000d00d00
dd000000000000ddddd0d0d0d0dddddd000d000000000d0000000000aaaaaaaaddddddddd0d0d0d000000000dddd0000d0dddd000dd0ddd00000000000000d00
0000000000000000dd0d0d0d0d0d0ddd0d0000000000000dddddddddaaaaaaaadddddddd0d0d0d0d00000000dddd000000dddd000d0d00d000000000000dd000
0000000000000000d0d0d0d0d0d0d0dd0000000000000000ddddddddaaaaaaaaddddddddd0d0d0d0000000000000ddddd0dddd000dd0d0d0000000000dd00dd0
00000000000000000d0d0d0d0d0d0d0d000000000000000000000000aaaaaaaadddddddd0d0d0d0d000000000000ddddd0dddd000d0d00d000000000d000000d
0000000000000000d0d0d0d0d0d0d0d00000000000000000ddddddddaaaaaaaaddddddddd0d0d0d0000000000000ddddd0dddd000d00d8d000000000dddddddd
00000000000000000d0d0d0d0d0d0d0d0000000000000000ddddddddaaaaaaaadddddddd0d0d0d0d000000000000dddd00dddd000dddddd00000000000000000
dddddddddddddddddddddddddddddddd0000000000000000d0d00dddddd0d0d0dddddddd0000000d000000000dddddddd0dddd00000000000000000000dd0000
dddddddddddddddddddddddddddddddd00000000000000000d0d0dddddd00d0ddddddddd00000d00000000000dddddddd0dddd0000000000000000000ddd0000
dddddddddddddddddddddddddddddddd0000000000000000d000000000000000dddddddd000d0000000000000000ddddd0dddd000000000000000000dddd0000
dddddddddddddddddddddddddddddddd00000000000000000d0dddddddddd00ddddddddd0d00000000000000ddd0dddd00dddd00dddddddd00000000ddddd000
dddddd0000dddddddddddddddddddddd0000000d0d000000d00dddddddddd0d0ddddddddd0d0d0d0d0000000ddd0ddddd0dddd00dddddddd00000000000dd800
dddd00000000dddddddddd0d0ddddddd00000d00000d00000000000000000000dddddd0d0d0d0d0d00d000d0ddd00000d0dddd0000000000000000000000ddd0
dd000000000000ddddddd0d0d0d0dddd000d000000000d000dddddddddddddd0ddddd0d0d0d0d0d0d000d000ddddd0ddd0dddd00000000000000000000000ddd
0000000000000000dd0d0d0d0d0d0d0d0d0000000000000d0dddddddddddddd0dd0d0d0d0d0d0d0d00d000d0ddddd0dd00dddd000000000000000000000000dd
000000000000000000000000d0d0d0d00000000000000000ddddddddddddddd00000000000000000000000000dddd0ddd0dddd00000000000000d000bbbbbb0d
0000000000000000000000000d0d0d0d00000000000000000d0d0d0d0d0d0d0ddddddddd00000000000000000dddd0dd00dddd000000000000000d00bbbbb0d0
d0d0d0d00000000000000000d0d0d0d0d000000000000000ddddddddddddd0d0dddddddd00dddd0dddd0000000000000d0dddd0000000000000000d0bbbb0d0b
0000000000000000000000000d0d0d0d000000000000000dd0d0d0d0d0dd0d0ddddddddd00dddd0dddd00000ddd0dddd00dddd0000000000ddddddddbbb0ddd0
0000000000000000d0d0d0d0d0d0d0d00000000000000000ddddddddddd0d0d0dddddddd0000000000000000ddd0dddd0dddddd000000000d000d00dbb0dd880
00000000000000000d0d0d0d0d0d0d0d00000000000000000d0d0d0d0d0d0d0ddddddddddddd0dddd0000000000000000dddddd000000000d000ddddb0ddd800
0000000000000000d0d0d0d0d0d0d0d0d000000000000000ddddddddd0d0d0d0dddddddddddd0dddd00000000dddd0dd00000000ddddddddd000dd8d0d8800bb
00000000000000000d0d0d0d0d0d0d0d000000000000000dd0d0d0d00d0d0d0d0000000000000000000000000dddd0dd0d0d0d0d0d0d0d0dddddddddd800bbbb
00000000dddddddd00000000000000000000000000000000000000dddd0000000000000000000000d0d0d0d0d0d0d0d0d0d0d0d000d0000d000d00000000ddd0
0000dddddddddddddddd00000000000000000000000000000000000d0d000000000000dddd0000000d0d0d0ddddddddd0ddddddd00d0000d00d0d0000000d0d0
00dddddddddddddddddddd0000000000d0000000000000000000dddddddd000000000dddddd00000d0d0d0d0ddddddd0dddddddddddddddd0d000d000000ddd0
0dddddddddddddddddddddd000000000000000000000000d00000d0dd0d000000000dddddddd00000d0d0d0ddddddd0ddddddddd0000d000d000d0d0000d0000
0dddddddddddddddddddddd000000000000000000000000000dddddddddddd00000dddddddddd000d0d0d0d00000d000000000000000d000dd0d0d0d00d00000
00dddddddddddddddddddd00000000000000000000000000000d0d0d0d0d0d0000dddddddddddd00dddd0ddddddd0ddddddddddddddddddd0dd0d0d00d000000
0000dddddddddddddddd000000000000d000000000000000dddddddddddddddd0dddddddddddddd0dddd0ddddddd0ddddddddddd00d0000d00dd0d00ddd00000
00000000dddddddd000000000d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0dd0d0d0d00000000000000000dddd0ddddddd0ddddddddddd00d0000d000dd0000dd00000
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbb0ddddd0bbbb
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0d0000d0b0000000bbbbbbbb000bbbb0d00000d0bbb
00000000bb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbb0000bbbbbb0d00d00d00dddddd0000000000d0bbb0d000000d0bbb
00000000b0dddd0bb0dddd0bb0dddd0bb0dddd0bb0dddd0bb0dddd0bb0dddd0bb0dddd0bb0dddd0bbbbb0d0000000000000d0d0ddddd0dd0bbb0d0000000d0bb
000000000d0000d00d0000d00d0000d00d0000db0d0000db0d0000db0d0000db0d0000db0d0000dbbbbb0d0000000000000d0d0ddddd0d00bbb0d00d0000d0bb
00000000d000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bbbbb0d00000000dddddd000000000000bbbb0d000d00d0bb
00000000d000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bbbbbb0d00000db0000000000bbbbbbbbbbbbbbb0db000d0b
00000000d080080bd080080bd080080bd0000800d0000800d0000800d000000bd000000bd000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0d00d0b
000dd000d000000bd000000bd000000bd0000000d0000000d0000000d000000bd000000bd000000bd000000bd0000000d000000b00000000bbbbbbbbb0d00d0b
00d00d00d000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000bd000000b00000000bbbbbdd888d00d0b
0d0000d0d00dd00bd00dd00bd00dd00b0d000ddb0d000ddb0d000ddbd000000bd000000bd000000bd00dd00b0d000ddbd000000b00000000bbbbb88db0d00d0b
ddd00ddd0d0000bb0d0000bb0d0000bb0d00000b0d00000b0d00000b0d0000bb0d0000bb0d0000bb0d0dd0bb0d000ddb0d0000bb00000000bbbbbbbbb0d00d0b
00d00d00b0dddbbbb0dddbbbb0dddbbbb0d000bbb0d000bbb0d000bbb0d00dbbb0d00dbbb0d00dbbbd0000bbb0d0000bb0d00dbb00000000bbbbbbbbb0dddd0b
00d00d00b000000bb000000bb00000bbbb0d0bbbbb0d0bbbbb0d0bbbb00dd00bb00dd00bb00dd00bb0ddd0bbbb0d000bb00dd00b00000000bbbbbbbbb000000b
00dddd000dd00dd00dd00dd00dd00dd000d00bbbb0d000bbb0d00bbb0dd00dd00dd00dd00dd00dd0bb000bbbbbb00bbb0dd00dd000000000bbbbbbbbbb0dd0bb
00000000d0d00d00d0d00d0000d00d0d0d00d0bbb0d00d0b0d00d0bbd000000dd000000dd000000dbbbbbbbbbbbbbbbbd000000d00000000bbbbbbbbbb0000bb
00080000d000000dd000000dd000000d0d00d0bbb0d00d0b0d00d0bbd000000dd000000dd000000d0000000000000000000000000000000000000000bb0dd0bb
00080000d000000dd000000dd000000d0d00d0bbb0d00d0b0d00d0bbd000000dd000000dd000000d0000000000000000000000000000000000000000bb0dd0bb
00080000d000000dd000000dd000000d0d00d0bbb0d00d0b0d00d0bbd000000dd000000dd000000d0000000000000000000000000000000000000000bb0dd0bb
88808880d000000dd000000dd000000d0d00d0bbb0d00d0b0d00d0bbd000000d0d00000dd00000d00000000000000000000000000000000000000000bb0dd0bb
00080000d000000d0d000000000000d00dddd0bbb0dddd0b0dddd0bbd000000d0d000000000000d00000000000000000000000000000000000000000bb0dd0bb
00080000d000000db000000bb000000b000000bbb000000b0000000bd000000d0000000bb00000000000000000000000000000000000000000000000bb0000bb
0008000000dd0d00bdd00d0bb0dd0ddbb0dd000bbb0dd0bbb0dd000b00d0dd000dd0dd0bb0d00dd00000000000000000000000000000000000000000b00dd0bb
00000000d0dd0d0db0000d0bb0dd000bb0000d0bbb0000bbb0000d0bd0d0dd0db000dd0bb0d0000b0000000000000000000000000000000000000000b0dd00bb
00dddd0000dd0d00b0dd0d0bb0dd0d0bb0dddd0bbb0dd0bbb0dddd0b00d0dd00b0d0dd0bb0d0dd0b000000000000000000000000d0d0d0d0ddddddddd0d0d0d0
00d00d00b0dd0d0bb0dd0d0bb0dd0d0bb0dddd0bbb0dd0bbbb0ddd0bb0d0dd0bb0d0dd0bb0d0dd0b0000000000000000000000000d0ddddddddddddddddd0d0d
00d00d00b0dd0d0bb0dd0d0bb0dd0d0bb0ddd0bbbb0dd0bbbb0dddd0b0d0dd0bb0d0dd0bb0d0dd0b000000000000000000000000d0ddddddddddddddddddddd0
ddd00dddb0dd0d0bb0dd0d0bb0dd0d0bb0ddd0bbbb0dd0bbb000ddd0b0d0dd0bb0d0dd0bb0d0dd0b0000000000000000000000000ddddddddddddddddddddddd
0d0000d0b0dd0d0bb0dd0d0bb0dd0d0b0dddd0dbbb0dd0bb0dd0ddd0b0d0dd0bb0d0dd0bb0d0dd0b000000000000000000000000ddddddddddddddddddddddd0
00d00d00b0dd0d0bb0dd0d0dd0dd0d0bdddd00dbbb0dd0bb0dd0dd00b0d0dd0bb0d0dd0dd0d0dd0b0000000000000000000000000ddddddddddddddddddddd0d
000dd000b000000bb00000dddd00000bd000000bbb00000b000000ddb000000bb0000dd00dd0000b000000000000000000000000d0d0ddddddddddddddddd0d0
000000000dd00dd0bbdd0dd00ddd0dbb0ddd0dddbb0dddd0ddd0ddd00dd00dd00dd000000000ddd00000000000000000000000000d0d0d0ddddddddd0d0d0d0d
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000808000000000000000000000000000000000010000000000000000008080000000000100000000000000008000000001010000000000
0101010101010100000000000000000000000000010101010101010000000001010101010000010001000000000100010101010000000101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010100000000010101
__map__
0000000000000000000000000000000000000000000000000000008a8a8a8a8a8a8a8a8a8a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000103132333410008a8a8aa48a8a8a8a8a8a8a8aa58a8a8a
0000000000000000000000000000000000000000000000000000008a8a8a948485958a8a8a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000102122232410008a8a8aa48a8a8a8a8a8a8a8aa58a8a8a
000000000000000000000000000000000000000000000000008a008a94848a46478a85958a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012130000001011121314100000888aa48a8ab85a5a5ab98aa58a8a8a
000000000000000000000000000000000000000000000000008a00848aa9aa56578a8a8a850000008a000000000000000000000000008a00000000000000000000000000008a00000000000000000000000000000000000000000000000000000000000002030000001001020304100000888aa48a7d9c4142439c8aa58a8a8a
000000000000000000000000000000008a00000000008a00008a00b7b3b365b3b35859b3b600000000000000008a00000000008a00000000000000008a00000000008a000000000000008a0000000000008a00000000008a0000000000000000008a00002737008a001005253516100000888ab4b3b39c5152539cb3b58a8a8a
000000000000000000000000000000000000000000000000009484a1a1a1a1a1a16869a1a1859500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030158a062636000098999aa1a1a1616263a1a1a185958a
00000000000000000000000000000000000000000000000084a1a1b8a8a8a1a1a1a1a1a1a1a1a185000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a078a8a8a8a178a84a1a1a1a1a1a1a1a1a1a1a1a1a1a185
000000000000000000000000000000000000000000000000a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a8a8a8a8a8a8a8aa1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
888888080808080808080808080808080808088888888a8a8888888a8a8a8a8a8a8a8a8a8a8888888888888a8a8a8a8a8a8a8a8a8a8888888888888a8a8a8a8a8a8a8a8a8a8888888888888a8a8a8a8a8a8a8a8a8a8888888888888aa9aa8a8a8a8a8a8a8a8a8a8aa9aa8a8a8a8a8a00008a8a8a8a8a8a8a8a8a8a8a8a888888
888888080808080808080808080808080808088888888a8a8888888a8a8a8a8a8a8a8a8a8a8888888888888a717238398a3a723b8a8888888888888a46478a0a0b8a46478a8888888888888a8a8a8a8a8a8a8a8a8a8888888888888a8a8a8a0909098a8a0909098a8a0909098a8a0909098a8a8a717238388a4464458a888888
888888080808a40808088a6b080808a4080808888a888a8a8800888aa04ea04e8a8a8a8a8a8888888800888a198a8a8a8a8a8a8a8a8888888800888a5657b31a1bb356578a8888888800888a4e4e4e4e8a8a8a8a8a8888888800889d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9d9a8a198aa9aa20548a558a888888
888888080808a40808085b8a080808a4080808888a888a8a8800888a8a5e8a5e8a0d0e0f6a8888888800888a8a4464458a8a8a8a8a885d888800888a8a8a666766672d2e2f8888888800888a5e5e5e5e8a6a8a8a8a8888888800888a8a8a8a414243a9aa4142438a8a414243a9aa4142438a8a8a8a8a8a8a8a548a558a888888
888888080808b40808080808080808b4080808888a888a8a8800888ab36eb36e8a5152537a8888888800888a8a548a558a8a8a8a8a886d888800888a8a8a761f1d773d3e3f8888888800888a6e6e6e6e8a7a2d2e2f888888880088b3b3b3b3515253b3b3515253b3b3515253b3b3515253b3b3b3b3b3b3b3b354b355b3888888
889080a1a1a1a1a1a1a16b6ba1a1a1a1a1a1a181a0888a8a88a282a3a3a3a3a3a3616263a383938888a282a3a3a3a3a3a3a3a3a3a383938888a282a3a3a3a3a3a3a3a3a3a383938888a282a3a3a3a3a3a3a33d3e3f83938888a080a1a1a1a1616263a1a1616263a1a1616263a1a1616263a1a1a1a1a1a1a1a1a1a1a1a1819188
80a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1818a8a82a3a3a3a3a3a3a3a3a3a3a3a3a3a38382a3a3a3a3a3a3a3a3a3a3a3a3a3a38382a3a3a3a3a3fdfefeffa3a3a3a3a38382a3a3a3a3a3a3a3a3a3a3a3a3a3a38380a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a181
8989898989898989898989898989898ab6a7898989898a8aa3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
8a8a8a080808080808088a8a8a8a8a8ab6a70808088888888888888a8a8a8a8a8a8a8a8a8a8888888a8a8aa48a8a8a8ab6a78989898a8a8a888888898989898989898989898888888a8a8a8a8a8aa48aa58a8a8a000000008a8a8a008a8a8a008a8a8a008a8a8a0000000000000000008a8a8aa9aa8a8a8aa9aa8a8a8a888888
8a8a8a080808080808088a8a8aadadb6a7080808088888888888888a8a46478a8a46478a8a8888888a8a8aa48a8a8ab6a7898989898a8a8a888888894647898989894647898888888a8a8a8a8a8a4040408a8a8a8a8a8a8a8a8a8a00008a8a008a8a8a00008a8a0000000000000000008a8a8aa4098a098a8a098a098a888888
8a888a08088a088a08088a8ab6a708080808a408088800888800888a8a56578a8a56578a8a8888888a8a8aa48a8ab6a789898989898a8a8a888a888b56578b8b8b8b56578b888a888a8a8a8a888a4040408a8a8a8a8a8a8a8a008a00008a8a008a008a00008a8a0000000000000000008a888a9d9d9d9d9d9d9d9d9d9d888a88
8a888a08088a085b08088ab6a760608a6060a460608800888800888a6a8a8a8a8a8a8a58598888888a8a8aa48ab6a78989898989898a8a8a888a8866676667666766676667888a5d8a8a8a8a888a4040408a8a8a8a8a8a8a8a008a00008a00008a008a00008a000000000000000000008a888a6a8a8a508a8a8a8a8a74888a88
8a888a08088a0808089686869770708c7070b47070880088880088b37ab32d2e2e2fb368698888888a8a8a968686978989898989898a8a8a888a8876777677767776777677888a6d8a8a8a8a888ab4b3b58a8a8a8a008a8a8a008a00008a8a008a008a00008a8a0000000000000000008a888a7ab3b36060606060b374888a88
8a98999aa1a1a16ba1a1a1a1a1a1a1a1a1a1a1a1a181a08888a282a3a3a33d3e3e3fa379798393888a9484a1a1a1a1a1a1a1a1a1a185958a88a080a1a1a1a1a1a1a1a1a1a181a0888a8a8a8a98999a9aa185958a8a8a008a8a00000000008a8a8a00000000008a8a00000000000000008a98999aa1a17070707070a1a181a088
84a1a1a1a1a1a1a1a1a1a1a1b8a8a8a8b9a1a1a1a1a1a18182a3a3a3a3a3a3a3a3a3a3a3a3a3a38384a1a1a1a148494a4b4ca1a1a1a1a18580a1a1a1a1a14a4b4ca149a14948a1818a8a8a84a1a1a1a14a4b4c858a8a8a8a000000000000008a000000000000008a000000000000000084a1a1a1a1a1a1a1a1a1a1a1a1a1a181
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a18a8aa3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a18a8a8aa1a1a1a1a1a1a1a1a18a8a8a8a000000000000000000000000000000000000000000000000a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
8a8a6c5c5a5a5a5a5a8c5a5a5a5a8c5a5a5a5a5a8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a8a8a8a6c8a5c8a8a8a6c8a8a5c88098809880988889b8809880988098809
8a6c8a8a5a6565655a9c5a8a4e5a9c5a6565655a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a6c8a8a8a8a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a6c8a8a6c8a8a6c8a8a5c8a8a880988098809888a4e8809880988098809
7c7c7c7c5a6565655a9c5a8a5e5a9c5a6565655a7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c9b88889b8888888a5e8888888888888888
a3a3a3a35a5a5a5a5a9c5a8a6e5a9c5a5a5a5a5aa3a3a3a3a3a3292a2a2a2ba3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3292a2a2a2ba3a3ab9b88888888888a6e9bab9b8888889b88
a3a3a3a3a3a3a3a3a3ac96868697aca3a3a3a3a3a3a3a3a3a3a3a328a328a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a3a328a328a3a3a3a3a3a3a3a3a396868697a3a3a3a3a3a3a3
bbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbabababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababababcbbbcbbbcbbbcbbbcbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbbbcbb
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a19a9a9a9a9aa1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a19a9a9a9a9a494a4b4c4849a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1a1
__sfx__
011a0000310552a0552a055310552a0552a055310552a055320552a055310552a0552a055310552a0552a055310552a055320552a055310552a0552a055310552a0552a055310552a055320552a055310552a055
011a00002a055310552a0552a055310552a055320552a0553005529055290553005529055290553005529055310552905530055290552905530055290552905530055290553105529055310552a0552a05531055
011a00002a0552a055310552a055320552a055310552a0552a055310552a0552a055310552a055320552a05530055290552905530055290552905530055290553105529055300552905529055300552905529055
011a0000300552905531055290552f05528055280552f05528055280552f0552805530055280552f05528055280552f05528055280552f0552805530055280552e05527055270552e05527055270552e05527055
011a00002f055270552e05527055270552e05527055270552e055270552f055270552f05528055280552f05528055280552f0552805530055280552f05528055280552f05528055280552f055280553005528055
011a00002e05527055270552e05527055270552e055270552f055270552e05527055270552e05527055270552e055270552f055270552a05523055230552a05523055230552a055230552b055230552a05523055
011a0000230552a05523055230552a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a055
011a000023055230552a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a0552305523055
011a0000000000000000000000000000000000000000000000000000000000000000320052a005310052a0052a005310052a0052a005310052a005320052a005310552a0552a055310552a0552a055310552a055
011a0000320052a005310052a0052a005310052a0052a005310052a005320052a005310552a0552a055310552a0552a055310552a055320552a055310552a0552a055310552a0552a055310552a055320552a055
011a0000310552a0552a055310552a0552a055310552a055320552a055310552a0552a055310552a0552a055310552a055320552a055300552905529055300552905529055300552905531055290553005529055
011a00002905530055290552905530055290553105529055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00002a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a05523055230552a055230552b055230552a05523055230552a05523055230552a05523055
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b043000000b04300000
010d00043853538535385353853538505385053850538505385053850538505385053850538505385053850538505385053850538505385053850538505385053850538505385053850538505385053850538505
011a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a0000064200641106410064100b4000b4000b4000b400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00001742017411174101741017400174001740017400174001740017400174001740017400174001740017400174001740017400174001740017400174000000000000000000000000000000000000000000
011a00000b4400b4310b4210b4110b4100b4100247002470024600245102441024310242102411024100241004470044700446104451044410443104421044110441004410064700647006461064510644106431
011a00001744017431174211741117410174101747017470174611745117441174311742117411174101741017470174701746117451174411743117421174111741017410174701747017461174511744117431
011a0000024600245102441024310242102411024100241004470044700446104451044410443104421044110441004410064700647006461064510644106431064210641106410064100b4700b4700b4610b451
011a00001746017451174411743117421174111741017410174701747017461174511744117431174211741117410174101747017470174611745117441174311742117411174101741017470174701746117451
011a000003470034700346103451034410343103421034110341003410000000000000000000000000000000000000000000000000000b4700b4700b4610b4510b4410b4310b4210b4110b4100b4100247002470
011a00000040000400004000040000400004000040000400124001240012400124001240012400124001240012400124001540015400124701247012460124511244112431124211241112410124101547015470
011a00001546015451154411543115421154111541015410164701647016460164511644116431164211641116410164100010000100001000010000100001000010000100001000010012470124701246012451
011a00001244012431124211241112410124101547015470154611545115441154311542115411154101541016470164701646016451164411643116421164111641016410000000000000000000000000000000
011a00001240012400124001240010470104701046110451104411043110421104111041010410104701047010461104511044110431104211041110410104101447014470144611445114441144311442114411
011a00001441014410144100000000000000000000000000000000000000000000001047010470104611045110441104311042110411104101041010470104701046110451104411043110421104111041010410
011a00001447014470144611445114441144311442114411144101441000400004000040000400004000040000400004000040000400174701747017461174511744117431174211741117410174101747017470
011a00000341003410034100000000000000000000000000000000000000000000000447004470044600445104441044310442104411044100441007470074700746107451074410743107421074110741007410
011a00000000000000000000000004470044700446004451044410443104421044110441004410074700747007461074510744107431074210741107410074100347003470034610345103441034310342103411
011a00000637006370063610635106341063310632106311063110631106300063000630006300063000630006300063000630006300063000630006300063000630006300063000630006300063000630006300
011a00001217012170121611215112141121311212112111121111211112100121000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
011a00000030000300003000030000300003000030000300063000630006300063000630006300063000630006300063000630006300063700637006360063510634106331063210631106310063100637006370
011a00000636006351063410633106321063110631006310054700547005460054510544105431054210541105410054100640006400064000640006400064000640006400064000640006370063700636006351
011a00000634006331063210631106310063100637006370063610635106341063310632106311063100631005470054700546005451054410543105421054110541005410000000000000000000000000000000
010a00002a2302a2212a2002a2002a2302a2212a200242002a2302a2212a2002a2002a2302a2212a200242002a2302a2212a2002a2002a2302a2212a200242002a2302a2212a2002a2002a2302a2212a20024200
010a00200647006471064000640006400004001240012400064001240012400124001240006400064000640006470064000647006400004000040006400064000040006400064000040000400004000040000400
010a00201207012071120001200006000000001200012000060001200012000120001200006000060001200012070120001207012000000000000006000060000000006000060000000000000000000000000000
010e10203407237072360723607236062360623606236052360523605236042360423603236032360223602236012360123601236012360123601236012360123601236012360123601236012360123601236012
010e10203601236012360123601236012360123601236012360123601236012360123601236012360123601236012360123601236012360123601236012360123601236012360123601236012360123600036002
012b00000b5000b5000b5000b5000e5000e5000e5000e50006570065710657106561065510653106511065001257012551125311251115570155511553115511165701655116531165110f5700f5510f5310f511
012b00002602500000260252600026025000002602500000260250000026025000002602500000260250000026025000002602500000260250000026025000002502500000250250000025025000002502500000
012b00001f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251e0251d0251e0251d0251e0251d0251e0251d025
012b00002602500000260250000026025000002602500000260250000026025000002602500000260250000026025000002602500000260250000026025000002502500000250250000025025000002502500000
012b00001f0251e0251f0251e0251f0251e0251f0251e0251e0251d0251e0251d0251e0251d0251e0251d0251d0251c0251d0251c0251d0251c0251d0251c0251c0251b0251c0251b0251c0251b0251c0251b025
012b00002602500000260250000026025000002602500000250250000025025000002502500000250250000024025000002402500000240250000024025000002302500000230250000023025000002302500000
012b00001d0251c0251d0251c0251d0251c0251d0251c0251c0251b0251c0251b0251c0251b0251c0251b02518025170251802517025180251702518025170251702516025170251602517025160251702516025
012b0000125001250012500125001550015500155001550000500005000050000500005000050000500005001257012551125311251115570155511553115511165701655116531165110f5700f5510f5310f511
012b00001257012551125311251115570155511553115511165701655116531165110f5700f5510f5310f5111057010551105311051113570135511353113511145701455114531145110d5700d5510d5310d511
012b0000240250000024025000002402500000240250000023025000002302500000230250000023025000001f025000001f025000001f025000001f025000001e025000001e025000001e025000001e02500000
012b00001057010551105311051113570135511353113511145701455114531145110d5700d5510d5310d5110b5700b5510b5310b5110e5700e5510e5310e5110f5700f5510f5310f51108570085510853108511
012b0000180251702518025170251802517025180251702517025160251702516025170251602517025160251f0251e0251f0251e0001f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e025
012b00001f025000001f025000001f025000001f025000001e025000001e025000001e025000001e0250000026025000002602500000260250000026025000002602500000260250000026025000002602500000
012b00000b5700b5510b5310b5110e5700e5510e5310e5110f5700f5510f5310f511085700855108531085110b5000b5000b5000b5000e5000e5000e5000e5000657006571065710656106551065310651106500
012b00001f0251e0251f0251e0001f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251f0251e0251e0251d0251e0251d0251e0251d0251e0251d025
013c00002b00032021320213202132021300212f0212d0212b02132021320213202132021300212f0112d0112b0002b00032000320003200032000300002f0002d0002b000320003200000000000000000000000
__music__
01 00 1e 15 28
00 01 1f 15 29
00 02 20 15 2a
00 03 21 15 25
00 04 22 15 24
00 05 23 15 1d
00 06 1c 15 1b
00 07 1a 15 19
02 0c 18 15 17
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 32 33 37 44
01 34 35 38 44
00 36 39 3a 44
00 3b 3c 3d 44
02 3e 31 30 44
02 26 27 26 27
00 2e 42 43 44
02 2f 42 43 44
00 41 42 43 44
00 41 42 43 44
00 2c 2d 43 44
00 2c 2d 43 44
00 2c 2d 43 44
00 2c 2d 43 44
03 2c 2d 2b 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
