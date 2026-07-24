pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--kelin's delivery: rain
--biolardi "vsio neithr" yoshogi
--twitter.com/vsios

vers,vl,t,f,n="v1.2.1",-1,true,false,nil bla,dbl,dpu,dgr,bro,dgr,ltg,whi,red,ora,yel,gre,blu,ind,pin,pea=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 b_l,b_r,b_u,b_d,b_o,b_x=0,1,2,3,4,5 s_ui,s_cg_pm,s_mvx,s_got=0,1,2,3 m_ryn,m_hrain=1,2 fc_d,fc_l,fc_r,fc_u,pl_anms,bt,bp=1,2,3,4,{{1,2,1,3},{17,18,17,19},{33,34,33,35},{49,50,49,51}},btn,btnp c_k,c_o="kelin","old man"nth_msg,usto_nth_msg="nothing interesting in front of me.","i don't have any idea what to do with them both."is_dbg_md,is_3=f,t pzm_ap,pzm_oa="abandoned_path","outside_abandoned"

function it_sts()it_gm()it_ttl()it_crd()it_otr()st_to("title")end
function it_iv_itms()dt_ivitm={}local o=o_itm_id o_vr1=192o"the package i must deliver to the client."o"a pack of fried noodle. simple to cook with hot water."o"a map so i can find the client's place easily."o"a sharp dagger to defend myself."o"a long stick."o"a key with blue tag."o"a key with red tag."o"a rusty old shovel."o"an empty bottle."o"a bottle with green liquid. the label says \"soap\"."o"an old bucket."o"a used lantern. it is full of leftover candle on the bottom."o"a note. it says \"whoever sees the back of the sky will be rewarded the next guide\". huh?"o"another note. it says \"seek under the place where useless stuffs gather.\". hmm..."o"a strainer. can be used to split noodle and hot water."o"a strainer with noodle on it."o"a cooking oil bottle."o"a dried instant noodle."o"a seasoning for noodle."o"an opened seasoning pack."o"a cleaned bowl."o"a dirty bowl."o"a small box of matches."o"an empty lantern. it has spot to hold candle tightly in the middle."o"a lantern with a candle."o"a lantern with lit candle."o"a candle."o"a cut sheet."o"a cleaned spoon."o"a dirty spoon."o"a pan."o"a bottle of water."o_vr1=238o"a rusty bronze key."o"a rusty bronze key. a lump is attached to it."o_vr1=254o"a dirty pan."o"a shovel head."iv_o={192,194,195}end

function mk_cb(cb,vls)dt_cb[cb]=vls end
function it_cb_itms()dt_cb={}local m,c,a=o_cb_msg,o_cb_cpy,mk_cb a("193,195",{1,{209,210},"kelin cut the noodle pack. inside were a dried noodle and a seasoning pack."})a("195,210",{2,{211},"kelin cut the seasoning pack open."})a("196,255",{3,{199},"kelin put the shovel head into the stick."})m("203,218","the candle leftover made it hard to put the candle.")m("192,195","kelin: i am curious too... but the client will be upset at me and my boss will cut my pay.")m("201,213","kelin: without water, it will get soapy")c("201,221","201,213")c"201,254"c"201,239"m("213,223","kelin: the dirty thing stays sticking. need some soap.")c("221,223","213,223")c"223,254"o_cb_ev("203,214",{ev_cndl})a("203,214,a",{1,{215},"kelin melted the candle leftover in the lantern."})a("215,218",{3,{216},"kelin put the candle into the lantern."})o_cb_ev("214,216",{ev_lt})a("214,216,a",{2,{217}})m("214,218","kelin: i could light up the candle, but carrying later will be a problem. i need something to carry it.")end

function mk_usto(cb,vls)dt_usto[cb]=vls end
function it_usto_itms()dt_usto={}local c,m,v,b,ew,a,p,em,ea=o_usto_cpy,o_usto_msg,o_usto_ev,bd,o_swc_mj1,mk_usto,o_pckp1,o_msg1,amsg
a("208,411",{0,n,{{vl,"34,1",407}},n,{b(o_msg1_a,"used some oil under the door and pushed the door. it opened.")}})
a("198,517",{1,n,{{vl,"29,17",515,"29,16",vl}},n,{b(o_msg1_a,"unlocked the lock on the trap door.")}})
a("197,413",{1,n,{{vl,"34,1",412}},n,{b(o_msg1_a,"unlocked the door.")}})
a("213,519",{1,n,{{vl,"34,19",523}},"&put the bowl on the table."})
a("212,519",{1,n,{{vl,"34,19",524}},"&put the bowl on the table."})
a("201,321",{1,{200},n,n,{b(ev_bckt,321,322),b(em,"whoops, i accidentally poured all of the liquid. might as well clean it.")}})
a("201,323",{1,{200},n,n,{b(ev_bckt,323,324),b(em,"whoops, i accidentally poured all of the liquid. might as well clean it.")}})
a("213,324",{1,{212},n,"&washed the bowl. it is clean now."})
a("221,324",{1,{220},n,"&washed the spoon. it is clean now."})
a("195,707",{0,{219},{{vl,"36,10",708,"36,11",706}},"&cut some part of the sheet."})
a("195,710",{0,{219},{{vl,"36,10",705,"36,11",706}},"&cut some part of the sheet."})
a("200,324",{0,n,n,"i was gonna fill it for water, but yuck, it's soapy!"})
a("239,816",{0,n,n,"the lump stuff, on the key head, blocked the key from entering."})
a("238,816",{1,{202},{{vl,"48,1",817}},"the key fits. the inside of the chest is... another bucket...?"})
a("239,324",{1,{238},n,"&washed the key and managed to remove the lump stuff."})
a("200,321",{1,{223},n,"&filled the bottle with water."})
a("254,324",{1,{222},n,"&washed the pan."})
a("222,529",{1,n,{{vl,"32,16",530}},"&put the cleaned pan onto the stove."})
a("223,530",{1,n,{{vl,"32,16",531}},"&poured water into the pan."})
a("208,531",{1,n,{{vl,"32,16",532}},"&added oil to the logs in the stove."})
a("214,532",{1,n,{{vl,"32,16",533}},"&lit the stove, boiling the water."})
a("209,533",{1,n,{{vl,"32,16",534}},n,{b(o_msg1_a,"put the noodle into the boiling water."),b(ea,{"now to wait few minutes while the noodle is being cooked."}),wyt,b(em,"..."),wyt,b(ew,"32,16",535),b(ea,{"looks like the noodle is cooked now.","i need something to take it from the hot water."})}})
a("206,535",{1,{207},{{vl,"32,16",536}},"&put the noodle onto a strainer."})
a("211,524",{1,n,{{vl,"34,19",525}},"&poured the seasoning into the bowl."})
a("207,525",{1,n,{{vl,"34,19",537}},"&put the noodle into the bowl with seasoning."})
a("220,537",{0,n,{{vl,"34,19",538}},"&stirred the noodle until it mixed with the seasoning."})
v("204,415",{b(em,"\"see the back of the sky\", huh?"),wyt,b(ea,{"hmm...","i can't find the back of the sky in this painting."}),wyt,b(ea,{"nope, still no clue.","perhaps, it means the back of the painting of sky.","... found it."}),b(p,205),b(o_itm_msg1,"a piece of paper."),b(ew,"36,3",409)})
v("205,526",{b(ea,{"\"useless stuffs gather\", garbage can fits the clue.","let me see under it.","...","there is a broken floor under the garbage can. i can see the key there."},c_k),b(p,197),b(o_itm_msg1,"a key."),b(ew,"35,16",514)})
v("219,322",{b(ev_bckt,322,324),b(o_msg1_a,"put the cut sheet into the bucket.")})
v("219,321",{b(ev_bckt,321,323),b(o_msg1_a,"put the cut sheet into the bucket.")})
v("199,103",{b(em,"finally!"),wyt,b(ew,"23,1",104),b(o_msg1_a,"managed to dig the dirt out the cave. however, the shovel broke at the end."),b(em,"thank you, old shovel!")})
v("192,1203",{b(ea,{"oh, i have been waiting for this!","thank you very much!"},c_o),b(em,"no problem. sign here that you have received your package."),b(em,"here it is.",c_o),b(em,"thank you! i am off now."),wyt,b(mv_chr,fc_d,1),b(mv_chr,fc_l,1),b(mv_chr,fc_d,2),wyt,b(ea,{"finally, job finished today. what a day!","gonna eat spicy fried noodle with fried egg after getting the payment from boss!"},c_k),wyt,b(pkio,3),b(ac_tr,t,b(st_to,"outro"),2)})
v("220,538",{b(pkio,2),b(ea,{"finally, the time for meal!","gonna enjoy the fried noodle while reading my map"},c_k),b(cg_pm_t,"blank",vl,vl,n,vl),b(ea,{"20 minutes later..."}),b(ew,"34,19",539,"kitchen"),b(cg_pm_t,"kitchen",n,n,n,vl),b(ea,{"*gulps gulps*","that was a great meal!"},c_k),ev_rn_stp,wyt,b(ply_msc,-1),wyt,b(ea,{"i no longer hear the rain. it seems the rain has finally stopped.","time to deal with the cave and the delivery."},c_k)})
m("213,520","this part of table is too damaged to put the bowl.")
m("204,409","nothing looks useful on the painting anymore.")
m("205,514","nothing looks useful under the garbage can anymore.")
m("223,528","eww... not gonna eat from dirty water.")
m("214,529","nothing to cook so not gonna waste these woods inside.")
m("209,531","the noodle will be too soggy if i put it early. put it when boiling.")
m("214,531","&tried to light the stove. however, the woods were too tough to burn.")
m("207,523","ewww... not gonna eat with dirty bowl!")
m("209,524","nope, i prefer soft noodle.")
m("207,524","nope, i prefer to put the seasoning first before the noodle. it spreads and tastes better.")
m("210,524","the pack is not opened yet.")
m("213,321","&tried to wash it with just water. it was still dirty.")
m("213,322","&tried to wash it with soapy water. however, some needs to be wiped using things like sheet.")
m("213,323","&tried to wipe it. some dirtiness was too sticky.")
m("202,308","there is no rope to reach the water in the well.")
m("195,517","&tried to break the lock using dagger, but the lock was too tough.")
m("197,517","the key didn't fit.")
c("213,521","213,520")
c("212,520","213,520")
c"212,521"
c"212,522"
c("214,528","214,529")
c"214,530"
c("209,523","207,523")
c"210,523"
c"211,523"
c("209,525","209,524")
c("222,326","213,326")
c"239,321"
c"254,321"
c"221,321"
c("222,322","213,322")
c"239,322"
c"254,322"
c"221,322"
c("222,323","213,323")
c"239,323"
c"254,323"
c"221,323"
c("195,413","195,517")
c("193,532","210,524")
ev_tobckt(317,22,21)
ev_tobckt(318,20,22)
ev_tobckt(319,17,22)
end

