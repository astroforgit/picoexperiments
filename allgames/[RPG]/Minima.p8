pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- minima
-- by feneric
a={
['true']=true,
['false']=false}
b={}
c={['{']="}",['[']="]"}
function d(e,f)
for i=1,#f do
if(e==sub(f,i,i)) return true
end
return false
end
function g(h, i, j, k)
if sub(h,i,i)!=j then
return i,false
end
return i+1,true
end
function l(h, i, m)
m=m or ''
local c=sub(h,i,i)
if(c=='"') return b[m] or m,i+1
return l(h,i+1,m..c)
end
function n(h,i,m)
m=m or ''
local c=sub(h,i,i)
if(not d(c,"-xb0123456789abcdef.")) return tonum(m),i
return n(h,i+1,m..c)
end
function o(h, i, p)
i=i or 1
local q=sub(h,i,i)
if d(q,"{[") then
local r,s,t={},true,true
i+=1
while true do
s,i=o(h, i, c[q])
if(s==nil) return r,i
if q=="{" then
i=g(h,i,':',true)
r[s],i=o(h,i)
else
add(r,s)
end
i,t=g(h, i, ',')
end
elseif q=='"' then
return l(h,i+1)
elseif d(q,"-0123456789") then
return n(h, i)
elseif q==p then
return nil,i+1
else
for u,v in pairs(a) do
local w=i+#u-1
if sub(h,i,w)==u then return v,w+1 end
end
end
end
x,y,z,ba=11,13,5,6
bb="\n\n\n\n\n\n  congratulations, you've won!\n\n\n\n\n\n\n\n\n\n    press p to get game menu,\n anything else to continue and\n      explore a bit more."
bc="\n\n\n\n\n\n      you've been killed!\n          you lose!\n\n\n\n\n\n\n\n\n\n\n\n    press p to get game menu"
bd="minima commands:\n\na: attack\nc: cast spell\nd: dialog, talk, buy\ne: enter, board, mount, climb,\n   descend\np: pause, save, load, help\nf: fountain drink; force chest;\n   flame torch\ns: sit & wait\nw: wearing & wielding\nx: examine, look (repeat to\n   search)\n\nfor commands with options (like\ncasting or buying) use the first\ncharacter from the list, or\nanything else to cancel."
msg=bd
be={f=1,mva=0,nm=0,mvp=0,hd=0,ch=0,z=0}
function bf(bg,bh)
return setmetatable(bg,{__index=bg.ot or bh})
end
bi={"plains","bare ground","tundra","scrub","swamp","forest","foothills","mountains","tall mountain","volcano","volcano","water","water","deep water","deep water","brick","brick road","brick","mismatched brick","stone","stone","road","barred window","window","bridge","ladder down","ladder up","door","locked door","open door","sign","shrine","dungeon","castle","tower","town","village","ankh"}
for bj=1,29 do
add(bi,"counter")
end
bk={}
for bj=1,38 do
add(bk,{})
end
bl=o('[{"t":[1,2,3,4,5,6,7,8,17,18,22,25,26,27,30,31,33,35],"gp":10,"hp":10,"ch":1,"mva":1,"hos":1,"ar":1,"exp":2,"dex":8,"dmg":13},{"mxx":128,"mn":0,"fri":1,"mxy":64,"mnx":80,"mxm":0,"newm":0,"mny":0},{"sz":1,"sy":1,"sx":1,"mnx":1,"sf":1,"dg":1,"c":{},"mxm":27,"mn":0,"ss":17,"mxy":9,"fri":false,"newm":25,"mxx":9,"mny":1},{"i":38,"ia":38,"n":"ankh","d":["yes, ankhs can talk.","shrines make good landmarks."]},{"ia":70,"p":1,"i":70,"f":2,"n":"ship","fm":1},{"ia":92,"shm":-2,"i":92,"szm":11,"n":"chest","p":1},{"iseq":12,"n":"fountain","fi":1,"i":39,"szm":14,"shm":-2,"p":1},{"ia":27,"shm":12,"i":27,"szm":20,"n":"ladder up","p":1},{"ia":26,"shm":-3,"i":26,"szm":20,"n":"ladder down","p":1},{"hos":false,"i":80,"exp":1,"gp":5,"ar":0},{"n":"orc","ch":8,"d":["urg!","grar!"]},{"dmg":14,"gp":5,"ch":5,"dex":6},{"dex":10,"gp":0,"ch":3,"ar":0},{"dex":9,"n":"fighter","cs":[{},[[1,12],[14,2],[15,4]]],"d":["check out these pecs!","i\'m jacked!"],"i":82,"hp":12,"dmg":20,"ar":3},{"ar":12,"n":"guard","cs":[{},[[15,4]]],"d":["behave yourself.","i protect good citizens."],"i":90,"hp":85,"dmg":60,"mva":0},{"n":"merchant","fi":1,"d":["consume!","stuff makes you happy!"],"i":75,"cs":[{},[[1,4],[4,15],[6,1],[14,13]],[[1,4],[6,5],[14,10]],[[1,4],[4,15],[6,1],[14,3]]]},{"n":"lady","fi":1,"d":["pardon me.","well i never."],"i":81,"cs":[{},[[2,9],[4,15],[13,14]],[[2,10],[4,15],[13,9]],[[2,11],[13,3]]]},{"i":76,"n":"shepherd","cs":[{},[[6,5],[15,4]],[[6,5]],[[15,4]]],"d":["i like sheep.","the open air is nice."]},{"i":78,"n":"jester","dex":12,"d":["ho ho ho!","ha ha ha!"]},{"i":84,"n":"mage","ac":[[9,6],[8,13],[10,12]],"d":["a mage is always on time.","brain over brawn."]},{"cs":[{},[[9,11],[1,3],[15,4]],[[9,11],[1,3]],[[15,4]]],"n":"ranger","fi":1,"d":["i travel the land.","my home is the range."]},{"hos":1,"n":"villain","d":["stand and deliver!","you shall die!"],"ar":1,"exp":5,"gp":15},{"mch":"food","n":"grocer"},{"mch":"armor","n":"armorer"},{"mch":"weapons","n":"smith"},{"mch":"hospital","n":"medic"},{"mch":"guild","n":"guildkeeper"},{"mch":"bar","n":"barkeep"},{"i":96},{"n":"troll","exp":4,"i":102,"hp":15,"gp":10,"dmg":16},{"exp":3,"gp":8,"i":104,"hp":15,"dmg":14,"ns":["hobgoblin","bugbear"]},{"exp":1,"gp":5,"i":114,"hp":8,"dmg":10,"ns":["goblin","kobold"]},{"n":"ettin","fi":1,"exp":6,"i":118,"hp":20,"ch":1,"dmg":18},{"i":98,"n":"skeleton","gp":12},{"i":100,"hp":10,"ns":["zombie","wight","ghoul"]},{"d":["boooo!","feeear me!"],"fi":1,"t":[1,2,3,4,5,6,7,8,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,35],"i":123,"hp":15,"exp":7,"ns":["phantom","ghost","wraith"]},{"exp":10,"cs":[{},[[2,8],[15,4]]],"d":["i hex you!","a curse on you!"],"i":84,"dmg":18,"ac":[[9,6],[8,13],[10,12]],"ns":["warlock","necromancer","sorcerer"]},{"cs":[{},[[1,5],[8,2],[4,1],[2,12],[15,4]]],"dex":10,"i":88,"th":1,"ch":2,"ns":["rogue","bandit","cutpurse"]},{"exp":8,"cs":[{},[[1,5],[15,4]]],"d":["you shall die at my hands.","you are no match for me."],"i":86,"gp":10,"po":1,"ns":["ninja","assassin"]},{"n":"giant spider","exp":5,"i":106,"hp":18,"gp":8,"po":1},{"n":"giant rat","exp":2,"eat":1,"i":108,"hp":5,"po":1,"dmg":10},{"po":1,"exp":6,"t":[4,5,6,7],"i":112,"hp":20,"ch":1,"ns":["giant snake","serpent"]},{"n":"sea serpent","t":[5,12,13,14,15,25],"i":116,"hp":45,"exp":10},{"n":"megascorpion","fi":1,"exp":5,"i":125,"hp":12,"ch":1,"po":1},{"exp":2,"eat":1,"cs":[{},[[3,9],[11,10]],[[3,14],[11,15]]],"t":[17,22,23],"i":122,"gp":5,"fi":1,"ns":["slime","jelly","blob"]},{"exp":8,"t":[12,13,14,15],"i":94,"hp":50,"ch":2,"ns":["kraken","giant squid"]},{"n":"wisp","fi":1,"t":[4,5,6],"i":120,"exp":3},{"exp":8,"n":"pirate","cs":[[[6,5],[7,6]]],"t":[12,13,14,15],"i":70,"f":1,"fi":false,"fm":1},{"cs":[{},[[2,14],[1,4]]],"t":[17,22],"i":119,"exp":4,"fi":1,"ns":["gazer","beholder"]},{"fi":1,"ac":[[9,6],[8,13],[10,12]],"hp":50,"ns":["dragon","drake","wyvern"],"exp":17,"i":121,"gp":20,"dmg":28,"ar":7},{"t":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,33,35],"ac":[[9,10],[8,9],[10,7]],"hp":50,"ch":0.25,"ns":["daemon","devil"],"exp":15,"i":110,"gp":25,"dmg":23,"ar":3},{"th":1,"n":"mimic","exp":4,"t":[17,22],"i":92,"gp":12,"ch":0,"mva":0},{"fi":1,"t":[17,22],"gp":8,"hp":30,"ch":0,"mva":0,"n":"reaper","i":124,"exp":5,"ar":5}]')
bm=bl[5]
for bn=1,#bl do
local bh
local bo=bl[bn]
if bn<10 then
bh=be
elseif bn<14 then
bh=bl[1]
elseif bn<23 then
bh=bl[10]
elseif bn<28 then
bh=bl[16]
elseif bn<29 then
bh=bl[17]
elseif bn<35 then
bh=bl[11]
elseif bn<38 then
bh=bl[12]
elseif bn<41 then
bh=bl[22]
elseif bn<48 then
bh=bl[13]
else
bh=bl[1]
end
bo.id=bn
bf(bo,bh)
if bn>28 then
for bp in all(bo.t) do
add(bk[bp],bo)
end
end
end
function bq(br,bs,bt)
bu(br)
bv=yield()
bw=bs(bv)
return bw and bt(bw) or bw==false and "you cannot afford that." or "no sale."
end
function bx(bw)
if bw and bw.p then
return by.gp>=bw.p and bw
else
return nil
end
end
function bz(br,ca,cb)
return bq(br,
function(bv)
return bx(ca[bv])
end,
function(bw)
if by[cb]>=bw.a then
return "that is not an upgrade."
else
by.gp-=bw.p
by[cb]=bw.a
return "the "..bw.n.." is yours."
end
end
)
end
cc={
food=function()
return bq({"$15 for 25 food; a\80\80\82\79\86\69? "},
function(bv)
if bv=='a' then
return by.gp>=15
else
return nil
end
end,
function()
by.gp-=15
by.fd=cd(by.fd+25)
return "you got more food."
end
)
end,
armor=function()
return bz({"buy \131cloth $12, \139leather $99,","\145chain $300, or \148plate $950: "},ce,'ar')
end,
weapons=function()
return bz({"buy d\65\71\71\69\82 $8, c\76\85\66 $40,","a\88\69 $75, or s\87\79\82\68 $150: "},weapons,'dmg')
end,
hospital=function()
return bq({"choose m\69\68\73\67 ($8), c\85\82\69 ($10),","or s\65\86\73\79\82 ($25): "},
function(bv)
cf=cg[bv]
return bx(cf)
end,
function(cf)
sfx(3)
by.gp-=cf.p
if cf.n=='cure' then
by.st=band(by.st,14)
else
ch(cf.a)
end
return cf.n.." is cast!"
end
)
end,
bar=function()
return bq({"$5 per drink; a\80\80\82\79\86\69? "},
function(bv)
if bv=='a' then
return by.gp>=5
else
return nil
end
end,
function()
by.gp-=5
ci=o('["faxon has many guards.","faxon is very powerful.","fountains respect injury.","dungeon fountains rule.","faxon fears a magic sword.","watch for secret doors.","fighters can bust doors.","good mages can zap doors."]')
bu{"while socializing, you hear:"}
return '"'..ci[flr(rnd(8)+1)]..'"'
end
)
end,
guild=function()
return bq({"5 \139torches $12 or a \145key $23: "},
function(bv)
local cj=ck[bv]
return bx(cj)
end,
function(bw)
by.gp-=bw.p
by[bw.attr]+=bw.q
return "you purchase "..bw.n
end
)
end
}
function cl(ca)
cm={}
for cn,co in pairs(ca) do
cm[co.a]=co.n
end
cm[0]='none'
return cm
end
ce=o('{"south":{"n":"cloth","a":8,"p":12},"west":{"n":"leather","a":23,"p":99},"east":{"n":"chain","a":40,"p":300},"north":{"n":"plate","a":70,"p":950}}')
cp=cl(ce)
weapons=o('{"d":{"n":"dagger","a":8,"p":8},"c":{"n":"club","a":12,"p":40},"a":{"n":"axe","a":18,"p":75},"s":{"n":"sword","a":30,"p":150},"t":{"n":"magic swd","a":40}}')
cq=cl(weapons)
cg=o('{"a":{"n":"attack","c":3,"a":1},"x":{"n":"medic","c":5,"a":1,"p":8},"c":{"n":"cure","c":7,"p":10},"w":{"n":"wound","c":11,"a":5},"e":{"n":"exit","c":13},"s":{"n":"savior","c":17,"a":6,"p":25}}')
ck=o('{"west":{"n":"5 torches","attr":"ts","p":12,"q":5},"east":{"n":"a key","attr":"keys","p":23,"q":1}}')
function cr()
local cs=ct.ss
ct=cu[cv]
cw=ct.con
if(cs and ct.ss)music(ct.ss)
by.hd=0
end
function cx()
cu=o('[{"sy":23,"mxx":105,"ex":13,"sx":92,"n":"saugus","signs":[{"x":92,"msg":"welcome to saugus!","y":19}],"mxy":24,"c":[{"x":89,"id":15,"y":21},{"x":84,"id":26,"y":9},{"x":95,"id":24,"y":3},{"x":97,"id":23,"y":13},{"x":82,"id":14,"y":21},{"x":101,"id":21,"y":5},{"x":84,"d":["the secret room is key.","the way must be clear."],"id":20,"y":5},{"x":103,"d":["faxon is in a tower.","volcanoes mark it."],"id":21,"y":18},{"x":85,"d":["poynter has a ship.","poynter is in lynn."],"id":17,"y":16},{"x":95,"id":15,"y":21}],"i":[{"x":84,"id":4,"y":4}],"ey":4},{"sy":23,"ex":17,"sx":116,"n":"lynn","signs":[{"x":125,"msg":"marina for members only.","y":9}],"mxy":24,"c":[{"x":118,"id":15,"y":22},{"x":106,"id":25,"y":1},{"x":118,"id":28,"y":2},{"x":107,"id":23,"y":9},{"x":106,"id":19,"y":16},{"x":122,"id":26,"y":12},{"x":105,"d":["i\'ve seen faxon\'s tower.","south of the eastern shrine."],"id":14,"y":4},{"x":106,"d":["griswold knows dungeons.","griswold is in salem."],"id":17,"y":7},{"x":119,"d":["i\'m rich! i have a yacht!","ho ho! i\'m the best!"],"id":16,"y":6},{"x":114,"id":15,"y":22}],"i":[{"x":125,"id":5,"y":5}],"mnx":104,"ey":4},{"sy":54,"mxx":112,"ex":45,"sx":96,"n":"boston","mxy":56,"c":[{"x":94,"id":15,"y":49},{"x":103,"id":25,"y":39},{"x":92,"id":24,"y":30},{"x":88,"id":23,"y":38},{"x":100,"id":26,"y":30},{"x":96,"id":19,"y":44},{"x":83,"d":["zanders has good tools.","be prepared!"],"id":14,"y":27},{"x":81,"id":16,"y":44},{"x":104,"d":["each shrine has a caretaker.","seek their wisdom."],"id":20,"y":26},{"x":110,"d":["i\'ve seen the magic sword.","search south of the shrine."],"id":16,"y":40},{"x":105,"mva":1,"id":15,"y":35},{"x":98,"id":15,"y":49}],"i":[{"x":96,"id":7,"y":40}],"mny":24,"ey":19},{"sy":62,"ex":7,"sx":119,"n":"salem","i":[{"x":116,"id":4,"y":53}],"c":[{"x":118,"id":15,"y":63},{"x":125,"id":27,"y":44},{"x":114,"id":28,"y":44},{"x":122,"id":23,"y":51},{"x":118,"id":17,"y":58},{"x":113,"d":["faxon is a blight.","daemons serve faxon."],"id":21,"y":50},{"x":123,"d":["increase stats in dungeons!","only severe injuries work."],"id":14,"y":57},{"x":120,"id":15,"y":63}],"mny":43,"mnx":112,"ey":36},{"c":[{"x":93,"id":23,"y":57},{"x":100,"id":28,"y":57},{"x":91,"d":["even faxon has fears.","lalla knows who to see."],"id":14,"y":60},{"x":82,"id":18,"y":57},{"x":102,"d":["gilly is in boston.","gilly knows of the sword."],"id":18,"y":63}],"sy":59,"mxx":103,"ex":27,"mny":56,"sx":82,"n":"great misery","ey":35},{"sy":62,"mxx":112,"ex":1,"sx":107,"n":"western shrine","c":[{"x":107,"d":["magic serves good or evil.","swords cut both ways."],"id":20,"y":59}],"mny":56,"mnx":103,"ey":28},{"sy":62,"mxx":112,"ex":49,"sx":107,"n":"eastern shrine","c":[{"x":107,"d":["some fountains have secrets.","know when to be humble."],"id":18,"y":59}],"mny":56,"mnx":103,"ey":6},{"sy":41,"newm":35,"ex":56,"sx":120,"n":"the dark tower","c":[{"x":119,"id":53,"y":41},{"x":126,"id":53,"y":40},{"x":123,"id":53,"y":38},{"x":113,"id":53,"y":40},{"x":121,"id":52,"y":37},{"x":119,"id":52,"y":38},{"x":120,"id":45,"y":34},{"x":118,"id":45,"y":35},{"ar":25,"dmg":50,"hp":255,"y":30,"x":118,"i":126,"id":50,"pn":"faxon"}],"i":[{"tm":12,"ty":8,"y":41,"x":117,"tz":3,"id":8,"tx":3},{"x":119,"id":6,"y":37},{"x":119,"id":6,"y":39},{"x":120,"id":6,"y":37},{"x":120,"id":6,"y":38},{"x":120,"id":6,"y":39},{"x":121,"id":6,"y":38},{"x":121,"id":6,"y":39}],"ss":17,"mxm":23,"mxy":43,"fri":false,"mny":24,"mnx":112,"ey":44},{"l":[[0,16382,768,12336,16380,13056,13308,192],[0,-13107,816,12336,15612,768,16332,704],[-32768,-3316,1020,12300,13116,13056,-3076,448],[29488,13116,0,-3073,0,-3124,780,13116]],"sy":8,"c":[{"x":8,"z":4,"id":50,"y":5},{"x":3,"z":4,"id":52,"y":1},{"x":1,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":52,"y":1},{"x":3,"z":4,"id":53,"y":3}],"ex":4,"attr":"int","i":[{"x":1,"z":1,"id":8,"y":8},{"x":8,"z":2,"id":8,"y":2},{"x":4,"z":3,"id":8,"y":8},{"x":1,"z":4,"id":8,"y":1},{"x":1,"z":4,"id":6,"y":8},{"x":7,"z":4,"id":6,"y":1},{"x":3,"z":4,"id":6,"y":8},{"x":5,"z":4,"id":6,"y":8},{"x":8,"z":4,"id":6,"y":8},{"x":6,"z":3,"id":7,"y":8}],"n":"nibiru","ey":11},{"l":[[824,16188,768,13296,-4036,13056,13308,768],[13060,13116,12,16332,12540,15360,15311,768],[768,13116,-20432,-196,48,16140,14140,816],[0,-13108,19468,-13108,192,-13108,3084,-13108]],"c":[{"x":3,"z":4,"id":50,"y":5},{"x":1,"z":4,"id":52,"y":5},{"x":7,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":53,"y":3},{"x":5,"z":4,"id":53,"y":7}],"ex":32,"attr":"str","i":[{"x":1,"z":1,"id":8,"y":1},{"x":7,"z":2,"id":8,"y":1},{"x":3,"z":3,"id":8,"y":7},{"x":1,"z":4,"id":8,"y":3},{"x":1,"z":4,"id":6,"y":1},{"x":1,"z":4,"id":6,"y":8},{"x":1,"z":4,"id":6,"y":7},{"x":2,"z":4,"id":6,"y":8},{"x":8,"z":4,"id":6,"y":8},{"x":7,"z":3,"id":7,"y":5}],"n":"purgatory","ey":5},{"l":[[768,16304,1020,13056,13299,12288,-4,0],[768,13180,12303,16382,252,15360,13263,12288],[768,13116,12348,13105,13119,13068,13116,512],[0,16188,12300,13260,12300,12300,16380,256]],"c":[{"x":3,"z":4,"id":50,"y":1},{"x":4,"z":4,"id":52,"y":5},{"x":5,"z":4,"id":52,"y":2},{"x":3,"z":4,"id":53,"y":4},{"x":6,"z":4,"id":53,"y":4}],"ex":33,"attr":"dex","i":[{"x":1,"z":1,"id":8,"y":1},{"x":5,"z":2,"id":8,"y":2},{"x":8,"z":3,"id":8,"y":4},{"x":4,"z":4,"id":8,"y":8},{"x":5,"z":4,"id":6,"y":5},{"x":3,"z":4,"id":6,"y":6},{"x":4,"z":4,"id":6,"y":6},{"x":5,"z":4,"id":6,"y":6},{"x":6,"z":4,"id":6,"y":6},{"x":6,"z":3,"id":7,"y":6}],"n":"sheol","ey":58},{"sz":3,"c":[{"x":4,"z":1,"id":51,"y":6},{"x":4,"z":2,"id":51,"y":7},{"x":1,"z":3,"id":51,"y":7},{"x":6,"z":3,"id":53,"y":8},{"x":8,"z":3,"id":53,"y":4},{"x":3,"z":3,"id":53,"y":1},{"x":6,"z":2,"id":53,"y":6},{"x":6,"z":1,"id":53,"y":8}],"ex":124,"sx":8,"n":"the upper levels","l":[[192,-17202,-817,204,16332,3276,204,3072],[192,31949,16323,14576,15555,3276,15566,192],[192,-13105,3264,13564,16320,207,13261,15104]],"mn":8,"i":[{"x":8,"z":3,"id":9,"y":1},{"tz":0,"tm":8,"z":3,"y":8,"x":3,"ty":41,"id":9,"tx":117},{"x":8,"z":3,"id":8,"y":7},{"x":3,"z":3,"id":8,"y":4},{"x":1,"z":2,"id":8,"y":2},{"x":8,"z":2,"id":8,"y":2}],"ey":26}]')
cu[0]=o('{"n":"world","mnx":0,"mny":0,"mxx":80,"mxy":64,"wrap":1,"newm":10,"mxm":12,"fri":false,"ss":0}')
cy={}
for cv=0,#cu do
local cz
ct=cu[cv]
if cv>0 then
if ct.l then
cz=bl[3]
else
cz=bl[2]
end
bf(ct,cz)
end
ct.w,ct.h=ct.mxx-ct.mnx,ct.mxy-ct.mny
cy[cv],ct.con={},{}
for bj=ct.mnx-1,ct.mxx+1 do
ct.con[bj]={}
for da=ct.mny-1,ct.mxy+1 do
ct.con[bj][da]={}
end
end
for co in all(ct.i) do
co.ot,db,dc,dd=bl[co.id],co.x,co.y,co.z or 0
ct.con[db][dc][dd]=bf(co)
if co.ot.n=='ladder up' and ct.dg then
dd-=1
ct.con[db][dc][dd]=bf{ot=bl[9]}
end
end
for de in all(ct.c) do
de.mn=cv
de.ot=bl[de.id]
df(de)
end
end
by=o('{"i":0,"ar":0,"dmg":0,"x":7,"y":7,"z":0,"exp":0,"lvl":0,"str":8,"int":8,"dex":8,"st":0,"hd":0,"f":0,"gp":20,"fd":25,"mvp":0,"mp":8,"hp":24,"keys":0,"ts":5,"lit":0}')
by.color=rnd(10)>6 and 4 or 15
cv=0
cr()
cy[0]={}
dg=bf(o('{"i":69,"iseq":23,"n":"maelstrom","t":[12,13,14,15],"mva":1,"x":13,"y":61}'),be)
cy[0][0]=dg
cw[13][61][0]=dg
dh=0
di=false
dj=0
_update=dk
_draw=dl
dm=dl
end
dn={"","","","",">"}
dp=5
dq=dp
function _init()
cx()
menuitem(1,"list commands",dr)
menuitem(2,"save game",ds)
menuitem(3,"load game",dt)
menuitem(4,"new game",run)
du=cocreate(dv)
cartdata("minima0")
end
function dr()
msg=bd
if _draw~=dw then
dm=_draw
_draw=dw
end
end
dx={'ar','dmg','x','y','str','int','dex','st','i','color','f','keys','ts','exp','lvl','gp','fd','mp','hp'}
function dy(dz,ea)
return bor(shl(dz,8),ea)
end
function ds()
if cv~=0 then
bu{"sorry, only outside."}
else
local eb=0
for ec in all(dx) do
dset(eb,by[ec])
eb+=1
end
for ed=1,12 do
local de=cy[0][ed]
if de then
dset(eb,de.id)
dset(eb+1,dy(de.x,de.y))
else
dset(eb,0)
end
eb+=2
end
bu{"game saved."}
end
end
function ee(ef)
return lshr(band(ef,0xff00),8),band(ef,0xff)
end
function dt()
cx()
local eb=0
for ec in all(dx) do
by[ec]=dget(eb)
eb+=1
end
for ed=1,12 do
eg=dget(eb)
if eg~=0 then
eh,ei=ee(dget(eb+1))
df{ot=bl[eg],x=eh,y=ei,mn=0}
eb+=2
else
break
end
end
bu{"game loaded."}
end
ej={
"west", "east", "north", "south",
"c", "x", "p", "?", "s", "f", "e", "d", "w", "a"
}
function ek(el)
local em=1
while el>1 do
el=lshr(el,1)
em+=1
end
return ej[em] or 'none'
end
function en(bv,eo)
local ep=cg[bv]
if by.mp>=ep.c then
by.mp-=ep.c
bu{ep.n.." is cast! "..(eo or '')}
return true
else
bu{"not enough mp."}
return false
end
end
function eq(er,es,et)
by.x,by.y,by.z,by.f,by.lit,cv=er or ct.ex,es or ct.ey,0,0,0,et or ct.mn
cr()
_draw=dl
end
function eu(ev,et,er,es,ew)
by.x,by.y=er or ev.sx,es or ev.sy
cv=et
cr()
if ev.dg then
_draw=ex
by.f,by.z=ev.sf,ev.sz
end
return "entering "..ev.n.."."
end
function dv(bv)
while true do
local ey=ez(by)
local db,dc,dd=by.x,by.y,by.z
local fa=cw[db][dc][dd]
local fb=fa and fa.n or nil
if _draw==dw then
if bv!='p' and by.hp>0 then
_draw=dm
end
elseif bv=='west' then
if ct.dg then
by.f-=1
if by.f<1 then
by.f=4
end
bu{"turn left"}
di=true
else
by.x,by.y=fc(ey[2],dc,bv)
end
elseif bv=='east' then
if ct.dg then
by.f+=1
if by.f>4 then
by.f=1
end
bu{"turn right."}
di=true
else
by.x,by.y=fc(ey[4],dc,bv)
end
elseif bv=='north' then
if ct.dg then
by.x,by.y,by.z=fd(1)
else
by.x,by.y=fc(db,ey[1],bv)
if by.x==121 and by.y==36 then
mset(116,41,22)
bu{"something clicks."}
end
end
elseif bv=='south' then
if ct.dg then
by.x,by.y,by.z=fd(-1)
else
by.x,by.y=fc(db,ey[3],bv)
end
elseif bv=='c' then
bu{"choose a\84\84\65\67\75, m\69\68\73\67, c\85\82\69,","w\79\85\78\68, e\88\73\84, s\65\86\73\79\82: "}
bv=yield()
if bv=='c' then
if en(bv) then
sfx(3)
by.st=band(by.st,14)
end
elseif bv=='x' or bv=='s' then
if en(bv) then
sfx(3)
ch(cg[bv].a*by.int)
end
elseif bv=='e' then
if not ct.dg then
bu{'not in a dungeon.'}
elseif(en(bv)) then
sfx(4)
eq()
end
elseif bv=='w' or bv=='a' then
if en(bv,'dir:') then
local fe=rnd(cg[bv].a*by.int)
if not ff(ey,fg,fe) then
bu{'nothing to target.'}
end
end
else
bu{"cast: huh?"}
end
di=true
elseif bv=='x' then
bu{"examine dir:"}
if not ff(ey,fh) then
if bv=='x' then
local fi={"search","you find nothing."}
fj=fk(db,dc)
if fj then
fi={"read sign",fj}
elseif db==1 and dc==38 and by.dmg<40 then
fi[2]="you find the magic sword!"
by.dmg=40
end
bu(fi)
else
bu{"examine: huh?"}
end
end
di=true
elseif bv=='p' then
bu{"pause / game menu"}
elseif bv=='s' then
di=true
bu{"sit and wait."}
elseif bv=='f' then
di=true
if fb=='fountain' then
sfx(3)
msg="healed!"
if ct.dg and by.hp<23 and by[ct.attr]<16 then
by[ct.attr]+=1
msg="you feel more capable!"
end
ch(100)
bu{msg}
elseif fb=='chest' then
local fl=ceil(rnd(100))
by.gp+=fl
bu{"you find "..fl.." gp."}
cw[db][dc][dd]=nil
elseif ct.dg and by.lit<1 then
if by.ts>1 then
by.lit=50
by.ts-=1
bu{"the torch is now aflame."}
else
bu{"you have no torches."}
end
else
bu{"nothing here."}
end
elseif bv=='e' then
di=true
local msg="nothing to enter."
if fb=='ladder up' or fb=='ladder down' then
if ct.dg then
if dd==ct.sz and db==ct.sx and dc==ct.sy then
msg="exiting "..ct.n.."."
eq()
elseif fb=='ladder up' then
msg="ascending."
by.z-=1
else
msg="descending."
by.z+=1
end
end
if fa.tm then
if ct.dg and not cu[fa.tm].dg then
eq(fa.tx,fa.ty,fa.tm)
else
msg=eu(cu[fa.tm],fa.tm,fa.tx,fa.ty,fa.tz)
end
end
elseif by.i>0 then
msg="exiting ship."
cw[db][dc][dd]=bf{f=by.f,ot=bm}
by.i,by.f=0,0
elseif fb=='ship' then
msg="boarding ship."
by.i,by.f=70,fa.f
cw[db][dc][dd]=nil
end
for fm=1,#cu do
local fn=cu[fm]
if cv==fn.mn and db==fn.ex and dc==fn.ey then
msg=eu(fn,fm)
end
end
bu{msg}
elseif bv=='d' then
bu{"dialog dir:"}
if not ff(ey,fo) then
bu{"dialog: huh?"}
end
di=true
elseif bv=='w' then
bu{
"worn: "..cp[by.ar].."; wield: "..cq[by.dmg],
by.ts..' torches & '..by.keys..' skeleton keys.'
}
elseif bv=='a' then
if by.i>0 then
bu{"fire dir:"}
else
bu{"attack dir:"}
end
if not ff(ey,fg) then
bu{"attack: huh?"}
end
di=true
end
if by.lit>1 then
by.lit-=1
if by.lit<1 then
bu{"the torch burnt out."}
end
end
if _draw==ex and by.lit<1 then
bu{"it's dark!"}
end
bv=yield()
end
end
function ff(ey,fp,fq,fr)
if ct.dg then
fr=fs[by.f]
elseif not fr then
fr=yield()
end
if fr=='east' then
fp(fr,ey[4],by.y,fq)
elseif fr=='west' then
fp(fr,ey[2],by.y,fq)
elseif fr=='north' then
fp(fr,by.x,ey[1],fq)
elseif fr=='south' then
fp(fr,by.x,ey[3],fq)
else
return false
end
return true
end
function bu(msg)
local br="> "
for ft in all(msg) do
dn[dq]=br..ft
dq+=1
if(dq>dp)dq=1
br=""
end
dn[dq]=">"
end
function df(fu)
local fv,db,dc,dd=fu.ot,fu.x,fu.y,fu.z or 0
fu.ot=fv
bf(fu)
if fu.pn then
fu.n=fu.pn
elseif fv.ns then
fu.n=fv.ns[flr(rnd(#fv.ns)+1)]
end
if(fv.cs)fu.co=fv.cs[flr(rnd(#fv.cs)+1)]
fu.iseq=flr(rnd(30))
fu.ia=false
add(cy[fu.mn],fu)
cu[fu.mn].con[db][dc][dd]=fu
return fu
end
function fw()
local fx=flr(rnd(ct.w))+ct.mnx
local fy=flr(rnd(ct.h))+ct.mny
local fz=ct.dg and flr(rnd(#ct.l)+1) or 0
if cw[fx][fy][fz] or fx==by.x and fy==by.y and fz==by.z then
fx=nil
end
if fx then
local ga=mget(fx,fy)
if ct.dg then
ga=gb(fx,fy,fz,1)
end
for fv in all(bk[ga]) do
if rnd(200)<fv.ch then
df{ot=fv,x=fx,y=fy,z=fz,mn=cv}
break
end
end
end
end
function gc(gd)
by.hp-=ceil(gd)
if by.hp<=0 then
msg=bc
_draw=dw
end
end
function ge(gf)
by.fd-=gf
if by.fd<=0 then
sfx(1,3,8)
by.fd=0
bu{"starving!"}
gc(1)
end
end
function cd(bj)
return min(bj,32767)
end
function gg(gf)
by.exp=cd(by.exp+gf)
if by.exp>=by.lvl^2*10 then
by.lvl+=1
ch(12)
bu{"you went up a level!"}
end
end
function ch(gf)
by.hp=cd(min(by.hp+gf,by.str*(by.lvl+3)))
end
function fd(gh)
local gi,gj=by.x,by.y
local db,dc,dd=by.x,by.y,by.z
local bv=gh>0 and 'advance' or 'retreat'
local co
local gk=false
if by.f==1 then
gj-=gh
gl=gb(db,gj,dd)
co=cw[db][gj][dd]
elseif by.f==2 then
gi+=gh
gl=gb(gi,dc,dd)
co=cw[gi][dc][dd]
elseif by.f==3 then
gj+=gh
gl=gb(db,gj,dd)
co=cw[db][gj][dd]
else
gi-=gh
gl=gb(gi,dc,dd)
co=cw[gi][dc][dd]
end
if co and co.hp then
gk=true
end
if gl==3 or gk then
gm(bv)
else
db,dc=gi,gj
sfx(0)
bu{bv}
end
di=true
return db,dc,dd
end
function gn(db,dc)
if not ct.wrap and(db>=ct.mxx or db<ct.mnx or dc>=ct.mxy or dc<ct.mny) then
bu{bv,"exiting "..ct.n.."."}
cv=0
return true
else
return false
end
end
function gm(bv)
sfx(5)
bu{bv,"blocked!"}
return false
end
go={north=1,west=2,south=3,east=4}
fs={"north","east","south","west"}
function fc(db,dc,bv)
local gp=true
local gq=mget(db,dc)
local gr=band(fget(gq),3)
local gs=fget(gq,2)
local gt=fget(gq,3)
local gu=cw[db][dc][by.z]
if by.i>0 then
by.f=go[bv]
local gv=mget(db,dc)
if gn(db,dc) then
db,dc=ct.ex,ct.ey
cr()
elseif gu then
if gu.n=='maelstrom' then
bu{bv,"maelstrom! yikes!"}
gc(rnd(25))
else
gp=gm(bv)
end
elseif gv<12 or gv>15 then
bu{bv,"must exit ship first."}
gp=false
else
bu{bv}
end
else
if gn(db,dc) then
db,dc=ct.ex,ct.ey
cr()
elseif gu then
if not gu.p then
gp=gm(bv)
end
elseif gq==28 then
bu{bv,"open door."}
gp=false
mset(db,dc,30)
elseif gq==29 then
if by.keys>0 then
bu{bv,"you jimmy the door."}
by.keys-=1
mset(db,dc,30)
else
bu{bv,"the door is locked."}
end
gp=false
elseif gt then
gp=gm(bv)
elseif gs then
gp=false
bu{bv,"not without a boat."}
elseif gr>by.mvp then
by.mvp+=1
gp=false
bu{bv,"slow progress."}
else
by.mvp=0
bu{bv}
end
end
if gp then
if by.i==0 then
sfx(0)
end
if gq==5 and rnd(10)>6 then
bu{bv,"poisoned!"}
by.st=bor(by.st,1)
end
else
db,dc=by.x,by.y
end
di=true
return db,dc
end
function fk(db,dc)
local fi=nil
if mget(db,dc)==31 then
for gw in all(ct.signs) do
if db==gw.x and dc==gw.y then
fi=gw.msg
break
end
end
end
return fi
end
function fh(gx,db,dc)
local bv,fj,gu="examine: "..gx,fk(db,dc),cw[db][dc][by.z] or nil
if fj then
bu{bv.." (read sign)",fj}
elseif gu then
bu{bv,gu.n}
elseif ct.dg then
bu{bv,gb(db,dc,by.z)<1 and 'passage' or 'wall'}
else
bu{bv,bi[mget(db,dc)]}
end
end
function fo(gy,db,dc)
local bv="dialog: "..gy
if bi[mget(db,dc)]=='counter' then
return ff(ez({x=db,y=dc}),fo,nil,gy)
end
local gz=cw[db][dc][by.z]
if gz then
if gz.mch then
bu{cc[gz.mch]()}
elseif gz.d then
bu{bv,'"'..gz.d[flr(rnd(#gz.d)+1)]..'"'}
else
bu{bv,'no response!'}
end
else
bu{bv,'no one to talk with.'}
end
end
function fg(fr,db,dc,fq)
local bv="attack: "..fr
local dd,de=by.z,cw[db][dc][by.z]
local gd=flr(rnd(by.str+by.lvl+by.dmg))
if fq then
gd+=fq
elseif by.i>0 then
bv="fire: "..fr
gd+=rnd(50)
end
if de and de.hp then
if fq or rnd(by.dex+by.lvl*8)>rnd(de.dex+de.ar) then
gd-=rnd(de.ar)
if fq then
de.hc={{9,6},{8,13},{10,12}}
else
de.hc=nil
end
de.hd=3
sfx(1)
de.hp-=gd
if de.hp<=0 then
by.gp=cd(by.gp+de.gp)
gg(de.exp)
if de.n=='pirate' then
cw[db][dc][dd]=bf{
f=de.f,
ot=bm
}
else
cw[db][dc][dd]=nil
end
bu{bv,de.n..' killed; xp+'..de.exp..' gp+'..de.gp}
if de.n=='faxon' then
msg=bb
_draw=dw
end
del(cy[cv],de)
else
bu{bv,'you hit the '..de.n..'!'}
end
if ct.fri then
for ha in all(cy[cv]) do
ha.hos=1
ha.d={"you're a lawbreaker!","criminal!"}
if ha.n=='guard' then
ha.mva=1
end
end
end
else
bu{bv,'you miss the '..de.n..'!'}
end
elseif mget(db,dc)==29 then
sfx(1)
if(not fq)gc(1)
if rnd(gd)>9 then
bu{bv,'you break open the door!'}
mset(db,dc,30)
else
bu{bv,'the door holds.'}
end
else
bu{bv,'nothing to attack.'}
end
end
function hb(hc,hd,he,hf)
local hg=abs(hc-he)
if ct.wrap and hg>ct.w/2 then
hg=ct.w-hg 
end
local hh=abs(hd-hf)
if ct.wrap and hh>ct.h/2 then
hh=ct.h-hh 
end
return hg+hh
end
function ez(de)
local hi,hj=ct.mxx,ct.mxy
local eh,ei=de.x,de.y
local hk,hl=(eh+ct.w-1)%hi,(eh+1)%hi
local hm,hn=(ei+ct.h-1)%hj,(ei+1)%hj
if not ct.wrap then
hm,hn,hk,hl=ei-1,ei+1,eh-1,eh+1
if de~=by then
hm,hn,hk,hl=max(hm,ct.mny),min(hn,hj-1),max(hk,ct.mnx),min(hl,hi-1)
end
end
return {hm,hk,hn,hl}
end
function ho()
local gothit=false
local hp=500
local db,dc,dd=by.x,by.y,by.z
for ed,de in pairs(cy[cv]) do
local hq,hr,hs,ht=de.f,de.x,de.y,de.z
if ht==dd then
while de.mva>=de.nm do
local ey=ez(de)
if de.hos then
local hu=0
hp=hb(de.x,de.y,db,dc)
local hv=hp
local hw=hv
for hx=1,4 do
if hx%2==1 then
hv=hb(de.x,ey[hx],db,dc)
else
hv=hb(ey[hx],de.y,db,dc)
end
if hv<hw or (hv==hw and rnd(10)<5) then
hw,hu=hv,hx
end
end
if hu%2==1 then
hs=ey[hu]
else
hr=ey[hu]
end
de.f=hu
else
if rnd(10)<5 then
if hq and rnd(10)<5 then
if hq%2==1 then
hs=ey[hq]
else
hr=ey[hq]
end
else
local hx=flr(rnd(4)+1)
de.f=hx
if hx%2==1 then
hs=ey[hx]
else
hr=ey[hx]
end
end
end
end
local gq=mget(hr,hs)
if ct.dg then
gq=gb(hr,hs,ht,1)
end
local hy=false
for bp in all(de.t) do
if gq==bp and de.mva>de.nm then
hy=true
break
end
end
de.nm+=1
if de.hos and hp<=1 then
local hz=by.dex+2*by.lvl
local ia="the "..de.n
if de.eat and by.fd>0 and rnd(de.dex*23)>rnd(hz) then
sfx(2)
bu{ia.." eats!"}
ge(flr(rnd(6)))
gothit=true
ib(9)
elseif de.th and by.gp>0 and rnd(de.dex*20)>rnd(hz) then
sfx(2)
local ic=min(ceil(rnd(5)),by.gp)
by.gp-=ic
de.gp+=ic
bu{ia.." steals!"}
gothit=true
ib(9)
elseif de.po and rnd(de.dex*15)>rnd(hz) then
sfx(1)
by.st=bor(by.st,1)
bu{"poisoned by the "..de.n.."!"}
gothit=true
ib(3)
elseif rnd(de.dex*64)>rnd(hz+by.ar) then
by.gothit=true
sfx(1)
local gd=max(rnd(de.dmg)-rnd(by.ar),0)
gc(gd)
bu{ia.." hits!"}
gothit=true
ib(3)
by.hd=3
by.hc=de.ac
else
bu{ia.." misses."}
end
break
elseif hy then
local gr=band(fget(gq),3)
de.mvp+=1
if de.mvp>=gr and not cw[hr][hs][dd] and not (hr==db and hs==dc and ht==dd) then
cw[de.x][de.y][de.z]=nil
cw[hr][hs][ht]=de
de.x,de.y=hr,hs
de.mvp=0
break
end
end
end
de.nm=0
end
end
return gothit
end
function dk()
local el=btnp()
if el~=0 then
coresume(du,ek(el))
end
if di then
di=false
dh+=1
if dh%500==0 then
ch(1)
end
if dh%50==0 then
ge(1)
end
if dh%10==0 then
by.mp=cd(min(by.mp+1,by.int*(by.lvl+1)))
end
if dh%5==0 and band(by.st,1)==1 then
gc(1)
sfx(1,3,8)
bu{"feeling sick!"}
end
gothit=ho()
if #cy[cv]<ct.mxm and rnd(10)<ct.newm then
fw()
end
end
end
function ib(id)
for ie=0,id do
flip()
end
end
function ig(ih)
local ii=flr(ih/16)*512+ih%16*4
if(fget(ih,7))then
for ij=0,448,64 do
reload(ii+ij,ii+ij,4)
fset(ih,band(fget(ih),64))
end
else
for ij=0,448,64 do
memcpy(ii+ij,ii+ij+4,4)
fset(ih,7,true)
end
end
fset(ih,2,true)
end
function ik()
local il,im,io=106,110,119
print("cond",il,0,5)
print(band(by.st,1)==1 and 'p' or 'g',125,0,6)
print("lvl",il,8,5)
print(by.lvl,io,8,6)
print("hp",il,16,5)
print(by.hp,il+8,16,6)
print("mp",il,24,5)
print(by.mp,il+8,24,6)
print("$",il,32,5)
print(by.gp,im,32,6)
print("f",il,40,5)
print(by.fd,im,40,6)
print("exp",il,48,5)
print(by.exp,il,55,6)
print("dex",il,63,5)
print(by.dex,io,63,6)
print("int",il,71,5)
print(by.int,io,71,6)
print("str",il,79,5)
print(by.str,io,79,6)
for ip=1,dp do
print(dn[(dq-ip)%dp+1],0,128-ip*8)
end
end
function iq(ir)
if ir then
for is in all(ir) do
pal(is[1],is[2])
end
end
end
function it(co)
local iu=false
if co.iseq then
co.iseq-=1
if co.iseq<0 then
co.iseq=23
if co.ia then
co.ia=false
if(co.fi==nil)co.i-=1
else
co.ia=true
if(co.fi==nil)co.i+=1
end
end
if co.fi then
iu=co.ia
end
end
palt(0,false)
iq(co.co)
return iu
end
function iv(x,y,iw,ix,iy,iz)
map(x,y,iw*8,ix*8,iy,iz)
for ja=x,x+iy-1 do
for jb=y,y+iz-1 do
local co=cw[ja][jb][0]
if co then
local iu=it(co)
local f=co.fm and co.f or 0
spr(co.i+f,(ja-x+iw)*8,(jb-y+ix)*8,1,1,iu)
pal()
if co.hd>0 then
iq(co.hc)
spr(127,(ja-x+iw)*8,(jb-y+ix)*8)
pal()
co.hd-=1
end
end
end
end
end
function gb(jc,jd,je,jf)
local blk=0
if jc>=ct.mxx or jc<ct.mnx or jd>=ct.mxy or jd<ct.mny then
blk=3
else
local ij=ct.l[je][jd]
ij=flr(shr(ij,(ct.w-jc)*2))
blk=band(ij,3)
end
return jf and (blk>1 and 20 or 22) or blk
end
function jg(jh)
local ji=jh[1]
jh[1]=jh[3]
jh[3]=ji
end
function jj(jc,jd,je,hx)
local jk={}
if hx%2==0 then
for jl=jd-1,jd+1 do
add(jk,{
blk=gb(jc,jl,je),
x=jc,
y=jl
})
end
if hx==4 then
jg(jk)
end
else
for jm=jc-1,jc+1 do
add(jk,{
blk=gb(jm,jd,je),
x=jm,
y=jd
})
end
if hx==3 then
jg(jk)
end
end
return jk
end
function jn(jc,jd,je,hx)
local jk={}
local jm,jl=jc,jd
if hx%2==0 then
for jm=jc+4-hx,jc+2-hx,-1 do
add(jk,jj(jm,jl,je,hx))
end
if hx==4 then
jg(jk)
end
else
for jl=jd-3+hx,jd-1+hx do
add(jk,jj(jm,jl,je,hx))
end
if hx==3 then
jg(jk)
end
end
return jk
end
function ex()
cls()
if by.lit>0 then
local jo=jn(by.x,by.y,by.z,by.f)
for jp,ij in pairs(jo) do
local jq,jr=(jp-1)*10,jp*10
local js,jt,ju,jv=30-jr,30-jq,52+jr,52+jq
local jw,jx,jy,jz,ka=30-jr*2,52+jr*2,42,31-jq,51+jq
if ij[1].blk==3 then
rectfill(js,js,jt,ju,0)
line(jw,js,js,js,5)
line(js,js,jt,jt)
line(js,ju,jt,jv)
line(jw,ju,js,ju)
end
if ij[3].blk==3 then
rectfill(jv,jt,ju,ju,0)
line(ju,js,jx,js,5)
line(jv,jt,ju,js)
line(jv,jv,ju,ju)
line(ju,ju,jx,ju)
end
if jp>1 then
local kb,kc,kd=jo[jp-1][1].blk,jo[jp-1][2].blk,jo[jp-1][3].blk
if (ij[1].blk==kc and ij[1].blk==3) or
(ij[1].blk~=kb) then
line(jt,jt,jt,jv,5)
end
if (ij[3].blk==kc and ij[3].blk==3) or
(ij[3].blk~=kd) then
line(jv,jt,jv,jv,5)
end
if kc==3 and kb==3 and ij[1].blk~=3 then
line(jt,jz,jt,ka,0)
end
if kc==3 and kd==3 and ij[3].blk~=3 then
line(jv,jz,jv,ka,0)
end
end
if ij[2].blk==3 then
rectfill(js,js,ju,ju,0)
line(js,js,ju,js,5)
line(js,ju,ju,ju)
if ij[1].blk<3 then
line(js,js,js,ju)
end
if ij[3].blk<3 then
line(ju,js,ju,ju)
end
end
ke(ij[2].x,ij[2].y,by.z,3-jp)
end
rectfill(82,0,112,82,0)
end
ik()
end
function ke(db,dc,dd,kf)
if db>0 and dc>0 then
local co=cw[db][dc][dd]
if co then
local iu,kg,shm,szm=it(co),kf*3,co.shm or 0,co.szm or 0
local kh,ki=20+kg+(szm*(kf+1)/8),35-(3-kf)*shm
local kj=60-szm-kg*4
sspr(co.i%16*8,flr(co.i/16)*8,8,8,kh,ki,kj,kj,iu)
pal()
if co.hd>0 then
palt(0,true)
iq(co.hc)
sspr(120,56,8,8,kh,ki,kj,kj)
pal()
co.hd-=1
palt(0,false)
end
end
end
end
function dw()
cls()
print(msg)
end
function dl()
local hi,hj,kk,kl=ct.mxx,ct.mxy,ct.mnx,ct.mny
local iy,iz,wrap=ct.w,ct.h,ct.wrap
local km,kn,ko,kp,iw,ix,kq,kr=0,0,0,0,0,0,by.x-ba,by.x+ba
if kq<kk then
ko=kk-kq
iw=ko
if wrap then
km=kq%iy+kk
end
kq=kk
elseif kr>=hi then
if wrap then
ko=y-kr+hi-1
iw=ko
km=kq
kq,kr=kk,kr%iy+kk
else
ko=kr-hi+1
kr=hi
end
end
local ks,kt=by.y-z,by.y+z
if ks<kl then
kp=kl-ks
ix=kp
if wrap then
kn=ks%iz+kl
end
ks=kl
elseif kt>=hj then
if wrap then
kp=x-kt+hj-1
ix=kp
ix,kn=kp,ks
ks,kt=kl,kt%iz+kl
else
kp=kt-hj+1
kt=hj
end
end
local ku,kv=min(y-ko,ct.w),min(x-kp,ct.h)
if dj%16==0 then
for ih=10,14,2 do
ig(ih)
end
end
dj+=1
cls()
if wrap then
if ko then
iv(km,ks,0,ix,ko,kv)
end
if kp then
iv(kq,kn,iw,0,ku,kp)
end
if ko and kp then
iv(km,kn,0,0,ko,kp)
end
end
iv(kq,ks,iw,ix,ku,kv)
palt(0,false)
if by.color==4 and by.i==0 then
iq{{4,1},{15,4}}
end
spr(by.i+by.f,48,40)
pal()
palt()
if by.hd>0 then
iq(by.hc)
spr(127,48,40)
pal()
by.hd-=1
end
ik()
end
__gfx__
600ff000000003000000040000000600000000000000000000330000000005000005500000006000000000000000000000000000000000000000111011100000
600ff550030000000400000006000000000300000100100003333000005050500050050000066600000898000008a90001000101101010000011010001000011
60985555000000000000000000000000003330000033000003333330050500050050005000d00600008089000080980010101010010101011100001000101100
68895555000300000004000000060000000300300000000000330333500050000500000505000d00050500800508008000010000000000100000000000000000
f8999550000000030000000400000006000003330000100103003333000505005000550005050050050000500500005000000000000000000001110011000001
00909550000000000000000000000000003000300000033033330330005005005005005050005050505000055050000501000101101010000110100010000110
00400400000030000000400000006000033300001001000033330000050000500050000500005005000000050000000510101010010101011000010101011000
04400440300000004000000060000000003000000330000003300000000000000000000000000000000000000000000000010000000000100000000000000000
6660666088808880555055506660666055005550550055500000050055555555cccccccc44000044000000005545545555555555555555555555555500000000
000000000000000000000000000000005550555055505550050000005d0d0d05c000000c44444444004004000044440054444405544444055400000500055000
606660668088808850555055606560665055505550555055000000005d0d0d05c000000c00000000004444000040040054444405544444055400000504444440
000000000000000000000000000000000055505500505055000500005d0d0d05c000000c00000000004004000044440054444405544444055400000507777770
666066608880888055505550666066605550555055555550000000055d0d0d05c000000c00000000004444000040040054449405544494059490000507777770
000000000000000000000000000000005550055555500555000000005d0d0d05c000000c00000000004004000044440054444405544aa4055400000507777770
606660668088808850555055606660665055505550555055000050005d0d0d05c000000c44444444004444000040040054444405544444055400000500055000
0000000000000000000000000000000000550000005500005000000055555555cccccccc44000044554554550000000054444405544444055400000500055000
0060060000050500080000800051150000000000000040000077750000c01c005555555555555555555555555555555555555555555555555555555555555555
006006000050505086000068000550005505505500044400075007500c17c7100006600006666600006666000666660006666660066666600066660006000060
05600650550000500677776000055000666666660004250007500750010c70c00060060006000060060000600600006006000000060000000600006006000060
655005560004400506666660005555006566665600052400007575000c07c0100600006006666600060000000600006006666000066660000600000006666660
65666656004004000677776000555500656556560400444000075000010c70c00666666006000060060000000600006006000000060000000606666006000060
656556560540045066744766005445006664466644404240077777506c07c0160600006006000060060000600600006006000000060000000600006006000060
6060060650400400667447660154451066644666424042400007500066cccc660600006006666600006666000666660006666660060000000066660006000060
00600600004004006774477601544510000000004240000000075000566666655555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
06666600066666000600060006000000066006600600006000666600066666000066660006666600006666000666660006000060060006000600006006000060
00060000000060000600600006000000060660600660006006000060060000600600006006000060060000000006000006000060060006000600006000600600
00060000000060000666000006000000060000600606006006000060060000600600006006000060006666000006000006000060006060000600006000066000
00060000000060000600600006000000060000600600606006000060066666000606006006666600000000600006000006000060006060000060060000600600
00060000060060000600060006000000060000600600066006000060060000000600606006000060060000600006000006000060000600000066660006000060
06666600006600000600006006666600060000600600006000666600060000000066660006000060006666000006000000666600000600000060060006000060
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555550011110000111000007270000002067000666000076020000004400000ff004000ff04000088aa000088aa00
06000600066666600000000000000000006600000100001001000100667276600067767077777770076776000004400400ff0404f0ff4040000770277e077000
060006000000060000000000000000000600600010000001100101006662666006770020777777700200776000eeeeee066660046666604000e772200ee77200
00606000000060000666666000000000006600001001100110100101677277600677067777777770776077604eeeee006666666f666666f00eee220000ee2220
00060000000600000000000000000000060060601010010110011001677277600067767077747770076776000e666600f0660664006666407e0b9000000b9027
000600000060000000000000000000000600060000101001100000010772770040020677066466007760200400600600006600040066004000bb99900bbb9900
000600000666666000000000000000000066606000100010010000100444440004444444044444004444444000600600006660040666604000b000ccdd000900
55555555555555555555555555555555555555550001110000111100004440000044444000444000044444000110011006666604066660400dd0000000000cc0
000ff00000044000600ff000000ff000402222004022220000011006000110000002200500022000000ff000000ff00000000000044444400d000dd00000dd00
600ff00000044004600ff550000ff000400ff200402ff00f600ff00f000ff000000ff00f000ff000000ff000f00ff00f0444444044a44a44d000dd00d00dd00d
5999990600d22d4460ee555500eee550402222204022222260111110f111110600111110f111110500cccc00ffccccff44444444444664440d0ddd0dd0ddd0d0
5099999504dddd006eee5555feee5555f222222240222222f11110006011111ff11110000011111f0fccacf000ccac0044466444455555540d0dd00dd0dd00d0
00099005044dd000fe1115506e1155554222220ff2222200010110006001100001011000000110000ffccff0000cc00055555555511111150d7d7dd00d7d7d00
00111000000dd0000010155060101550402222004222220000111100001111000088880000888800000cc000000cc000444444444444444400ddd00000ddd00d
0010110000dddd000040040060400550402222004022220000100100001001000040040000400400005005000050050044444444444444440d00d000dd00d0d0
044004400dddddd0044004400440044040222200402222000110011001100110044004400440044005500550055005500000000000000000d0000dd00dd00d00
40033000000330000006600000066000000550000005500040033000000330004003300000033000000000000000000000000000000000000858858000588500
40033000000330034006600000066006400550000005500540133100001331064003300000033003000000000500005000004440044400008808808808088080
43455430034554334000000000000060400110000001105043155130331551334350053033500533050000500500005000004004400400008845548888455488
33544533335445304056650006566500405115000551150033511533435115303355553343555530056006505560065500444400004444008848848888488488
00044003400440000600006040000000050110504001100000011006400110000005500340055000566556655065560504555440044555408808808888088088
00344300403443000006600640066000000110054001100000411400404114000035530040355300565885655658856505858540045858508854458888544588
003003004030030000500500405005000010010040100100004004000040040000300300003003000605506006055060045e54400445e5408080080888400488
03300330033003300650056006500560055005500550055004400440044004400330033003300330000000000600006000400400004004000880088084400448
0000000000000000000000000000000000100390001000930dd0dd0012001200000000000b0bb0b00003300000055000b0033000000088800066650000000000
0000000000000000400330000003300010000333100003330dd0dd000120201200000060b3bb703b003333000050050030355300000550080086850000900900
00bb008b00b00b804003300000033003000100330001033000ddd5000022220000600676b38b033b033b33306050050005333350005225006055550609088090
0b00b0b00b0b00b0431111300311113301033033013303300d5dd5d002277220067600609aa33b3b03333b3355555555008338030058850055065055008aa800
0b00b0b00b00b0b033511533335115300033330303333030d00dd00d0278872000600600aa13bb3b33b33333555555560535530b0505508060065006008aa800
00b00bb0b000bb00000110034001100000333303033330300011100d02277220000067609313313b33333b3050555505b0355350080008880056550009088090
000b00000b00000000311300403113000333330333333030011011000022220000000600b013310b033b3300005555000035530b888008080050050000900900
00000000000000000330033003300330033333033333303044000440000000000000000003311330000330000555555000355300808000000550055000000000
c0c0c0c040404040101010604040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c010100111015050110111111111111101110111111111110111101001110110104161616161616161614141415141d141
c0c0c0c0c0c040406060604040404040c0c0c0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101111111111111011101111111111101111010011101101041616161616161616141616161616141
e0e0c0c0c0c0404040606060104040c0c0e0e0e0e0e0e0e0e0c07070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101111111111111011101111111111101111010011101101041616161616161616141614141414141
e0e0e0c0c0c01040104040404040c0c0e0e0e0e0e0e0e0e0e0c0105270c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110150501101010101110101011101010111010101111010011101101041616161616161616171616161616141
e0c0c0c0c0c0c0424010404040c0c0e0e0e0e0e0e0e0e0e0e0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111111111111111111111111111111111111111111111011101101041614141414141714151414141416141
c040c0c0c0c0c0104010106010c0c0e0e0e0e0e0e0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111010101010101111010101010101011010101010111011101101041616161616141616161416161616141
c06040c0c0c0c0c04040104010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101111111110111104010c01040101101b3c3d20111011101101041414141416141616161516141414141
c04040c0e0e0c0c040401010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01010011101110192c2825301111010c0c0c0101011011111110111011101101041616161616171616161416161616141
c0c0c0e0e0e0e0c0c01010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01010011101110111111111011110c0c061c0c01011018293430111011101101041614141414141414171414141416141
e0c0c0e0e0e0e0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111101111010c061c010101101111111011101110110104161616141b141616161616161616141
e0e0e0e0e0e0e0e0e0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0c080a080c0c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101111111110111104010611040101111111111011101110110104141414141414141d141414141414141
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0e0c070807070c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111111111010106110101011011111110111011101101001010101010101010101010101010101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080a080c07070328070c0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111011111111101111111111111111111011111110111011101101001111111110111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0c070808070c0e0e0e0c0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010100111011101a3b363730111111111111111111101111111011101110110100192c2c293011101148253b2c293a301
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0e0c07070c0e0e0e0c080c0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111010101010101110111111111110111010101c1011101110110100111111111c111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0e0e0e0c080a080
c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101001110111111111111111110111111111110111111111111111011101101001111111110111011111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c080c0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100101110101010110101010100111111111110110101010100101011101010101f282c3a3011101010101c101010101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100111111111110110101010108111111111118110101010100111111111110101010101010111111111111111111101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0100111111111110101010101010111111111110101010101010111111111110101111111111111110101010101011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e010811111111111111111111111d11111111111d111111111111111111111118101110101810101110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001111111111101010101010101111111111101010101010101111111111101011101c0c0c0011101e26363b2011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001111111111101101010101001111111111101101010101001111111111101011181c062c081110111111111c11101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e01001010181010101101010101010111111111110101010101001010181010101011101c061c001110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101010101010101010101010101011111111111010101010101010101010101001110101c10101110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e02020202020404060606001538253a204349293c2e3a30140401041104110404001111111111111110111111111011131
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c0c0c0c0c03080807080303030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0202020202020404010600111111111111111111111110140104141104141104001111111601111110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0808070707070c0c0c0c080803090128030903030c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e06161616161206110404001c282b3344434b2930353230110104141104141101001111160406011110111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0807070908090807070c0c070808080709080803030c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e061616161616161404040011111111111111111111111014110411010104110410111604010406011c111111111011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0803090809080308070c0c0c07080809070803030c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e02020202020616120202001111111111111111111111101411010101010101041011111604060111101c282b3a3011101
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c03030707030307070c0c0c0c0c0c080808030c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e020202010202061612020010101010101c101010101010141104110101041104101111111601111110101010101011101
e0e0e0c0c0c0c0c0c0c0c0c0c0e0c0c0c0c0c0c03080307070c0c080808070c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0202010101020206161612020202040406140402020202040404110101041404001111111111111111111111111111101
e0e0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0703090308070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0
e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0101010101010102020616161616161616120202020202010404110101041401001010101010111111101010101010101
__gff__
0000000001010201020303830484048408000800080000080800000008080000000000000000080008080808080808080808080808080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0e0c0c0c0c0c0c0c0c0c0c060c0e0e0e0e0c0c0c0c0e0e0c0c0c0803030303080e0e0e0e0e0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10101010101010101010101010101010101010101010131010101010101010101010101010101010100c101010101010
0c0606060506060707070606040c0e0e0e0c06060c0c0c0708080809030809080c0e0e0e0e0c0707070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100101010101010101010101010101010101010101010404101111111110040101010401103a2c28100c0c0101013410
0c04040605050708080808070c0c0c0e0c0c0606040104080809090303090908070c0e0e0e070303030707040c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101810100101011010101010101010101010101004102839343a1001040104040410111111100c0c0c01012810
0c01040406070808080908070c04040c0c0c040101010107080909030309030308070c0c0c0407030303030704050c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001100c0c0c10010101101111111111111111111111100110111111111004040101040410373c2910020c0c0c013910
0c01010404040707070808010c24010c0124010104040707070807090903080807070c0404040407040407040505050c0c06040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001180c260c18010101102e36362b433235302e2f3b100110111111111c111111111104101111111d02020c0c0c3010
0101010104040404070801010101010c010101010101040707070807080807072107070401040406040404040605050c0606060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c041001100c160c1001010110111111111111111111111110011010101010100101010111041011111110020202020c3510
0c0c010101010104070101010101010c010101010101010404070704060707070607060401010606060606040606050c0620060c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100110101610100101011011111111111111111111111001100101010101010101011101101111111002020202022810
0c0c0c0c010101010101010101010c0e040401010101010404010404040606060606060601010504060606060605050c060606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c10010101010101010101101111111111111111111111100110010101010101010101110110101c10101810181d181010
0c01010107010604040401010c0c040c0404060406040101040401010404060606060606040505050404060605050c0c040606040c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110101010100101011011111010101010101010101001101010101010101001011111111111111111111111040410
0c010107070704040606040c0604040c0c0406060601010101010401010104040606040401050c0c050505050c0c0c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c1001101111111001010101111101010101010101010101011011111111111110010111040101010101010101011f0410
0c010708080701060606040c06040c0c010c0606010101010101010101040404040606010405050c0c0c050c0c050c04040406040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110434343100101011111110101010101010101010101102e39362a2c391001041104010101010101010101010110
0c0c01082108070104060606040c0c0c01010c010101010101010101010c04040404040401050505050c0c0c05050c0c0406040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100110111111100101111111010101010101010101010101101111111111111c11111111010110101010101010101010
0e0c0c0c07070c0c01040401010c0e0c010101010101010101010c0c0c0c0c0c0c05040404050505050505050505050c0404040c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100118111111180101111101011010101010101010101001101111111111111001010411010110111111111111111110
0e0e0e0c0c0c0c0c0c01010c0c0c0c0c0c01010101010104040c0c0c0e0e0c0c0c050505040505050505050505050c0c04040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1001101111111001111111010110111111111111111110011011111111111110010101110104102f363a37303b283310
0e0e0e0c0c0c0c05050101010c0505050c0c01010104010404040c0c0c0e0e0c0c0c050505050505050505050c0c0c0404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10011011111110011111010101102d36362b3428393b1001101010101010101001010111040410111111111111111110
0e0e0c0c07070505040101050504040405050c05050101010404040c0c0c0c0c0c0c0505050505050505050c0c01010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e10011011111111111111010101101111111111111111100110010101010101010101011111111c111111111111111110
0e0c0c070707070404010505040404040101050101010101010101010c0c0c0505050505010101010505050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e100110111111111111110101011011111111111111111001100101010101040601010111040410111111111111111110
0c010707080804040101010101010101010101010101010101010601010101010505050101010c0c0c0c050c0c010407070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e1001101111111001111101010110101010101111101010011001010106040104010101110401101c10101c10101c1010
0c0707080804010101070707070101010101010101010106040401040401060406010101010c0c01010c0c0c010107070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100110342c2b100111110101010101010101111101010101100101010401010106010111010110111110111110111110
0c0c08060401010107070202020707070707070101040606060604060606060404010101010c01010101010101220c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c1001101010101001111111111f1111111111111101010101100101060401040401010111110110111110111110111110
0c0c06080601040702020202020202020202070707040406060606060606040606010101011901010106040407070c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c100101010101010101111111111111111111111101010101100101010404060101010404110410101010101010101010
0c0c0c060401080702020202020202020202020207040404060606060404040404010101010c010106060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100401010101010101010411111104010101010101010104100101010101010101040404110404010101010101040110
0c0c0c040101010702020202020202020202020208040404060604040406060c0c04040c0c0c0404060404070c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c100404010101010101040411111104040101010101010404100101010101010101040411111104040101040401010110
0c0c0c01010104040702020202020202020202020704060606040406040606060c0c0c0c040606060404070c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101010101010101010100411111104101010101010101010101010101010101010101011111110101010101010101010
0c0c010101040408040702020202020202020707040404060c01060606040604040404040606060c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101010181010100101010101010101010101010101010101011010101810101014141414141414141414141414141414
0c01010101010404040407070707080807070704040404060c01010606010106060101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101111111111101010101010101010101010101013101010101011111111111014161616161616161614161616161614
0c0c0c0c06040601010406060404070707040505050404040c0c010101010101010c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c10111111111111111111111111111111111111111111111111111111111111101416161616161616161416161b161614
0707010c0404010101040406060404040404050505050c04040c0c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c181111111111101010101010101010101010101010101010101011111111111814161616161616161614161616161614
082001190101010101060401010c0c0c050505050c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c101111111111101111111111111111111111111111111111111011111111111014161616161616161614161616161614
0701010c0c0c0c0101040401010c0c0c0c0c0c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101111111111101110101010101010101110101010101010111011111111111014161616161616161614161616161614
0704010c0101010c0104060101040c0c0c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c101010111010101110111111111111101110111111111110111010101110131014161616161616161614161616161614
0c040c0c040101010101010101040c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0101101113050511102b2c2d2c353a101110342c2b302a10110101101110010114161616161616161617161616161614
__sfx__
000100002365024650206501e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000245202a6403075034660367703667034770326602f6602d75029650297502a640296402b7402c6502e6502f7502f6502d640296302563022720000000000000000000000000000000000000000000000
0001000017070160601505016050170501a06021060290702f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000276432f4732f4732f4732f4732f4732f4733b1733b2733b2733b2733b2733b2733b2733b2733b2733b2733b2333851500000000000000000000000000000000000000000000000000000000000000000
0002000002643024730347305473074730a4730d47311173162731b2731f27324273292732d27331273362733b2733e2333f51500000000000000000000000000000000000000000000000000000000000000000
000100001263113341164511335117451133511544111341144310e331114210b3210c411073110a41104611236001f6002f50029500235001e5001e500225002750029500255001f5001e500000000000000000
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420
01200000134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201342013420134200e4200e4200e4200e420134201542016420184201a4201a4201a4201a420
01200000184201842018420184201142011420114201142016420184201a4201b4201d4201d4201e4201e4201f4201f4201f4201f420184201842018420184201a42016420154201342015420134201542013420
0120000013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4201a4201a42013420134201a4201a4200e4200e4200e4200e420
012000000c4200c420114201142016420164201742017420184201a4201c4201e4201f4201f4201d4201d4202042020420204202042021420204201e4201c4201e4201e4201e4201e42020420204202642026420
0120000025420214201c420214201942019420194201942024420214201c4202142018420184201842018420234201f4201a4201f42017420174201742017420224201f4201a4201f42016420164201842018420
012000000c4200c420114201142016420164201742017420184201a4201c4201e4201f4201f4201e4201e4202042020420204202042021420204201e4201c4201e4201e4201e4201e42020420204202642026420
012000001f4201f42013420134201a4201a4200e4200e420134201342013420004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
01200000004000040000400004000040000400004000040000400004000040000400004000040000400264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202b4202d4202e4202e4202d4202e42030420304202e420304203242032420304202e4202d4202d420
012000002e4202d4202b4202b4202d4202b4202a4202a4202b4202d4202b4202b420264202642026420264202b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d42030420
012000002e4202d4202b4202e4202d4202d4202a4202a4202b4202b4202642026420244002440026420264202d4202b4202d4202b4202a4202a420334203342032420324202e4202e4202e4202a4002e4202e420
01200000304202e420304202e4202d4202d420334203342032420324202e4202e4202e4202e4202d4202d4202e4202e4202b4202b420294202942027420274202642026420264202642029420294202942029420
012000002b4202d4202e4202b4202d4202e420304202d4202e4202e4203242032420304202e4202d420304202e4202d4202b4202e4202d4202d4202a4202a4202b4202b420264202642000000000002642026420
012000002b4202d4202e4202e4202d4202e42030420304202e420304203242032420304202e4202d4202d4202e4202d4202b4202b4202d4202b4202a4202a4202b4202d4202b4202b42026420264202642026420
012000002742026420244202442026420264202642026420284202642024420244202642026420274202742028420284202f4202f420314202f4202d4202c4202d4202d4202d4202d4202f4202f4202c4202c420
012000002d420284202542028420214202142021420214202d420284202442028420214202142021420214202b4202642023420264201f4201f4201f4201f4202b4202642022420264201f4201f4201e4201e420
012000002742026420244202442026420264202642026420284202642024420244202642026420274202742028420284202f4202f420314202f4202d4202c4202d4202d4202d4202d4202f4202f4202c4202c420
012000002b4202d4202e4203042032420334203642032420374203742037420320001800022000210002100022000210001f0001f000210001f0001e0001e0000000000000000000000000000000000000000000
01200000220051a0051f005220051a0051f005210051e005000000000000000000000000000000000000000022420264202b42022420264202b4202d4202a4202b4202b4202e4202e4202d4202b4202a4202d420
012000002b4202b42026420264202a4202a42024420244202242026420214201f4201a4201b4201e420244202a420284202a42028420264202642030420304202e4202e4202b4202b4202b4202b4002b4202b420
012000002d4202b4202d4202b420294202942030420304202e4202e4202942029420294202942026420264202b4202b4202742027420214202142024420244202242022420224202242021420214202142021420
0120000022420264202b4202e420264202b4202d4202a4202b4202b4202e4202e4202d4202b4202a4202d4202b4202b42026420264202a4202a4202442024420224201a420224201f4201a4201b4201e42024420
012000002442022420214202142022420224201f4201f420244202342021420214202342023425234202342523420234202342023420284202842028420284002842028420274202742028420284202842028420
01200000284202542021420254201c4201c4201c4201c420284202442021420244201c4201c4201c4201c42026420234201f420234201a4201a4201a4201a42026420224201f420224201a4201a4251a4201a420
0120000022420214201f42022420214201f4201e420214201f4201f4201f420000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800000942009420104201042015420154201042010420114201142011420114200000000000000000000009420094201042010420154201542018420184201c4201c4201c4201c42000000000000000000000
011800000942009420104201042015420154201042010420114201142011420114200000000000000000000010420104201142011420104200e4200c4200b4200942009420094200942000000000000000000000
01180000000001a4201a42021420214202642026420214202142022420224202242000000000000000000000000001a4201a420214202142026420264201d420294202d4202d4202d42000000000000000000000
01180000000001a4201a420214202142026420264202142021420224202242022420000000000000000000000000021420214202242022420214201f4201d4201c4201a4201a4201a42000000000000000000000
01180000000000942009420104201042015420154201042010420114201142011420000000000000000000000000009420094201042010420154201542018420184201c4201c4201c42000000000000000000000
01180000000000942009420104201042015420154201042010420114201142011420000000000000000000000000010420104201142011420104200e4200c4200b42009420094200942000000000000000000000
011800002442024420244202442024420244202442024420214202142021420214200040000400004000040024420244202442024420244202442024420244201f4201f4201f4201f4201c000000000000000000
011800002442024420244202442024420244202442024420214202142021420214200000000000000000000020420204202042020420234202342023420234202442024420244202442000000000000000000000
01180000244202442028420284202d4202d420284202842027420274202742027420000000000000000000002142024420284202c4202d4202b42028420284202b4202b4202b4202b42000000000000000000000
011800002442024420284202842024420244202842028420294202942029420294200000000000000000000028420264202842024420264202442026420234202142021420214202142000000000000000000000
0118000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d4200000000000000000000021420214201c4201c420214202142024420244202842028420284202842000000000000000000000
0118000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d420000000000000000000001c4201c4201d4201d4201c4201a42018420174201542015420154201542000000000000000000000
011800000000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d4200000000000000000000015420154201c4201c4202142021420244202442028420284202842028420000000000000000
011800000000015420154201c4201c42021420214201c4201c4201d4201d4201d4201d420000000000000000000001c4201c4201d4201d4201c4201a420184201742015420154201542015420000000000000000
01180000000003542035420394203942032420324203942039420364203642036420364000000000000000000000032420354203b4203142032420314203b4203b42030420304203042030400000000000000000
011800000000035420354203942039420324203242039420394203642036420364203640000000000000000000000394203742039420354203742035420374203442032420324203242032400000000000000000
011800000000024420244202442024420244202442024420000002142021420214200000000000000000000000000244202442024420244202442024420244200000020420204202042000000000000000000000
011800000000024420244202442024420244202442024420000002142021420214200000000000000000000000000204202042020420234202342023420244202442024420244202442000000000000000000000
011800003441034410344103441034410344103441034415334103341033410334100000000000000000000034410344103441034410344103441034410344153441034410344103441000000000000000000000
011800003441034410344103441034410344103441034415354103541035410354100000000000000000000034410344103441034410384103841038410384103941039410394103941000000000000000000000
01180000344103441039410394103c4103b410394103941539410394103941039410000000000000000000003041034410394103b4103c4103b41039410394103b4103b4103b4103b41000000000000000000000
01180000344103441039410394103c4103b410394103941539410394103941039410000000000000000000003c4103b4103c410394103b410394103b410384103941039410394103941000000000000000000000
011800001c4101c41023410234102841028410234102341024410244102441024410000000000000000000001d4101d410234102341028410284102b4102b4102f4102f4102f4102f41000000000000000000000
011800001c4101c41023410234102841028410234102341024410244102441024410000000000000000000002341023410244102441023410214101f4101e4101c4101c4101c4101c41000000000000000000000
01180000000002d4102d41034410344103941039410344103441035410354103541035410000000000000000000002d4102d410344103441039410394103c4103c41034410344103441034410000000000000000
01180000000002d4102d4103441034410394103941034410344103541035410354103541000000000000000000000344103441035410354103441032410304102f4102d4102d4102d4102d410000000000000000
011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001050012500195002050024500000000e50011500165001b500235002a50000000000000c5000e500155001d50022500255000000000000095000c50011500175001d5002450029500000000000000000
__music__
00 06 11 43 44
00 07 12 43 44
00 08 13 43 44
00 09 14 1d 44
00 0a 15 1e 44
00 0b 16 1f 44
00 0c 17 20 44
00 0c 18 20 44
00 0d 19 21 44
00 0e 1a 22 44
00 06 17 43 44
00 0c 17 20 44
00 0d 1b 21 44
00 0e 1a 22 44
00 06 18 20 44
00 0c 18 20 44
02 10 1c 23 44
01 24 42 43 44
00 25 42 43 44
00 24 2a 36 44
00 25 2b 37 44
00 24 2c 38 44
00 25 2d 39 44
00 24 2e 3a 44
00 25 2f 3b 44
00 24 30 3c 44
00 25 31 3d 44
00 26 32 43 44
00 27 33 43 44
00 28 34 43 44
02 29 35 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
