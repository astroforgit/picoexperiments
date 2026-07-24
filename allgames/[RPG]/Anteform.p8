pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- anteform
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
if(not d(c,"-0123456789.")) return tonum(m),i
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
bb="\n\n\n\n\n\n  congratulations, you've won!\n\n\n\n\n\n\n\n\n\n    press p for game menu,\n anything else to continue and\n      explore a bit more."
bc="\n\n\n\n\n\n      you've been killed!\n          you lose!\n\n\n\n\n\n\n\n\n\n\n\n    press p for game menu"
bd="anteform commands:\n\na: attack\nc: concentration action\nd: dialog, talk, buy\ne: enter, board, mount, climb,\n   descend\np: pause, save, load, help\nf: use flashlight; force chest\ns: sit & wait\nw: wearing & wielding\nx: examine, look (repeat to\n   search or read)\n\nfor commands with options (like\nconcentrating or buying) use the\nfirst character from the list,\nor anything else to cancel."
msg=bd
be={f=1,mva=0,nm=0,mvp=0,hd=0,ch=0,z=0}
function bf(bg,bh)
return setmetatable(bg,{__index=bg.ot or bh})
end
bi={"plains","bare ground","hills","scrub","swamp","forest","foothills","mountains","tall mountain","filing cabinet","bed","water","water","deep water","deep water","bridge","brick road","brick","mismatched brick","stone","stone","road","barred window","window","brick","ladder down","ladder up","door","locked door","open door","sign","crater","cave","facility","monastery","cabin","village","helipad","fountain","chair","desk"}
for bj=1,31 do
add(bi,"counter")
end
bk={}
for bj=1,38 do
add(bk,{})
end
bl=o('[{"gp":0,"hp":10,"ch":1,"dmg":13,"t":[1,2,3,4,5,6,7,8,10,16,17,26,27,30,31,32,38,40,41],"hos":1,"ar":1,"dex":8,"exp":2,"mva":1},{"mny":0,"newm":0,"mxm":0,"mxy":64,"fri":1,"mxx":128,"mn":0,"mnx":80},{"sf":1,"fri":false,"dg":1,"mnx":1,"mxm":27,"mxy":9,"newm":25,"mxx":9,"mny":1,"sy":1,"sz":1,"mn":0,"sx":1},{"i":70,"p":1,"ia":70,"n":"boat","fm":1,"f":2},{"i":94,"p":1,"ia":94,"n":"chest","szm":11,"shm":-2},{"i":39,"p":1,"iseq":12,"fi":1,"n":"fountain"},{"i":27,"p":1,"ia":27,"n":"ladder up","szm":20,"shm":12},{"i":26,"p":1,"ia":26,"n":"ladder down","szm":20,"shm":-3},{"i":80,"ar":0,"exp":1,"gp":10,"hos":false,"t":[1,2,3,4,11,17,22,30,40]},{"i":104,"hp":23,"ch":0,"dmg":18,"t":[1,2,3,4,5,6,7,8,9,10,16,17,22,26,27,30,31,32,38,40,41],"ar":3,"po":1,"d":["chirp chirp!"],"exp":9},{"i":102,"gp":10,"d":["ahhrg!"],"ch":0,"dmg":18,"n":"zombie","exp":8,"t":[1,2,3,4,5,6,7,8,9,10,16,17,22,26,27,30,31,32,38,40,41]},{"exp":5,"ch":2},{"i":82,"cs":[{},[[4,5],[15,4]]],"n":"hunter","d":["the woods are scary now.","i\'m safer at home."]},{"i":90,"ar":12,"hp":85,"dmg":60,"cs":[{},[[15,4]]],"n":"cop","d":["thanks for your help.","this is beyond my ability."]},{"i":77,"fi":1,"n":"merchant","cs":[{},[[1,4],[4,15],[6,1],[14,13]],[[1,4],[6,5],[14,10]],[[1,4],[4,15],[6,1],[14,3]]]},{"i":81,"fi":1,"n":"lady","cs":[{},[[2,9],[4,15],[13,14]],[[2,10],[4,15],[13,9]],[[2,11],[13,3]]]},{"i":92,"n":"scientist","cs":[{},[[6,12],[15,4]],[[6,12]],[[15,4]]]},{"i":78,"n":"sunbather","fi":1,"cs":[{},[[8,12],[15,4]],[[8,12]],[[15,4]],[[8,14]]],"d":["i saw the weirdo!","i\'m glad we\'ve got locks."]},{"i":79,"cs":[{},[[8,12],[15,4]],[[8,12]],[[15,4]]],"fi":1,"n":"bodybuilder","d":["weird stuff up north.","we\'re vacationing indoors."]},{"i":84,"n":"monk","d":["you are welcome here.","though we are troubled."],"ac":[{},[[2,5],[15,4]],[[2,4]],[2,5]]},{"i":86,"n":"student","cs":[{},[[15,4]],[[1,2],[15,4]],[[1,2]]]},{"i":75,"n":"child","cs":[{},[[15,4]],[[11,14],[3,8],[15,4]],[[11,14],[3,8]]],"d":["the animals aren\'t right.","mom says stay inside."]},{"i":88,"cs":[{},[[1,5],[8,2],[4,1],[2,12],[15,4]]],"n":"citizen"},{"mch":"food","n":"grocer"},{"mch":"armor","n":"clerk"},{"mch":"weapons","n":"vendor"},{"mch":"hospital","n":"medic"},{"mch":"guild","n":"dealer"},{"i":81,"n":"bartender","mch":"bar"},{"i":100},{},{"n":"woods weirdo","ch":-1,"t":[6]},{"n":"worker ant"},{"i":110,"n":"winged ant","t":[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,22,25,26,27,30,31,32,38,40,41]},{"i":118,"hp":64,"dmg":23,"n":"soldier ant","exp":12},{"i":125,"n":"queen ant","hp":235,"dmg":42},{"i":123,"exp":5,"mva":0,"hp":10,"dmg":5,"fi":1,"n":"ant larva","t":[22]},{"i":124,"n":"ant eggs","hp":5,"ia":124},{"i":106,"gp":8,"hp":5,"po":1,"exp":4,"n":"large spider"},{"i":108,"gp":2,"hp":4,"dmg":9,"t":[1,2,3,4,5,6,7,8,10,16,17,22,26,27,30,31,32,38,40,41],"po":1,"n":"large rat","exp":2,"eat":1},{"i":96,"n":"coyote","ch":3,"d":["grrr!"]},{"i":120,"n":"lynx","ch":3,"d":["grar!"]},{"i":112,"hp":7,"po":1,"dmg":9,"ch":1,"ns":["snake","serpent"],"t":[4,5,6,7]},{"i":114,"n":"rattlesnake","exp":6,"po":1},{"i":116,"hp":20,"exp":7,"n":"large eel","t":[5,12,13,14,15,16]},{"i":95,"hp":8,"po":1,"fi":1,"ch":1,"n":"scorpion"},{"i":122,"gp":10,"eat":1,"fi":1,"exp":2,"cs":[{},[[3,9],[11,10]],[[3,14],[11,15]]],"n":"slime","t":[22,23]},{"i":98,"hp":25,"exp":9,"ns":["big catfish","sturgeon"],"t":[12,13,14,15,16]}]')
bm=bl[4]
for bn=1,#bl do
local bh
local bo=bl[bn]
if bn<9 then
bh=be
elseif bn<13 then
bh=bl[1]
elseif bn<24 then
bh=bl[9]
elseif bn<30 then
bh=bl[15]
elseif bn<33 then
bh=bl[11]
elseif bn<39 then
bh=bl[10]
else
bh=bl[12]
end
bo.id=bn
bf(bo,bh)
if bn>29 then
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
return bq({"$12 for 25 food; a\80\80\82\79\86\69? "},
function(bv)
if bv=='a' then
return by.gp>=12
else
return nil
end
end,
function()
by.gp-=12
by.fd=cd(by.fd+25)
return "you got more food."
end
)
end,
armor=function()
return bz({"buy \131cloth $12, \139leather $99,", "or \145flak $300: "},ce,'ar')
end,
weapons=function()
return bz({"buy d\65\71\71\69\82 $8, c\76\85\66 $40,","or a\88\69 $75: "},weapons,'dmg')
end,
hospital=function()
return bq({"choose f\73\82\83\84 \65\73\68 ($8), c\85\82\69","($10), or m\69\68\73\67 ($25): "},
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
return cf.n.." is performed!"
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
ci=o('["i think they\'re aliens.","funny citronella smell.","they smell like lemons.","they act like zombies.","they look burned.","the cult knows something.","they spook the animals."]')
bu{"while socializing, you hear:"}
return '"'..ci[flr(rnd(7)+1)]..'"'
end
)
end,
guild=function()
return bq({"4 \139batts $12 or a \145key $23: "},
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
ce=o('{"south":{"n":"cloth","a":8,"p":12},"west":{"n":"leather","a":23,"p":99},"east":{"n":"flak","a":40,"p":300},"north":{"n":"vest","a":70}}')
cp=cl(ce)
weapons=o('{"d":{"n":"dagger","a":8,"p":8},"c":{"n":"club","a":12,"p":40},"a":{"n":"axe","a":18,"p":75},"s":{"n":"shotgun","a":40}}')
cq=cl(weapons)
cg=o('{"a":{"n":"aim","c":3,"a":1},"f":{"n":"first aid","c":5,"a":1,"p":8},"c":{"n":"cure","c":7,"p":10},"x":{"n":"medic","a":6,"p":25}}')
ck=o('{"west":{"n":"4 batteries","attr":"ts","p":12,"q":4},"east":{"n":"a key","attr":"keys","p":23,"q":1}}')
function cr()
local cs=ct.ss
ct=cu[cv]
cw=ct.con
if(cs and ct.ss)music(ct.ss)
by.hd=0
end
function cx()
cu=o('[{"mny":24,"sn":[{"x":107,"msg":["an engagement ring; steve","was ready to propose."],"y":27},{"x":102,"msg":["mary studied astronomy","as a hobby."],"y":33},{"x":107,"msg":["lou was a mixed martial","arts champion."],"y":33}],"n":"village","mxx":112,"c":[{"x":91,"y":27,"id":26},{"pn":"fred","y":30,"x":89,"id":13},{"x":85,"y":27,"id":25},{"x":100,"y":44,"id":24},{"x":108,"y":37,"id":29},{"x":87,"d":["welcome to anteform valley.","we\'re all glad you\'re here."],"y":37,"id":16},{"pn":"anne","y":51,"x":86,"id":22},{"x":80,"y":52,"pn":"flip","d":["greybeard hid his treasure!","it\'s on big sister island!"],"id":22},{"x":109,"y":40,"pn":"gwen","d":["steve, lou, & mary are gone.","i\'m not straying far."],"id":23},{"x":98,"y":47,"pn":"ralph","d":["radio square is southwest.","folks are missing there too."],"id":23},{"x":108,"y":30,"pn":"sally","d":["please find steve.","our rooms are adjacent."],"id":21},{"pn":"bruce","y":37,"x":105,"id":14}],"mxy":56,"i":[{"x":103,"y":38,"id":6}],"ex":57,"sy":54,"sx":96,"ey":37},{"sn":[{"x":120,"msg":["a myrmecology paper by","dr. greene."],"y":6},{"x":105,"msg":["a paper on irregular growth","in animals."],"y":11},{"x":120,"msg":["data on valley insect","populations."],"y":11}],"n":"thinktank","c":[{"x":116,"mva":0,"y":18,"pn":"artemis","d":["spooky stuff\'s afoot.","missing people; crazy animals."],"id":14},{"x":110,"y":17,"id":24},{"x":106,"y":1,"id":27},{"x":111,"y":7,"pn":"dr. wong","d":["concentrated it can burn.","a simple carboxyl."],"id":17},{"x":120,"y":20,"pn":"dr. tetrado","d":["find dr. tucker.","he\'s figured it out."],"id":17},{"x":110,"y":22,"pn":"dr. greene","d":["several of us are missing.","those researching up north."],"id":17}],"i":[{"x":123,"tm":3,"y":4,"tz":0,"tx":126,"ty":33,"id":8}],"mxy":24,"mnx":104,"ex":26,"sy":23,"sx":116,"ey":33},{"mny":32,"sn":[{"x":123,"msg":["a paper on insect","pheromones."],"y":33},{"x":124,"msg":["a paper on formic acid","& its effects."],"y":33},{"x":123,"msg":["a paper on ants controlling","aphids."],"y":35},{"x":113,"msg":["a diagram of modified aphid","brains."],"y":33}],"n":"the basement","c":[{"x":115,"y":34,"pn":"dr. tucker","d":["it\'s semiochemicals.","controlled living corpses."],"id":17},{"x":119,"y":33,"pn":"dr. agawon","d":["they\'re literally brain dead.","higher functions burnt out."],"id":17}],"mnx":112,"mxy":43,"sy":33,"sx":126,"i":[{"x":126,"tm":2,"y":33,"tz":0,"tx":123,"ty":4,"id":7}]},{"sn":[{"x":92,"msg":"he\'ll rise again!","y":20},{"x":100,"msg":["a secret prophesy about the","eschaton starting here."],"y":9}],"n":"monastery","mxx":105,"c":[{"pn":"bro. meinrad","y":21,"x":89,"id":20},{"x":85,"y":15,"id":27},{"x":99,"y":15,"id":24},{"x":92,"y":1,"pn":"sis. pat","d":["i saw the flash in heaven.","the animals now punish us."],"id":20},{"x":82,"y":5,"pn":"learner jo","d":["i found the star jelly.","i think it turned the beasts."],"id":21},{"x":90,"y":6,"pn":"sis. gail","d":["god sent us a sign.","i saw his star fall to earth."],"id":20}],"mxy":24,"i":[{"x":84,"tm":5,"y":9,"tz":0,"tx":113,"ty":31,"id":7},{"x":92,"y":6,"id":6}],"ex":34,"sy":23,"sx":92,"ey":17},{"mny":24,"sn":[{"x":126,"msg":["a list of the missing;","many monks & nuns are gone."],"y":29}],"n":"the top floor","c":[{"x":117,"y":27,"pn":"bro. stamos","d":["we know of your quest.","we will help as we can."],"id":20},{"x":125,"y":30,"pn":"mother francine","d":["some of us were taken.","they are now possessed."],"id":20},{"x":126,"y":26,"pn":"father ted","d":["our dead brothers & sisters.","they are beset by demons."],"id":20}],"mnx":112,"mxy":33,"sy":31,"sx":113,"i":[{"x":113,"tm":4,"y":31,"tz":0,"tx":84,"ty":9,"id":8}]},{"mny":56,"sn":[{"x":105,"msg":["no one\'s been here in awhile.","seems the hermit\'s missing too."],"y":61}],"n":"hermit cabin","mxx":113,"i":[{"x":110,"y":61,"id":4}],"mnx":103,"ex":3,"sy":57,"sx":111,"ey":47},{"mny":43,"sn":[{"x":114,"msg":["the dj was investigating","the monks for the news."],"y":53},{"x":114,"msg":["some expired coupons & a","copy of \'coyote waits\'."],"y":56},{"x":114,"msg":["a zombie comic book; someone","drew a robe on the zombie."],"y":59}],"n":"radio square","c":[{"x":114,"y":45,"id":26},{"x":123,"y":60,"id":24},{"x":123,"y":44,"id":28},{"x":126,"y":46,"pn":"becky","d":["the hermit has a boat.","west past the billabong."],"id":13},{"x":114,"y":48,"pn":"jack","d":["it\'s in the n.e. cabin.","you can borrow my shotgun."],"id":13},{"x":121,"y":53,"pn":"dj jazzy joe","d":["the monks have seen them.","the woods weirdos."],"i":80,"id":15},{"x":124,"y":58,"pn":"emma","d":["hang out in the bar none.","good woods weirdos discussion."],"id":23}],"mnx":112,"ex":34,"sy":62,"sx":119,"ey":53},{"mny":56,"n":"southern cabin","mxx":104,"c":[{"x":101,"y":59,"pn":"sue","d":["you can borrow my vest.","you\'ll need it."],"id":13}],"mnx":96,"ex":38,"sy":62,"sx":100,"ey":60},{"mny":56,"n":"pennisula cabin","mxx":104,"c":[{"x":99,"y":58,"pn":"jim","d":["weird stuff up north.","we\'re vacationing indoors."],"id":19},{"x":98,"y":58,"pn":"daisy","d":["i saw the weirdo!","i\'m glad we\'ve got locks."],"id":18}],"mnx":96,"ex":56,"sy":62,"sx":100,"ey":24},{"mny":56,"n":"lakeside cabin","mxx":104,"c":[{"x":98,"y":58,"pn":"jane","d":["find my friend to the south.","she\'ll help."],"id":18}],"mnx":96,"ex":41,"sy":62,"sx":100,"ey":39},{"mny":56,"sn":[{"x":101,"msg":["a sketch of an ant","moving a rock."],"y":60}],"n":"western cabin","mxx":104,"mnx":96,"ex":21,"sy":62,"sx":100,"ey":28},{"mny":56,"mxx":104,"sx":100,"mnx":96,"ex":75,"sy":62,"n":"hunting cabin","ey":3},{"mny":56,"mxm":15,"n":"the queen\'s chamber","mxx":96,"ss":14,"c":[{"x":83,"y":60,"id":36},{"x":93,"y":58,"id":37},{"x":89,"y":57,"id":35},{"x":89,"y":62,"id":35},{"x":94,"y":57,"id":35}],"i":[{"x":94,"tm":16,"y":62,"tz":1,"tx":3,"ty":6,"id":7},{"x":83,"y":59,"id":38},{"x":84,"y":59,"id":38},{"x":84,"y":60,"id":38}],"mnx":80,"newm":26,"sy":31,"sx":113,"fri":false},{"l":[[0,-196,782,13263,15564,12288,16380,16384],[2,-12481,961,12348,16332,12,-3124,192],[12301,13260,192,15612,12348,13056,-3076,192]],"i":[{"x":1,"y":8,"z":1,"id":7},{"x":8,"y":3,"z":2,"id":7},{"x":8,"y":1,"z":3,"id":7},{"x":4,"y":8,"z":3,"id":5}],"ex":57,"sy":8,"n":"greybeard\'s cave","ey":33},{"l":[[205,15360,2876,16320,12351,-3328,1020,-19711],[48,16128,14332,768,-244,780,13119,28672]],"n":"vetusaur mine","ss":14,"c":[{"x":7,"z":1,"y":8,"ch":-2,"id":33}],"i":[{"x":8,"y":8,"z":1,"id":7},{"x":8,"tm":0,"z":1,"y":1,"tz":0,"tx":3,"ty":5,"id":7},{"x":3,"y":3,"z":2,"id":7},{"x":1,"y":8,"z":2,"id":7}],"ex":3,"sy":8,"sx":8,"ey":9},{"ss":14,"sx":4,"l":[[204,12480,13308,12300,16332,14348,16380,256]],"i":[{"x":4,"y":8,"z":1,"id":7},{"x":3,"tm":13,"z":1,"y":6,"tz":0,"tx":94,"ty":62,"id":8}],"ex":7,"sy":8,"n":"formika mine","ey":3}]')
cu[0]=o('{"n":"anteform valley","mnx":0,"mny":0,"mxx":80,"mxy":64,"newm":10,"mxm":11,"fri":false,"ss":0,"sn":[{"x":64,"y":43,"msg":"nw village"},{"x":68,"y":40,"msg":"n monastery"},{"x":68,"y":40,"msg":"w thinktank"},{"x":58,"y":21,"msg":"w monastery"},{"x":24,"y":3,"msg":["a meteorite hit here. it\'s","corrupted the water."]}]}')
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
ct.con[db][dc][dd]=bf{ot=bl[8]}
end
end
for de in all(ct.c) do
de.mn=cv
de.ot=bl[de.id]
df(de)
end
end
by=o('{"i":0,"ar":0,"dmg":0,"x":67,"y":50,"z":0,"exp":0,"lvl":0,"str":8,"int":8,"dex":8,"st":0,"hd":0,"f":0,"gp":20,"fd":45,"mvp":0,"mp":8,"hp":24,"keys":3,"ts":2,"lit":0}')
by.color=rnd(10)>6 and 4 or 15
cv=0
cr()
dg,dh,di,dj,dk,dl=0,0,0,0,0,false
_update,_draw=dm,dn
dp=dn
end
dq={"","","","",">"}
dr=5
ds=dr
function _init()
cx()
menuitem(1,"list commands",dt)
menuitem(2,"save game",du)
menuitem(3,"load game",dv)
menuitem(4,"new game",run)
dw=cocreate(dx)
cartdata("anteform0")
end
function dt()
msg=bd
if _draw~=dy then
dp=_draw
_draw=dy
end
end
dz={'ar','dmg','x','y','str','int','dex','st','i','color','f','keys','ts','exp','lvl','gp','fd','mp','hp'}
function ea(eb,ec)
return bor(shl(eb,8),ec)
end
function du()
if cv~=0 then
bu{"sorry, only outside."}
else
local ed=0
for ee in all(dz) do
dset(ed,by[ee])
ed+=1
end
if by.i>1 then
dg,dh=0,0
end
dset(ed,ea(dg,dh))
dset(ed+1,di)
ed+=2
for ef=1,11 do
local de=cy[0][ef]
if de then
dset(ed,de.id)
dset(ed+1,ea(de.x,de.y))
else
dset(ed,0)
end
ed+=2
end
bu{"game saved."}
end
end
function eg(eh)
return lshr(band(eh,0xff00),8),band(eh,0xff)
end
function dv()
cx()
local ed=0
for ee in all(dz) do
by[ee]=dget(ed)
ed+=1
end
dg,dh=eg(dget(ed))
di=dget(ed+1)
if dg>0 or dh>0 then
cu[0].con[dg][dh][0]=bf{ot=bl[4]}
end
ed+=2
for ef=1,11 do
ei=dget(ed)
if ei~=0 then
ej,ek=eg(dget(ed+1))
df{ot=bl[ei],x=ej,y=ek,mn=0}
ed+=2
else
break
end
end
bu{"game loaded."}
end
el={
"west", "east", "north", "south",
"c", "x", "p", "?", "s", "f", "e", "d", "w", "a"
}
function em(en)
local eo=1
while en>1 do
en=lshr(en,1)
eo+=1
end
return el[eo] or 'none'
end
function ep(bv,eq)
local er=cg[bv]
if by.mp>=er.c then
by.mp-=er.c
bu{er.n.." performed! "..(eq or '')}
return true
else
bu{"not enough ap."}
return false
end
end
function es(et,eu,ev)
by.x,by.y,by.z,by.f,by.lit,cv=et or ct.ex,eu or ct.ey,0,0,0,ev or ct.mn
cr()
_draw=dn
end
function ew(ex,ev,et,eu,ey)
by.x,by.y=et or ex.sx,eu or ex.sy
cv=ev
cr()
if ex.dg then
_draw=ez
by.f,by.z=ex.sf,ex.sz
end
return "entering "..ex.n.."."
end
function dx(bv)
while true do
local fa=fb(by)
local db,dc,dd=by.x,by.y,by.z
local fc=cw[db][dc][dd]
local fd=fc and fc.n or nil
if _draw==dy then
if bv!='p' and by.hp>0 then
_draw=dp
end
elseif bv=='west' then
if ct.dg then
by.f-=1
if by.f<1 then
by.f=4
end
bu{"turn left"}
dl=true
else
by.x,by.y=fe(fa[2],dc,bv)
end
elseif bv=='east' then
if ct.dg then
by.f+=1
if by.f>4 then
by.f=1
end
bu{"turn right."}
dl=true
else
by.x,by.y=fe(fa[4],dc,bv)
end
elseif bv=='north' then
if ct.dg then
by.x,by.y,by.z=ff(1)
else
by.x,by.y=fe(db,fa[1],bv)
end
elseif bv=='south' then
if ct.dg then
by.x,by.y,by.z=ff(-1)
else
by.x,by.y=fe(db,fa[3],bv)
end
elseif bv=='c' then
bu{"choose a\73\77, f\73\82\83\84 \65\73\68, or","c\85\82\69: "}
bv=yield()
if bv=='c' then
if ep(bv) then
sfx(3)
by.st=band(by.st,14)
end
elseif bv=='f' then
if ep(bv) then
sfx(3)
ch(cg[bv].a*by.int)
end
elseif bv=='a' then
if ep(bv,'dir:') then
local fg=rnd(cg[bv].a*by.int)
if not fh(fa,fi,fg) then
bu{'nothing to target.'}
end
end
else
bu{"command: huh?"}
end
dl=true
elseif bv=='x' then
bu{"examine dir:"}
if not fh(fa,fj) then
if bv=='x' then
local fk={"search","you find nothing."}
fl=fm(db,dc)
if fl then
fk=fl
elseif db==99 and dc==58 and cv==12 and by.dmg<40 then
fk[2]="you find a shotgun!"
by.dmg=40
elseif db==101 and dc==59 and cv==8 and by.ar<70 then
fk[2]="you find a bulletproof vest!"
by.ar=70
end
bu(fk)
else
bu{"examine: huh?"}
end
end
dl=true
elseif bv=='p' then
bu{"pause / game menu"}
elseif bv=='s' then
dl=true
bu{"sit and wait."}
elseif bv=='f' then
dl=true
if fd=='chest' then
by.gp+=500
bu{"you find $500."}
cw[db][dc][dd]=nil
elseif ct.dg and by.lit<1 then
if by.ts>1 then
by.lit=80
by.ts-=1
bu{"the flashlight is lit."}
else
bu{"you have no batteries."}
end
else
bu{"nothing here."}
end
elseif bv=='e' then
dl=true
local msg="nothing to enter."
if fd=='ladder up' or fd=='ladder down' then
if ct.dg then
if dd==ct.sz and db==ct.sx and dc==ct.sy then
msg="exiting "..ct.n.."."
es()
elseif fd=='ladder up' then
msg="ascending."
by.z-=1
else
msg="descending."
by.z+=1
end
end
if fc.tm then
if ct.dg then
es(fc.tx,fc.ty,fc.tm)
else
msg=ew(cu[fc.tm],fc.tm,fc.tx,fc.ty,fc.tz)
end
end
elseif by.i>0 then
msg="exiting sailboat."
cw[db][dc][dd]=bf{f=by.f,ot=bm}
by.i,by.f=0,0
dg,dh=by.x,by.y
elseif fd=='boat' then
msg="boarding sailboat."
by.i,by.f=70,fc.f
cw[db][dc][dd]=nil
end
for fn=1,#cu do
local fo=cu[fn]
if cv==fo.mn and db==fo.ex and dc==fo.ey then
mset(99,61,29)
msg=ew(fo,fn)
elseif db==3 and dc==5 then
msg=ew(cu[15],15,8,1,1)
end
end
bu{msg}
elseif bv=='d' then
bu{"dialog dir:"}
if not fh(fa,fp) then
bu{"dialog: huh?"}
end
dl=true
elseif bv=='w' then
bu{
"worn: "..cp[by.ar].."; wield: "..cq[by.dmg],
by.ts..' batteries & '..by.keys..' skeleton keys.'
}
elseif bv=='a' then
bu{"attack dir:"}
if not fh(fa,fi) then
bu{"attack: huh?"}
end
dl=true
end
if by.lit>1 then
by.lit-=1
if by.lit<1 then
bu{"battery died!"}
end
end
if _draw==ez and by.lit<1 then
bu{"it's dark!"}
end
bv=yield()
if di==0 then
di=1
df{ot=bl[32],x=31,y=4,mn=0}
end
end
end
function fh(fa,fq,fr,fs)
if ct.dg then
fs=ft[by.f]
elseif not fs then
fs=yield()
end
if fs=='east' then
fq(fs,fa[4],by.y,fr)
elseif fs=='west' then
fq(fs,fa[2],by.y,fr)
elseif fs=='north' then
fq(fs,by.x,fa[1],fr)
elseif fs=='south' then
fq(fs,by.x,fa[3],fr)
else
return false
end
return true
end
function bu(msg)
local br="> "
for fu in all(msg) do
dq[ds]=br..fu
ds+=1
if(ds>dr)ds=1
br=""
end
dq[ds]=">"
end
function df(fv)
local fw,db,dc,dd=fv.ot,fv.x,fv.y,fv.z or 0
fv.ot=fw
bf(fv)
if fw.ns then
fv.n=fw.ns[flr(rnd(#fw.ns)+1)]
end
if(fw.cs)fv.co=fw.cs[flr(rnd(#fw.cs)+1)]
fv.iseq,fv.ia=flr(rnd(30)),false
add(cy[fv.mn],fv)
cu[fv.mn].con[db][dc][dd]=fv
return fv
end
function fx()
local fy,fz,ga=flr(rnd(ct.w))+ct.mnx,flr(rnd(ct.h))+ct.mny,ct.dg and flr(rnd(#ct.l)+1) or 0
if cw[fy][fz][ga] or fy==by.x and fz==by.y and ga==by.z then
fy=nil
end
if fy then
local gb=mget(fy,fz)
if ct.dg then
gb=gc(fy,fz,ga,1)
end
for fw in all(bk[gb]) do
if rnd(200)<fw.ch then
df{ot=fw,x=fy,y=fz,z=ga,mn=cv}
break
end
end
end
end
function gd(ge)
by.hp-=ceil(ge)
if by.hp<=0 then
msg=bc
_draw=dy
end
end
function gf(gg)
by.fd-=gg
if by.fd<=0 then
sfx(1,3,8)
by.fd=0
bu{"starving!"}
gd(1)
end
end
function cd(bj)
return min(bj,32767)
end
function gh(gg)
by.exp=cd(by.exp+gg)
if by.exp>=by.lvl^2*10 then
by.lvl+=1
ch(12)
bu{"you went up a level!"}
end
end
function ch(gg)
by.hp=cd(min(by.hp+gg,by.str*(by.lvl+3)))
end
function ff(gi)
local gj,gk=by.x,by.y
local db,dc,dd=by.x,by.y,by.z
local bv=gi>0 and 'advance' or 'retreat'
local co
local gl=false
if by.f==1 then
gk-=gi
gm=gc(db,gk,dd)
co=cw[db][gk][dd]
elseif by.f==2 then
gj+=gi
gm=gc(gj,dc,dd)
co=cw[gj][dc][dd]
elseif by.f==3 then
gk+=gi
gm=gc(db,gk,dd)
co=cw[db][gk][dd]
else
gj-=gi
gm=gc(gj,dc,dd)
co=cw[gj][dc][dd]
end
if co and co.hp then
gl=true
end
if gm==3 or gl then
gn(bv)
else
db,dc=gj,gk
sfx(0)
bu{bv}
end
dl=true
return db,dc,dd
end
function go(db,dc)
if db>=ct.mxx or db<ct.mnx or dc>=ct.mxy or dc<ct.mny then
bu{bv,"exiting "..ct.n.."."}
cv=0
return true
else
return false
end
end
function gn(bv)
sfx(4)
bu{bv,"blocked!"}
return false
end
gp={north=1,west=2,south=3,east=4}
ft={"north","east","south","west"}
function fe(db,dc,bv)
local gq=true
local gr=mget(db,dc)
local gs=band(fget(gr),3)
local gt=fget(gr,2)
local gu=fget(gr,3)
local gv=cw[db][dc][by.z]
if by.i>0 then
by.f=gp[bv]
local gw=mget(db,dc)
if go(db,dc) then
db,dc=ct.ex,ct.ey
cr()
elseif gv then
gq=gn(bv)
elseif gw<12 or gw>16 then
bu{bv,"must exit boat first."}
gq=false
else
bu{bv}
end
else
if go(db,dc) then
db,dc=ct.ex,ct.ey
cr()
elseif gv then
if not gv.p then
gq=gn(bv)
end
elseif gr==28 then
bu{bv,"open door."}
gq=false
mset(db,dc,30)
elseif gr==29 then
if by.keys>0 then
bu{bv,"you jimmy the door."}
by.keys-=1
mset(db,dc,30)
else
bu{bv,"the door is locked."}
end
gq=false
elseif gu then
gq=gn(bv)
elseif gt then
gq=false
bu{bv,"not without a boat."}
elseif gs>by.mvp then
by.mvp+=1
gq=false
bu{bv,"slow progress."}
else
by.mvp=0
bu{bv}
end
end
if gq then
if by.i==0 then
sfx(0)
end
if gr==5 and rnd(10)>6 then
bu{bv,"poisoned!"}
by.st=bor(by.st,1)
end
else
db,dc=by.x,by.y
end
dl=true
return db,dc
end
function fm(db,dc)
local fk=nil
for gx in all(ct.sn) do
if db==gx.x and dc==gx.y then
if mget(db,dc)==31 then
fk={" (read sign)",gx.msg}
elseif db==by.x and dc==by.y then
fk=gx.msg
end
break
end
end
return fk
end
function fj(gy,db,dc)
local bv,fl,gv="examine: "..gy,fm(db,dc),cw[db][dc][by.z] or nil
if fl then
bu{bv..fl[1],fl[2]}
elseif gv then
bu{bv,(gv.pn or gv.n)}
elseif ct.dg then
bu{bv,gc(db,dc,by.z)==0 and 'passage' or 'wall'}
else
bu{bv,bi[mget(db,dc)]}
end
end
function fp(gz,db,dc)
local bv="dialog: "..gz
if bi[mget(db,dc)]=='counter' then
return fh(fb({x=db,y=dc}),fp,nil,gz)
end
local ha=cw[db][dc][by.z]
if ha then
if ha.mch then
bu{cc[ha.mch]()}
elseif ha.d then
bu{bv,'"'..ha.d[flr(rnd(#ha.d)+1)]..'"'}
else
bu{bv,'no response!'}
end
else
bu{bv,'no one to talk with.'}
end
end
function fi(fs,db,dc,fr)
local bv="attack: "..fs
local dd,de=by.z,cw[db][dc][by.z]
local ge=flr(rnd(by.str+by.lvl+by.dmg))
if fr then
ge+=fr
end
if de and de.hp then
hb=(de.pn or "the "..de.n)
if fr or rnd(by.dex+by.lvl*8)>rnd(de.dex+de.ar) then
ge-=rnd(de.ar)
de.hd=3
sfx(1)
de.hp-=ge
if de.hp<=0 then
by.gp=cd(by.gp+de.gp)
gh(de.exp)
cw[db][dc][dd]=nil
bu{bv,de.n..' killed; xp+'..de.exp..' $+'..de.gp}
if de.ch==-1 then
di,bl[30].ch,bl[31].ch=2,3,4
bu{'a zombie?!'}
elseif de.ch==-2 then
bu{'an ant bigger than a cow!'}
di,bl[33].ch,bl[34].ch,bl[35].ch,bl[37].ch,bl[30].ch,bl[31].ch,bl[40].ch=3,7,3,5,2,2,3,0
elseif de.i>124 then
msg=bb
_draw=dy
end
del(cy[cv],de)
else
bu{bv,'you hit '..hb..'!'}
end
if ct.fri then
for hc in all(cy[cv]) do
hc.hos=1
hc.d={"criminal!"}
hc.mva=1
end
end
else
bu{bv,'you miss '..hb..'!'}
end
elseif mget(db,dc)==29 then
sfx(1)
if(not fr)gd(1)
if rnd(ge)>12 then
bu{bv,'you break it open!'}
mset(db,dc,30)
else
bu{bv,'the door holds.'}
end
else
bu{bv,'nothing to attack.'}
end
end
function hd(he,hf,hg,hh)
local hi,hj=abs(he-hg),abs(hf-hh)
return hi+hj
end
function fb(de)
local hk,hl=ct.mxx,ct.mxy
local ej,ek=de.x,de.y
local hm,hn=(ej+ct.w-1)%hk,(ej+1)%hk
local ho,hp=(ek+ct.h-1)%hl,(ek+1)%hl
ho,hp,hm,hn=ek-1,ek+1,ej-1,ej+1
if de~=by then
ho,hp,hm,hn=max(ho,ct.mny),min(hp,hl-1),max(hm,ct.mnx),min(hn,hk-1)
end
return {ho,hm,hp,hn}
end
function hq()
local gothit=false
local hr=500
local db,dc,dd=by.x,by.y,by.z
for ef,de in pairs(cy[cv]) do
local hs,ht,hu,hv=de.f,de.x,de.y,de.z
if hv==dd then
while de.mva>=de.nm do
local fa=fb(de)
if de.hos then
local hw=0
hr=hd(de.x,de.y,db,dc)
local hx=hr
local hy=hx
for hz=1,4 do
if hz%2==1 then
hx=hd(de.x,fa[hz],db,dc)
else
hx=hd(fa[hz],de.y,db,dc)
end
if hx<hy or (hx==hy and rnd(10)<5) then
hy,hw=hx,hz
end
end
if hw%2==1 then
hu=fa[hw]
else
ht=fa[hw]
end
de.f=hw
else
if rnd(10)<5 then
if hs and rnd(10)<5 then
if hs%2==1 then
hu=fa[hs]
else
ht=fa[hs]
end
else
local hz=flr(rnd(4)+1)
de.f=hz
if hz%2==1 then
hu=fa[hz]
else
ht=fa[hz]
end
end
end
end
local gr=mget(ht,hu)
if ct.dg then
gr=gc(ht,hu,hv,1)
end
local ia=false
for bp in all(de.t) do
if gr==bp and de.mva>de.nm then
ia=true
break
end
end
de.nm+=1
if de.hos and hr<=1 then
local ib=by.dex+2*by.lvl
local ic="the "..de.n
if de.eat and by.fd>0 and rnd(de.dex*23)>rnd(ib) then
sfx(2)
bu{ic.." eats!"}
gf(flr(rnd(6)))
gothit=true
id(9)
elseif de.th and by.gp>0 and rnd(de.dex*20)>rnd(ib) then
sfx(2)
local ie=min(ceil(rnd(5)),by.gp)
by.gp-=ie
de.gp+=ie
bu{ic.." steals!"}
gothit=true
id(9)
elseif de.po and rnd(de.dex*15)>rnd(ib) and band(by.st,1)~=1 then
sfx(1)
by.st=bor(by.st,1)
bu{"poisoned by the "..de.n.."!"}
gothit=true
id(3)
elseif rnd(de.dex*64)>rnd(ib+by.ar) then
by.gothit=true
sfx(1)
local ge=max(rnd(de.dmg)-rnd(by.ar),0)
gd(ge)
bu{ic.." hits!"}
gothit=true
id(3)
by.hd=3
by.hc=de.ac
else
bu{ic.." misses."}
end
break
elseif ia then
local gs=band(fget(gr),3)
de.mvp+=1
if de.mvp>=gs and not cw[ht][hu][dd] and not (ht==db and hu==dc and hv==dd) then
cw[de.x][de.y][de.z]=nil
cw[ht][hu][hv]=de
de.x,de.y=ht,hu
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
function dm()
local en=btnp()
if en~=0 then
coresume(dw,em(en))
end
if dl then
dl=false
dk+=1
if dk%500==0 then
ch(1)
end
if dk%50==0 then
gf(1)
end
if dk%10==0 then
by.mp=cd(min(by.mp+1,by.int*(by.lvl+1)))
end
if dk%5==0 and band(by.st,1)==1 then
gd(1)
sfx(1,3,8)
bu{"feeling sick!"}
end
gothit=hq()
if #cy[cv]<ct.mxm and rnd(10)<ct.newm then
fx()
end
end
end
function id(ig)
for ih=0,ig do
flip()
end
end
function ii(ij)
local ik=flr(ij/16)*512+ij%16*4
if(fget(ij,7))then
for il=0,448,64 do
reload(ik+il,ik+il,4)
fset(ij,band(fget(ij),64))
end
else
for il=0,448,64 do
memcpy(ik+il,ik+il+4,4)
fset(ij,7,true)
end
end
fset(ij,2,true)
end
function im()
local io,ip,iq=106,110,119
print("cond",io,0,5)
print(band(by.st,1)==1 and 'p' or 'g',125,0,6)
print("lvl",io,8,5)
print(by.lvl,iq,8,6)
print("hp",io,16,5)
print(by.hp,io+8,16,6)
print("ap",io,24,5)
print(by.mp,io+8,24,6)
print("$",io,32,5)
print(by.gp,ip,32,6)
print("f",io,40,5)
print(by.fd,ip,40,6)
print("exp",io,48,5)
print(by.exp,io,55,6)
print("dex",io,63,5)
print(by.dex,iq,63,6)
print("int",io,71,5)
print(by.int,iq,71,6)
print("str",io,79,5)
print(by.str,iq,79,6)
for ir=1,dr do
print(dq[(ds-ir)%dr+1],0,128-ir*8)
end
end
function is(it)
if it then
for iu in all(it) do
pal(iu[1],iu[2])
end
end
end
function iv(co)
local iw=false
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
iw=co.ia
end
end
palt(0,false)
is(co.co)
return iw
end
function ix(x,y,iy,iz,ja,jb)
map(x,y,iy*8,iz*8,ja,jb)
for jc=x,x+ja-1 do
for jd=y,y+jb-1 do
local co=cw[jc][jd][0]
if co then
local iw=iv(co)
local f=co.fm and co.f or 0
spr(co.i+f,(jc-x+iy)*8,(jd-y+iz)*8,1,1,iw)
pal()
if co.hd>0 then
is(co.hc)
spr(127,(jc-x+iy)*8,(jd-y+iz)*8)
pal()
co.hd-=1
end
end
end
end
end
function gc(je,jf,jg,jh)
local ji=0
if je>=ct.mxx or je<ct.mnx or jf>=ct.mxy or jf<ct.mny then
ji=3
else
local il=ct.l[jg][jf]
il=flr(shr(il,(ct.w-je)*2))
ji=band(il,3)
end
return jh and (ji>1 and 20 or 22) or ji
end
function jj(jk)
local jl=jk[1]
jk[1]=jk[3]
jk[3]=jl
end
function jm(je,jf,jg,hz)
local jn={}
if hz%2==0 then
for jo=jf-1,jf+1 do
add(jn,{
b=gc(je,jo,jg),
x=je,
y=jo
})
end
if hz==4 then
jj(jn)
end
else
for jp=je-1,je+1 do
add(jn,{
b=gc(jp,jf,jg),
x=jp,
y=jf
})
end
if hz==3 then
jj(jn)
end
end
return jn
end
function jq(je,jf,jg,hz)
local jn={}
local jp,jo=je,jf
if hz%2==0 then
for jp=je+4-hz,je+2-hz,-1 do
add(jn,jm(jp,jo,jg,hz))
end
if hz==4 then
jj(jn)
end
else
for jo=jf-3+hz,jf-1+hz do
add(jn,jm(jp,jo,jg,hz))
end
if hz==3 then
jj(jn)
end
end
return jn
end
function ez()
cls()
if by.lit>0 then
local jr=jq(by.x,by.y,by.z,by.f)
for js,il in pairs(jr) do
local jt,ju=(js-1)*10,js*10
local jv,jw,jx,jy=30-ju,30-jt,52+ju,52+jt
local jz,ka,kb,kc,kd=30-ju*2,52+ju*2,42,31-jt,51+jt
if il[1].b==3 then
rectfill(jv,jv,jw,jx,0)
line(jz,jv,jv,jv,5)
line(jv,jv,jw,jw)
line(jv,jx,jw,jy)
line(jz,jx,jv,jx)
end
if il[3].b==3 then
rectfill(jy,jw,jx,jx,0)
line(jx,jv,ka,jv,5)
line(jy,jw,jx,jv)
line(jy,jy,jx,jx)
line(jx,jx,ka,jx)
end
if js>1 then
local ke,kf,kg=jr[js-1][1].b,jr[js-1][2].b,jr[js-1][3].b
if (il[1].b==kf and il[1].b==3) or
(il[1].b~=ke) then
line(jw,jw,jw,jy,5)
end
if (il[3].b==kf and il[3].b==3) or
(il[3].b~=kg) then
line(jy,jw,jy,jy,5)
end
if kf==3 and ke==3 and il[1].b~=3 then
line(jw,kc,jw,kd,0)
end
if kf==3 and kg==3 and il[3].b~=3 then
line(jy,kc,jy,kd,0)
end
end
if il[2].b==3 then
rectfill(jv,jv,jx,jx,0)
line(jv,jv,jx,jv,5)
line(jv,jx,jx,jx)
if il[1].b<3 then
line(jv,jv,jv,jx)
end
if il[3].b<3 then
line(jx,jv,jx,jx)
end
end
kh(il[2].x,il[2].y,by.z,3-js)
end
rectfill(82,0,112,82,0)
end
im()
end
function kh(db,dc,dd,ki)
if db>0 and dc>0 then
local co=cw[db][dc][dd]
if co then
local iw,kj,shm,szm=iv(co),ki*3,co.shm or 0,co.szm or 0
local kk,kl=20+kj+(szm*(ki+1)/8),35-(3-ki)*shm
local km=60-szm-kj*4
sspr(co.i%16*8,flr(co.i/16)*8,8,8,kk,kl,km,km,iw)
pal()
if co.hd>0 then
palt(0,true)
is(co.hc)
sspr(120,56,8,8,kk,kl,km,km)
pal()
co.hd-=1
palt(0,false)
end
end
end
end
function dy()
cls()
print(msg)
end
function dn()
local hk,hl,kn,ko=ct.mxx,ct.mxy,ct.mnx,ct.mny
local ja,jb=ct.w,ct.h
local kp,kq,kr,ks,iy,iz,kt,ku=0,0,0,0,0,0,by.x-ba,by.x+ba
if kt<kn then
kr=kn-kt
iy=kr
kt=kn
elseif ku>=hk then
kr=ku-hk+1
ku=hk
end
local kv,kw=by.y-z,by.y+z
if kv<ko then
ks=ko-kv
iz=ks
kv=ko
elseif kw>=hl then
ks=kw-hl+1
kw=hl
end
local kx,ky=min(y-kr,ct.w),min(x-ks,ct.h)
if dj%16==0 then
for ij=12,14,2 do
ii(ij)
end
end
dj+=1
cls()
ix(kt,kv,iy,iz,kx,ky)
palt(0,false)
if by.color==4 and by.i==0 then
is{{4,1},{15,4}}
end
spr(by.i+by.f,48,40)
pal()
palt()
if by.hd>0 then
is(by.hc)
spr(127,48,40)
pal()
by.hd-=1
end
im()
end
__gfx__
000ff000000003000000040000000400000000000000000000330000000005000005500000006000055555600277772000000000000000000000111011100000
000ff565030000000400000000404040000300000100100003333000005050500050050000066600666656600277772001000101101010000011010001000011
00888676000000000000000004040004003330000033000003333330050500050050005000d006006ff656600288882010101010010101011100001000101100
f8888565000300000004000040004000000300300000000000330333500050000500000505000d00666656600088880000010000000000100000000000000000
08ccc5000000000300000004000404000000033300001001030033330005050050005500050500506ff656600088880000000000000000000001110011000001
00c0cc00000000000000000000400400003000300000033033330330005005005005005050005050666656600288882001000101101010000110100010000110
00c00c000000300000004000040000400333000010010000333300000500005000500005000050056ff656600222222010101010010101011000010101011000
01100110300000004000000000000000003000000330000003300000000000000000000000000000666656000200002000010000000000100000000000000000
006666004440444055505550fff0fff055005550550055500000050055555555ccccccccfff0fff0000000005545545522222222222222222222222200000000
065555600000000000000000000000005550555055505550050000005d0d0d05c000000c00000000004004000044440025555502255555022500000200055000
650000564044404450555055f0f4f0ff5055505550555055000000005d0d0d05c000000cf0fff0ff004444000040040025555502255555022500000204444440
444444440000000000000000000000000055505500505055000500005d0d0d05c000000c00000000004004000044440025555502255555022500000207777770
446666444440444055505550fff0fff05550555055555550000000055d0d0d05c000000cfff0fff0004444000040040025559502255595029590000207777770
465555640000000000000000000000005550055555500555000000005d0d0d05c000000c00000000004004000044440025555502255aa5022500000207777770
654444564044404450555055f0fff0ff5055505550555055000050005d0d0d05c000000cf0fff0ff004444000040040025555502255555022500000200055000
6500005600000000000000000000000000550000005500005000000055555555cccccccc00000000554554550000000025555502255555022500000200055000
0000050000050500000550000087800000000000000040000666666000c01c000000220000000000555555555555555555555555555555555555555555555555
005050500050505050066005087778000008800000044400690000860c17c7100002882000ffffff000660000666660000666600066666000666666006666660
05055505550000509596695984474480008448000004250060900806010c70c0000288200ffffff2006006000600006006000060060000600600000006000000
5050005000066005555555554ff7ff400844448000052400600980060c07c01000028820ffffff42060000600666660006000000060000600666600006666000
00500050006006005d5665d5f5fff5f0042245400400444060089006010c70c00088882024994242066666600600006006000000060000600600000006000000
000555000560065055566555fff4fff00422454044404240608009066c07c0160888822024444202060000600600006006000060060000600600000006000000
055000505060060055566555fff4fff004224440424042406800009666cccc660200202020000200060000600666660000666600066666000666666006000000
00000000006006000000000000000000000000004240000006666660566666650200200020000200555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00666600060000600666660006666600060006000600000006600660060000600066660006666600006666000666660000666600066666000600006006000600
06000060060000600006000000006000060060000600000006066060066000600600006006000060060000600600006006000000000600000600006006000600
06000000066666600006000000006000066600000600000006000060060600600600006006000060060000600600006000666600000600000600006000606000
06066660060000600006000000006000060060000600000006000060060060600600006006666600060600600666660000000060000600000600006000606000
06000060060000600006000006006000060006000600000006000060060006600600006006000000060060600600006006000060000600000600006000060000
00666600060000600666660000660000060000600666660006000060060000600066660006000000006666000600006000666600000600000066660000060000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
5555555555555555555555555555555555555555555555555555555500626000000067000067600000760000000000000000000000044000000ff000000ff000
0600006000666600060006000666666000000000000000000066000006626600000677000677760000776000000ff000000ff00000044004f00ff000000ff00f
0600006006000060060006000000060000000000000000000600600007626700006777000777770000777600000ff000000ff00000eeeeeeff8ff8ffffffffff
0600006000000060006060000000600006666660000000000066000007626700066777000777770000777660f3bbbb0000bbbb004eeeee000088880ff0ffff00
00600600000666000006000000060000000000000000000006006060076267000066770007747700007766000b0bb3bffb3bb3b00e666600000ff000000ff000
0066660000000000000600000060000000000000000000000600060007727700400620000664660000026004000bb000000bb0f0006006000008800000088000
006006000006600000060000066666600000000000000000006660600444440004444444044444004444444000111100001111000060060000f00f0000f00f00
55555555555555555555555555555555555555555555555555555555004440000044444000444000044444000110011001100110011001100ff00ff00ff00ff0
000ff00000044000500ff000000ff000400ff000400ff00000011000000110000002200500022000000ff000000ff000000ff00000ff00000000000000008880
600ff00000044004500ff000000ff000400ff000400ff00f000ff00f000ff000000ff00f000ff000000ff000f00ff00f000ff000f0ff00000444444000055008
9999990600d22d44503433005034330f402222204022222260111110f111110000111110f111110500cccc00ffccccff07767000777670f04444444400522500
0099999904dddd005344344353443443f222222240222222f11110006011111ff11110000011111f0fccacf000ccac007776777f777677704446644400588500
00099000044dd000f433430f543343004222220ff2222200010110000001100001011000000110000ffccff0000cc000f0767070007677005555555505055080
00111000000dd00040304300f0304300400222004222200000cccc0000cccc000088880000888800000cc000000cc00000717000007170004444444408000888
0010110000dddd000010010040100100402222004022220000c00c0000c00c000040040000400400005005000050050000101000001010004444444488800808
044004400dddddd00110011001100110402222004022220001100110011001100440044004400440055005500550055001101100011011000000000080800000
00404000004040000000000100100000000550000005500040055000000550000101101000011000000000000000000000000000000000006001100661011016
00444000004440000110550000105501400550000005500540055000000550051011110101011010000000000500005000004440044400006601106666011066
00848400008484000005666010056660400110000001105040111100401111500010010015100151050000500500005000004004400400006660066666600666
00f5f44000f5f4400555556005555551405115000551150040111100451111000501105050011005056006505560065500444400004444000661166056611665
000f4445000f44455866850145866840050110504001100045111050500111005110011550100105566556655065560504555440044555405010010550100105
00444f400f444f404666640004666600000110054001100040011005401110005108801501088010565885655658856505858540045858501108801101088010
00f40ff0ff040f4405005140045005440010010040100100001111004011110001011010010110100605506006055060045e54400445e5401001100110011001
0ff0004400440ff00466000000066000055005500550055000111100401111000000000001000010000000000600006000400400004004000000000010000001
00000000000000000000000000000000001003900010000000011000010110100000000000000000000330000000000000000000000110000101101000000000
00000000000000000000000000000000100000301000093001011010100110010040400000404000003333000004400000007f00011111101011110100900900
00bb008b00b00b80000008f000008f00000100300001030010100101151001510044490000444000033b3330004ff40007f0ff00101551011215512109088090
0b00b0b00b0b00b0500004000050400001033031013303010501105050011005008489900084890003333b33004444000ff000000201102020011002008aa800
0b00b0b00b00b0b00f00ff000f00ff000030033003003100501001055010010507f4f70007f4f79033b33333004ff400007f07f02015510220155102008aa800
00b00bb0b000bb00044444f0004444f010300100010100001108801101088010047f7400007f794033333b300044440000f7fff0111881110118811009088090
000b00000b00000000ffff0000ffff00010100001000000010011001100110014494940004044990033b33000048840007fff00010c11c0110c11c0100900900
00000000000000000000000000000000000000100010010000c00c0010c00c01000099004400000000033000000440000ff00000000110001001100100000000
909090807070704040606060606060606010101010404010101010c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0404010c0c0c0c010
10303020203070907070707080809090202020401111402020204011114020202020209191919191111191919191912041414141414141414141414141414141
909090807070404040606060606060106060601010101040101022c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c010701240c0c0c0c010
103020202030708080709080809090902020202011111111111111111111112020202091118292911111919282119120419282114192821151a0a0a0a041b141
90909080707040404060606060601010606060101010104010101010c0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c01010c0c0e0e0c010
102030202030708090707080809080902020202020202020202020202020112020202091b01111d11111d11111b0912041111111411111114141414141411141
90908080704040606060606060606060601060601010101010104010c0101010c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0e0e0c0c010
10101020307080908090709080908090202020209191919191919191202011202020209191919191c1c191919191912041115454411154544182929282411141
9080808070704060606060606060106060101010404010101040c0c0c01010101010c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c01010
10301010303080807070707080808090202020209154d38304735491202011202020202020111111111191b2a2b3912041111192411111924111111111411141
90908080707040404040404010101010101010101010101010100110101010101010c0c0e0e0e0c0c0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0521010c0c01010
102030102020307070707070808090902020202091a011111111a0914020112020202020111140c0401191111111912041111182411111824111111111411141
9090908070704040101010101010101010101010404040401010c01010101010101010c0c0c0c0c0c0c0c0c0c0e0e0e0c0c0c0c0c01040104010104040401010
1020201020203030303070708080909020202020915413a25353549140401111111111111140c072c091738373e2912041111111411111114111111111411141
9090808070701010c0c0c0c0c0c0c0101010c0c0c0c0c0c0c0c0c010401040401010101010d0101010421010c0c0c0c0c0c0c010101010404040101040101010
103020102020203030307070809090902020202091111111111111111111112020202020111140c040111111111191204141d1414141d1414141d14141411141
90908080707010c0c01010101010c0c0c0c0c01010101010c0101040401040402010101010d01010101010101010101010101010101040707040101010101010
30303010f12030202030707080809090202020209111111111111191404011202020202020111111111111111111912041111111a0111111a011111111d11141
90908080707010c010101010101010101010101010101010c0104040401040203010101010011010401010101010101010101010101010101010401010101010
10404010102020202030707080809090202020209191919191919191402011202020202020101010919191919191912041a011111111111111111111a041a041
908080c0c0c0c0c01060606060101010101010101010101001101010101030202020303010d01030304020101020204010404020202020202010101010101010
10101010102020307070707080809090202020202020202020202020202011202091919191919110101010101010202041414141414141414141414141414141
908090807070101010606060101010101010101010c0c0c0c0104040302020202020202010d01010103020202020203010202030302020302020202020101010
f1101010102020202070807080808090209191919191919191919120202011202091f28383d29110919191919191202091919191919120919191919191919191
9090808070706060604010101010101010c0c0c0c0c0101010102030203020202020202010d0d0d0102020303020202010203030302030303020202020202020
20201010102030202070808080808090209154c3c213838353549120202011204091111111119110919282111191202091a273d3e29120911111111111111191
90908080907040101010404010101010c0c0c01010101020202020202020202020202020101010d0103020203030202010303020202030303020202020202020
30201010102020202070708080909090208111111111111111118120202011404091c3d383939110918211111191202091111111119120910413a2d3c213a291
909080908090104040404040c0c0c0c0c010c050c0501020202020202020202020202020202010c0104030202020203010303020303030302020202020202020
20301010103020302070707080809090209111111111111111119120202011111111111111119110911111b0b09120209113e373d39120c11111111111111191
90809042707040c0c0c0c0c0c01010101050c0c0c0c05010202020202020202020202020201010c0104030203020303010302020303030202030303030303020
2030101010303020207070708080909020815454541111545454812020201140409111111111911091d191919191202091111111119120911173e2e2d2141191
908090c0c0c0c0c04040404040404050c0c0c0c0c0c0501020202020202020202010101010101001101010101010101010202030303030202020303030302020
20101010101030202030707080809090209182828211118282829120202011104091919191919110111110101010202091111111119120919191919191919191
9080808070704060606060604040505050c0c0c0c0501010202020202020202020104040202010c0c0c0c0c0c0c0c0c0c0c0c030202020203020202020202030
20101010101020203030707080809090208154545411115454548110101011101010101010101010111091919191912091911191919120202020202020202020
909090807070606060606060404040101010105050501050102020202020202020104010101010c010807070303030202030c0c0d03030303020302020302030
20101062101020203030707080809090209182828211118282829140104011101010101010101010111091b0b011912020402040202020202020202020202020
909080807040404060606040401020202020101010505050102020202020202040101010c0c0c0c0809080703030303020303030d03020202020202030302020
2010101010102030303070708080909020911111111111111111c111111111101010101010101010111091111111912020202020202020212121212121212020
908080807070404040404040103030303030202020201010202020202020202040101010c01010809090909090303030202020d0d02030302030203030303020
202010101020203030307070808090902091919191919191919191401040111111111111111111111111d111118291202091919191202021b3a2d22383212020
908080807070704040403030303030303030303030303020202020202020204040105210c01090907070707090302030303030d0303030202030203030303030
30202020202030303030707080809090201010101010101010101010101020201120202010101010101091118292912020919282914020211111111111212020
909080807070704040303030303030303030303030303030303030303020304040401010c01090708090907070802020202020d0202020202020203030808030
3020303030303030307070809080909020101010101010101010101010102020112020201010101010109191919191202091b011c12020c11111111111212020
909080807070807070803030307030303030303030303030303030303030303040404070c01090709070709080707030303030d0303020707070203030707070
3030303030303070708070708080909020202020202020202020202020202020112020202020202020202020202020202091919191402021435353b354212020
909080808070707080703030708080307070707070707030303030303030303080808070c080907090709090909090803030d0d0303020708080703080808080
80303030303080808080808080809090414141414141414141414141414141412020202020202020202020202020202020919282914020212121212121212020
90908080908070907070803030308070707070808080703030303030307070808070c0c0c080907070707070709080707030d030707070707080708070909090
7070303030307070708090808090909041616161616161614161416161616141209191919191912091919191401020202091b011c12020202020202020202020
90908080809080708070707070807070707080808070707070707070707070707070c080909070909090909070907070d0d0d080807070707070707090709070
70707070707070808080908080909090416141514161616141616161616161412091b0b01111912091b011911010102020919191914020204082828282824020
90909080808080807080907070707070707090909080807070707070707080808070c0907070707070707090708090d0d0707070708080807070707070707070
70808070808070809080909080809090416141616161616161616161614161412091111111829120911111c110c0101020919282914020209153e373c2139120
90909090808080809080808080808080808080809090808080808080808080808080c08090804280809080808080908080808080808090808080808080808080
808080808090808080808080808090904161416161616161616161616141614120911111829291209111119110c0c01020918211c12020209111111111119120
90809090809080808080909080808080808080808080808070808080809090909080c08090808080809090808090909080808080808080809080808080808080
9090909080808080808080808080909041614141416161614161616161416141209191d191919120919282911001c0c02091b0b0914020209163e373c2139120
90808080809090909090909080909090908080809090909090908080909080808080909090909090908080809090808080808080909090909090909090909080
808090909090908090908080909090904161616161616161416141616141b14120201020101020209191919140c0c0c020919191912020204082828282824020
90909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090
909090909090909090909090909090904141414141414141414141414141414120202020202020202020202020c0c0c020202020202020202020202020202020
__gff__
0000000101010201020b00000484048400000800080000080808000008080000010000000000000000000808080808080808080808080808080808080808080808080808080808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909141414141418141414141414181414141414141814141414141414141414141814141414141414141814141414141414
0909090909090909090909090808090909090909090808090909080809090909080909080808090909090908080909090909090909090909090909080808080909090809090909090909090909090909140404010101010101010104040401010101010101010404141111111404010101010101010101010101010101040414
090909080808080808090909090808080808080908080808080909080908080807080909090808080807080808080809090808080808080808080808080808080908080808080809090808080808090914040114141414141414010101010114141414141414010414362e2d1401010101010101010101010101010101010414
09090808080808210908080808080808080808080c0c0c082009080806060608080808080809080808080808080808080808080908080808080808080808090808080808090809080808092408080909140101140b110b110b141814181418140b110b110b140101141111111c02141414141414141414141414141414010114
090909080709090907070707070707070707080808070c0c0c07070606070606060606080907070707070707070707080807080808070707070708090809070909080909090809080909080909080909140101140b110b110b141111111111140b110b110b140101141111111404151111111111111111111111111a14010114
090908210907070707070707070707070c0c0707070707070c0707070606060706060707070d0d0d0d0d0d0d0d0d0d070707080808070707070708080807070709070809090808080808090808090909140101140b110b110b14110c0c0c11140b110b110b140101141414141414141414141414141414141414141414010114
0909090909070505070505050505050c0c070707040407040c07070404060607070707070d0d06060606060606060d0d0d0d0707070d0d0d0d0d0d07070709070909080909080709090809080808090914010114111111111114110c270c11141111111111140101142928111114292811111429281111142928111114010114
0909080c0c0c0c0c0c050505050c0c0c05060606060404040c0c0c0c04040606040407070d0606060606060606060607070d0d0d0d0d040207070d07070707080808090809090709070808090908080918010114292811111114110c0c0c11141111112829140101181111111114111111111411111111141111111114010118
09090809080707050c0c0c0c0c0c050c05060606060604040404040c0c0c040406060d0d0d0606060606060606060606060707020202020202020d0203070707030707080809090907090808090808091401011414141411111d11111111111d11111414141401011414141d141414141d141414141d141414141d1414010114
0909092109080805050505050505050c050606060606060606060604040c01040d0d0d06060606060606060606060606060606040204040202030d020203030302030307070809090908090809080909140101141b111d11111418141114181411111d110a140101141111111111111111111111111111111111111114010114
0909080c0c080707050505050505050c050606060606060606060606040c010110040604060606060606060606060606060606040404020202020d0d0d0d0d0d020202030708080808080908080809091401011414141414141401141c14011414141414141401011414171414171414171414141d1414141414141414010114
090808080c070705050c0c0c0c0c050c050406060606060606060606010c0c0c0c0c0c060406060606060606060606060606060404020204020202020203020d0d0d0202070708080908070809090909140101010404040404010101110101010404040404010101140a111111111111110a14111111140a0a0a0a0a14010114
090908080c070505050c0505050c050c0504060606060606060606060604040404040c0c06040606060606060606060606060604040204020202020202020202030d0d0d020707080908090708080809140101010101010101010101110101010101010101010101141111111111111111111d1111111d111111110a14010114
090909050c0705050c0c0505050c0c0c0c0104040406060606060606060604040404010c0c0606060606060606060606060404040202020402020202020202020202030d0d0d0d070808080909080909140119191919191919190101110101191919191919191901143d313237343d2a373414111111140a0a0a0a0a14010114
09090c0c0c0c0c0c0c050505050505050c0c0c01040404040406060606040404040401040c0c06060606060606060606040404020402040202020202020202020302020202030d0d0d080708080809091401193c39323b323d190401110104194535322f2e4419011414141414141414141414141d1414141414141414010114
09090c0807050505050505050505050505010c0c0c0c0c01040404040404040404040104040c040404060606060606040401020402020202040202020202020202020202020202020d0d0d0d0d0d0909140119111111111111190401110104191111111111111901140101010101010101040404020404040101010101010414
090c0c070707050505050505050505010101010101050c0c0c0c0c0c0104010401010101040c040404040404060606040101010101010202020202020202020202020202020202030202070708090909180119312e2a353d3119040111010419452b3b2e2a2d1901180112121212121212121201020101010101010101040418
0909070707070505050505050505050101010101010101010c01010c0c0c0101010c2301010c04040404040404040404010101010101010101010202020202020202020203020202020707070809080914011911111111111119040111010419111111111111190114011211111111111111120102011414141414141d141414
090907080705050c0c0c0c0505050505050101010101010c0c010101010c0c0c0c0c0101010c0101040104010101010101010101010101010101010102020202020202020202020702020708080908091401191111111111111904011101041911111111111119011401122c2a373d2e2e371201020114112829141111110b14
090908080c0c0c0c05050c0c0c0c0c0c0505010c0c0c0c0c01010101010101010c0d01010110010101010101010101010101010101010101010101010202020202020303020202020707070708080809140119191911191919190111111101191919191119191901140112111111111111111201020114111128142811111114
0909080807070505050505050505050c0c0c0c0c010101010101010401010101010d0d01010d0101010101010101010101010101010101010101010101020302020202020202030207070707080809091401010104110401010101111f110101010104110401010114011211111111111111120102021d111111142928111114
090909080707040505050505050501010101010c01010101040101010101010101010d0d010d0d0101010c0c0c0c0c0c010101010101010404011f010101020303020202020202070207070808080909140101010111111111111111111111111111111101010101140112121212111212121201020114111111142811111114
0909080807040404040404010101010101010c0c0101040101010101010101010c0c0c0c0c0c0c0c0c0c0c010c0c0e0c0c0c0c0c0c0c0c0c040101010101010103020202030202020207070808090909140101010101010101040404110404040101010101010101140101010101020202020202020114110b0b1411110b0b14
090808080707040407070701010101010c0c0c0101010101040104010101010c0c0e0e0c0c01010c0e0e0c0c0c0e0e0e0e0e0e0e0e0e0c0c040104040101010101020202020202020207070708080909141414141418141414140411111104141414141814141414141414141414141814141402020214141414141414141414
090808080707070707070c0c0c0c0c0c0c01010101040101010101010101010c0e0e0e0e0c0c0c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c2401040c0101010101020302020202030202070708080909020202020202020202020202020202020202020202020202020202020202020214141414141414141414141414141414
0909080c0c0c0c0c0c0c0c07070c010101010101010101040101010101010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c01010c0c0c0c0c0101030202020202020202070708080909021919191919191919191919191919190202021919191919191919191919190214111d111111111d11110b140b111114
090909080707070707070707070c010104010101010101010101010101010c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c0c0c010303020202020202020707080808090219332a2c342e3d19313e373d454619040202192a392a3b3d362e373d3c190214111411111128142811111411112814
090908080707070707070707070c0101010104010101010101010101010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0e0e0c0c0c0c01020202020302020202070708080909021911111111111119111111111111190402021911282919111119292811190214111411111129142911111c11112914
0908080807070707070c0c0c0c0c01010101010101240101010101010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c010102020202020202020207070808090902193b2a2c342e3d19452f323c314519040202190b11111d11111d11110b190214111114141414141414141414141414
0909080807070707070c0401010101040101010101010104040101010c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c010c0c0101020203020202020203070708080909021911111111111119111111111111190402021919191919111119191919190214111511111129142911111c11112914
090908080c0c0c0c0c0c04040404010101010101040401010401010c0c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c01040c010101020203020203030303070708080809021911111111111113111111111111190402021911282919111119292811190214111411111128142811111411112814
0909080907070707040404040606040101010101040101010104010c0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0c0c0c0c0c0c0c01010102030302030307030307070808090902191919111119191919191111191919020202190b11111d11111c11110b1902141a14111111111d11110b140b111114
__sfx__
000100002365024650206501e64000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000245202a6403075034660367703667034770326602f6602d75029650297502a640296402b7402c6502e6502f7502f6502d640296302563022720000000000000000000000000000000000000000000000
0001000017070160601505016050170501a06021060290702f0700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f2710e1710e1710d1710d1710c1710c1751e2711d7711d7711d7711b7711b7711b771197711977119771177311771500100001000050000000000000000000000000000000000000000000000000000
000100001263113341164511335117451133511544111341144310e331114210b3210c411073110a41104611236001f6002f50029500235001e5001e500225002750029500255001f5001e500000000000000000
011800002b4252b42529425264252942529425264252442526425264252442523425244252342521420214251c4201c4201c4201c4201c4251d4001d4201d4251c4201c4201c4201c42515425174251a4251d425
011800001c4201c4201c4201c4201c425000001d4201d4251f4201f4201f4201f4201f4201f4201f4201f4251f4201f4201f4201f4201f4201f4201f4201f4251f4201f4201f4201f4251f4201f4251842517425
0118000000000000000000000000000000000000000000000000000000000000000000000000001d4251f4252242022425224202242520420204251d4251f4252242522420224251f4201f4201f4201f4201f425
011800000000000000000000000000000000000000000000000000000000000000000000000000000000000013320133201332013320133201332013320133251332013320133201332013320133201332013325
011800001a4201a4201a4201a4201a4201a425000001a4251d4251d4201d4251f4201f4201f4201f4201f425244202442024420244202442524000244202442522420224202242022420224251f425224251f425
011800000000022420224251f4201f4201f425000001a4251d4251d4201d4251f4201f4201f4201f4201f4250000024420244252442024420244250000000000224251f4201f4251f4201f4201f4201f4201f425
011800000030013320133251732017320173250030017325153251532015325133201332013320133201332500300133201332513320133201332500300133251332517320173251732017320173201732017325
011800001a4201a4201a4201a4201a425000001a4201a4251d4251d4201d4251f4201f4251f425234251f425244202442024420244202442524000244202442522420224202242022420224251f425224251f425
011800002240022420224251f4201f4201f4251a4051a4251d4251d4201d4251f4201f4201f4201f4201f4250000024420244252442024420244250000000000224251f4201f4251f4201f4201f4201f4201f425
011800001330013320133251732017320173250030017325153251532015325133201332013320133201332500300133201332513320133201332500300133251332517320173251732017320173201732017325
011800002442024420244202442024425000002442024425234202342023420234202342500000234252442526420264202642026425244202442024420244252342023420234202342521420214202142021425
01180000000002442024425244202442024425000001f425224251f4201f4251f4201f4201f4252342524425264202642526425264252442524425244252442523425234252342523425214251d4251d4201d425
011800000030013320133251732017320173250030017325133251732017325173201732017325133251532517320173251732517325153251532515325153251332513325133251332511325153251532015325
011800001f4201f4201f4201f4251d4201d425000001f4251f42515425174251a4251f4201f4252142021425234202342023420234252442024425000002b4252b4252b425294252642529425294252642524425
011800000000022425214251f4251d4251a4251d4251f4251f4201f4201f4201f4201f4201f4201f4201f4250000022425214251f4251d4251a4251d4251f4251f4201f4201f4201f4201f4201f4201f4201f425
01180000003001732515325133251132011325153251332513320133201332013320133201332013320133250c300173251532513325113201132515325133251332013320133201332013320133201332013325
0118000026425264252442523425244252342521420214251f4201f4201f4201f4201f425000001d4201d4251f4201f4201f4201f42515425174251a4251d4251f4201f4201f4201f4201f425000001d4201d425
011800001f4201f4201f4201f4201f4201f4201f4201f425000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001332013320133201332013320133201332013325000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011800001f4201f4201f4201f4201f4201f4201f4201f4251f4201f4201f4201f4201f4201f4201f4201f4251f4201f425000001f4201f4251f42518425174251a4201a4201a4201a4201a425000001a4201a425
011800000000000000000000000000000000001d4251f425234202342523425234251f4251f4251d4251f425224251f425224251f4201f4201f4201f4201f4250000022420224251f4201f4201f425000001a425
011800000000000000000000000000000000000000000000133201332013320133201332013320133201332513320133201332013320133201332013320133250000013320133251732017320173250000017325
011800001d4251d4201d4251f4201f4201f4201f4201f4251f4201f4201f4201f4201f4201f4201f4201f4251f4201f425000001f4201f4251f42518425174251a4201a4201a4201a4201a425000001a4201a425
011800001d4251d4201d4251f4201f4201f42500000000001f4201f4201f4201f4201f4201f4201f4201f4251f4201f4201f4201f4201f4201f4201f4201f4250000022420224251f4201f4201f425000001a425
011800001532515320153251332013320133250000000000173251732517325173251732517325173251832519325183251732513320133201332013320133250000013325173201732017325000000000017325
011800001d4251d4201d4251f4201f4251f425234251f425244202442024420244202442500000244202442522420224202242022420224251f425224251f4252442024420244202442024425000002442024425
011800001d4251d4201d4251f4201f4201f4201f4201f425000002842028425284202842028425000001f425224251f4201f4251f4201f4201f4201f4201f425000002442024425244202442024425000001f425
011800001532515320153251332013320133201332013325000001332013325133201332013325000001332513325173201732517320173201732017320173250000013320133251332013320133250000013325
011800002242022420224202242022425000002242524425264202642026420264252442024420244202442522420224202242022425214202142021420214251f4201f4201f4201f4251d4201d425000001f425
01180000224251f4201f4251f4201f4201f42522425244252642026425264252642524425244252442524425224252242522425224251d4251d4251d4201d4250000022425214251f4251d4251a4251d4251f425
011800001332517320173251732017320173251332515325173201732517325173251532515325153251532513325133251332513325113251532515320153250000017325153251332511320113251532513325
011800001f42515425174251a4251f4201f4252142021425224202242022420224252242022425000002b4252b4252b4252942526425294252942526425244252642526425244252242524425224252142021425
011800001f4201f4201f4201f4201f4201f4201f4201f4250000022425214251f4251d4251a4251d4251f4251f4201f4201f4201f4201f4201f4201f4201f4251f4201f4201f4201f4201f4201f4201f4201f425
011800001332013320133201332013320133201332013325000001732515325133251132011325153251332513320133201332013320133201332013320133251332013320133201332013320133201332013325
011800001f4201f4201f4201f4201f425000001d4201d4251f4201f4201f4201f42515425174251a4251d4251f4201f4201f4201f4201f425000001d4201d4251f4201f4201f4201f4201f4201f4201f4201f425
010c0000000000940009400104001040015400154001040010400114001140011400000000000000000000000000009400094001040010400154001540018400184001c4001c4001c40000000000000000000000
011800001c12521125211252112021125231252412024125231252412024125211251f1201f1201f1201f1251c1051c1251f1201f1201f1201f12524100211251c12521125211252112021125231252412024125
011800001712017125171251712017125171251712017125171251712017125171251712017125171251712017125171251712017120171252110021100231001712017125171251712017125171251712017125
011800001332013325003000e3200e325003000a3200a3250f3050e3200e325003000a3200a3250e3050e3200e325003001132011325003000e3200e325003001332013325003000e3200e325003000a3200a325
011800002312524120241252612528120281202812028125001002412528120281202812028125241252612528120281252812528125261252412526120261252612526120261252f12524120241252412524125
011800001712517120171251712517120171251712517120171251712515120151201512500100001000010017125171051710517100171051710517125171051710517100171051710517125171051710517100
01180000003000632006325003000a3200a325003001132011325003000e3200e3200e1250e3000e305003000732513305003000e3000e3050030005325163050030012300123050030007325163050030011300
0118000023125211252312023125231252312524125261252812028125281052812028125241052412024125261052312023125231051c125211252112521120211251f125211202112021125231052410526105
0118000017105171051512015125151050010000100001001f1201f125001001d1201d125001001c1201c125001001a1201a125001001712500100001000010000100001001510500100001001a1201a1251a125
01180000003001530002320023251c30021300213001c30013320133251d3001132011325003001032010325003000e3200e3251d300073251c3001a3001830017300153001530015300153000e3200e3250e325
01180000211202112021125394003940032400211202112021125364003640036400364000000000000000000000032400354003b4003140032400314003b4001f1251c1251f125241202412500000241251f125
011800001f1201f125354002112021125324002312023125211251f1201f1251d1251a1251f1251f1251f1201f1252112522120221252112522120221251f1251a1201a1201a1201a1201a1251a1251a1201a120
011800001332013325243001532015325243001732524300003002130021300213001332500300003000e32500300243001332524300243000e32524300243001132520300203000e32500300003001132500300
01180000241252812028125244002440024400244002440000000214002140021400000000000000000000001f1251c1251f12524120241252340023125201252312528125241252612528120281252812528125
011800001a1201a1201a1251f1251a1251f1251f1251f1201f125211252212022125211252212022125241252212022120221202212022125221252112021120211253440034400344001f125000000000000000
01180000344000e32534300343001332534300343000e32535300353001332535300003000e32500300003001132534300343000e32538300383001232538300393000e325393003930013325000000000000000
011800002612524125261202612526125261202612523125241202412524125241252312521125231202312523125231252412526125281202812539400394003b4003b400261202612500000000000000000000
0118000034400344001d125394003c4003b40039400394051c12539400394003940000000000001a125000003c4003b4003c400394003b400394003b4001f1201f125394003940039400000001d1201d12500000
011800001c3001c3001132523300283002830023300233000f32524300243002430000300003000e325003001d3001d300233002330028300283002b30007320073252f3002f3002f30000300053200532500000
011800002412024125234002340028400284002312023125244002440024400244001c125211252112521120211251f125211202112021125214001f4001e4002112021120211251c40000000000002112021125
01180000000002d4002d4001a1201a1253940039400344003440018120181253540017125000000000000000000002d4002d40034400344001a1201a1251a1252612026125241252212022125211251f12500000
01180000000002d4002d4000432004325394003940034400344000232002325354000732500000000000000000000344003440035400354000e3200e3250e3251a3201a325183251732017325153251332500000
010c00000000016120161251610016105221002210022100221002210022100221002210500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c000004500073200732507305073000730007300073000730007300073000730007305000000c5000e500155001d50022500255000000000000095000c50011500175001d5002450029500000000000000000
__music__
00 05 42 43 44
00 06 07 08 44
00 09 0a 0b 44
00 0c 0d 0e 44
00 0f 10 11 44
00 12 13 14 44
00 15 16 17 44
00 18 19 1a 44
00 1b 1c 1d 44
00 1e 1f 20 44
00 21 22 23 44
00 24 25 26 44
00 27 42 43 44
02 28 42 43 44
01 29 2a 2b 44
00 2c 2d 2e 44
00 2f 30 31 44
00 32 33 34 44
00 35 36 37 44
00 38 39 3a 44
00 3b 3c 3d 44
02 3e 3f 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