function it_mp_cts()y_r,x_r,is_hr=0,0,f g_mp_cts()end
function g_mp_cts()local o00,o01,o10,o11,oc,im,mp=o_mkmj00,o_mkmj01,o_mkmj10,o_mkmj11,c_mj,it_pm,mk_pm local ea,et,es,em,b,ei,ew,ec,p=amsg,cg_pm_t,swc_mj,o_msg1,bd,o_itm_msg1,o_swc_mj1,mv_chr,o_pckp1

im(mp("blank",0,0,0,0,0,0))

im(mp("intro_forest",16,0,16,8,12,9,dr_ryn),1)
o00(1,16,4,n,n,{b(et,pzm_ap,26,13,fc_l)})
o00(2,16,5,n,n,{b(et,pzm_ap,26,14,fc_l)})
o01(3,23,1,86,{b(em,"a pile of dirt is blocking the entrance. i should find an alternative path.")})
o00(4,23,1,70,{b(em,"i can go inside the cave now.")},{b(et,"cave_tunnel",57,8,fc_u)})
o11(5,23,1,86,{b(ea,{"what?!","the cave is blocked at this time?!","...","i should try other path. hope i can find some place to stay before it fully rains."},c_k),b(es,{{vl,"23,1",103,"16,4",101,"16,5",102}})})
o10(6,16,4,n,n,{b(pkio,0),b(em,"no, not this way."),b(ec,fc_r,1)})
oc(7,16,5,6)

im(mp(pzm_ap,14,10,8,24,14,7,dr_ryn),2)
o10(1,27,13,n,n,{b(et,"intro_forest",17,4)})
o10(2,27,14,n,n,{b(et,"intro_forest",17,5)})
o10(3,14,12,n,n,{b(et,pzm_oa,26,22)})
o10(4,14,13, n,n,{b(et,pzm_oa,26,23)})
 
im(mp(pzm_oa,14,17,8,8,14,8,dr_ryn),3)
o10(1,27,22,n,n,{b(et,pzm_ap,15,12)})
o10(2,27,23,n,n,{b(et,pzm_ap,15,13)})
o11(3,20,20,101,{b(ea,{"*knock knock*"}),wyt,b(em,"hello? anyone there?"),b(ew,"20,20",310),wyt,b(ea,{"hmm...","the door isn't locked.","the house looks old too.","seems no one here.","i guess i will stay inside for a while until the rain stops."},c_k)})
o00(4,20,20,102,{b(ew,"20,20",305)},{b(et,"main_house",39,7),b(ev_plymc,m_ryn),b(ev_bckt,320,321)})
o01(5,20,20,101,{b(ew,"20,20",304)})
o01(6,22,19,98,{b(em,"a barrel. it is shut tightly.")})
oc(7,22,20,6)
o11(8,24,20,104,{b(em,"a deep dark mossy well.")})
o11(9,22,21,107,{b(p,202),b(ew,"22,21"),b(ei,"a bucket.")})
o00(10,20,20,102,{b(ew,"20,20",311)},{b(et,"dark_main",44,8),b(es,{{pzm_oa,"20,20",312,"18,20",314}}),wyt,b(ea,{"...","it's so dark here"},c_k)})
o01(11,20,20,101,{b(ew,"20,20",310)})
o00(12,20,20,102,{b(ew,"20,20",313)},{b(et,"dark_main",44,8)})
o01(13,20,20,101,{b(ew,"20,20",312)})
o01(14,18,20,187,{b(ea,{"an empty lantern. seems used to light up the front house.","i guess i need this now to light up the house."},c_k),b(p,203),b(ew,"18,20"),b(ei,"an empty lantern.")})
o11(15,18,20,187,{b(em,"an empty lantern. seems used to light up the front house.")}) 
o11(16,22,19,160,{b(em,"there is a candle on the barrel."),b(p,218),b(ew,"22,19",306),b(ei,"an old candle.")})
o01(17,22,21,n,{b(em,"the rain reaches here. i don't want to move any further.")})
oc(18,20,22,17,f)
oc(19,17,22,17,f)
o01(20,22,21,169,{b(em,"not much water yet. perhaps, i should wait inside.")})
o01(21,22,21,153,{b(ea,{"the bucket is filled. it will mess my bag if i carry it.","i should bring something to here if i want to use the water."},c_k)})
o01(22,22,21,154,{b(em,"a bucket with soapy water.")})
o01(23,22,21,156,{b(em,"a bucket with cut sheet.")})
o01(24,22,21,155,{b(em,"a bucket with soapy water and sheet. can be used to wash something.")})
o11(25,21,22,146,{b(ea,{"looks like a shovel. let me pull it.","...","it was too hard to pull."},c_k)})
o01(26,21,22,146,{b(ea,{"the soil must be softer after raining.","let me pull it again.","..."},c_k),b(p,196),b(ew,"21,22"),b(ei,"a shovel... without its head.")})

im(mp("main_house",29,0,16,8,12,9),4)
o10(1,39,8,102,{b(ew,"39,8",402)},{b(et,pzm_oa,20,21),b(ev_plymc,m_hrain,3)})
o01(2,39,8,101,{b(ew,"39,8",401)})
o10(3,29,6,n,n,{b(et,"kitchen",37,21)})
o10(4,29,7,n,n,{b(et,"kitchen",37,22)})
o10(5,31,1,102,{b(ew,"31,1",406)},{b(et,"bathroom",39,11)})
o01(6,31,1,101,{b(ew,"31,1",405)})
o00(7,34,1,102,{b(ew,"34,1",408)},{b(et,"bedroom",30,11)})
o01(8,34,1,101,{b(ew,"34,1",407)})
o01(9,36,3,113,{b(em,"a painting of sky.")})
o11(10,33,0,114,{b(em,"a painting of gold ore.")})
o01(11,34,1,180,{b(em,"the door is stuck. i can't push it further.")})
o01(12,34,1,101,{b(ew,"34,1",411),wyt,b(em,"huh? stuck?.")})
o01(13,34,1,101,{b(em,"the door is locked.")})
o11(14,34,1,101,{b(ea,{"the door is locked.","hmm, there is a small rolled piece of paper in the keyhole."},c_k),b(p,204),b(ew,"34,1",413),b(ei,"a piece of paper.")})
o11(15,36,3,113,{b(em,"a painting of sky.")})
o11(16,38,5,63,{b(em,"a note. it says..."),b(ea,{"to anyone who read this note.","hi, this is the owner who wrote this. just wanted to inform you this.","i have moved to a new home and i have no use of this house anymore.","so feel free to use or take anything in this house. you can even own this house if you like."},"note")})

im(mp("kitchen",29,15,16,8,10,8),5)
o10(1,38,21,n,n,{b(et,"main_house",30,6)})
o10(2,38,22,n,n,{b(et,"main_house",30,7)})
o11(3,29,20,99,{b(em,"an empty box.")})
oc(4,29,21,3,f)
oc(5,29,22)
oc(6,31,22,3,f)
oc(7,32,22)
o11(8,29,21,99,{b(pk,{193,206}),b(ew,"29,21",504),b(ei,"a noodle pack and a strainer.")})
o00(9,29,17,84,n,{b(et,"warehouse",42,2)})
o01(10,29,17,84,{b(es,{{vl,"29,17",515,"29,18",vl,"29,16",vl}})})
o00(11,29,16,n,n,{b(es,{{vl,"29,17",509,"29,16",vl,"30,16",512}})})
o00(12,30,16,n,n,{b(es,{{vl,"30,16",vl,"29,16",511,"29,17",510}})})
o11(13,31,22,99,{b(p,208),b(ew,"31,22",506),b(ei,"a bottle of cooking oil.")})
o01(14,35,16,123,{b(em,"a garbage can. it is empty.")})
o00(15,29,17,185,{ev_trpdr})
o01(16,29,18,186)
o10(17,29,17,184,{b(em,"the trap door is locked.")})
o10(18,29,16,168)
o01(19,34,19,94)
o11(20,35,19,95)
o11(21,34,20,110)
o11(22,35,20,111)
o11(23,34,19,130,{b(p,213),b(ew,"34,19",519),b(ei,"picked a bowl. it is dirty.")})
o01(24,34,19,129,{b(em,"a cleaned bowl.")})
o01(25,34,19,129,{b(em,"a bowl with seasoning.")})
o11(26,35,16,123,{b(em,"a garbage can. it is empty.")})
o11(27,37,16,131,{b(p,221),b(ew,"37,16"),b(ei,"a spoon. it is dirty.")})
o11(28,32,16,134,{b(p,254),b(ew,"32,16",529),b(ei,"a pan. it is dirty.")})
o01(29,32,16,128,{b(em,"a stove. there are some woods inside.")})
o01(30,32,16,133,{b(em,"a stove with cleaned pan.")})
o01(31,32,16,135,{b(em,"a stove with pan filled with water.")})
o01(32,32,16,135,{b(em,"a stove with pan filled with water. the log also has been added with oil.")})
o01(33,32,16,132,{b(em,"a lit stove and pan filled with boiling water.")})
o01(34,32,16,136)
o01(35,32,16,137,{b(ea,{"a stove with pan filled with boiled noodle.","i need something to take the noodle from the hot water."},c_k)})
o01(36,32,16,135,{b(em,"a stove with used pan.")})
o01(37,34,19,138,{b(em,"a bowl of noodle with seasoning below it.")})
o01(38,34,19,140,{b(em,"a bowl of stirred noodle with seasoning. ready to be eaten.")})
o01(39,34,19,129,{b(em,"a bowl i used to eat noodle. that was tasty meal!")})

im(mp("bathroom",38,10,32,16,3,4),6)
o10(1,40,11,102,{b(ew,"40,11",602)},{b(et,"main_house",32,1)})
o01(2,40,11,101,{b(ew,"40,11",601)})
o11(3,39,10,n,{b(em,"i look cute even from an old mirror.")})
o11(4,38,10,n,{b(em,"it's empty.")})

im(mp("bedroom",29,9,48,16,8,5),7)
o10(1,29,11,102,{b(ew,"29,11",702)},{b(et,"main_house",33,1)})
o01(2,29,11,101,{b(ew,"29,11",701)})
o11(3,35,13,99,{b(em,"an empty box.")})
oc(4,36,13,3)
o01(5,36,10,145,{b(em,"a bed. nothing interesting anymore there.")})
o01(6,36,11,161)
o11(7,36,10,162,{b(ea,{"a bed with stuck sheet.","something is under the pillow."},c_k),b(p,198),b(ei,"a key with red tag."),b(ew,"36,10",710)})
o01(8,36,10,145,{b(ea,{"a bed.","something is under the pillow."},c_k),b(p,198),b(ei,"a key with red tag."),b(es,{{vl,"36,10",705,"36,11",706}})})
o11(9,36,11,178)
o01(10,36,10,162,{b(em,"a bed with stuck sheet.")})

im(mp("warehouse",42,0,16,16,8,6),8)
o10(1,42,1,n,n,{b(et,"kitchen",29,16)})
o01(2,43,1,99,{b(em,"an empty box.")})
o11(3,43,2)
o10(4,43,3,n,n,{b(es,{{vl,"43,2",vl,"42,2",806,"42,3",805,"43,3",vl}})})
o00(5,42,3,n,n,{b(es,{{vl,"43,2",803,"42,2",vl,"43,3",804,"42,3",vl}})})
o01(6,42,2)
oc(7,44,1,2)
oc(8,45,1)
oc(9,46,1)
oc(10,43,4)
oc(11,44,4)
oc(12,45,4)
oc(13,46,4)
oc(14,47,4)
o11(15,46,4,99,{b(p,201),b(ew,"46,4",813),b(ei,"a bottle of green liquid.")}) 
o11(16,48,1,82,{b(em,"an old chest. it is locked.")})
o01(17,48,1,83,{b(em,"an old chest. it is empty.")})
o11(18,43,1,99,{b(p,239),b(ew,"43,1",802),b(ei,"a rusty key with dirt lump.")})
o11(19,49,2,157,{b(p,255),b(ew,"49,2"),b(ei,"a shovel... head only.")})

im(mp("dark_main",42,7,80,56,5,3),9)
o11(1,42,7,53,{b(em,"i won't move any further. it's too dark there.")})
oc(2,42,8,1)
oc(3,43,7,1,f)
oc(4,44,7)
oc(5,45,7)
o10(6,44,9,102,n,{b(et,pzm_oa,20,21)})
o11(7,43,7,53,{b(em,"there is something below the chair."),b(p,214),b(ei,"a box of matches."),b(ew,"43,7",903)})

im(mp("cave_tunnel",50,1,24,8,12,9),10)
o10(1,57,9,n,n,{b(et,"intro_forest",23,2)})
o10(2,53,1,n,n,{b(et,"blank",-1,-1),b(ea,{"after this, kelin goes through the forest by following her map she carry.","there wasn't any significant obstacles."}),wyt,b(ea,{"30 minutes later..."}),b(et,"client_entrance",-1,-1),wyt,b(em,"*huft*"),b(cg_pl_slpos,53,19),wyt,b(em,"finally, here's the place."),b(ec,fc_u,1),wyt,b(em,"now to deliver the package.")})

im(mp("client_entrance",49,11,8,8,14,9),12)
o11(1,54,17,152,{b(ew,"54,17"),b(o_msg1_a,"opened the fence.")})
o11(2,55,14,167,{b(ea,{"*knock knock*"}),b(em,"yes, yes. be right there.","???"),wyt,b(ew,"55,14",1203),wyt,b(em,"oh, a little girl. what are you doing this hour? should you go home now? it is late afternoon.",c_o),b(em,"good afternoon, old man. i have a package delivery for you."),b(em,"oh that package! yes, i have been waiting for it. give it to me.",c_o)})
o01(3,55,14,15,{b(em,"so, where's the package?",c_o)})

intro_evs={b(cg_pl_v,f),wyt,b(ea,{"one day in a forest..."}),wyt,b(em,"*huft*","?????"),wyt,b(cg_pl_v,t),wyt,b(em,"still a long way before i can finish delivering this package."),b(ec,fc_u,2),b(em,"...i feel hungry now..."),b(em,"it is starting to rain now... i have to reach the cave soon.")}cg_pm("intro_forest",22,8,fc_u)
end

function ev_tobckt(id,slx,sly)o_usto_ev("202,"..id,{bd(cg_mj_pos,320,vl,slx,sly),bd(o_swc_mj1,""..slx..","..sly,320),bd(o_msg1_a,"put the bucket on the ground that the rain can reach.")})end
function ev_plymc(id,id2)if(is_hr)then ply_msc(id)elseif(id2)then ply_msc(id2)end nx_ev() end
function ev_trpdr()if(pl_slx==29 and pl_sly==18)then o_msg1("i can't open it from this side.")else swc_mj({{vl,"29,17",510,"29,16",511,"29,18",516}})end end
function ev_rn_stp()local mjs,slx,sly=pms[pzm_oa].a_mjs pms["intro_forest"].wthr,pms[pzm_ap].wthr,pms[pzm_oa].wthr,is_hr=n,n,n,f is_ev=f o_swc_mj1("21,22",326,pzm_oa)if mjs["17,22"].id==319 then slx,sly=17,22 elseif mjs["20,22"].id==318 then slx,sly=20,22 elseif mjs["22,21"].id==317 then slx,sly=22,21 end o_swc_mj1(""..slx..","..sly,n,pzm_oa)wyt()is_ev=t nx_ev()end
function ev_lt()nx_ev()if(cr_pm==pms["dark_main"])then cb_itm(iv_ocbn_ix,iv_oix,"a")iv_mnix,is_hr=-1,t a_evs({bd(pkio,1),bd(o_msg1_a,"lit the candle in the lantern."),bd(swc_mj,{{pzm_oa,"20,20",304,"22,21",317,"20,22",318,"17,22",319}}),bd(cg_pm_t,"main_house",pl_slx-5,pl_sly-1,n,vl),bd(amsg,{"nice. i can see more now.","...","the inside looks old.","need to find something to eat and something to rid the pile."},c_k),bd(ply_msc,m_ryn),bd(amsg,{"?","it seems it rains hard right now."},c_k)})else iv_mnix=0 tlkr=c_k up_crmsg("it's too humid and windy here. i should try to light it inside...",c_k)tlkr=n end end
function ev_cndl()if(cr_pm==pms["dark_main"])then cb_itm(iv_ocbn_ix,iv_oix,"a")else iv_mnix=0 tlkr=c_k up_crmsg("it's too humid and windy here. maybe i will light it inside...")tlkr=n end nx_ev()end
function ev_bckt(id_chk,id_to)if(is_hr)then local mjs,slx,sly=pms[pzm_oa].a_mjs,-1 if(mjs["22,21"].id==id_chk)then slx,sly=22,21 elseif(mjs["20,22"].id==id_chk)then slx,sly=20,22 elseif(mjs["17,22"].id==id_chk)then slx,sly=17,22 end if(slx>0)then is_ev=f cg_mj_pos(id_to,pzm_oa,slx,sly)o_swc_mj1(""..slx..","..sly,id_to,pzm_oa)is_ev=t end end nx_ev()end

function pkio(d)poke(0x5f80+d,1)nx_ev()end

function it_ttl()mk_st("title",dr_ttl,up_ttl)vc,fr,fr_t=#vers,1,0 vx=128-vc*4 end
function dr_ttl()spr(224,8,16,14,2)spr(39,92,34,8,1)ctx("(z) start",96)ctx("(x) credit",104)print(" 2017 biolardi yoshogi / neithr",0,116)print(vers,vx,1)map(18,3,52,56,3,3)line(61,71,66,71,dbl)spr(pl_anms[fc_l][fr],60,64)end
function up_ttl()fr_t+=1 if(fr_t>4)then fr_t=0 fr+=1 if(fr>4)then fr=1 end end if(bp(b_o))then ply_msc(7)ac_tr(t,bd(st_to,"gameplay"),2)a_evs(intro_evs)sfx(s_cg_pm)end if(bp(b_x))then ac_tr(t,bd(st_to,"credit"),2)sfx(s_cg_pm)end end

function it_crd()mk_st("credit",dr_crd,up_crd)end
function dr_crd()local nm={"biolardi y. / neithr"}crd_el("coder",nm,12)crd_el("story writer",nm,28)crd_el("artist",nm,44)crd_el("sound+music",nm,60)crd_el("special thanks to",{"pico-8","notepad++","indiean as tester","you, the player"},76)end
function crd_el(rl,els,y)rect(4,8,123,119,dgr)print(rl,8,y,gre)local ln=#els for i=1,ln do print("- "..els[i],16,y+8*i,whi)end end
function up_crd()if(bp(b_o)or bp(b_x))then sfx(s_cg_pm)ac_tr(t,bd(st_to,"title"),2)end end

function it_gm()mk_st("gameplay",dr_gm,up_gm)rst_gm()end
function rst_gm()it_iv()it_msg()it_mv()frm,frm_f,pl_fc,pl_x,pl_y,pl_slx,pl_sly,pl_selx_s,pl_sely_s,pl_vis=1,0,fc_d,0,0,0,0,0,0,t it_ev()it_mps()end

function it_otr()mk_st("outro",dr_otr,up_otr)gp_ryn,gp_rynlmt=0,31 end
function dr_otr()otr_fx() local r,e=rectfill,rect palt(blk,f)r(56,56,71,71,blk)e(56,56,71,71,dgr)spr(7,60,60)r(4,8,124,48,blk)e(4,8,124,48,dgr)r(4,108,124,120,blk)e(4,108,124,120,dgr)ctx("congratulation!",12)ctx("kelin has finally finished",22)ctx("her delivery job!",28)ctx("thank you for playing!",38)ctx("hold z+x to return to title",112)palt(blk,t)end
function otr_fx()cry=-8 local gp,tx=0 while(cry<128)do for i=0,5 do tx=24*i+gp line(tx,cry+gp_ryn,tx,cry+4+gp_ryn,blu)end gp=-(gp-12)cry+=16 end end
function up_otr()gp_ryn+=1 if(gp_ryn>gp_rynlmt)then gp_ryn=0 end if(bp(b_x)and bp(b_o))then sfx(s_cg_pm)ac_tr(t,bd(st_to,"title"),2)rst_gm()end end

function it_iv()iv_mnix,iv_mntxtix,iv_itm_ix,iv_oix,iv_oslct_ix,iv_oshft,iv_ocbn_ix,iv_mntxts=-1,0,0,0,0,0,0,{"use on front","combine"}it_iv_itms()it_cb_itms()it_usto_itms()end
function dr_iv()local ybs=64 if(iv_mnix>-1)then if(pl_y>=56)then ybs=20 else ybs=64 end if(iv_mnix==1 and iv_mntxtix==0)then if(pl_fc==fc_d)then if(pl_y<65)then spr(48,pl_x,pl_y+8)end elseif(pl_fc==fc_l and pl_x>8)then spr(48,pl_x-8,pl_y)elseif(pl_fc==fc_r and pl_x<104)then spr(48,pl_x+8,pl_y)elseif(pl_fc==fc_u and pl_y>8)then spr(48,pl_x,pl_y-8)end end palt(blk,f)rectfill(0,ybs+8,128,ybs+24,blk)map(0,0,4,ybs+4,16,2)map(0,3,4,ybs+20,16,1)palt(blk,t)dr_iv_itms(ybs)drw_iv_slctn(ybs)end if(iv_mnix==1)then local ln=#iv_mntxts for i=1,ln do print(iv_mntxts[i],12,96+(i-1)*8,whi)end print(">",8,96+(iv_mntxtix)*8,whi)end end
function drw_iv_slctn(ybs)local gp,is_skip=iv_ocbn_ix+iv_oslct_ix-iv_oix if(#iv_o>0)then pal(dgr,blu,0)pal(gre,whi,0)map(0,4,16+iv_oslct_ix*20,ybs+8,2,2)pal()else dr_unslt(17+20*(iv_oslct_ix),ybs+9)end if(iv_mnix==2)then if(gp>-1 and gp<5)then pal(dgr,ora,0)pal(gre,yel,0)map(0,4,16+gp*20,ybs+8,2,2)pal()end end for i=1,5 do is_skip=f if(iv_oslct_ix==i-1)then is_skip=t end if(gp==i-1 and iv_mnix==2)then is_skip=t end if(not is_skip)then dr_unslt(17+20*(i-1),ybs+9)end end end
function dr_iv_itms(ybs)local ln=#iv_o if(ln==0)then return end for i=1,5 do if(iv_o[i+iv_oshft])then spr(iv_o[i+iv_oshft],20*(i),ybs+12)end end end
function dr_unslt(x,y)spr(6,x+6,y)spr(36,x,y+6)spr(4,x,y)spr(38,x+6,y+6)end
function mv_slctr_l()local ln=#iv_o if(ln>0)then iv_oix-=1 if(iv_oix<0)then iv_oix=ln-1 end if(ln>5)then if(iv_oslct_ix>2)then iv_oslct_ix-=1 elseif(iv_oshft>0)then iv_oshft-=1 else if(iv_oslct_ix>0)then iv_oslct_ix-=1 else iv_oshft=ln-5 iv_oslct_ix=4 end end else iv_oslct_ix=iv_oix end end end
function mv_slctr_r()local ln=#iv_o if(ln>0)then iv_oix+=1 if(iv_oix>#iv_o-1)then iv_oix=0 end if(ln>5)then if(iv_oslct_ix<2)then iv_oslct_ix=iv_oix elseif(iv_oshft<ln-5)then iv_oshft+=1 else if(iv_oslct_ix<4)then iv_oslct_ix+=1 else iv_oshft=0 iv_oslct_ix=0 end end else iv_oslct_ix=iv_oix end end end
function slctr_rst()iv_oslct_ix,iv_oix,iv_oshft=0,0,0 end
function up_iv()if(iv_mnix>-1)then if(bp(b_l))then mv_slctr_l()sfx(s_ui)if(iv_mnix==2)then if(iv_oix==iv_ocbn_ix)then mv_slctr_l()end end if(iv_mnix==0 or iv_mnix==1)then up_crmsg(dt_ivitm[iv_o[iv_oix+1]])end elseif(bp(b_r))then mv_slctr_r()sfx(s_ui)if(iv_mnix==2)then if(iv_oix==iv_ocbn_ix)then mv_slctr_r()end end if(iv_mnix==0 or iv_mnix==1)then up_crmsg(dt_ivitm[iv_o[iv_oix+1]])end end end if(iv_mnix==-1)then if(bp(b_x))then if(iv_mnix==-1)then if(not is_mvx)then sfx(s_ui)iv_mnix=0 up_crmsg(dt_ivitm[iv_o[iv_oix+1]])end end end elseif(iv_mnix==0)then if(bp(b_o))then if(#iv_o>0)then iv_mnix=1 up_crmsg("")sfx(s_ui)end elseif(bp(b_x))then iv_mnix=-1 up_crmsg()sfx(s_ui)end elseif(iv_mnix==1)then local ln=#iv_mntxts if(bp(b_u))then iv_mntxtix-=1 if(iv_mntxtix<0)then iv_mntxtix=ln-1 end elseif(bp(b_d))then iv_mntxtix+=1 if(iv_mntxtix>ln-1)then iv_mntxtix=0 end elseif(bp(b_l)or bp(b_r))then iv_mnix=0 elseif(bp(b_o))then if(iv_mntxtix==0)then itm_frnt()elseif(iv_mntxtix==1)then iv_ocbn_ix=iv_oix ln=#iv_o if(iv_oix<ln-1)then mv_slctr_r()else mv_slctr_l()end iv_mnix=2 up_crmsg("which item i should combine with?")end elseif(bp(b_x))then iv_mnix=0 up_crmsg(dt_ivitm[iv_o[iv_oix+1]])end elseif(iv_mnix==2)then if(bp(b_o))then cb_itm(iv_ocbn_ix,iv_oix)elseif(bp(b_x))then iv_mnix=1 up_crmsg""end end end
function add_itm(spr_ix)add(iv_o,spr_ix)end
function rm_itm(itm_ix)local ln=#iv_o-1 if(ln+1==0)then return end itm_ix+=1 iv_o[itm_ix]=n for i=itm_ix,ln do iv_o[i]=iv_o[i+1]end iv_o[ln+1]=n if(itm_ix==ln+1)then iv_oix-=1 if(iv_oix<0)then iv_oix=0 end if(iv_oshft>0)then iv_oshft-=1 else iv_oslct_ix=iv_oix end else if(iv_oshft>0)then iv_oshft-=1 iv_oslct_ix+=1 else iv_oix-=1 iv_oslct_ix=iv_oix end end end
function cb_itm(ix1,ix2,tag)ix1+=1 ix2+=1 local id1,id2,ln,cb=iv_o[ix1],iv_o[ix2],#iv_o if(id1>id2)then local tmp,t_ix=id1,ix1 id1,ix1=id2,ix2 ix2,id2=t_ix,tmp end if(tag==n)then cb=id1..","..id2 else cb=id1..","..id2..","..tag end local rslt=dt_cb[cb]if(rslt)then local dest_typ=rslt[1] or 0 if(dest_typ==1)then rm_itm(ix1-1)elseif(dest_typ==2)then rm_itm(ix2-1)elseif(dest_typ==3)then rm_itm(ix2-1)rm_itm(ix1-1)end if(rslt[2])then pk(rslt[2])sfx(s_got)end if(rslt[4]==n)then up_crmsg(rslt[3])else iv_mnix=-1 a_evs(rslt[4])return end else up_crmsg(c_k..": "..usto_nth_msg)end iv_mnix=0 end

function it_mps()pms,cr_pm,cr_mjs,cr_a_mjs={},0,n,n it_mp_cts()cr_mjs,cr_a_mjs=n,n end
function it_pm(t_pm,id)cr_id,cr_mjs,cr_a_mjs=(id or 0)*100,t_pm.mjs,t_pm.a_mjs end
function mk_pm(nm,slx,sly,posx,posy,slw,slh,wthr)local pm={slx=slx,sly=sly,posx=posx,posy=posy,slw=slw,slh=slh,mjs={},a_mjs={},wthr=wthr}pms[nm]=pm return pm end
function dr_pm()if(cr_pm)then map(cr_pm.slx,cr_pm.sly,cr_pm.posx,cr_pm.posy,cr_pm.slw,cr_pm.slh)local t_a_mjs,t_spr_ix=cr_pm.a_mjs for pos,mj in pairs(t_a_mjs)do t_spr_ix=mj.spr_ix if(t_spr_ix)then spr(t_spr_ix,(mj.slx-cr_pm.slx)*8+cr_pm.posx,(mj.sly-cr_pm.sly)*8+cr_pm.posy)end end end end
function mk_mj(id,is_actv,slx,sly,is_blk,spr_ix,b_evs,s_evs)local mj={id=cr_id+id,slx=slx,sly=sly,is_blk=is_blk,spr_ix=spr_ix,b_evs=b_evs,s_evs=s_evs}if(is_actv)then cr_a_mjs[(""..slx)..(","..sly)]=mj end cr_mjs[mj.id]=mj return mj end
function cg_mj_pos(id,mpnm,nw_slx,nw_sly)local pm=pms[mpnm]or cr_pm local mj=pm.mjs[id]mj.slx,mj.sly=nw_slx,nw_sly nx_ev()end
function c_mj(nw_id,slx,sly,frm_id,is_actv)o_vr2=frm_id or o_vr2 local t_mj=cr_mjs[o_vr2+cr_id]mk_mj(nw_id,is_actv==n,slx,sly,t_mj.is_blk,t_mj.spr_ix,t_mj.b_evs,t_mj.s_evs)end

function get_frnt()local xfc,yfc=0,0 if(pl_fc==1)then yfc+=1 elseif(pl_fc==2)then xfc-=1 elseif(pl_fc==3)then xfc+=1 elseif(pl_fc==4)then yfc-=1 end return cr_pm.a_mjs[(pl_slx+xfc)..","..(pl_sly+yfc)]end
function itm_frnt()local mj=get_frnt()if(mj==n)then tlkr=c_k up_crmsg(usto_nth_msg)tlkr=n iv_mnix=0 return end rslt=dt_usto[iv_o[iv_oix+1]..","..mj.id]if(rslt==n)then tlkr=c_k up_crmsg(usto_nth_msg)tlkr=n else local msgs,evs,ln=rslt[4],rslt[5],0 if(rslt[1]==1)then rm_itm(iv_oix)end if(rslt[2])then pk(rslt[2])sfx(s_got)end if(rslt[3])then swc_mj(rslt[3])end if(evs)then iv_mnix=-1 if(msgs)then up_crmsg(achr(msgs))tlkr=n else a_evs(evs)return end else up_crmsg(achr(msgs))tlkr=n end end iv_mnix=0 end
function achr(msg)if(sub(msg,1,1)=="&")then return c_k.." "..sub(msg,2)else tlkr=c_k return msg end end
function chk_frnt()local mj=get_frnt()if(mj==n)then o_msg1(nth_msg)else if(mj.b_evs==n)then o_msg1(nth_msg)end a_evs(mj.b_evs)end end
function pk(vls)local ln=#vls for i=1,ln do add_itm(vls[i])end slctr_rst()mv_slctr_l() nx_ev()end
function swc_mj(vls)local ln,cr_mjs,len_cr_mjs,pm,pm_nm,t_mj=#vls for i=1,ln do cr_mjs,len_cr_mjs=vls[i],#vls[i]for j=2,len_cr_mjs do pm_nm=cr_mjs[1]if(pm_nm==vl)then pm=cr_pm else pm=pms[pm_nm] end t_mj=pm.mjs[cr_mjs[j+1]]pm.a_mjs[cr_mjs[j]]=t_mj j+=1 end end nx_ev()end
function cg_pm_t(pm_nm,plslx,plsly,plfc,snd_fx)if(snd_fx==n)then sfx(s_cg_pm)else if(snd_fx!=vl)then sfx(snd_fx)end end local func=bd(cg_pm,pm_nm,plslx,plsly,plfc)ac_tr(t,bd(cg_pzbck,func),3,{2,2,15,10})end
function cg_pzbck(fnc)ac_tr(f,nx_ev,3,{2,2,15,10})fnc()end
function cg_pm(pm_nm,plslx,plsly,plfc)cr_pm=pms[pm_nm]if(plslx!=-1)then pl_slx=plslx or pl_slx pl_x=(pl_slx-cr_pm.slx)*8+cr_pm.posx else pl_x=-8 end if(plsly!=-1)then pl_sly=plsly or pl_sly pl_y=(pl_sly-cr_pm.sly)*8+cr_pm.posy else pl_y=-8 end pl_fc=plfc or pl_fc end

function it_mv()n_stp,is_mvx,mvx_gp=0,f,0 end
function mv_chr(fc_dir,stp)n_stp,pl_fc,is_prs=stp or 1,fc_dir,f if(stp==0)then nx_ev() return end if(fc_dir==fc_l)then if(not fget(mget(pl_slx-1,pl_sly),0))then if(get_frnt()==n or not get_frnt().is_blk)then pl_x-=2 is_prs=t end end elseif(fc_dir==fc_r)then if(not fget(mget(pl_slx+1,pl_sly),0))then if(get_frnt()==n or not get_frnt().is_blk)then pl_x+=2 is_prs=t end end elseif(fc_dir==fc_u)then if(not fget(mget(pl_slx,pl_sly-1),0))then if(get_frnt()==n or not get_frnt().is_blk)then pl_y-=2 is_prs=t end end elseif(fc_dir==fc_d)then if(not fget(mget(pl_slx,pl_sly+1),0))then if(get_frnt()==n or not get_frnt().is_blk)then pl_y+=2 is_prs=t end end else return end if(is_prs)then is_mvx=t mvx_gp+=2 end end
function mvx_chr()if(mvx_gp<8)then if(pl_fc==fc_l)then pl_x-=2 elseif(pl_fc==fc_r)then pl_x+=2 elseif(pl_fc==fc_u)then pl_y-=2 elseif(pl_fc==fc_d)then pl_y+=2 end mvx_gp+=2 if(mvx_gp==8)then mvx_gp=0 n_stp-=1 if(pl_fc==fc_l)then pl_slx-=1 elseif(pl_fc==fc_r)then pl_slx+=1 elseif(pl_fc==fc_u)then pl_sly-=1 elseif(pl_fc==fc_d)then pl_sly+=1 end if(n_stp==0)then is_mvx=f local stp_mj=cr_pm.a_mjs[""..pl_slx..","..pl_sly]if(is_ev)then nx_ev() else if(stp_mj)then a_evs(stp_mj.s_evs)end end end end end end
function up_mvx()local ec=mv_chr if(not is_mvx)then if(not is_ev)then if(bt(b_l))then ec(fc_l)elseif(bt(b_r))then ec(fc_r)elseif(bt(b_u))then ec(fc_u)elseif(bt(b_d))then ec(fc_d)end end if(frm!=1 and not is_mvx)then frm,frm_f=1,0 end else frm_f+=0.40 if(frm_f>=1)then frm_f-=1 frm+=1 if(frm>4)then frm=1 end end mvx_chr()end end

function it_msg()tlkr,cr_msg,cr_msgs,is_msgx,msg_ix=n,n,n,f,1 end
function amsg(msgs,itlkr,snd_ix)is_msgx,cr_msgs,tlkr=t,msgs,itlkr up_crmsg(cr_msgs[1])if(snd_ix==n)then sfx(s_ui)else sfx(snd_ix)end end
function nwln_msg(msg)if(msg==n)then return end local nwln_msg,n_chrs,strt_ix,chr_ix,gp_ix,gppd_ix="",#msg,1,29,0,0if(n_chrs>chr_ix-1)then while(chr_ix<n_chrs)do gppd_ix=chr_ix-gp_ix if(sub(msg,gppd_ix,gppd_ix)!=" ")then gp_ix+=1 else nwln_msg=nwln_msg..sub(msg,strt_ix,gppd_ix).."\n"strt_ix=gppd_ix+1 chr_ix,gppd_ix,gp_ix=strt_ix+28,0,0 end end end nwln_msg=nwln_msg..sub(msg,strt_ix,n_chrs)return nwln_msg end
function up_msg()if(is_msgx)then if(bp(b_o))then if(msg_ix<#cr_msgs)then msg_ix+=1 up_crmsg(cr_msgs[msg_ix])else is_msgx,tlkr,msg_ix=f,n,1 up_crmsg()nx_ev()end sfx(s_ui)end end end
function up_crmsg(txt)if(tlkr)then cr_msg=nwln_msg(tlkr..": "..(txt or ""))else cr_msg=nwln_msg(txt)end end
function dr_msg()if(cr_msg)then print(cr_msg,7,96,whi)map(0,0,4,92,15,4)end end

function it_ev()evs,ev_ix,is_ev,wyt_tm,is_wytx=n,0,f,0,f end
function a_evs(nw_evs)if(nw_evs==n)then return end evs,is_ev=nw_evs,t nx_ev()end
function nx_ev()if(is_ev)then local ln=#evs if(ev_ix<ln)then ev_ix+=1 evs[ev_ix]()else ev_ix=0 evs=n is_ev=f end end end
function wyt(dur)local dur=dur or 30 if(is_3)then wyt_tm=dur else wyt_tm=dur*2 end is_wytx=t end
function up_ev()if(is_wytx)then if(wyt_tm>0)then wyt_tm-=1 else is_wytx=f nx_ev()end end end

function up_gm()up_ev()if(not (is_mvx or is_wytx) and iv_mnix==-1)then if(is_msgx)then up_msg()else if(bp(b_o))then chk_frnt()end end end if(not(is_mvx or is_msgx or is_wytx))then up_iv()end if(not (is_msgx or is_wytx) and iv_mnix==-1)then up_mvx()end end
function dr_gm()dr_pm()map(0,0,4,4,15,1)for i=1,7 do map(0,1,4,4+i*8,15,2)end map(0,3,4,76,15,1)dr_msg()if(pl_vis)then line(pl_x+1,pl_y+7,pl_x+6,pl_y+7,dbl)spr(pl_anms[pl_fc][frm],pl_x,pl_y)end if(cr_pm.wthr)then cr_pm.wthr()end dr_iv()end
function dr_ryn()local xlwbs,gpx,gpy,ybs,xlmt,ylmt,ygplm=10,16,16,8,120,72 local xbs=xlwbs while(ybs<ylmt)do if(is_hr)then line(xbs+x_r,ybs+y_r,xbs+1+x_r,ybs+4+y_r,blu)line(xbs+x_r+8,ybs+y_r+8,xbs+1+x_r+8,ybs+4+y_r+8,blu)else line(xbs+6,ybs+y_r,xbs+6,ybs+2+y_r,blu)end xbs+=gpx if(xbs>xlmt)then xbs=xlwbs ybs+=gpy end end if(is_hr)then x_r+=1 y_r+=1.5 ygplm=8 else y_r+=1 ygplm=16 end if(y_r>ygplm)then y_r=0 x_r=0 end end
function cg_pl_v(is) pl_vis=is nx_ev()end
function cg_pl_slpos(slx,sly)pl_slx,pl_sly=slx or pl_slx,sly or pl_sly pl_x,pl_y=(pl_slx-cr_pm.slx)*8+cr_pm.posx,(pl_sly-cr_pm.sly)*8+cr_pm.posy nx_ev()end

function it_st()cr_st,cr_st_nm,sts=n,"",{}end
function mk_st(nm,dr_ev,up_eva)st={dr=dr_ev or no_ev,up=up_eva or no_ev}sts[nm],cr_st_nm=st,nm return st end
function st_to(nwst_nm)ac_tr(f)cr_st_nm,cr_st=nwst_nm,sts[nwst_nm]end
function no_ev()end

function it_tr()frm_tr,frm_tr_spd,tr_ix,anm_tr,is_tr,is_tr_frwd,en_tr_ev,t_ar_x0,t_ar_y0,t_ar_x1,t_ar_y1=0,1,1,{55,54,53,52},f,f,n,1,1,16,16 end
function up_tr()if(is_tr)then frm_tr+=frm_tr_spd if(frm_tr>=10)then frm_tr=0 frm_tr_spd+=0.5 if(is_tr_frwd)then if(tr_ix<4)then tr_ix+=1 else en_tr()end else if(tr_ix>1)then tr_ix-=1 else en_tr()end end end end end
function en_tr()is_tr=f en_tr_ev()end
function dr_tr()if(is_tr)then pal(dbl,blk)for i=t_ar_y0,t_ar_y1 do for j=t_ar_x0,t_ar_x1 do spr(anm_tr[tr_ix],(j-1)*8,(i-1)*8)end end pal()end end
function ac_tr(isfwd,ev,frmspd,ar)frm_tr_spd,en_tr_ev,is_tr_frwd=frmspd or 1,ev or no_ev,isfwd if(ar)then t_ar_x0,t_ar_y0,t_ar_x1,t_ar_y1=ar[1] or 1,ar[2] or 1,ar[3] or 16,ar[4] or 16 else t_ar_x0,t_ar_y0,t_ar_x1,t_ar_y1=1,1,16,16 end if(is_tr_frwd)then tr_ix=1 else tr_ix=#anm_tr end is_tr=t end

function o_msg1(msg,nm)amsg({msg},nm or c_k)end
function o_msg1_a(msg)amsg({c_k.." "..msg})end 
function o_itm_msg1(msg)amsg({c_k.." picked up "..msg},n,s_got)end
function o_itm_id(msg)dt_ivitm[o_vr1]=msg o_vr1+=1 end
function o_swc_mj1(pos,id,pznm)swc_mj({{pznm or vl,pos,id or vl}})end
function o_pckp1(itm_ix)pk({itm_ix})end
function o_usto_ev(cb,evs,itm_typ)dt_usto[cb]={itm_typ or 1,n,n,n,evs}end
function o_usto_msg(cb,msg)dt_usto[cb]={0,n,n,msg}end
function o_usto_cpy(cb1,cb2)o_vr3=cb2 or o_vr3 dt_usto[cb1]=dt_usto[o_vr3]end
function o_cb_ev(cb,evs)dt_cb[cb]={0,n,n,evs}end
function o_cb_msg(cb,msg)dt_cb[cb]={0,n,msg}end
function o_cb_cpy(cb1,cb2)o_vr3=cb2 or o_vr3 dt_cb[cb1]=dt_cb[o_vr3]end
function o_mkmj00(id,cx,cy,s_id,b_evs,s_evs)mk_mj(id,f,cx,cy,f,s_id,b_evs,s_evs)end
function o_mkmj01(id,cx,cy,s_id,b_evs,s_evs)mk_mj(id,f,cx,cy,t,s_id,b_evs,s_evs)end
function o_mkmj10(id,cx,cy,s_id,b_evs,s_evs)mk_mj(id,t,cx,cy,f,s_id,b_evs,s_evs)end
function o_mkmj11(id,cx,cy,s_id,b_evs,s_evs)mk_mj(id,t,cx,cy,t,s_id,b_evs,s_evs)end

function ply_msc(ix)if(cr_msc==ix)then return end cr_msc=ix music(ix)nx_ev()end
function ctx(txt,y,gpx,x)print(txt,(x or 64)-#txt*2+(gpx or 1),y,whi)end
function bd(func,...)local a={...}return function()return func(a[1],a[2],a[3],a[4],a[5],a[6])end end

function _init()ply_msc(6)cr_msc=-1 it_tr()it_st()it_sts()end
function _update()if(not is_tr)then cr_st.up()else up_tr()end end
function _draw()cls()cr_st.dr()dr_tr()end
__gfx__
00000000005551000000000000000000000000000000000000000000005551004440000000000000000000003333333300000225442000003333333311666d11
0000000001dd3310005551000055510000bb3b33333333333333330001dd33104000000000000000000000003331633300054d425445000033255133166666d1
0070070002bbbd2001dd331001dd33100bb00000000000000000033002bbbd2040000000000000000000000033b66d33002244422522000031d44213161ee1d1
00077000081ee18002bbbd2002bbbd200b0000000000000000000030081ee18000000000000000000000000033bbdbd302d4222542d420003255511316ffffd1
0007700008ffff80081ee180081ee180030000000000000000000030f8f88f8f000000000000000000000000333b5dd302d4424422d4420032dd421314666d41
007007000677776008ffff8008ffff800b0000000000000000000030067777600000000000000003300000003b53353b0444452244444520325511131f46d4f1
00000000f0d33d0f05777ff00ff7775003000000000000000000003000d33d0000000000000000033000000033b3b3b3255552d4255552d0312d421311444211
00000000008008000088050000508800030000000000000000000030008008000000000000000333333000003333333352242d4452242d443511115311242211
00333300005551000000000000000000030000000000000000000030000000000000044400000333333000004442d22544421225dddddddd44444444000e8000
033333300dd333100055510000555100030000000000000000000030000000000000000400000003300000005445ddd254451112ddd5ddd55444444400eae800
081ff180bb3331100dd333100dd33310030000000000000000000030000000000000000400000003300000002522444225221112dd11111d541111140ea82e80
08ffff800e1e2220bb333110bb333110030000000000000000000030000000000000000000000000000000004211222542d42225d144421d51444215ea8da2e8
067777600fff88200e1e22200e1e2220030000000000000000000030000000000000000000000000000000002211124422d44244dd44211d4d44211425152d12
f077770f000763200fff88200fff8820030000000000000000000030000000000000000000000000000000004111152244444522d115ddd5411544440251d120
00333300000ff10000ff73800057738003000000000000000000003000000000000000000000000000000000255552d4255552d4dddddddd4444544400251200
004004000008200000228500008825000300000000000000000000300000000000000000000000000000000052242d4452242d44d5ddd5dd5455554500022000
0000000000155500000000000000000003000000000000000000003000000011006cccc0000000000c0000000000000000000000000000003333333304125000
000000000133dd500015550000155500030000000000000000000030001106d106cc1ccc000000000100000000000000000000000000000033b33b33992d5100
00000000011333bb0133dd500133dd500300000000000000000000b006d10cc006c101cc00ccc000cc00c0cc000000000000000000000000353333b3156d2100
000000000222e1e0011333bb011333bb0300000000000000000000300cc000000cc000cc00111c001c00cc11c000000000000000000000003333335366d21000
000000000288fff00222e1e00222e1e00300000000000000000000b0000011000cccccc100cccc000c00c100c000000000000000000000003b3323335d214100
00000000023670000288fff00288fff0033000000000000000000bb00006d1000cc11cc00c111c000c00c000c000000000000000000000003353b33302102410
00000000001ff000083775000837ff00003333333333333333b3bb00000cc0000cc001cc01ccccc00cc0c000c000000000000000000000003335333300000445
00000000000280000052880000582200000000000000000000000000000000000110001100111110011010001000000000000000000000003333333300000051
cc0550cc00555100000000000000000011111111010101010101010101010101414141413131313154566d440000000000000000444545444444444400000000
c000000c05dd35100055510000555100111111111010101010001000000000001544144413b31b3344d551450000000000000000445444444422224400000000
000000000133331005dd351005dd35101111111101010101010101010101010141414151313131b144d561440000000000000000454444544426724400056500
500000050222222001333310013333101111111110101010001000100000000044144414331333132216d122000000000000000054544454222762220056d600
500000050822828002222220022222201111111101010101010101010101010141414141313131314551154400000000000000005444444544267244006dd600
00000000068888600822828008228280111111111010101010001000000000001444144413531333444444540000000000000000444445444422224400566500
c000000cf033330f058888f00f888850111111110101010101010101010101014151414131313131444454450000000000000000445444444444444400000000
cc0550cc0080080000e805f00f508e001111111110101010001000100000000044144d1433133313222222220000000000000000444445442222222200000000
33333333311111134444444433444444444443334442d22544242224b33333333333333333333333333953335339533353395339333953395339533324452444
33b33b3315bb33214544444433344444454444335445dd4244511445353338e33d533d5333333333333443334334433343344334333443344334433322222225
353333b31bb3b3514444445435444454444443b325224442555111423353328335b5db5333221133333453334224533342245225333452245334533352d54624
333333531b33332144444444333444444444445342d42225441111143e833b53333b5333325b351333355333544d45335d5d4d45333dd45545544533d2411522
3b333333133b3221444444443b4444444444433322d44244411111123823333333bdd53332b3b313333953334544545344445544333d455442254523d2655d24
3353b33331532513444444443334444444444433444445224111111233b38e3335d33253313b3513333443335335533353355335333453354334433322222225
3335333333122133445444443344444444544333255552d451222212353328333233335331b35213333d53335114513351145114333d5114511451332545d445
333333333514215344444d4433344d444444443352242d44254445523353b333333333333315513333345333333333333333333333311333333333332dd22252
2445244544444444000000000011110011111111151514144424222422222222555544445555444455554444333953394545444445dddd54ddddd5d555222225
24545454544444440011110001444410555552214141515144511445223223224544555545445555411111553334433445d5444445444254dd4d444444444422
5445244554444444014949100111111022222221555444545551114221222232555444545554445451111154333452244545555555444255d4d4444444444442
d4552455554555450112111001222210ddd44441222222224412511422222212222222222222122222111222354d4d45454244d545222244dd44444444224442
d44524454444544401d99d1001d99d10544444415554454441251212232222225554454455511544555115443354554445224445454d4454d444444444244415
2455d4554444444401d55d1001d55d1021212121444544554595952222123222444544554441145544454455333553354522222545d442545444444444441415
2545554544445444015dd510015dd51012121211454554455959545222212222454554454511144545455445331451144525552555222245d444441144112415
2dd22252545555450111111001111110111d21112222222225454522222222222222222222222222222222223333333355255545452552545444112244222445
ddddddddd4444445000000000000000055554444111111111111111126d1d621333333333333333333333333333333334444545445dddd545444444441222442
ddd5ddd5dddd444d00255100d020ddd24222222514544541155111112d212d2133d66d33333333333b3333b33331213344445d54454442542441111412224442
dddddddd5555555d01d442102022211152d5462414544541145211115d212d52362222633322113333533333335562d3555554545544425524112222222244d2
d5ddd5dd5552522d02555110212111122241152214244541145521115d5255523d655653325b3513333d4553316622d35d442454454442441442222222444dd1
ddddddddd444444502dd4210dd41414252655d2414254541145521115d525d523dd3d52332b3b3133544dd5331dd22535444225445444254144442200221dd11
ddd5ddd5dddd444d025511102d24212142222225152445111555211155522d21b23d551b313b35133dd511b33b55b25b52222254452222541221122000221111
dddddddd5555555d012d4210242424214545544514544541145521112d2126d13522115331b35213311b353333b3b3b352555254552552451212220000022215
d5ddd5dd5552522d0511115022121111222222221424425114521111d621d6d133bb3b3333155133333333333333333354555255452552541115400000005515
24ddd4d10000000000000000445d5d44666ddd33d33333d113dd3dd1666ddddd24452445244524450000000000000000dd5555dddd5555dd5555555555222222
2555555105525220055252204dd66dd466ddddd535533556d37763dd66ddddd3246d6d54249949540000000000000000dd4442d5dd4442d55dd4d444444444d2
1424222105cccc1005454520456dd6546dddddd225252523377d57636dddddd254d6dd45542422450011111000dd1000dd4442dddd4442dd2d4d114444444d41
1111111105cc6c200544a4204d6dd6d4ddddddd212121213d765d763ddddddd2d46dd655d4224255014442100d202100d52222ddd54442dd24d122444444d4d1
1442422102c66c10025a9510456dd654dddddd6511111116d731163ddddddd33d4dd6d45d42421450d44211001661100dd4544dddd4442dd1d422444444d4dd1
1111111102212110022121104d6dd6d43dddd66526636233d335d36d3dddd51524d6d655242222550115000001d02100dd5442d5dd2222d51221111111111221
14424221000000000000000045d66d545533666522222d11dd6366d355dd3115256d66452545554500000000010d0100dd2222dddd2dd2dd1212222222222121
11111111000000000000000044d5d544522555221111111155555555522555222dd222522dd222520000000000111000d52dd2ddd52dd2dd111dddddddddd111
11111111ddddd5d5ddddd5d524ddd4d11dd511111dd511111d3511111dd511111dd511111dd51111ddddd5d5ddddd5d5ddddd5d5444444443333333333333333
12235221dd4d4444dd4d444425555551dccc5221d2225221d2223221dccc5221daca5221daca5221dd4d4444dd4d4444dd4d44444544444433b33b3333b33b33
12255221d4111144d4111144142422218d5442212d544221335342212d5442218d5442212d544221d4111144d4111144d41111444444445435434353434343b3
15355531d1222214d152221411111111198944311222443113324431122244311989443112224431d14a4a14d1488a14d18a8914444444443334444444444453
2dddd5d2d1ddd514d135d3141442d2212dddd5d22dddd5d22dddd5d22dddd5d22dddd5d22dddd5d2d1dda514d1dda514d1dd9514444444443b44444444444333
23122152541d5144541d514411111111239898522312215223122152231221522398985223122152541d5144541d5144541d5144444444443334444444444433
25311552d4444411d444441114424221253995522531155225311552253115522539955225311552d4444411d4444411d4444411445444443354444444544333
2222222254441122544411221111111122222222222222222222222222222222222222222222222254441122544411225444112244444d4433344d4444444d33
11111111000000003322222333395339333953399339533353395333533953335333333900000000000000000000000000000000000000003344444444444333
19955221029994203324441333344334333443344334533343344333433443334944499400dd110000dd110000dd110000dd1100000000003334444445444433
18955221025dd520353321b333345225333d5224522553335224533352245333532332350dcccc100d6bb6100d6bbd500dccdd500001d00035444454444443b3
15555551052dd56033334153333454443334d444544d5333544453335444533353433434016dd11001c66c1001c66dd0016d5dd0006d16003334444444444453
2dddd5d2062222503b33211333355555333945545559533355555333555953335343343501dd551001dc561001dc55d001dd55d0006dd6003b44444444444333
2598985206666650335333333332233233345335533453332332233323345333255545520b1bd1b00b1bd1b00b1bd1500b1bd150004242003334343434343433
25599552066665d03335333333345114333d5114411d533351145333511d53335111111400b3b30000b3b30000b3b55000b3b550000000003335333333353333
2222222205666650333333333333333333315333333d533333333333333d53333333333303333330033333300333333003333330000000003333333333333333
00000000066666d0000000005339533933395333544444448882883211111111444444440000000022444334433443344334442544d66d254455454444554544
00255100056d55600299942043344334333453334444544588828882145445415444444400dd1100244446b446b446b446b444425465d14245446d5445444454
01d6d210044d4d40025dd5205224522533345333444444448822882214545541544444440d22221025555555555555555555555225124142d354434444544444
0255511002222420052dd560544454443335533322222222222122221454454155455545016dd11052222222222222222222222542142125534d344354444444
02dd4210012222100622225055555555333953334544444483828882145445414444544401dd551022444334433443344334442222d1124454635d5554445455
02551110000000000d4664d02332233233345333444444548882888215544511444444440b1bd1b0244446b446b446b446b44442444445224534456445444544
012d4210000000000d6d6d5051145114333d5333444454458822882214544541444dd44400b3b300255555555555555555555552255552d44d55443444554444
051111500000000005d6d550333333333334533322222222222122211454454154d52d450333333052222222222222222222222552242d444334454444444544
24ddd4d1d5d5d5d50d555dd0544524451111111124ddd4d124ddd4d100000000226dd12222222222255d255255d66d4433333333444400004455454444554444
2555555111122111055d556024499454155552112555555125555551ddddddd224dd11422444444224544542456dd15533b33b33454444004542154445422144
1542245125d22d52044d4d4054956d45145455211e312e2114422421d222211224444442244444422444544255155154353333b344444450442d4154442d4514
2d4224d25d5d25d502222420d426525514244521185158211244422121211112254555422545554225455545221d6122333333534444444052d4d41441d44414
2d4224d25d5dd5d501222210d4422445142545211442421111111111dd444442244454422444544224444442555115443b33333344444440524d4514454d4525
2d4224d25d4dd545000000002455d455152445211c3b5bd1144224212d242421244444422444444222222222444544553353b3334444440041d5541241455414
1d2112d1244544450000000025455545145455211c5b25d112444221242424212444444224444442111111114545544533299233445440001542424142142254
111111112dd22252000000002dd2225215255211111111111111111122121111222d1222222d1222112124442222222235142153444400004454545444444544
002121000066600000942000000490000000000049000000000000000660000000d4250000d42500055222500006111000000000000000000000000000000000
01d994100d6a560000425f006500490024000000049000000000088094d6000000d6d10000d6d100d211112100d6151000d666000066d0000000000000000000
144d9551d6a4a510944d23f0065004400240000045590000090008206dd46000000d5000000d50005d7765150dd551200d55500006655d00066dd00006add000
144425516a4a495149d3c24200650044002400000909aa405490022009dd1000000d5000000d500057ddd5150d00002001510000d65666d060000d5169a9ad51
144425515694942145233d12000552000002400000009090455900600061d00000d6050000d60500565dd5150200502005150000066655d0d2222500d2222500
1d441551022942210f31c1000000494000002d44000046900409aa46000024000d6000100d6bb310565dd5110d0560200d515000006566d02505010025a5a100
01d4151000122110002c1000000009920000090d0cc1600000009060000002450d6600d00d6633d0015d55100256652000d666000006dd000221100002211000
0011110000011100000220000000004200000d200c110000000049900000005000111d0000111d00005555000025520000000000000000000000000000000000
4d000000000a00000000d000000500000000000000000000000ff00000061110000611100006111000000000ddd00000066000000b6000000666d00000d42500
d5d0000000a49000000d620000605200066555100634341000f9ff0000d6151000d6151000d615100600000066dd10006dd5000063d100006212150000d6d100
010225000a9a4900006d6620560066206d2222d1bd2211d10f99ff000dd551200dd551200d955620606d00001116dd105dd5000053350000d1212500000d5000
00100050a9a9a2400d66d6220006d62262222221b222222155fff4000d0000200d000020090a90900055d00001dd1dd0055400000154000056dd4900000d5000
0016aaad0a9a492466d66d2000d66d2056666611543b3311655f400402000020020660200209a090000662000011d11d000260000002b0000555549000d60500
002a699d00a492400d6dd2000d6dd2000566651005336410065400f00d0000200d0650200906602000005d2000011d1d0000260000001b00000000490d6ccc10
0005999d0009240000dd200000dd2000005551000051110000600f000215512002155120026556900000052000001dd10000026000000160000000040d66c5d0
000055d000004000000200000002000000000000000000000000f00000222200002222000022220000000000000011d100000024000000230000000000111d00
0ee00000ee0000000000000000000000000000000000000000000eeeeeee00000000000000000000000000000000000000000000000000000000000000000000
edde000edde00133000060000066000000000000000000000000eddddddde0000000000600000660000000000000000000000000000000000000000000000000
edde00eddde013333006d60006d3600000000006000000000000edddddddde000000006d60006d36000000000000000000000000000000000400000099400000
e88e0e888e10113bbb06d600063160000000006d600000000000e88eee888e000000006d60006316000000000000000000000000000000005440000054430000
e88ee888e10000000006d6000166100000000063600000000000e88e00e88e000000006d60001661000000000000000000000000000000004594000045340000
e888888e10000666600636000666600666066016106666000000e88e00e88e006666006360006666006660666006666006660660066606660004994000043340
e222222e00006dddd606d60006dd6006d66dd60106dddd600000e22e00e22e06dddd606d60006dd6006d606d606dddd606d66dd606d606d60000906000003060
e88ee888e0006366360636000663600636333600063666100000e88e00e88e063663606360006636006360636063663606363666063606360000444000004440
e22e1e222e006333600636000163600633663600063333600000e22eee222e0633361063600016360063606360633360063361110636063605d6d00006660000
e22e01e222e06166600616600061660616161600016661600000e22222222e0616660061660006166061161160616660061610000611611663331500944d6000
e22e001e22e06111160611160061160616061600061111600000e2222222e106111160611160061160161116106111160616000001611161d13135009ddd4600
1ee10001ee1016666101666100166106660666000166661000001eeeeeee10016666101666100166100166610016666106660000006116105d5d39306dd11d00
01100000110001111000111000011001110111000011110000000111111100001111000111000011000011100001111001110000061161000555539009d1d500
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666100000000049006d5d50
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111000000000004000005d0
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0100000000000000010101000101010000000000000000000101010101010100000000000000000000000000000000000000000000000000000001000000010000010000000100000001010101010101010000000001000001010101000001010000000101010001010101010000010101010100000101000101010000000101
0101010101010101010101000100000001010001010101010100000000000000000101010101010100000101010100000101010101010101000001010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
04050505050505050505050505050600000000000c45454545450d0000000050505050000000000000000050505050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
140000000000000000000000000016000000000c454545464545450d00000074735151000000000000006151515151515100000000af0000000000450000000000414147424241410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14000000000000000000000000001600000941414141424242414141000000005151000000000000000061515151515151bd000000af4545000045af0000000041414142424241410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2425252525252525252525252525260041414141474042424741414100005050511e0050505050b3500051515151515151080000003dafbead1cafae4500000041414242424041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
040600000000000000000000000000004840404040424242474141410000705151515070607c7c60b50051515151515151001b45ad3daeafaf3dafafaf00004141474242424141000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
242600000000000000000000000000004040404040424242404047410050515151515151607e7f6051000000000000000000afbfafafaf000000bf3d3d45004141424242474100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000414141404842424240404141005151511e510051607d7d6051000000000000000000af3dafafbf0000adafaf3daf004140424242404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000414141404742424240404141005151515151001e5151515151007d7d60510000000018afbe3daf451bafafbeafae004147424240404100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000194141414742424247414141000000000000000000000051000051515151000000000018afafafbebeafbe080000004140424240414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000050505050b1b3500000000000000051000000000000000000000018af08000000000041414241410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000041414141410b41410a0009414141005051b6b5b051515100797850000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414148474949494141414141474100515160606060515100747474000000000000000041414194a3a3a3a3a3a3a3a3a3950000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000004847404840404840404940484741000051601d60605151007774000000000000000000414147a440a6a6a6a6a6a60e40a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000404040494048404040404840404000001e606060605151007576000000000000000000414740a440a6a6a6a6a6a60e40a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000004148414141414141414141414048000000000000000000000000000000000000000000414040a4403a403ea6a6a64040a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000041414141411a0000001941414141005050504f5050b350500000000000000000000000424242a440393839a53e3a4068a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000005151518051515170700000000000000000000000424242a4474040403939394040a40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000094141414141414141414141410000515151515151515151000000000000000000000041424293a340a3a397aaababaca40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414d4c67676767674c4c4b6a4100005151511e515d51515100000000000000000000004142424242424241a4aaababaca40000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414949676767676740476a4a410000515151515c515151510000000000000000000000414242424242424193a3a3a3a3960000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414a475a586440594040404a410a00515151515c5151511e500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414a6a39393939394040404a4141005151515151516d5151510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000415b4b475b4c402e5b4c4c4b47400051515151511e515151510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000414141414141404047404840404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000194141414141414141414141414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010000001705000301003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
000800000256003500005000256000500005000256001500005000256000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
001000000f0501500000000030000000000000000000000000000000000000000000000000000000000000001f000000000000000000000000000000000000000000000000000000000000000000000000000000
000800002405025050260501a500215001b0001a0000c500005001150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
004000000161203612016120361201612046120661203612016120361201612036120361206612016120461204612046120761206612046120661205612046120261205612066120461204612066120161204612
01400000196121b612196121b612196121c6121e6121b612196121b612196121b6121b6121e612196121c6121c6121c6121f6121e6121c6121e6121d6121c6121a6121d6121e6121c6121c6121e612196121c612
001000000835508305003000030003355003050030508305083550030500305003050335500305003050030508355003050030500305033550030500305003050835500305003050030503355003000030000300
0010000016554165001454414500165541650014544015001a5541950418554175041655415504135440050413544135441455414554155540050000500165001655401500155001450013544005000050016500
001000000c534165000c534145040f544165040f54401504125540050412554115440f544195040f5440f504125540050412554115440f544005040f544115441455413504145540050412544145041455416500
01200000046031c603046031c6021c6031c603046031c6030460304603046031c60304603046031d6121c6130460304603046031c6030460304603046031c6030460304603046031c60304603206001e6121c613
012a00000160000600016000060001600166010160000600016000060019600006001960000600196000060019600006001960015601196000060019600006001960000600196000060019600006001960000600
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
00 00 00 00 00
03 04 42 43 44
03 05 42 43 44
01 41 06 43 44
01 41 08 06 44
02 41 07 06 44
03 41 06 43 44
03 41 09 43 44
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
