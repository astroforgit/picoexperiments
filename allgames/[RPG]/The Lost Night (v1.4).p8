pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
function _init()
menuitem(1,"clear game", _af)
_hb,_bt,_l2,_a=0,2492,true,0.0058
debug,parts,c0ls,_g5,_b={},{},{},{},{}
cartdata"the_lost_night" _c=split"0,0,0,0,112,48"
battle_x,battle_y,battle_w,_d=19,78,90,47
_e=split"-1,1,0,0,1,1,-1,-1" _f=split"0,0,-1,1,-1,1,1,-1" _g=_kx[[
31|96|16|22|-7
%64|96|15|21|-6
%47|96|17|21|-8
%79|96|9|25|-5
%88|96|07|23|-6
%104|96|8|24|-8
]]
_bk,_7,_h=_kz(),_kz(),_kz()
_i=_kx[[
1|1|1|3|3|3|5|5|5|5|5|5|7|7|7|7|7|7|9|9|9|9|9|9%
1|1|1|3|3|3|4|4|5|5|6|6|7|7|8|8|9|9|10|10|11|11|12|12%
1|1|1|3|3|3|4|4|5|5|6|6|7|7|8|8|9|9|10|10|11|11|12|12%
1|5|5|5|5|7|7|7|7|7|7|10|10|10|10|10|10|10|16|16|16|16|24|24%
1|1|1|2|2|2|3|3|3|3|3|3|4|4|4|4|5|5|5|5|6|6|6|6%
1|1|1|9|9|9|9|9|9|9|9|9|9|9|9|9|9|9|9|9|9|9|20|20
]]
_j=_kx[[
1|2|2|3|3|3|3|3|3|3|3|3|4|4|4|4|5|5|5|5|5|5|6|6%
1|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|6|6|6|6%
1|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|5|6|6|6|6%
1|5|5|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2|2%
1|2|2|2|2|2|2|2|2|2|2|2|3|3|3|3|3|3|3|3|3|3|4|4%
1|2|2|3|3|5|5|5|5|7|5|5|5|5|5|6|6|6|6|7|7|8|8|8
]]
_k=split".06,.075,.09,.15,.12"
_l=split"1,2,3,4" _m=split"1,2,3,4,5" _n=split".04,.055,.065,.08,.1" _o=split"1,1.2,1.4,1.6,1.8" _ar()
_a3()
end
function _update60()
_p=time()
_q=sin(_p/2)/2.5
_r=cos(_p)*.2
_x()
_mb()
_le()
end
function _draw()
_w()
clip()
camera()
_l7()
_lx()
for i=0,15 do
pal(i,i+128,1)
end
pal(137,9,1)
clip()
cursor(2,2)
color(8)
for _ao in all(debug) do
print(_ao)
end
end
function _s()
_az()
_au()
_ad()
_9,_cq,_v=_c
_t()
_w,_x=_bb,_ba
music(-1,1000)
_l0()
music(10)
end
function _t(_u)
_y={}
local _z,_0,sx,sy,_1,_2=unpack(_9)
_cd()
for y=_0,_2+_0-1 do
for x=_z,_1+_z-1 do
local _3,_4=mget(x,y)
local _4=fget(_3,1)
local _x,_y=(x-_z)*8+sx,(y-_0)*8+sy
if _3==119 then
_5=v2:_k0(_x,_y-4)
end
if _4 then
_jk(_x,_y)
end
end
end
local _6
if _v then
_6=split(_v[2][5],"|")
end
if _6 then
local x,y=unpack(_6)
_5=v2:_k0(x*8,y*8)
end
_be()
_7=_bk*8
_bd()
_d4()
_ak()
_an()
_ax()
if _u then return end
_ex()
end
function _8()
_b=_cp
_ed(_v)
_9=split(_v[2][1],"|")
_ab=_5+0
_t()
_l0()
end
function _aa()
local x,y=_jm(_bt)
local _ac={
_jo(x,y+1),_b0,_fs,max_hp,acc_lvl,pwr_lvl,rate_lvl,size_lvl,_ah
}
for i=1,#_ac do
dset(i-1,_ac[i])
end
local i=10
for _jq in all(_av) do
dset(i,_jq)
i+=1
end
local i=34
for _bu in all(_ai) do
dset(i,_bu)
i+=1
end
end
function _ad()
local _ae=0
local _ac={
2492,
10,
45,
10,
1,
1,
1,
1,
1
}
for i=1,9 do
local _ag=dget(i-1)
if _ag != 0 then
_ac[i]=_ag
end
end
_ae,_b0,_fs,max_hp,acc_lvl,pwr_lvl,rate_lvl,size_lvl,_ah=unpack(_ac)
local x,y=_jm(_ae)
_5=v2:_k0(x,y)
_5*=8
for i=10,33 do
local _ag=dget(i)
if _ag != 0 then
add(_av,_ag)
end
end
_ai={}
for i=34,64 do
local _ag=dget(i)
if _ag != 0 then
add(_ai,_ag)
end
end
for i in all(_ai) do
_a0[i][2][4]=true
end
_aj=#_av+1
end
function _af()
sfx"52" for i=0,64 do
dset(i,0)
end
end
function _ak()
_al={}
_am=split[[wELCOME BACK MY CHILD.,,dID YOU ENJOY YOURSELF
,AS ONE OF THEM?
,...
,cANDY?
,sURE i'LL HAVE SOME.
,,thanks for playing!
]]
local _ae=[[
61|20|ä mY hOME.
%60|23|aaghh!è... SORRY. ièMISTOOK YOU FOR AèHORRIBLE CHILD.ètAKE THESE.èdON'T FOLOW ME.
%53|27|hAVE YOU BEEN TO PEPE'SèPLAZA? THERE IS A NICEèLADY THAT MAKESèAN EXCELENT EARTH SOUP!.
%55|34|iF YOU GET KNOCKED OUTèYOU'LL RETURN TO THEèLAST VENDING MACHINEèYOU USED.
%62|38|pUMPKIN hOUSE lOOKOUT->
%57|41|tHE PUMPKIN HOUSE ISèSCARY,YOU CAN USE THEèLOOKOUT TO APPRICIATEèTHE ARCHITECTURE THOUGH.
%58|45|wATER.èIF YOU CAN'T SWIMèYOU CAN'T CROSS OVER
%45|42|"pEPE pLAZA" èA PLACE WHERE EVERYONEèIS LATE.
%40|41|i WAS LATE.èSHE'S LATE TOO i GUESS.
%42|35|tHEY SAY cHIPS CANèRAISE YOUR HEALTHèPERMANENTLY.->
%34|37|mY BOY CHUBS LOVED MYèEARTH SOUP. hE WAS AèWEIRD ONE.i REMEMBERèHIM ON NIGHTS LIKE THISèhAVE SOME soup.
%39|24|iF YOU'RE NOT FEELIGèGREAT GET SOME TEA AT AèVENDING MACHINE.
%36|29|tHE SNACKS IN VENDINGèMACHINES MAKE ME FEELèSTRONGER AND FASTER.èmOM DISAGREES
%33|24|i'M TOO TIREDèTO MOVE. gET MEèSOME eARTH sOUPèAND I'LL LET YOU PASS.
%36|21|wHAT A GREAT CHICKEN!
%38|19|cHICKENS FRIGHTEN ME.
%43|26|iT'S LOCKED.ètHE KEY-HOLE IS SHAPEDèLIKE A BONE.èTHERE'S A DOG ONèTHE OTHER SIDE!
%43|23|bARK!èyOU PET THE DOG
%21|29|fIND MY DOG!
%24|8|i HOPE TONIGHTèTHE GHOSTS WILL TAKE ME.
%30|9|"fISHING ISèNOT VERY FUN" èètHAT'S A QUOTE FROMèA BOOK I WAS READING.èI LOST IT THO å
%29|10|fROG RIVER ->
%14|11|i FEEL SOMETHING'S OFFèABOUT YOU.
%2|5|tHE GREAT PUMPKIN IS ANGRY.èi CAN FEEL IT.
%2|5|sOMEONE IS LOOKING FORèYOU.èèaRE YOU LOOKING BACK?
%5|4|àinsightà CORNER.
%5|1|a BOOK ABOUT FISHINGèèeww!! IT'S WET.
%6|14|a HORNED kEYèWONDER WHO DROPPED IT?
%34|1|yOU LOSE YOURSELF INèTHE STAR PATTERNEDèBOOTS.
%38|6|we'll be togetherèagain!á
%42|4|tHE BRIDGE COLLAPSEDèiM FINE ON THISèSIDE THO
%23|35|a BOULDER IS IN YOUR WAY.èMAYBE YOU CAN BLAST ITèWITH EXPLOSIVES.
%19|42|aN OLD FURNACEè"tORTILLA kING" èlOOKS A LITTLE OLD BUTèIT SHOULD STILL WORK.è
%29|42|aS THE NIGHT PASSESèTHE SPIRITS GETèSTRONGER.
%22|46|...hMM, mUSHROOMS.èTHE SMELL MAKES YOUèDIZZY
%9|19|i SAW A KEYèUP THERE.
%3|23|hAhAhA.ètHAT'S sAD.
%1|23|aND THEN lUISA SAIDè"lOU, I'M LEAVING YOU" %10|33|yO nERD!ègOT SOME SHROOMS?
%1|38|sMALLEST ONE.ètAKE MY POWER.èbE WEIGHTLESS
%13|44|tHE COYOTE STATUE'S EYESèSHINE.è"A FEATHERED OFFERING" %7|42|aN OLD hORNED DOOR
%79|1|wE USED TO DRAMA
%89|3|i DON'T HAVE ILLEGALèFIREWORKS HIDDEN INèMY BACKYARD!
%86|21|i LOVE SHOPPING!
%82|22|wE USED TO DRAMA
%89|28|yOU'RE DOING GREAT!èèwHA?  nOèI'M TALKING TO MYSELF.
%107|5|mAUSOLEUM
%97|1|a pALOMAèlIGHTING THIS SHOULD BEèA blast!
%110|43|wE NEVER RETURNèFROM THE pUMPKIN hOUSE.
%50|4|bOOK HOUSE
%76|19|wEENIE RACE!èEVERY DAYè IN PEPE PLAZA
%74|30|yO! i'VE ALWAYS WANTEDèTO MAKE TORTILLASèBY HAND.èi'D SET UP IN THE PLAZA,èAND SLOWLY CREATE DEMANDèAND BOOM!èJACK-UP THE PRICE.èHNNN... CAPITALISMá
%71|25|nEED CANDY REEEEAL BADè:SWEATS:
%76|26|aN OLD RUSTED KEY.èkINDA' LOOKS LIKE AèSKULL.èIT'S A sPOO KEY!
%66|25|a bone SHAPED KEY.
%99|28|i'M NOT SELLING CANDY
%108|23|bEING CLOSER MAEKSèTEH MIND SL...P AWY..
%109|29|sPOOKY gATE
%93|42|dO NOT LET FENCES STOPèYOU, YOUNG ONE.
%84|37|I..DON'T FEEL TOO GOOD,èMY FEET ARE ROOTED TOèTHE EARTH
%75|43|pUMPKIN HOUSEèyOU MADE IT BACKèCOME IN
]]
if _v then
_ae=_v[2][2]
end
_ae=_kx(_ae)
for t in all(_ae) do
local x,y,_ao=unpack(t)
_ji(
x,y,_ao,_al
)
if not _jv(nil,_jo(x,y)) then
_jk(x*8,y*8)
end
end
end
function _an()
_ap={}
_aq={}
local _ae=[[
53|27|1
%60|23|5|
%36|29|2|
%39|24|8|
%21|29|3|
%33|24|04
%34|37|05
%57|41|1|
%42|35|7
%55|34|6
%29|42|8|
%40|41|1
%24|8|2
%10|33|03
%30|09|6|
%2|5|5
%14|11|7|
%9|19|1|
%1|23|6
%3|23|2|
%38|19|5|
%38|6|7
%42|4|4|
%99|28|4|
%86|21|8
%89|28|3
%82|22|1
%89|3|2|
%71|25|6|
%84|37|1|
%110|43|3|
%108|23|7|
%22|46|022
%13|44|024
%36|21|023
%5|1|021
%7|42|016
%6|14|017
%1|38|010
%23|35|027
%19|42|031
%74|30|07
%76|26|029
%109|29|028
%93|42|012
%97|1|030
%66|25|026
%43|23|018
%43|26|025
%34|1|019
%79|1|8|
%-7|12|011|
]]
if _v then
_ae=_v[2][3]
end
_ae=_kx(_ae)
for c in all(_ae) do
_ef(unpack(c))
end
end
function _ar()
_as={}
local _ae=[[
60$18$
112|0|24|24|10|10
>
7|9|uMM...èwHY ARE YOU HERE?
%10|5|wHY DO PEOPLEèKEEP BARGING IN?èI EVEN PUT UP A SIGNè
%12|7|"tHE ART OF ART" è... OK
>
7|9|1
%10|5|4|false
%7|8|14
%10|8|14|false
%9|8|13
%5|4|15
%12|7|15
<60$30$
123|0|45|25|5|10
>
9|6|tHAT GUY...ègIVES ME THE CREEPS
%6|6|pEOPLE THINK IM CREEPYèå
>
9|6|2|false
%6|6|4
>
8|5|5|0|0
<55$27$
112|10|0|40|16|6
>
13|7|tHANKS FOR COMING!è... NOW LEAVE.
>
13|7|7|false
%4|8|13
%8|8|13
%12|6|14|true
>
10|7|5|0|1
<42$27$
112|0|24|24|10|10
>
10|5|wHERE DID ALL OURèFURNNITURE GO?
%7|8|mY TEACHER SAYS GHOSTSèAREN'T REAL.èbUT I'VE SEEN SOME SHIT.èå
>
10|5|7|false
%7|8|3
<36$23$
112|24|8|32|15|8
>
14|7|tHE TOWNèWAS BUILT AROUND THEèOLD pUMPKIN HOUSE.ègIVEN THAT NAME BECAUSEèONCE A YEAR, STRANGEèPUMPKINS WITH FACESèGROW AROUND IT.
%4|8|i FEEL WEIRD PRESENCESèWHEN I'M OUTSIDE.
>
14|7|6|false
%4|8|1
%15|11|20
<45$33$
118|16|24|40|10|7
>
8|7|sHE THINKS SPIRITSèPASS THROUGH THE TOWNèDRESSED AS CHILDERNèON NIGHTS LIKE THIS.
%6|7|i WAS TEN WHEN I CROSSEDèTHE RIVER, JUMPED THEèFENCE, AND PEEKEDèINTO pUMPKIN HOUSE.
>
8|7|6|
%6|7|7
<35$42$
113|32|8|0|14|16
>
6|7|fEELING PRESSUREèIN THE ROOM.è
>
6|7|3
%3|4|20
%4|4|20
%5|4|20
%6|4|20
%7|4|20
%8|4|20
%9|4|20
%10|4|20
%11|4|20
%2|11|20
%3|11|20
%4|11|20
%5|11|20
%6|11|20
%8|11|20
%9|11|20
%10|11|20
%11|11|20
%7|11|15
>
8|12|5|0|1
%5|9|1|1è0è2|.6
%12|3|1è5|8è0è2|.5
%12|2|2|2|1
>
2|14
>
4|1|36|39
<37$39$
113|32|8|0|14|16
>
14|10|tHE HOUSE FEELSèDIFFERENT
>
14|10|3|
%3|4|20
%4|4|20
%5|4|20
%6|4|20
%7|4|20
%8|4|20
%9|4|20
%10|4|20
%11|4|20
%2|11|20
%3|11|20
%4|11|20
%5|11|20
%6|11|20
%8|11|20
%9|11|20
%10|11|20
%11|11|20
%7|11|15
>
8|1|1|0|0
>
4|2
>
2|15|35|42
<55$40$
112|16|45|35|5|8
>
8|6|oNLY THE WIND LIVES HERE.
>
8|6|13
%6|9|14
%9|9|14|true
>
8|7|1|0|1
<22$23$
112|16|45|35|5|8
>
7|8|i SAW A DOG-PERSONèROAMING THE WASTELANDS.
>
8|6|13
%7|6|13
%7|8|2
<18$20$
112|16|45|35|5|8
>
9|6|wHEN i WAS A LADèkIDS WOULD SOMETIMESèDISSAPPEAR.ètHAT'S WHY i'VE NEVERèLEFT THIS HOUSE.èsORRY ABOUT THE SMELL.
>
8|8|15
%9|8|15
%9|6|4|true
<28$19$
118|16|24|40|10|7
>
4|7|oUR FAMILY sTOPPEDèA DINER ROBBERY ONCE.èa WHOMPING BUFFETèIF YOU WILL.
>
4|7|6
%6|9|20
%6|8|20
%8|8|14
<25$7$
123|0|43|25|5|10
>
9|7|bORK!bORK!è(fINALLY MY OWN PLACE.)è
>
9|7|18
<2$2$
118|16|24|40|10|7
>
9|7|gETTING A TASTE OF LIFE?
>
9|7|24
%8|8|27
%9|9|27
<0$28$
112|16|45|35|5|8
>
7|6|gOT MY BUTT KICKEDèAT A BUFFET...ètWICE.
>
7|6|4
<41$0$
112|0|24|24|10|10
>
10|4|fROG RIVER?èmORE LIKE ROCK RIVERèèaM i RIGHT?
>
10|4|5|
>
7|6|4|0|1
<68$22$
112|24|8|32|15|8
>
13|8|mY TWIN WENT THEREèSAYING"HE" WAS CALLINGè
>
13|8|1|
<109$5$
112|0|24|24|10|10
>
8|8|sAVE US?
>
8|8|22
%6|10|6
%10|10|5|
<82$26$
112|10|0|40|16|6
>
8|8|LLEGAS AL FINALèY DESPUES QUE?
>
9|8|23
<1$42$
113|32|8|0|14|16
>
5|6|yOU SMELL LIKEèMUSHROOMS
>
2|6|24|
%5|6|24
%6|6|20
%7|6|20
%8|6|20
%9|6|20
%10|6|20
%11|6|20
%12|6|20
%2|11|20
%3|11|20
%4|11|20
%5|11|20
%6|11|20
>
8|8|2è1è4è3|7è4è6è8è3è5|1
>
2|14
>
4|1|4|38
<4$38$
113|32|8|0|14|16
>
5|6|yOU STILL SMELL LIKEèMUSHROOMS
>
2|6|24|
%5|6|24
%6|6|20
%7|6|20
%8|6|20
%9|6|20
%10|6|20
%11|6|20
%12|6|20
%2|11|20
%3|11|20
%4|11|20
%5|11|20
%6|11|20
>
8|12|2|0|0
>
4|2
>
2|15|1|42
<9$30$
113|32|8|0|14|16
>
11|3|dON'T MIND MEèI'M JUST CHILLIN
>
2|7|20
%4|8|20
%6|7|20
%8|8|20
%10|7|20
%12|8|20
%4|4|20
%7|11|20
%11|3|23
>
8|12|2|0|0
>
2|14
>
4|1|7|27
<7$27$
113|32|8|0|14|16
>
11|3|jESUS! GET GOINGèWILL YA?
>
2|7|20
%4|8|20
%6|7|20
%8|8|20
%10|7|20
%12|8|20
%4|4|20
%7|11|20
%11|3|23
>
8|12|2|0|0
>
4|2
>
2|15|9|30
<62$45$
112|24|8|32|15|8
>
3|6|tHIS IS THE PATHèOF MOBILITY, LITTLE ONE
>
12|11|20
%12|10|20
%12|9|20
%12|8|20
%12|7|20
%6|7|20
%5|8|20
%3|6|9
%3|10|20
>
8|12|2|0|0
>
15|10
>
2|11|36|0
<36$0$
112|24|8|32|15|8
>
0|0|
>
12|11|20
%12|10|20
%12|9|20
%12|8|20
%12|7|20
%6|7|20
%5|8|20
%3|10|20
>
8|12|2|0|0
>
2|10
>
15|11|62|45
<51$3$
113|32|8|0|14|16
>
6|2|bOOKS?èwE GOT 'EM
>
6|2|5|
%6|3|13
%4|4|15
%4|6|15
%4|8|15
%4|10|15
%8|4|15
%8|6|15
%8|8|15
%8|10|15
%12|4|15
%12|6|15
%12|8|15
%12|10|15
>
8|12|2è4|0è1è2è3|1
>
4|2
>
2|15|54|9
<54$9$
113|32|8|0|14|16
>
6|2|bOOKS?èwE GOT 'EM
>
6|2|5|
%6|3|13
%4|4|15
%4|6|15
%4|8|15
%4|10|15
%8|4|15
%8|6|15
%8|8|15
%8|10|15
%12|4|15
%12|6|15
%12|8|15
%12|10|15
>
8|12|2|0|0
>
2|14
>
4|1|51|3
<84$22$
113|32|8|0|14|16
>
0|0|
>
2|9|20
%3|9|20
%4|9|20
%5|9|20
%6|9|20
%7|9|20
%8|9|20
%9|9|20
%10|9|20
>
8|12|2|0|0
>
4|2
>
2|15|94|30
<94$30$
113|32|8|0|14|16
>
0|0|
>
2|9|20
%3|9|20
%4|9|20
%5|9|20
%6|9|20
%7|9|20
%8|9|20
%9|9|20
%10|9|20
>
8|12|2|0|0
>
2|14
>
4|1|84|22
<105$41$
112|24|8|32|15|8
>
0|0|
>
4|9|27
>
0|0|0|0|0
>
15|10
>
2|11|93|37
<93$37$
112|24|8|32|15|8
>
0|0|
>
4|9|27
>
0|0|0|0|0
>
2|10
>
15|11|105|41
<22$39$
112|24|8|32|15|8
>
0|0|0
>
3|7|22
%5|8|22|
%12|9|22
>
5|6|4|0|1
>
15|10
>
2|11|18|39
<18$39$
112|24|8|32|15|8
>
0|0|0
>
3|7|22
%5|8|22|
%12|9|22
>
0|0|0|0|0
>
2|10
>
15|11|22|39
<73$41$
113|32|8|0|14|16
>
4|3|yOU'RE BACKèLET'S GO HOME.
>
4|3|11
%3|6|20
%4|6|20
%5|6|20
%6|6|20
%7|6|20
%8|6|20
%9|6|20
%8|4|20
%8|3|20
%8|2|20
%8|9|13
%5|11|20
%4|11|20
%3|11|20
%2|11|20
%11|11|20
%12|11|20
%13|11|20
%14|11|20
%10|11|15
%6|11|15
>
10|4|6|0è3è4|1
%8|11|1è2è3è4è5è6|0è2è3è4è5è6|1
>
2|14
>
4|1|-10|12
]]
for c in all(split(_ae,"<")) do
local x,y,_at=unpack(split(c,"$"))
_jh(
x,y,_at
)
end
end
function _au()
_av={}
_aw={}
local _ae=_kx[[
60|23|grampsèyOU GOT 45 SWEETS!%
34|1|dashèdASH BY PRESSING é%
01|38|waterèwALK ON WATER%
93|42|fenceèpASS THROUGH THIN FENCES%
43|23|dogètHEY FOLOW YOU NOW%
34|37|key1èyOU GOT EARTH SOUP%
33|24|gate1èTHE GUY FADED. WTF?èkey1%
22|46|key2èyOU GOT MUSHROOMS%
10|33|gate2èi'M GONNA TRIPèkey2%
66|25|key4ègOT BONE KEY%
43|26|gate4ècLOSER TO DOGèkey4%
97|01|key5èGOT AN EXPLOSIVE%
23|35|gate5èbOOM!èkey5%
19|42|key6èfURNACE ACQUIRED%
74|30|gate6èhEHE I''LL BE RICHèkey6%
76|26|key7èGOT THE SKULL KEY%
109|29|gate7ètHE JAW UNHINGESèkey7%
06|14|key9ègOT THE HORNED KEY%
07|42|gate9èiT CLICKS OPENèkey9%
36|21|key10èyOU GOT A CHICKEN%
13|44|gate10ètHE STATUE CRUMBLESèkey10%
05|01|key11ègOT A WET BOOK%
30|09|gate11ètHANKS! yOU FOUND ITèkey11]]
for t in all(_ae) do
local x,y,id=unpack(t)
_ji(
x,y,id,_aw
)
end
end
function _ax()
_ay={}
local _ae=[[
38|28|5|0|.9
%37|29|1è5|0è3è2|.1
%59|37|1è5|0è2|0.8
%43|42|1è5|0è2è1è3è4|.4
%51|41|1è5|0è3|.7
%24|26|1è5è2|0è1è2è3è4|.5
%27|38|1è2|0è2è4|.9
%20|9|1è2è5|0è2è1è3è5|.8
%28|6|1è2è5|0|.9
%6|3|1è2|0è3|1
%13|8|5è2|0è1è3|.9
%6|17|3|0è2|1
%13|23|1è2è3è5|0è1è5|.3
%4|27|2|0è4è6è7|.3
%13|39|1è3|0è7|.6
%5|35|2è5|0è6|.6
%6|46|4|0|.5
%23|43|4è3|0è2|.7
%40|12|1è2è5|0è4è1|.5
%51|18|5|0è1è2|.9
%59|7|4|0è7|1
%40|17|1|0|1
%65|5|3|0|1
%74|10|1è2è3è4è5|0è3è4è8è1è7|.8
%70|19|2è4|0è2|.9
%68|26|1è2è3è4è5|0è2è4è6|.8
%88|5|1è2è3è4è5|0|1
%99|19|4|0|1
%102|1|1è3è4|0è7è6|.8
%102|11|5è2|0è6è4|.6
%107|25|1è2è3è4è5|0è4è7|.7
%87|43|4è1è3|0è1è2|1
%85|45|4è2è5|0è1è2è4è3|1
%109|39|4è5è2|0è4è3è2|1
%73|39|6|0|1
%44|10|1è5|0è2|.8
]]
if _v then
_ae=_v[2][4]
end
_ae=_kx(_ae)
for spwn in all(_ae) do
_eu(unpack(spwn))
end
end
function _az()
_a0={}
local _a1=[[hp teaè1è63
,chipsè10è62
,sodaè10è61
,baconè10è60
,tkykè15è59
,pizzaè15è58
,popè20è57
]]
_a2=split(_a1)
local _ae=_kx[[
45|36|2
%20|1|2
%101|37|2
%99|24|2
%80|01|2
%56|36|3
%06|19|3
%80|36|3
%52|21|3
%33|28|4
%19|44|4
%87|27|4
%65|45|4
%27|20|5
%51|10|5
%20|39|5
%110|18|5
%26|43|6
%97|08|6
%107|44|6
%78|26|6
%36|38|7
%27|02|7
%32|38|7
]]
for c in all(_ae) do
local x,y,i=unpack(c)
_ji(
x,y,_a2[i],_a0
)
end
end
function _a3()
_a6=.5
_mh()
_x=_a4
_w=_a5
music(13)
end
function _a4()
if btnp(ó) then
_s()
end
end
function _a5()
cls()
_mk()
local x=25
local y=30
circfill(x+38,y+23+_ki(),30,13)
sspr(0,96,31,24,x,y+_ki(),62,48)
y+=66
local _ao="óstart game" x=_ku(_ao)
print(_ao,x-4,y,14)
_ca("an rpg by,@eljovenpaul,@afk_mario",y+10,13)
end
function _a7()
_w=_a9
_x=_a8
_mh()
music(-1,1000)
_l0()
music(8,100)
end
function _a8()
if btnp(ó) or btnp(é) then
_a3()
end
end
function _a9()
_mk()
_ca(
"game over,press ó to continue",60+_ki(),14
)
end
function _ba()
_be()
_ce()
if not _cq then
_cv()
_d5()
_fe()
end
end
function _bb()
cls()
_bd()
if not _v then
rect(_bi.x,_bi.y+4,_bj.x+1,_bj.y+5,14)
end
map(unpack(_9))
_lf()
_ei()
_eb()
_db()
_gc()
_jl()
end
function _bc()
local b = _bk*8
local c = _7-b
if c:_k8() > 1 then
_7-=c:_k9()*8
camera(_7.x,_7.y)
else
_ex()
_7=b
_x=_ba
camera(_7.x,_7.y)
end
end
function _bd()
_7+=_h
camera(_7.x,_7.y)
end
function _be(_bf)
local _z,_0,sx,sy,_1,_2=unpack(_9)
local _bh=_bk
_bi=v2:_k0(sx,sy-4)
_bj=v2:_k0(sx+_1*8-2,sy+_2*8-6)
local x,y=(_5.x+4)\8,(_5.y+4)\8
x=x\16
y=y\16
x*=16
y*=16
_bk=v2:_k0(x,y)
if _bh != _bk then
if not _v and not _bf then
_x=_bc
end
end
end
function _bg()
_w=_b2
_x=_bv
sfx"52" _mh()
_br=0
_bs=0
_ed(_b1)
_bt=_b1[1]
local _bu={-1,split(_a2[1],"è")}
_bw={_bu,_b1}
music(-1,1000)
_l0()
music(8,100)
end
function _bv()
if btnp(î) then _br-=1 end
if btnp(É) then _br+=1 end
_br=_br%3
_bs=max(0,_bs-.125)
if btnp(ó) then
if _br<#_bw then
local _bx=_bw[_br+1]
local _ao,_by,s,_bz=unpack(_bx[2])
if
_bz or
_by>_fs
then
_bs+=1
sfx"53" _me(_bz and"sold out" or"not enough candy",30)
return
end
if s == 63 then
_b0=min(_b0+5,max_hp)
elseif s== 62 then
max_hp+=3
_b0=max_hp
elseif s==61 then
rate_lvl+=1
elseif s==60 then
_ah+=1
elseif s==59 then
acc_lvl+=1
elseif s==58 then
pwr_lvl+=1
elseif s==57 then
size_lvl+=1
end
_fs-=_by
_bx[2][4]=true
sfx"52"
if _bx[1] != -1 then
add(_ai,_bx[1])
end
else
_b1=nil
sfx"52" music(-1,1000)
_l0()
music"10" _aa()
_x=_ba
_w=_bb
end
end
_bw[1][2][4]=_b0==max_hp
end
function _b2()
local x,y,w,h=28,20
y+=_ki()
x-=(2-rnd"4" *_bs)
_mk()
_b3(x+30,y-6,52,66)
_b8(x,y+62,80)
local _x,_y=x-2,y+26
spr(206,_x,_y,2,4)
spr(206,_x+8,_y,2,4,true)
_x+=1
_y-=10
_l5(_x,_y,22,9,14)
spr(5,_x+2,_y+2,2,1)
print(_kr(_fs),_x+13,_y+2)
end
function _b3(x,y,w,h)
local s=0
if _br<#_bw then
s=_bw[_br+1][2][3]
end
_l5(x,y-3,w,h,14)
x+=13
print("YOU",x,y,13)
y+=7
_ac={
{"hp:" .._b0.."/" ..max_hp,63},{"maxhp:" ..max_hp,62},{"move:" ..acc_lvl,59}
}
for stt in all(_ac) do
_b5(x,y,s,unpack(stt))
y+=6
end
y+=4
print("ATTACK",x,y,13)
y+=7
local _ac={
{"size:" ..size_lvl,57},{"power:" ..pwr_lvl,58},{"rate:" ..rate_lvl,61},{"speed:" .._ah,60}
}
for stt in all(_ac) do
_b5(x,y,s,unpack(stt))
y+=6
end
end
function _b5(x,y,s,_ao,ss)
local c=s==ss and 7 or 6
print(_ao,x,y,c)
local _b6=s==63 and"+5" or"+1"
if c==7  then
print(_b6,x-9,y)
end
end
function _b8(x,y,w)
for i=1,#_bw do
local c=i-1==_br and 15 or 6
local bc=i-1==_br and 7 or 14
local _bx=_bw[i]
local _ao,_by,s,_bz=unpack(_bx[2])
_l5(x-2,y-3,w+4,12,bc)
spr(s,x,y-1)
print(_ao,x+10,y+1,c)
local _ao=_bz and"out" or"buy" print(_ao,x+w-12,y+1,c)
if not _bz then
c=i-1==_br and 15 or 14
spr(5,x+w-32,y+1,2,1)
print(_kr(_by),x+w-22,y+1,c)
end
local s=_bx.s
s=63
local _x=x+26
y+=13
end
local c=2==_br and 15 or 6
local bc=2==_br and 7 or 14
x=x+w-18
_l5(x,y-2,19,9,bc)
print("exit",x+2,y,c)
end
function _ca(_cb,y,c)
local _cc=split(_cb)
for _ao in all(_cc) do
x=_ku(_ao)
_kh(_ao,x,y,c)
y+=6
end
end
function _cd()
_cf=v2:_k0(3,3)
_cg=v2:_k0(1,5)
_ch=v2:_k0(4,4)
_ci=_kz()
_cj=_kz()
end
function _ce()
local _ck=_5+_cg
if _j1(_ck,2) then
_v=_ct(_as)
if _v then _8() end
end
if _j1(_ck,3) then
local cx,cy,_cm,_cl=_ck.x\8,_ck.y\8,_v[2][6],true
if _cm then
_cm=_kx(_cm)
for _bu in all(_cm) do
local x1,y1,x2,y2=unpack(_bu)
if x1 == cx and y1 == cy then
_5=v2:_k0(x2*8,y2*8+4)
_cl=false
if x2<0 then
_5.y-=2
music(-1,1000)
_l6(
12,12,105,#_am*7+6,_am
)
end
end
end
end
if _cl then
_5=_ab
end
_ci=_kz()
_cj=_kz()
_v=nil
_9=_c
_be(true)
_t()
if _cl then
_cp=_b
end
_l0()
end
if btnp(ó) then
if _cq then
_cq._mf=15
_cq.onend=_jp
_cq=nil
sfx"60" else
local _ao=_ct(_al)
if _ao then
_mg(_ao[2])
sfx"61" return
end
_b1=_ct(_a0)
if _b1 then  return _bg() end
end
end
end
function _ct(_cu)
local x,y=(_5.x+4)\8,(_5.y+4)\8
local o=_jj(x,y,_cu)
if o then return o end
for i=1,8 do
local _x=x+_e[i]
local _y=y+_f[i]
o=_jj(_x,_y,_cu)
if o then return o end
end
end
function _cv()
local _cw=_cj:_k8()>0
local n=_kz()
local ix,iy,_hi,frc,dsh_spd,_cx=0,0,.085,.815,1.2,0.95
local jp=sin(_p*3)*.04
if btn(ë) then
ix+=1
_cy=false
_cz=false
end
if btn(ã) then
ix-=1
_cy=true
_cz=false
end
if btn(î) then
iy-=1
_cz=true
end
if btn(É) then
iy+=1
_cz=false
end
if ix*iy !=0 then
ix*=0.707
iy*=0.707
end
if
btnp(é) and
not _cw and
_jv"dash" then
_cj.x+=ix*dsh_spd
_cj.y+=iy*dsh_spd
sfx"62" end
_ci.x += ix*_hi
_ci.y += iy*_hi
_ci.x -= ix*jp
_ci.y -= iy*jp
if _jz({
v=_5,_c2=_ch,of=_cg
},_cp)
then
return _g2()
end
local _c3=_di(_5,_ci,_cj,_ch,_cg)
_5=_c3.v
_5+=_ci+_cj
_ci*=frc
_cj*=_cx
if abs(_cj.x)<.2 then _cj.x=0 end
if abs(_cj.y)<.2 then _cj.y=0 end
if abs(_ci.x)<.02 then _ci.x=0 end
if abs(_ci.y)<.02 then _ci.y=0 end
if
_ci:_k8() != 0 and
_p*100%1 == 0 and
_cj:_k8() == 0
then
sfx"63" _lt(_5.x,_5.y)
end
if
_cj:_k8() > .5 and
flr(_p*20)%2==0
then
_lu(_5.x,_5.y,_ci.x,_ci.y)
end
end
function _db()
local s = _cz and 3 or 2
local x,y=_5.x,_5.y
local bx,by,hx,hy=x,y,x,y
local cx,cy=bx+5,by+6
if _cy then
cx=bx-1
bx+=2
hx-=1
end
local _dg=cos(_p*3)
if _ci:_k8()==0 then
hy+=min(0,sin(_p*.9))+1.2
end
if
abs(_ci.y) > 0 and
_ci.x ==0
then
hy+=min(.2,_dg)+1
end
if abs(_ci.x) > 0 then
hy+=1
hx+=min(.2,_dg)+1
end
local _dk={24,8,5,3,bx,by+7,5,3,_cy}
local _dl={s,hx,hy,1,1,_cy}
_km(unpack(_dk))
_kl(unpack(_dl))
sspr(unpack(_dk))
sspr(40,8,3,4,cx,cy)
spr(unpack(_dl))
end
function _di(v,d,_dj,_c2,of)
local w,h=_c2.x,_c2.y
local nx=v.x+d.x+_dj.x
local ny=v.y+d.y+_dj.y
local n=v2:_k0(nx,ny)
local _dm=n+of
local _dn=n+of-1
local _do=n+of
_do.y-=1
_do.x+=2
local _dp=n+of+2
local _dq=n+of
_dq.y+=2
_dq.x-=1
if not _jy(n,_c2,of) then return {v=v,d=d,_dj=_dj} end
local _dy=_dw(
d,_dn,_do,_dp,_dq
)
if _dy > 0 then
v.x+=_e[_dy]*.3
v.y+=_f[_dy]*.3
else
if _jy(
v2:_k0(nx,v.y),_c2,of
) then
d.x *= 0
_dj.x *= -1
end
if _jy(
v2:_k0(v.x,ny),_c2,of
) then
d.y *= 0
_dj.y *= -1
end
end
return {v=v,d=d,_dj=_dj}
end
function _dw(
_dx,a,b,c,d
)
local dx=_dx.x
local dy=_dx.y
local _dz={}
local _a=_jy(a,_cf)
local _b=_jy(b,_cf)
local _c=_jy(c,_cf)
local _d=_jy(d,_cf)
add(_dz,_a)
add(_dz,_b)
add(_dz,_c)
add(_dz,_d)
local _d0=0
for c in all(_dz) do
if c then _d0+=1 end
if _d0>1 then return 0 end
end
if dy < 0 then
if _a then return 2 end
if _b then return 1 end
end
if dx > 0 then
if _b then return 4 end
if _c then return 3 end
end
if dy > 0 then
if _c then return 1 end
if _d then return 2 end
end
if dx < 0 then
if _a then return 4 end
if _d then return 3 end
end
return 0
end
function _d4()
_d6={}
_d7=0
_d8=0
_d9=_5
_ea=false
end
function _d5()
if not _jv"dog" then return end
_d8=max(0,_d8-.1)
if
_5 != _d6[#_d6] and
_d8 == 0
then
_d8=1
add(_d6,_5)
end
local a=_d9
local b=_d6[1]
if b then
local c=b-a
if c:_k8() > 10 then
_ea=b.x>a.x
_d9+=c:_k9()*0.5
if _p*100%20 == 0 then
_lt(v.x+4,v.y-3)
end
else
del(_d6,b)
end
end
end
function _eb()
if not _jv"dog" then return end
local s=_kv({40,41})
local x,y=_d9.x,_d9.y+_ki()
_kl(s,x,y,1,1,_ea)
spr(s,x,y,1,1,_ea)
end
function _ed(_ee)
local _ae=_ee[1]
local x,y=_jm(_ae)
_5=v2:_k0(x*8,((y)*8)+4)
_ci=_kz()
_cj=_kz()
end
function _ef(x,y,_eg,fx)
if _jv(nil,_jo(x,y)) then return end
local _eh=split"48,49,50,53,27,28,29,30,7,8,23,24,121,122,126,56,55,40,20,90,9,10,240,241,242,243,249,246,247,248,244" local _ej=_kx[[
24|24|6|4
%24|28|6|4
%32|24|6|4
%32|28|6|4
%80|8|6|4
%80|12|6|4
%24|24|6|4
%32|24|6|4
%56|16|5|5
%56|16|5|5
%56|16|5|5
%56|16|5|5
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
%100|32|1|1
]]
local _ek={
v=v2:_k0(x,y),fx=fx,_el=_eh[_eg],_dk=_ej[_eg],t=rnd()*10,_eg=_eg
}
local _ae=_jo(x,y)
add(_aq,_ae)
_ap[_ae]=_ek
end
function _ei()
for i in all(_aq) do
local n=_ap[i]
local v,_el,_dk,_eg,t,fx=n.v*8,n._el,n._dk,n._eg,n.t,n.fx
local x,y=v.x,v.y
local sx,sy,sw,sh=unpack(_dk)
local hy=y
if _eg<13 then
hy+=min(0,sin((_p+t)*.8))+1.2
end
_km(sx,sy,sw,sh,x+1,y+7,sw,sh,fx)
_kl(_el,x,hy,1,1,fx)
sspr(sx,sy,sw,sh,x+1,y+7,sw,sh,fx)
spr(_el,x,hy,1,1,fx)
end
end
function _eu(
x,y,_eg,_ev,_ew
)
local point = {
x=x,y=y,_eg=split(_eg,"è"),_ev=split(_ev,"è"),_ew=_ew
}
add(_ay,point)
return point
end
function _ex()
local _ez,_e0=_bk.x,_bk.y
_cp={}
for pnt in all(_ay) do
local x,y,_eg=pnt.x,pnt.y,pnt._eg
local _ev,_ew=pnt._ev,pnt._ew
local _e1=_j5(
x,y,_ez,_e0,_ez+16,_e0+16
)
if _e1 then
for loc in all(_ev) do
if rnd() < _ew then
if loc == 0 then
_ey(x*8,y*8,rnd(_eg))
else
local _x,_y=x+_e[loc],y+_f[loc]
_ey(_x*8,_y*8,rnd(_eg))
end
end
end
end
end
end
function _ey(x,y,_eg,mn,mx)
local _eh=split"17,1,35,36,16,23" local _ej=split"32,22,34,37,54,22" local _e9=split"11,13,14,15,12,253" local _fa=split"cHUBS,kUNKY,gUPSY,lUISA,sPOOP,bOSS" local _fb=split"2,2,2,2,2,3"
local _fc=split".006,.005,.008,.007,.006,.008"
local _fd=split"2,2,2,2,2,2" local _fh=_j[_eg][_aj]
local b={
v=v2:_k0(x,y),d=_kz(),_dj=_kz(),of=v2:_k0(1,6),_c2=v2:_k0(4,4),fx=rnd()>0.5,_el=_eh[_eg],_dk=_ej[_eg],_fi=_ff,_fj=0,_fk=0,_fl=v2:_k0(x,y),t=rnd()*10,r=30,_fm=_g[_eg],_fn=_e9[_eg],hp=_fh,_fh=_fh,_eg=_eg,_fo=_fa[_eg],_fp=0,_fq=_fc[_eg],_fr=0,_d0=_fd[_eg],_fs=_fb[_eg]
}
add(_cp,b)
return b
end
function _fe(b)
_kn(_cp,function(a,b)
return a.v.y>b.v.y
end
)
for b in all(_cp) do
b:_fi()
end
end
function _ff(_fg)
local v=_fg.v
local of=_fg.of
local a=v+of
local b=_5+4
local d=_fg.d
local _c2=_fg._c2
local n=v2:_k0(nx,ny)
local _ft=0.32
local mt=(_fg._fl-v):_k8()
local mp=(a-b):_k8()
local _dj=_fg._dj
if mp > _fg.r then
if mt < 1 then
if _fg._fj == 0 then
_fg._fl=_gb(v,32)
_fg._fj=30+rnd"150" else
_fg._fj=max(0,_fg._fj-1)
_ft=0
end
_fg._fk=0
else
if _fg._fk == 120 then
_fg._fl=_gb(v,8)
_fg._fk=0
_fg._fj=30+rnd"150" else
_fg._fk=min(120,_fg._fk+1)
end
end
else
_fg._fl=_5
_fg._fj=0
_fg._fk=0
end
d+=(_fg._fl-v):_k9()*0.09
d.x=mid(-_ft,d.x,_ft)
d.y=mid(-_ft,d.y,_ft)
local _f6=_jz(_fg,_cp)
if _f6 then
_dj=(v-_f6.v):_k9()*0.5
d*=0
end
if _jy(
v2:_k0(v.x+d.x+_dj.x,v.y),_c2,of
)then
d.x*=0
_dj.x*=0
end
if _jy(
v2:_k0(v.x,v.y+d.y+_dj.y),_c2,of
) then
d.y*=0
_dj.y*=0
end
_fg.v+=d+_dj
_fg.d=d*0.9
_fg._dj=_dj*0.9
_fg.fx=_fg._fl.x < _fg.v.x
end
function _gb(v,r)
local _gd=true
local _v=_kz()
local _ez,_e0=_bk.x*8,_bk.y*8
while _gd do
local _ge=rnd()
local _x=v.x+sin(_ge)*r
local _y=v.y+cos(_ge)*r
_x=mid(_ez+8,_x,_ez+112)
_y=mid(_e0+8,_y,_e0+112)
_v=v2:_k0(_x,_y)
_gd=_j1(_v,0)
end
return _v
end
function _gc()
for b in all(_cp) do
local x,y,w,h,fx,_el,_dk=b.v.x,b.v.y,b._c2.x,b._c2.y,b.fx,b._el,b._dk
local hy,by=y+_ki(),y+6
_kl(_dk,x,by,1,1,fx)
_kl(_el,x,hy,1,1,fx)
spr(_dk,x,by,1,1,fx)
spr(_el,x,hy,1,1,fx)
end
end
function _g2()
_g3=split"42,43,44,45,46,47" _g5={}
drones,_g9,battle_candy,ship_v,ship_d,ship_rate,_hm,_hj,_hk,_cq={},{},0,v2:_k0(61,118),_kz(),_n[rate_lvl],0,0,0
_he()
music(63,300)
_x,_w=_g4,_hd
_l0(true)
music()
end
function _g4()
_hf()
_hx()
_i0()
_ig()
_g6=battle_x+battle_w-4
_g7=_kp(
battle_x+1,_g6
,(sin(_p/20)+1)/2
)
if not _jv"dog" then
_g7=-2
elseif _p*100%10 == 0 and
rnd() > .5
then
_hl(
_g7+2,_g6+10,1,0,.6
)
end
if _b0 == 0 then
_a7()
end
for _fg in all(_hg) do
if _fg.hp>0 then return end
end
for _fg in all(_hg) do
battle_candy+=_fg._fs
del(_cp,_fg)
end
_mg(split"yOU SCARED OFF THE,GHOSTS!,tHEY DROPPED SOME CANDY")
_fs+=battle_candy
_g9={}
music"17" _cq.butt=false
_cq.onend=function()
_cq=nil
_x=_ba
_w=_bb
_l0(true)
music(10,100)
end
_hb=1
_x=_ha
end
function _ha()
_hb=max(0,_hb-.015)
if _hb != 0 then return end
_cq.butt=true
if btnp(ó) then
_cq._mf=0
sfx"60" end
end
function _hd()
cls()
_i1()
local x,y,w=ship_v.x,ship_v.y,50
_l4(64-w/2,126,w,_b0,max_hp,7)
_l5(battle_x,battle_y,battle_w,_d,14)
clip(battle_x+1,battle_y+1,battle_w-2,_d-2)
_lf()
_h7()
_ih()
spr(25,_g7,battle_y+_d-6)
if _hj>0 then
pal(5,7)
end
if _hk>0 then _kj"7" end
spr(31,x,y)
pal()
if battle_candy > 0 then
clip()
local x,y=ship_v.x-6,ship_v.y-16
spr(5,x+3,y,2,1)
print(
_kr(_fs-battle_candy),x+14,y,14
)
print(
"+" .._kr(battle_candy),x+10,y+8,14
)
end
end
function _he()
_hg={}
for _fg in all(_cp) do
if
(_fg.v-_5):_k8()<30 and
#_hg < 5
then
add(_hg,_fg)
end
end
end
function _hf()
local ix,iy,_ft,_hh=0,0,1,.9
local _hi=_k[acc_lvl]
_hj=max(0,_hj-.5)
_hk=max(0,_hk-.06)
if btn(ë) then ix+=1 end
if btn(ã) then ix-=1 end
if btn(É) then iy+=1 end
if btn(î) then iy-=1 end
if
btn(ó) and
_hm == 0
then
_hm=1
_hj=3
_hl(
ship_v.x+3,ship_v.y-2,1,_l[size_lvl],_o[_ah]
)
end
if ix*iy != 0 then
ix*=0.707
iy*=0.707
end
ship_d.x+=ix*_hi
ship_d.y+=iy*_hi
ship_d.x=mid(-_ft,ship_d.x,_ft)
ship_d.y=mid(-_ft,ship_d.y,_ft)
if
ship_v.x+ship_d.x<battle_x or
ship_v.x+ship_d.x+6>battle_x+battle_w
then
ship_d.x*=-1
end
if
ship_v.y+ship_d.y<battle_y or
ship_v.y+ship_d.y+4>battle_y+_d
then
ship_d.y*=-1
end
ship_v+=ship_d
ship_d*=_hh
_hm=max(0,_hm-ship_rate)
end
function _hl(x,y,_eg,r,_ft)
local ts={3,0}
local ds={-1,1}
local b = {
v=v2:_k0(x,y),r=r,_eg=_eg,_ft=_ft,d=ds[_eg],t=ts[_eg]
}
sfx"57" add(_g9,b)
return b
end
function _hx()
for b in all(_g9) do
b.v.y+=b.d*b._ft
b.t=max(0,b.t-0.2)
if b._eg == 1 then
for _ii in all(drones) do
local _c=(_ii.v+2)-b.v
if
_c:_k8()<4+_l[size_lvl]
and
_ii.v.y>battle_y
then
sfx"56"
if _ii._fp == 0 then
_ii.hp=max(0,_ii.hp-_m[pwr_lvl])
_ii._fp+=1
end
if _ii.hp == 0 then
local _fg=_ii._fg
_fg.hp=max(0,_fg.hp-1)
_fg._fp+=1
_lv(_ii.v)
del(drones,_ii)
sfx"55" end
del(_g9,b)
end
end
end
if b._eg == 2 then
local of=v2:_k0(3,2)
local c=b.v-(ship_v+of)
if _hk == 0 then
if c:_k8() < b.r + 2 then
_b0=max(0,_b0-1)
_hk+=1
sfx"54" del(_g9,b)
return
end
end
end
if
b.v.y+b.r<battle_y or
b.v.y-b.r>battle_y+_d
then
del(_g9,b)
end
end
end
function _h7()
for b in all(_g9) do
local c=b._eg == 1 and 14 or 6
local x,y,t=b.v.x,b.v.y,b.t
if t>0 then
local r=b.r+3
r-=3-t
circfill(x,y+2,r,14)
end
circ(x,y,b.r,c)
end
end
function _h8(x,y,_fg)
local _fc=split".008,.02,.015,.02,.009,.02" local _if=split"1,1,1,1,1,1" local _eg=_fg._eg
local _ii={
v=v2:_k0(x,y),_fg=_fg,_ft=_if[_eg],_fp=0,_fq=_fc[_eg],_fr=0,t=rnd(),hp=_i[_eg][_aj]
}
add(drones,_ii)
return _ii
end
function _ig()
for _ii in all(drones) do
_ii._fr=max(0,_ii._fr-_ii._fq)
_ii._fp=max(0,_ii._fp-.06)
local _eg=_ii._fg._eg
_ii.v.x+=_jf(_eg)*_ii._ft
_ii.v.y+=_jg(_eg)*_ii._ft
if _ii._fr == 0 then
_ii._fr=1
_hl(
_ii.v.x+3,_ii.v.y+4,2,1,.5
)
end
if
_ii.v.y>141 or
_ii.v.x>115 or
_ii.v.x<5
then
del(drones,_ii)
end
if _ii._fg.hp==0 then
_lv(_ii.v)
del(drones,_ii)
end
end
end
function _ih()
for _ii in all(drones) do
local s=_ii._fg._fn
if _ii._fp > 0 then _kj"7" end
spr(s,_ii.v.x,_ii.v.y)
pal()
end
end
function _i0()
for bttl in all(_hg) do
bttl._fr=max(0,bttl._fr-bttl._fq)
if bttl.hp > 0 then
bttl._fp=max(0,bttl._fp-.06)
if bttl._fr==0 then
local _eg=bttl._eg
local x,y=_i9(_eg),_je(_eg)
bttl._fr=1
for i=1,rnd(bttl._d0)+1 do
_h8(x+i*6,y,bttl)
end
end
end
end
end
function _i1()
clip(0,17,128,57,0)
_kq(_g3[flr(_p*10%#_g3+1)])
clip()
line(0,15,128,15,5)
line(0,75,128,75,5)
local _i2=split"64,38,90,14,114" for i=#_hg,1,-1 do
local b=_hg[i]
if b.hp > 0 then
local x=_i2[i]
local y=35+sin(_p+b.t)*2+.1
if b._fp > 0 then _kj"7" end
local sx,sy,sw,sh,dx=unpack(b._fm)
sspr(sx,sy,sw,sh,x+dx,y)
if b._eg > 4 then
sspr(sx,sy,sw,sh,x+dx+sw,y,sw,sh,true)
end
pal()
x-=11
y=2
local w,h=23,10
rectfill(x+1,y+1,x+w-2,y+h-2,15)
_l5(x,y,w,h,14)
print(b._fo,x+2,y+2,5)
local x+=1
local y+=1+h
_l4(x,y,w-3,b.hp,b._fh,14)
end
end
end
function _i9(_eg)
if _eg==2 then
return 11
elseif _eg==3 then
return 101
end
return rnd(split"22,35,67,83")
end
function _je(_eg)
if _eg==2 or _eg==3 then
return rnd({86,96})
end
return 70
end
function _jf(_eg)
if _eg==1 then
return _q
elseif _eg==2 then
return .1+_q
elseif _eg==3 then
return -.1-_q
elseif _eg==4 then
return 0
elseif _eg==5 then
return _q
elseif _eg==6 then
return _r
end
end
function _jg(_eg)
if _eg==1 then
return .08
elseif _eg==2 then
return sin(_p)*.5
elseif _eg==3 then
return _r
elseif _eg==4 then
return sin(_p)*.3+.05
elseif _eg==5 then
return _r+.08
elseif _eg==6 then
return _q+.08
end
end
function _jh(x,y,_at)
local _ae=_jo(x,y)
local r={}
for i in all(split(_at,">"))do
add(r,i)
end
_as[_ae]={_ae,r}
end
function _ji(x,y,_bx,_cu)
local i=_jo(x,y)
if _jv(nil,i) then return end
_cu[i]={i,split(_bx,"è")}
end
function _jj(x,y,_cu)
return _cu[_jo(x,y)]
end
function _jk(x,y)
add(_y,v2:_k0(x,y))
end
function _jl()
for v in all(_y) do
local c=(_5+4)-(v+4)
if c:_k7() <= 13 then
spr(112,v.x+1,v.y-5+_ki())
end
end
end
function _jm(_jn)
return _jn%128,_jn\128
end
function _jo(x,y)
return x+y*128
end
function _jp()
local _jq=_ct(_aw)
if not _jq then return end
local _jr,_js=unpack(_jq)
local id,_jt,_ju=unpack(_js)
if _jv(id) then return end
if
_ju and
not _jv(_ju)
then
return
end
_mg({_jt})
sfx"52" add(_av,_jr)
_aj+=1
_aa()
_t(true)
return true
end
function _jv(id,_jw)
for _jq in all(_av)do
local _jx=unpack(_aw[_jq][2])
if
_jx==id
then
return true
end
if _jq == _jw then
return true
end
end
end
function _jy(v,_c2,of)
local of=of or _kz()
if _j4(
v,v+_c2,_bi,_bj
) then
return true
end
if god then
return
end
if _j0(v,_c2,of,0) then return true end
if _j0(v,_c2,of,-1) then return true end
if not _jv"water" then
if _j0(v,_c2,of,6) then return true end
end
if not _jv"fence" then
if _j0(v,_c2,of,7) then return true end
end
end
function _jz(o,_cu)
local v,_c2,of=o.v,o._c2,o.of
local a1,a2=v+of,v+of+_c2
for i in all(_cu) do
local b1,b2=i.v+i.of,i.v+i.of+i._c2
if i != o then
if _j3(a1,a2,b1,b2) then
return i
end
end
end
end
function _j0(v,_c2,of,f)
local v=v+of
local a,b,c,d=v,v+_c2,v2:_k0(v.x+_c2.x,v.y),v2:_k0(v.x,v.y+_c2.y)
local _j6=f==-1 and _j2 or _j1
if _j6(a,f) then return a end
if _j6(b,f) then return b end
if _j6(c,f) then return c end
if _j6(d,f) then return d end
end
function _j1(v,f)
local v=v+0
local _z,_0,sx,sy=unpack(_9)
v.x-=sx
v.y-=sy
local mx=flr(v.x/8)
local my=flr(v.y/8)
mx+=_z
my+=_0
return fget(mget(mx,my),f)
end
function _j2(v)
return _jj(flr(v.x/8),flr(v.y/8),_ap)
end
function _j3 (a1,a2,b1,b2)
return a1.x < b2.x and
a2.x > b1.x and
a1.y < b2.y and
a2.y > b1.y
end
function _j4(a1,a2,b1,b2)
return a1.x<b1.x or
a2.x>b2.x or
a1.y<b1.y or
a2.y>b2.y
end
function _j5(x,y,x1,y1,x2,y2)
return x>x1 and x<x2 and y>y1 and y<y2
end
function _kh(_t,_x,_y,_c)
for i=1,8 do
print(_t,_x+_e[i],_y+_f[i],0)
end
print(_t,_x,_y,_c)
end
function _ki()
return flr(min(0,sin(_p)))
end
function _kj(_kk)
for i=0,15 do
pal(i,_kk)
end
end
function _kl(s,x,y,w,h,fx,fy)
_kj"0" for i=1,4 do
spr(s,x+_e[i],y+_f[i],w,h,fx,fy)
end
pal()
end
function _km(sx,sy,sw,sh,dx,dy,dw,dh,fx,fy)
_kj"0"
for i=1,4 do
sspr(sx,sy,sw,sh,dx+_e[i],dy+_f[i],dw,dh,fx,fy)
end
pal()
end
function _kn(a,_ko)
for i=1,#a do
local j=i
while j>1 and _ko(a[j-1],a[j]) do
a[j],a[j-1]=a[j-1],a[j]
j-=j
end
end
end
function _kp(a,b,t)
return a*(1-t)+b*t
end
function _kq(s)
local _ft,a,b=20,21,13
local sx,sy=flr(s%16)*8,flr(s/16)*8
local t=_p*_ft
local go=sin((t%100)/100)
for y=0,128 do
local lo=sin(((t+y)%100)/100)
for x=0,128,8 do
local _ks=sy+(y+go*a+lo*b*sin(_p/2)-.2)%8
sspr(sx,_ks,8,1,x,y)
end
end
end
function _kr(n)
return n<10 and"0" ..n or n
end
function _kt(x,y,t)
local _dg=sin(t*_p/1.5+.3)*2.5
line(
x-.5+_dg/2,y,x+1.5-_dg/2,y,5
)
line(
x,y-1.5+_dg,x,y+2.5-_dg,5
)
end
function _ku(s)
return 64-#s*2
end
function _kv(_kw)
return _kw[flr(_p*100/15)%#_kw+1]
end
function _kx(s)
if not s then return end
local _cu=split(s,"%")
for i=1,#_cu do
_cu[i]=split(_cu[i],"|")
end
return _cu
end
v2={}
function _kz()
return v2:_k0()
end
function v2:_k0(x,y)
v={}
v.x=x or 0
v.y=y or 0
setmetatable(v,self)
self.__index=self
return v
end
function v2.__add(a,b)
if type(b) =="number" then
return v2:_k0(a.x+b,a.y+b)
end
return v2:_k0(a.x+b.x,a.y+b.y)
end
function v2.__sub(a, b)
if type(b) =="number" then
return v2:_k0(a.x-b,a.y-b)
end
return v2:_k0(a.x-b.x,a.y-b.y)
end
function v2.__mul(a, b)
if type(a) =="number" then
return v2:_k0(b.x*a,b.y*a)
elseif type(b) =="number" then
return v2:_k0(a.x*b,a.y*b)
end
return a.x * b.x + a.y * b.y
end
function v2.__div(a,b)
if type(a) =="number" then
return v2:_k0(b.x/a,b.y/a)
elseif type(b) =="number" then
return v2:_k0(a.x/b,a.y/b)
end
end
function v2.__eq(a,b)
return a.x==b.x and a.y==b.y
end
function v2:_k7()
local nx=self.x*0x0.01
local ny=self.y*0x0.01
return sqrt(nx*nx+ny*ny)*0x100
end
function v2:_k8()
return sqrt(self.x*self.x+self.y*self.y)
end
function v2:_k9()
return self/self:_k8()
end
function _la(
x,y,dx,dy,_lb,_lc,_ld
)
local p = {
x=x,y=y,dx=dx,dy=dy,_lg=0,_lb=_lb,c=_lc[1],_lc=_lc,r=_ld[1],_ld=_ld,}
add(parts,p)
return p
end
function _le()
for part in all(parts) do
part._lg+=1
part.x+=part.dx
part.y+=part.dy
if #part._lc == 1 then
part.c=part._lc[1]
else
local ci=part._lg/part._lb
ci=1+flr(ci*#part._lc)
part.c=part._lc[ci]
end
if #part._ld == 1 then
part.r=part._ld[1]
else
local ri=part._lg/part._lb
ri=1+flr(ri*#part._ld)
part.r=part._ld[ri]
end
if part._lg > part._lb then
del(parts,part)
end
end
end
function _lf()
for part in all(parts) do
circfill(part.x,part.y,part.r,part.c)
end
end
function _lt(x,y)
local _ge=rnd()
local _x,_y=x+6+sin(_ge),y+9
if not _cy then _x-=5 end
_la(
_x,_y,0,0,30,split"6,6,13",split"1,0")
end
function _lu(x,y,dx,dy)
local _ld={rnd(split"1,1,1,2"),1}
local _lc=split"15,14,14,14,5" local _ge=rnd()
local _x=x+4+sin(_ge)*3
local _y=y+6+cos(_ge)*2
_la(
_x,_y,dx*.2,dy*.2,40,_lc,_ld
)
end
function _lv(v)
local _ld=split"3,2,1,1,0" local _lc=split"7,15,14,13" for i=1,3 do
local x,y=v.x+1,v.y
local _ge=rnd()
x+=sin(_ge)*.2
y+=cos(_ge)*.2
_la(
x,y,0,-rnd()*.5,40,_lc,_ld
)
end
end
function _lw()
local t=_a6
local c=0
local w=16
for i=0,8 do
for j=0,8 do
local x=i*w
local _ly=sin(t+i*0.1)
local _lz=sin(t+j*0.03)
local y=j*w+_ly*w
local r=_lz*w
local _x=_l2 and x or y
local _y=_l2 and y or x
circfill(_x,_y,r,c)
if r>4 and _l2 then
circ(_x,_y,r-3,5)
circfill(_x,_y,r/2-3,14)
end
end
end
end
function _lx(_ft)
if _a6>0 then
_a6=max(_a6-_a,0)
_lw()
end
end
function _l0(_l1)
_l2=_l1
_a=_l1 and.0058 or .009
camera()
_a6=1
local _l3=.6
repeat
_a6=max(_a6-_a,_l3)
_lw()
flip()
until _a6==_l3
_a6=_l3
end
function _l4(x,y,w,hp,_fh,c)
local x1=x
local x2=x1+(hp*w/_fh)
line(x1,y,x1+w,y,5)
line(x1,y,x2,y,c)
end
function _l5(x,y,w,h,c)
line(x+1,y,x+w-2,y,c)
line(x+w-1,y+1,x+w-1,y+h-2,c)
line(x+w-2,y+h-1,x+1,y+h-1,c)
line(x,y+1,x,y+h-2,c)
end
function _l6(x,y,w,h,_ao)
local w={
x=x,y=y,w=w,h=h,_ao=_ao
}
add(_g5,w)
return w
end
function _l7()
for w in all(_g5) do
local wx,wy,ww,wh=w.x,w.y,w.w,w.h
rectfill(wx+1,wy+1,wx+ww-2,wy+wh-2,0)
_l5(wx,wy,ww,wh,14)
clip(wx,wy,ww-2,wh-2)
wy+=4
wx+=4
for i=1,#w._ao do
local _ao=w._ao[i]
print(_ao,wx+4,wy,14)
wy+=6
end
clip()
if w._mf == nil and w.butt then
_kh("ó",wx+ww-15,wy+1+_ki(),14)
end
end
end
function _mb()
for w in all(_g5) do
if w._mf!=nil then
w._mf-=1
if w._mf<=0 then
local _mc=w.h/4
w.y+=_mc/2
w.h-=_mc
if w.h<3 then
if w.onend then
w.onend()
end
del(_g5,w)
end
end
end
end
end
function _me(_ao,_mf)
local _mi=(#_ao+2)*4+7
local w=_l6(
63-_mi/2,50,_mi,13,{_ao}
)
w._mf=_mf
end
function _mg(_ao,y)
if not _ao then return end
local y=y or 50
_cq=_l6(
12,y,105,#_ao*7+6,_ao
)
_cq.butt=true
end
function _mh()
_mj={}
for i=1,25 do
add(_mj,{flr(rnd"128"),flr(rnd"128"),rnd()})
end
end
function _mk()
cls()
for s in all(_mj) do
_kt(unpack(s))
end
end
__gfx__
000000000eeeee00000d0000000d0000000d00000e0eef0000000000000000000006770000ee70000077000006060000077000000eee0000006600000e0e0000
00000000eff55ee00e9e9e000e9e9e000e9e9e00e6e77ff00000000007700770007777707eeede00077770000776700077770000e777e000066660000d7d0000
00700700ef5775e09e9999e09e9e99e09e9999e000e77ff00000000000f77f0000677760eedeede00677600007d67000de7e0000e7dde00066ddd60007d70000
00077000ee57d5e09ed999d09e9999e09ed999d000ffff6ee00000000077770000657750deeddeee000e00776d6660007ddd0000e7dde000667d7600eeee0000
00077000eee55ee09e9dd9e09e9999e09e9559e0000ffe0e000000000075777700676760ddeeeee707e007776fddd000777700000eee000006eee6000ee00000
00700700eeeeeee09999e9e0e999e9e0999559e000000000000000000066775700d6d6d00ddeeffd777000660d0d0000707000000e0e000000d6d000e0e00000
000000000eeeee000eeeee000eeeee000eeeee00000000000000000000077566000ddd0000dd7dd06660000e0000000000000000000000000000000000000000
000000000e0e0e0000000000000000000000000000000000000000000000666000000000000dd0000e0000e00000000000000000000000000000000000000000
07777700007007000eeeee0000666000000000000d0000000e0e0e000000d0000f000f006560000007eee000000000000000000000000000777000000eeeee00
7777777006666600effeeee007777000000f777fd0d00000000e0e0000e9e9e000eee00077700000777e70000ddd0000055550000555550077777700e5e9e5e0
7777777067777670effffee0777660000000dd60eee00000000e00000e9999e9fefffef057500000e7777000dddddd005777755055555550777ee770e9e9e9e0
77de7ed067dd7670ee5555e000000000d00dddd00e000000000000000e5599550ef17e00707000007eeee000ddfff6f0555555005557777007e5ee50e9eee9e0
7777777067dd7670eee55ee006666600d6dd6dd600000000000000000e579957fef77ef00000000055d50000dff55f50667d7d005775757007eedde00eeeee00
77dddd7067777670eeeeeee077777700fdddd0dd00000000000000000e9dddd90deeed0000000000556560000dffddf0777666005777ee7007eeeee000000000
07777700066666000eeeee00000000000ffff0ff000000000000000000eeeee000ddd00000000000655500000df6fff00777770055777750007ee70000000000
00000000000000000e0e0e0000000000000000000000000000000000000000000000000000000000050500000000000000000000050000500000000000000000
06d6600006d6600000066000000000000000000000ee000000777700077700000607000000000000050050500500550005055055500050500050550505050555
66d6666606d666600066e600000000000e000e000eeee00000777700077770000777000006070000505555005005555000555500505505055000000550505005
66d666d666d6666666dddd60000000000e000e00ee6e6e0007777000077790007757000007770000005555500055555050550550005000500500500005055500
66fd660d66d666d666d7d7600ee000000e777700eeeeee0007777000779660005777700077577000055555550555055505500055550000050505550550555550
d6dddd0066fd660d06eeee00e77e000007777d000e6e000000777700666660006677770757777700505555550055555000550550005000505000500005055505
0ddddd00dddddd00066d6d00ed7e00000ed7d7000e0e000000077700000000000077777766777777005555505005550550055505500505055050000550505000
00d0d00000d0d000000d60000ee0000000e7d000e0e0000000007000000000000777767007777677505050005050550050505005005050000000505005500055
0000000000000000000000000e000000000000000000000000000000000000000767677007767670505005050050050550550050500505050505505550505050
000e0e000000000000000000f888000077e700000000000077777700000000000055550000dff00000fff00000dfd000ddd00000066660000fefefe066660000
0eeeee0005555500005555007fff7000e777e00000777700777777007600000057eeee750d6df6000ff770000ddded00e7e000006dddd6000667770006ff6660
eeeeeef055555550585555500ddd0000066600000677776077777700d7760000e775577e0d6dd600ff777e000deddd006e7600006777e600667e7e000677ff66
fe77777055666660555eeee00606000008080000065577500777770007d70076570000750d6dd600f77e77006dddddf00e7e00006e77760077eee70006ee776f
f7767670656566505ee5e5e0eeee000077676000077755700707700007d77777575005750dfdd600dd777e7066ddd66006e760006ee776007e77660006efee66
e77ee770066886605eee8ee06eee60007666670007777770000700000776d55dee7557ee0ddddd0000dd77700666ff0000e7e00067ee760077e6660006eeee60
077777000666660055eeee00055500000dddd00000777700000000007ddd00005e5005e5000e00000000dd7000000000006e76006dddd600efefef0000666600
000000000000000050000000070700000e00e000000000000000000055000000eee77eee000f000000000070000000000006dd00066660000000000000000000
055555555555555555555550fff55fff055555505eeeeeeeeeeeffeeefeeeee5000555555555555555555000000055555555000000005eeeeee500005ee5eeee
5efeeeefeeeefeeefffeefe5ff5ee5ff5eeeeff55eeeeefeeeeeeeeeeeeefee5005eeeeeeeeeeeeeeeeee50000005eeeeee5000000005eeeeee500005ee5eeee
5f55555555555555555555e5ff5fe5ff5feeeee55effeeeeeeeeeeeeeeeeeef505effefefeffeefefeeffe5000005eeeeee50000000055eeee5500005ee5eeee
5e5eeeeeeeeeeeeeeeeee5e5ff5ff5ff5eeeeee55eeeeeeeeefeeeefeeeeeee55eeeeeeeeeeeeeeeeeeeeee500005eeeeee50000000005555550000055555555
5eeeeeeeeeeeeeeeeeeeeee5ff5ef5ff5eeeeee55feefeeefeeefeeefeefeef55efefffeeffeeffefffefee50000555555550000000000000000000000000000
555555555555555555555555ff5ee5ff5555555555ff5fff5fff5fff5ff5ff555eeeeeeeeeeeeeeeeeeeeee500005eeeeee50000000000000000000000000000
5eeefeeeeeeeffeeeeeefee5ff5ee5ff5eeeeef55f55f555f555f555f55f55f55efffeefffeefeffefefefe500005eeeeee50000000000000000000000000000
5eeeeeeefeffeeefefeeefe5ff5555ff5feeeee55ffffffffffffffffffffff55eeeeeeeeeeeeeeeeeeeeee500005eeeeee50000000000000000000000000000
5ffffffffffffffffffffff5ffffffff00500500005ff500055555505555555500eeeeeeddddddddeeeeeeee0000000000555550000000000000555000000000
5ffffffffffffffffffffef55555555505f55f50505ee5055ffffff55eeeeee500efeeeeddddddddeeeeeeee0555000005000005055555000005555500000000
5ffffffffffffffffffffff55fefeee505e55e50055ef5505eeeeee55eeeeee50efeeeeeddddddddeeeeeeee0505005005055505050005000000555000000000
5ffffffffffffffffffffff55efefee55ffffff55e5ee5e55e7f77e55eeeeee50feeeeee55555555eeeeeeee0555000005050505050505000000000000000000
5ffffffffffffffffffffff55eefefe505d55d505e0ff0e55e777fe55ffffff50feeeeeedddddddd555555550000000005055505050005000555005555555555
5feffffffffffffffffffff55555555505e55e50505ee5005e7f77e55ffffef50feeeeeeddddddddeeeeeeee000555000500000505555500555550555eee5eee
5fffffeffffffffffffffff5ffffffff05e55e50005ee5055eeeeee55ffffff50efeeeeedddddddd55555555000505000055555000000055555550005eee5eee
5ffffffffffffffffffffff5ffffffff00500500050550055e5555e55555555500feeeee5555555555555555000555005000000000000055055500005eee5eee
5ffffffffffffffffffffff5e555555efffeffffeeeeee0005555500eeeeeeee5555e555ddddddddeeeeeeee00000e00000000e0550555550000000000000000
5fffffffff5555fffffffff55eeeefe5ffffffffeeeefe005feefe50eeeeeeee5efe5fefddddddddeeeeeeee0000ee000000e000000000000050000000000000
5ffffffff5efee5ffffffff55ed77de5ffffffffeeeeefe05e55ee50eeeeeeee5efe5fefdd5555dd5555555500000e000e000ee0555555050555000000000000
5ffffffff5eefe5ffffffff55edddde5ffffffffeeeeeef05eeeee50eeeeeeeefefe5eee55dddd555ddffff500000ee00e000e00555555550000000000000000
5ffffffff555555ffffffff55feeeee5ffffffffeeeeeef05ee5e5e5eeeeeeee5eee5eeedddddddd5dedfdd500000e0000ee0e00000000000000005000000000
5feffeeffffffffffeeeffe55eeee5d5feffefeeeeeeeef005eefee5eeeeeeee5efe5fefddd5dddd5fdffde500000e00000eee0e555555500000055500000000
5eeeeeeeeeeeeeeeeeeeeee55eefeee5eeeeeeeeeeeeefe005eeee50eeeeeeee5efe5fefdddddddd5555555500005e5000000e0e555055550005000000000000
055555555555555555555550e555555e55555555eeeeef0005555550eeeeeeee5555e55555555555eeeeeeee0000555000000eee000000000055500000000000
055500000555555000000000055555505fe5500000055ef5f555555fdddddddd0eeeeee000000000f00000005e5005e50055550000000000fddddddffeeeeeff
577750005efeefe5000000005effffe55555e550055e55555eeeeee5dddddddd0eeeeee000000000f0ffff005e5055e505ffff5005050000fffffffffef77eff
057500005effffe5000bb0005f6767f55eeef5e55e5feee55fefefe5df8888fd00000000effffffef00d00005f5005f55feffff505050505fedededffe7ffeff
005000005eeeeee500bbbb005ff676f5555555f55f5555555555555588ffff880eeeeee0effffffed0ffff005f5005e55ffffef500000505dedfdeddfef7feff
0000000055ffff55000bb0005eeeeee55effeef55feeffe55ffffff5ffffffff00000000feeeeeefdeedee005e5505f55effefe500000000dedededdfdddddff
000000005feffef50000000005555550555555555555555555555555fff8ffff0eeeeee0dddddddd0ddddd005f5005f55eeeeee500505000dffffffdffffffff
0000000005feef5000000000005ee5005fffffe55efffff55ffffff5ffffffff00000000dff55ffd0d000d005e5005f505dddd5000505000ddedededeeeeeeee
000000000555555000000000005ee5005d55d5d55d5d55d5555555558ffffff800000000500000050d000d00050050505055550500000000ddededed55555555
c5c5c50000e5b7c7b7e6c5d517000085560000c6d7e60055000000000000005575b6d50000d50000d7d500b40515151525062600000054343434000000849494
a4e5053416260000e500d500000000000000000000d500000000e5e5d5d5e5e500000055550000005500d75555e5005500f6f67676767676767676767676f600
000000000000868686c7e5c7c700008556c5d7b6d700d55517e500000000e51717000000c5c5c5d5b500e5b4063616f726e5000000c50667346700d500061616
26e50626f4e4e50000d5e50000e5d500e500e5d5e5e5000000000000e50000000000555500e500e55555d7d75500005500f676a587a5a5a5a5a5a5a5a5a57600
94a4000000000000e50000000000e6857676560000d7b50017b500c5c500b51717d6d6d617c5c517d6d6d6d6f4f4f4e4e500c500042445061626c5d6d6d60004
1424b7b7b7b7b74745454557b7b7b7b7b75555555555555555550000044424000055555555000055d700d70055d700550076a59595959696959696959695a500
647400d5000000e500c50000e500d78576767656d5c5d5d55517d6d6d6d6175555d7b500d5c5c5d5000000c5d700e500000000005474e5e5e500000000000434
3425c500d5c6c500e5e500d5e50000c5c5c50000e50000e555e555041444142455e55500e55555d7e5d7d70055e5d75500769596969595959695959696959500
9494a400000000000000000000d7857676867656b50424d50055d6d6d6d6550055c7c755c7c7d50000d7d700d565c5d7d70000e5052500c565000000e5000646
4626000000b6000000d5000000d5d5c565c500000000e555e500843434673434a400e555d7d700d7d70000e555d7005500767695959595969595959595959600
141414141447000000e6d7d70000e5857686041414642500b555b5c5c5b555454555d5000055000000c5c600868686d7c6c5e50006042400e500c5000000e555
5500d5000000005767676747e500e5c5c5c500c5c5c50055008434161636161634a40055d765e5e5d700d7d75500e5550076a595969595959596959596959600
67d6d6d636164700d7000000c5c50000d5860534163425b500550000000055d5655500d56504442400d7b6c5c5c5c5c5b600d700005474000000e50000c53717
55170000c60055949494949455d50000c500d5c500c50055c5344626c5c5c5064634c555d700d70000e5d7001700005500a69695959595959695959595a67600
67c5c5c5c58556e6d700d7d7e6d700d7c5473646654636000055000000005500d584a40000361625d700c5c5f5f5f5c5c5d70055550534245555551700c5c5c5
c5004500b6b7005754c57447c65500c600000000c5c50055b467d6d6c5c5c5d6d667c455d700d717555555170000005500a59596959595959595959595767600
94a4c5c5c5855600d7d7c7d70000d700c547f4f4f455f400005500b5000055d6d65474d500000067c5d7c5b4d5c6d5c4c5d7c500d7063436000000b700c5c5c5
00b54500e555d50434163424b65500b6d5d500000000e555d4f400b5d6d6d600e6f4e455d7e50055041424c5c5e5005500969595959596959595969595a5a500
64744766b7b716c7d7d7d7c7d7b58494a455d500d5550000d555d6d6d6d655d5c505340414240525c500c5b4d5b6d5c4c5d7c50000e544c5e500c70000c50017
551700c6c555c60525360525e5550000e500c5000000e55500e545454545454545e500550000175706361647c5e5005500959596959595959695959595959500
b736b7e5b700d7d7d7d7d7b5d7c7b7b5b755d5d50055d5c60055d6d6d6d65500d505253646260626c5d7c5b4d537d5c4c500c500000044e50000c50000000055
550000b600b7b60625d605260055c50000c50000d5000055550000e600e600e600000055d7b55517d6d6d617c5e5005500769696969595959595959596959600
b5b500c66600c6c7d7b5d7d7c555e5d7e50017b766d5c5b6c655650000005500c50525c50000d717e600c6c5f4f4f4c5c6b5c5c5d500b50000e500c600042455
5500c5000055e50067c56737c5b700e5c60000d500d500e600555500000000e600555555b5005557d6d6d647c500e55500a59696959595959595959596959500
00d7c6b667d7b6666600d700d7d7d700d7d7b765b75517c5b6550000b54455d6d605344700c500d700d7b6c5c5c5c5c5b600000000000000b50000b604646424
c7b7b700005500c6710071c5c545c5c5b6c5c5c5c5c5c500e600e6555555555555e60000454547c5c5c5c565c500005500959695959596959596959596959500
4700b60000b5d700c644c7d7c7d700d7d500c5d7e5c5c545c55500b5001655e50005154447e6000000c5000000e5000000c500e600c5008494a48556b7463646
b765b7b700b7e5b600c500c5c545c5c5e5c5c5c5c5c5c5008576560000e600000085765600e655e5e5d7e5d700c5c55500969595959595969595959595959600
6747d7000000c5d7b61655c755d7c7d700c500d700000045458555555555560000053404141424d6d6d6d6d6c5c5c5d6d6d6d6d6d6849464647400e5b5e5d6e5
e5c5b517c60055b75555b75555c5000000000000000000e6000000e600857656e600d7857656550000d70000c5c5c5550096779596959595959695969595f600
6767470000c5c5c500e5005500c55500d7e584a455e50000b5857676767656b5000646671646b7000000e600c717c7e6000000e600064667462600b500e5e5e5
00b50017b600000000c500000000c500d5000000000000000000855600d7000000d7000000554755555555555555551700f687f6f6f6f6f6f6f6f6f6f6f6f600
0e0e00e00000000000000000000000000000066006600000eee000000000000000000eeeee0000000e0000e00007777000000000000000000077777777777777
ee0ee0ee000ee00000e0000000000000000006600660000e777e006660000000000eeeeeeeee0000ee000ee00077777000000000000009e90700000000000000
ee0e00e0e0ee000000ee000000000000000666666666000e7dde66666660000000eeffffeeeee000ee000ee00777777000000000009e99e9700eeeeeeeeeeeee
ee00e0e0e0eee00000ee000000000000006677776666700e7ddee666666600000eefffdddddeee0eeeeeeee0777777700000000009e99e9970eeeeeeeeeeeeee
ee00000000000eee00eeee000000000006677dd77666d700eee666ee666660000efffdd777ddee0777777eee77ddd7700000000009e555e970eeeeeeeeeeeeee
ee00000eee00ee0ee0eee00000eee0000667dddd7666d7000ee666ee66666600eeffdd77777ddee7777777ee7ddeed7000000000995eee5970eee77777777777
ee0000ee0ee0eee000ee00000eeee0000667dddd7666d7006666666666666660eeffd777dd77deedd77777ee77ddd77000000000995e775970ee777777777777
ee0000ee0ee00eee00ee00000eeeee0006677dd77666d7066e6ddddddddd6666eeffd77d7dd7deedd77dd7ee7777777000000000995e775970ee777777f77777
ee0000ee0ee000eee0ee0000eeeeeee000667777dddd700666dd77ddd77dd666eeefd77dddd7dee77d7dd7ee7d777770000000009995559570ee77777fff7ff7
eeeee0ee0ee0ee0ee0eeee000000000000066666666600066dd7777d7777dd66eeeedd77dd7ddee77dd77ee0777dddd0000000009e9e999570ee77ff7fff7ff7
0eee000eee000eee000eeee000000000666dd6666666660066d7777d7777d6600eeeedd777ddee007dd7ee007777777000000000ee9559e970ee77ff7fff7ff7
00000000000000000000000000e00006666ddd666666666006eeeeeeeeeee6000eeeeedddddeee000777e00077777770000000000999955570ee777777777777
00ee000ee0000000000ee00000ee0006666ddd666666666006eeeeeeeeeee60000eeeeeeeeeee0000eeee00077777770000000000e9e995570ee7fffffffffff
0eee000ee0000000000ee00000ee0006666ddd66666666600666eeeeeee66600000eeeeeeeeee000eeeeee00777777700000000000eee9e970ee777777777777
0eee000ee0ee000ee00ee00000eeee06666dff6666666660066d6666666d6600000eeeeeeeeee00e66ee66e0077777700000000000000eee70ee777f77777777
0eeee00ee0000eeeee0ee00000eee006666dffddddddd660066dd66666dd6600000eeeeeee0ee00e66ee66e007777770000000007000707070ee77fff7f77f7f
0eeeee0ee0ee0ee0ee0ee0ee00ee0006666dddddddddd660006dd66666dd6000000eee0eee0ee000eeeeee0007777770000000000777007070ee77fff7f7ff7f
0ee0ee0ee0ee0ee0ee0eee0ee0ee000066ddddddddddd6000000d66666d000000000e00eee0ee0000eeee00007777770000000000000077070ee77fff7f7ff7f
0ee00eeee0ee0ee0ee0ee00ee0ee000000ddddddddddd00000000066600000000000000eee0e000000eee00007777770000000000000700770ee777777777777
0ee00eeee0ee0ee0ee0ee00ee0eeee00000ddddddddd000000000000000000000000000eee0000000ee6ee0000707770000000000077007070ee7fffffffffff
0ee000eee00ee0eeee0ee00ee00eeee00006660006660000000000000000000000000000e00000000ee0ee0000007770000000000000000070ee777777777777
0000000000000000ee000000000000000006600006600000000000000000000000000000000000000ee0eee000000770000000000000000070eee77777777777
0000000000000eeee00000000000000000000000000000000000000000000000000000000000000000ee0ee000000000000000000000000070eeeeeeeeeeeeee
000000000000eeee0000000000000000000000000000000000000000000000000000000000000000000e00e000000000000000000000000070eeeeeeeeeeeeee
000ee000600600000055550007700000077777700777777000555500000077700077700000077d000000000000000000000000000999000070eeee6666666666
07777000d66d000055755755777000006d5dd5d67dedddd75577775500060777007776000077d6600000000000ffff00000000009595900070eeee6666666666
0d7d7700e66e0000ee7777ee777600006d5555d6e75f5ed7e7d77d7e000677660dd6777000dd6660000000000fddddf0000000009e5e900070eeeeeeeeeeeeee
ee777777d66d50005e0770e5dd6760006dddddd6ee77777e57d77d7500070606077dd77d000dd000000000000fddddf0000000000999000070eeeeeeeeeeeeee
0e7777770dd56d055e5775e500d6777066666666eeeeeeee5e7777e50076666007777d0007006070000000000effffe00000000070707000700ee00000000000
0777777700566d50ee5775ee000d77700de7e7d00eeeeee0e507705e06760000776d00007770077d000000000deeeed000000000000000000700007777777777
077767660d56d6d05e7777e5000077d00dddddd0000eee00e506605e07607000dd000000d77d0dd6000000000edddde000000000000000000077770000000000
007776600d060d50ee7557ee0000dd00d000000d00000000ee7777ee00700000000000006dd660d60000000000eeee0000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303000000000000000000000000000001010101010101010101010000000000010101018001030140000100000000000101010601400140000001000000000100010001010101000a01010101000001
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5152494a545d000000005d007d7d007d000060616461625b505152005c55404142555c606362556061636267655d5e404353434343534342000000005867676500000000000058686867650000005e5e5e550000005e40414141426064646464767b0055555555555555555555555500004849496a4949494a00000067676700
535241424c00005b00000000000000005d5b006c565d007d505352005e4b606162555c5c5c00555867686868686800505343535353435352006c00006c586767650000006e5867676867655e0000000056550000000050434343624f4f4f4f4f005e555e00665e006600005e6c665e55485a5a5a5a5a5a5a5a4a006a5a5a5a6a
515263624c0000000000005b5d5c000000005e6b00006c7d505152560055000000555c00005857676767676767655b605353535353535362006b6e006b6e586765006e0058656e5867655555550000005e00550000006061616200004041425e000055005e6e005e6d6d6d6d6b6e00555a69595969595959595a005a5969695a
53524c4f4e5c00004042000000000000000000006c7d6b005053525c0055005c00555c0058675767676767676765006661616163616161660000000058676767656c0058676868555555000000550000005e54000000555c0000004546476255555555005e005e6e005e665e6d55005559695959595959696959006969595969
51524c5e00730000504340414200005c5e00004b6b4c7d7d505152000055000000005555555557676767676765545e6d6d6d73596d6d6d556c006e6867676500006b6868676767557c0000000055005e0000540000000000005c5c6061625d00007555000066006d66006e0048434a5569595969595959695959005969695969
61624c000000000050515153524c54545400004d4f4e005d5053525454540000005e004b686868686767686868684c5b005c5c5c5c5c5e556b005868686868006c005867676768557c0000000000555555550000000000000000005e005e0000005e5e6d6d5e5e6d6d5e00734363435569595959595959596959006959695959
4f4f4e005b00004b60616464624c5e404200005d5b005d4b5051524c000000000000004b686868676767676868684c00005c5b5d5b5c006600000058676765006b6e00586767676800005e005e5e00000000000000000000000000000000000000005e6d006d00005e6c006d5e6d5e5559596959596959595969005969695959
005b0000005c004d4f4f4f4f4f4e6c505200000000005e4b6063624c000048444a75767674545e58676767655e54005e005c5c5c5c404266006e006e6c58676765000058676768650000005e00005e005c0000005c00000000000000000000000075555566546654556b5466005e005559596959596959596959005959596959
000000484a00005e00000000005d6b5052005c000000004d4f4f4f4e5b0060616200000000586767676767676765006c004041414146476600006c006b6e586767686767676765000000000000005e5e000000000000000000440000000000000056555e6e5e006e0000006d006e5e556f69595969776959596f006f5977696f
00004846464a00004041414200005c60625c0000005b5b005e5e5e000000000000005b5b004042586767655d00005d6b005051616161635500006b0000586767686867676765006c00000000005e58655e00000040414141414142005e000000000055006c5e5e6d6d5e6d5e6d6d6c556f6f6f6f6f786f6f6f6f006f6f786f6f
5d4b505353524c4b504343524c5c5d54545c0000006c00000000000000730000000000000050435558676500005c000000505256006c5b556e0000006e586767676767676c6e006b00005e005e586767655e005c506161436161520000000000000055006b6d666e006c5e666d5e6b556f676a676767676a67675a5a5a6a676f
004b607f61624c4b606464624c005c48494a0000006b0000005c0000004849494a000000005043555867655d00005b5d0060625c006b5c5500005867676767656e5867656b000000000000005e586767655e0000504361616143526d6d6d5d404142555e006d6e6d6d6b006d00005e55675a5a5a5a5a5a5a5a5a6959695a5a67
004d4f4f4f4f4e4d4f4f4f4f4e00005051525d0000005e000000000000504343526d6d6d6d7b62006d586566545454545454540000000066005867676767656e6c5867676768656e00000000005e58655e000000604546464647625d00006d50434342550000000055556e00006e55005a59695969595969595959695959695a
6c0000005e5554555554555e0048494a604454445444544454556d6d5550434352000000006d6d6d0058655e00005c5b5c6e54545454545400006e5867656e006b586767676867650000005e5c005e5e0000005e0060616161620000000000505151525e76000000005500000055000069595969696959595969695959695969
6b5e6c005b556d6d6d6d555b00454647556d005c000000005e5d005c557b61617b00000000005e0000586765000000000000000000000000000000006e0000000058676767686767655c00000000005c00000000005d5e6d00000000000000607f7f6200550000000000555e007600006f77595959695969696959596959596f
00006b5d00550000005b55000060616255005e00005e5c5c5455005d555e5e5e00000000000000005b5e68685b006c005b6e005b005e00000000444141446c0000686868676867655c0000000000000000005c000000006d5e00000000005c005d5e5d00550000005e5500005e5e55006f786f6f6f6f6f6f6f6f6f6f6f6f6f6f
0000000000555d005d0055000054545454000000000000007676000055005b005d00000000000000005e686800006b005e00005e5d00005b0000404141426b0000586767676865000000000000005d000000000000005d6d00000000005e005d00000000550000000055005e000055000044444400000067676a67676a676700
000000000055000000005500005e00557b5e0000005c005b000055005500000000000000000000005b5867655b000000006c0000005e6c00445746464646574444676765000000000000005e005e00404141425e0000006d5d00404141444200005c000055005e000000755454747d7d485a5a5a4a00675a5a5a5a5a5a5a5a67
6d6d6d6d555b000000005b55000000557b544042005e40414241444144414142665d540000005d005b586765005b006c5c6b5d006c006b00555d6061636200557467650000000000005e0048494a445761615741415700005e4b50616161524c5e000000555d00000000555e005556005a5969695a005a59695969596969695a
434c4b43555b565b5c00005500005e577b5c45474c4b504352614464636464646554540000005d5d005b586500006c6b6c005b5d6b5b005b55005c5c005c5c557b00000000005d5e5e5e5e607f634b504343434343524c6d004b50436143524c00000000555571005d00550000557d7d59596959590059695969595959596969
434c4b435500000000000055000000557b4b63624c4b6064625e5e564f5b5c58656d6d6d6d6d6d6d0000586765006b006b5b005454404200555d000000735d557b004041425e5e5e5e5e00006d7157576161616161574c5e5d4b60616161624c005d5e00555e00715b0055005e557d7d69595969590059595959596959595959
4f5e5d4f555b5c005d5b5e55005c00557b4d4f4e4c4b5b5c0000005e5e00484a5744005b5d5b00445c005b5865005b6c0000586556454768555c5d00005c5d557b406161525e5c5e5e5c5e0000714b505353535353524c6d004d4f4f4f4f4f4e0000005d555d005b5d5d555e0055007d59595959690059695959697759695959
005d5e000054540000005400000000557b5e40424c4b4042000000004849464744454141414141474c75555555746c6b005867650060625555005c5d5c5c0055745045476354546e5e5e5e5e00714b606161616163624c00005d40444141425454545454555e0000005e765555767d7d5969597759006f6f6f6f6f786f6f6f6f
000000005d005400404200005b0000577b4b60624c4b6362005b5c5e6064646244616161636161625d556d6d6d556b586767655d000000004054556d6d555440426061626d0000715e5e5d0000714d4f4f4f4f4f4f4f4e00005e50435143525c005c5d5c545e0000555500005e555e006f6f6f786f0000000000000000000000
5d00005c000054006062446c000000557b4d4f4f4e4d4f4f6d6d6d484a4f4f4e005e4d4f4f4f4f4e55556d6d6d40414254005e0054484a5b606255546d556061625c5c5c0000007171717171710000005e5d0000005e0000000050534353525c005c0056550000550000000000555e7d006767676a676700000067676a670000
000000000000545c4f4f766b5d005b557b5e005d00005e00005c4b45474c5c5757005c5e005c5e004041426d6d4546475c005b005b454658656c005e5b0000484a5c005c005d5d5d7576745d005555754444444444745c5d5c5e71515351710000005d00550000550000005e00555e7d675a5a5a5a5a5a6700675a5a5a5a6700
40425c000000404200005500000000557b54555c5c55000000004b60624c005555416d6d6d6d41415051526d405743575b40414254455741426b005e00005460625c5c5c00005d005053526e00005650534363435352575757575061436152444042000055000000005500007c7d5e7d5a6969596959695a675a596969595a00
505244005d0050635b005500005d0057555d007d6c0054005b004d4f544e005757006d6d6d6d5d4b607f636d60646164546064625c606463624c5d00000054005d006e005d006e005051626e006e4b5061616d6161624c565e007151535171765051414255000000007600007d7d7d0069695959595969595a69696959695900
6364624c5e00504f005b484a5c0000586500006c6b6e005500005d40425c005555565c00005c5d4d4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4f4e0000404142005e005e000000000060616e005d004b50575c6d5c4f4f4e5e5d4b50534353524c60617f62555e00555500005e007d5e7569595969596959696959595959695900
4f4f4f6c0000505c5c406062426d6d58655c006b6b7d00555d004b60624c5b575700005c0000005b5e005d005e005d005b00005d005e00005c005d4b50435174550000005e00005e7b7b0000744042404141414141424c00004b45464646474c005e000055000000557d007d557d757b69696959596959696959695959696900
6d6d6d6b5c7d504652634f4f624c0058655c5b7d6b7d5b55005b4d4f4f4e5e555500005c5d005b005d6c7d0040414141425c000000005c48494a004b635143525500404200006e00000000557b6064606161646161624c5d004b57616161634c00005e005576555e555e5500557d7b7569775959696959595a59695969696900
5c5d5c00005c6061624f5c5c7b7d0058657d006c00007d550000005d5d000055576c5c0000000000006b004b504343515240425c5d0040454647005d5d6161646200505341425e00006e00005d004d4f4f4f4f4f4f4f4e005e4d4f4f4f4f4f4e005e005555000000555e5e55555e007b6f786f6f686868686f6f686868687800
__sfx__
000e00000d0520d0520d0520d002080520805208052080020d0520d0520d0520d002080520805208052080020d0520d00208052080020d0520d00210052100020f052100520f052100520f052100520c0520c052
010e00000c54307503135430000031625000000c543000000c54307503135430000031625000000c543000000c54307503135430000031625000000c543000000c543075031354300000316250c5430c54300000
000e0000077530775319052077531c052077531905207753200522005207753077531c0521c052077530775319052190521905219052190521905219052190520775307753077530775307753077530775307753
010e00000d0520d0520d0520d002080520805208052080020705207052070520d00208052080520805208002080520d0020905208002080520d00209052100020805206002060521000204052060520205202052
010e0000077530775319052077531c0520775319052077532005220052077530775321052210520775307753200522105220052210522005221052200522105220052077531e052077531c052077531805218052
010e00001905007753140500775319050077531c050077531b050077531805007753140500775318050077531905007753140500775310050077531405007753190500775314050077530d050077030000000000
010e00000d0520d0520d0520d002080520805208052080020d0520d00210052100020f052080021205208002100520d0020d0520c7020c0520d00208052100020d0520d052040021000201052010520105201052
010e00000d0520d0520d0520d002080520805208052080020d0520d0520d0520d002080520805208052080020d0520d00208052080020d0520d00208052100020705207052070520705208052080520800208002
010e00000d0520d0520d0520d002100521005210052100020f0520f0520f0520d00212052120521205208002100521005210052080020d0520d0520d052100020f0520f0520f0520700208052080520805208052
010e00000105201052010520d0020d0520d0520d052080020c0520c0520c0520d0020d0520d0520d052080020d0520d002100520e002070520d00208052100020705207052070520705208052080520800208002
010e00001405207703100520770312052077030f05207703100520b0020d052090020f0520700214052090020d0520d052040020900208052080520b002040020405204052070020500201052010520100200002
010e0000190501905520050077531c050077531e0500775319050077531c050077531f050077532005007753250500775320050077531f05007753200500775323050077531e5320775324050077531f53207753
010e0000200522005200002000021c0501f00220050000021f0521f05200002000021b0521b0521c00200002200522005200002000021f0500000220050000021805218052000020000219052190520000200002
010e00002505007753200500775325052250520775307753240500775320050077532305223052077530775321050077531c050077531b050077531c0500775320050077531b0500775318050077531b05007753
011a000007555005050e555005051255512505005050050507555005050e555005051255512505005050050507555005050e555005051255512505005050050507555005050e5550050512555125051555500505
011a000005555005050c555005051055500505005050050505555005050c555005051055500505005050050505555005050c5550050510555005050050500505005550050507555005050c555005050755500505
011a00002305526005260550c005210550c005230550c0051f0550c005210550c0051e0550c0051f0550c0051a0551a0551a0551a0451a0451a0351a0251a0150c0050c0050c0050c0050c0050c0050c00523005
011a0000210552100524055240051f0551f00521055210051d0551d0051f0551f0051c0551c0051d0551d00518055180551805518045180451803518025180150c0050c0050c0050c0050c0050c0050c0050c005
011a00000c0050c00526055240052a0550c005260550c0052f0522f0422f0522f0422f0352f0052a0550c0052605226042260522604226052260422603226022260150c0050c0050c0050c0050c0050c0050c005
011a00000c7050c705247550c705287550c705247550c7052d7522d7422d7522d7422d7350c7052b7552a7452975229742297522975229752297422973229722297150c7050c7050c7050c7050c7050c7050c705
012d00001a5551d555155551d5551a5551d555155551d5551a5551d555155551d5551a5551d555155551d555195551c555155551c555195551c555155551c555195551c555155551c555195551c555155551c555
012d0000260422605524045220452005220055210422104500000210402004521045220522104520045210451c0521f045190452204221045000002804225055000002204221055000051f055000051d0451c055
012d0000135551555516555135551a5551655515555135550e555105551155513555155550050011555105551355516555155551355511555155551355511555105551355511555105550e555005000d5500d555
012d00001d0521f0451c05526045210522104221055000000000000000200452105525045220551d045220551c0421f055190451605515042160551504516055190421a055190451a0551c0421d0551f04521055
012d00001a055210551d0551f055100551d0552005521055260422605524045220452104021055000000000022055220001f0552205521055000001d0551c0001f055210551d0551c0551a055000000000000000
01200000130451f0451a0452604514045200451804524045130451f0451a0452604514045200451804524045130451f0451a0452604514045200451804524045130451f0451a0452604514045200451804524045
01200000237322373223732237321f7321f7321f7321f73523735007052673500705217350070523735007021f7321f7321f7321f7321a7321a7321a7321a7350070000700007000070000700007000070000700
01200000131250c105131220c105131250c105131220c105131250c105131220c105131250c105131220c105131250c105131220c105131250c105131220c105131250c105131220c105131250c1051312213125
012000001f732007001a732187321a7321a7351f7021d7321f7321f7321f73500700207322073220735007001f7321f732237321f735007001a7321a7321d7321a73500700147321473218732117321375500700
01200000110451d0450f0451b045110451d0450e0451a045130451f0450e0451a0450c045180450e0451a045110451d0450f0451b045110451d0450e0451a045130451f0450e0451a0450c045180450e0451a045
01200000111250c105111220c105111250c105111220c105131250c105131220c105131250c105131220c105111250c105111220c105111250c105111220c105131250c105131220c105131251d0001312213125
0109000020055070051b055070051a0551a0051b055070051e055070051b055070051a055070051b0550700514052140521405214055070050700507005070050700507005070050700507005070050700507005
01090000195550c505145550c5051355513505145550c505175550c505145550c505135550c505145550c5050d5520d5520d5520d5550c5050c5050c5050c5050c5050c5050c5050c5050c5050c5050c5050c505
012000001873220702207322270223702247322370223732237021f73223702207321f7021f7321f702137321b732007002b7021a7321b7322f702207321f7322f7021a7322b7022f702187321a7321773224702
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000137521850119552106021c552185021955218502205522055220054245022455224552250542450525552255522555225552255422553225522255121850218502185021850218505185021850200504
010c0000107541270420754007041c75414704197540a7041475414754117040a7041b7541b7540a7040050419754197541975419754197541975419754197540050400504005040050400504000040000400700
010c00000453309500045030950004533005000450300500045330750004503005000453300500075000950004533005000050000500075330753307533075330753307500075330050007533005000753300500
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
000300001c0501c0502303023030270202702023020230201c0101c01023010230101c0151c015060000400001000000000300002000020000000000000000000000000000000000000000000000000000000000
000100001f0501c0501a05015150111500c15012050100500e0500c0500c1500905009050041500315002150001500015000150001001a0001500011000100001c00000100270000400000000000000000000000
00030000247702a7702a770247601d7601c7501a750127000e7000a70009700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
0003000025153291632d1632e1732f1732f1732b17328163251632416324153031530310303103031030310303103031030310303103031030310303103031030310303103031030310303103031030310303103
010200002165325653286532865314123141331414314153171631715317153101631016017160151000e1000e0000e0000200002000020000200002000020000200002000020000200002000020000200002000
000200000b152147521a7521c052160521c0520410204102041020410204102041020410204102041020410204102041020410204102041020410204102041020410204102041020410204102041020400204002
00010000161201f1401f140211201a100191001610014100131001310013100121001210012100121001310014100171001810000100001000010000100001000010000100001000010000100001000010000100
00010000000002d020300303204034030350203602000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000257402575023720217301f740007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
00020000297202e7302c7403273034720000001a70000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000157341554429704287041a0241a0341d7441d5441e744287041f7341f53421704237042352422734267042270427554265442b704007042302423534247340070420724285442474426734227541f744
00010000006200e720037000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 00 01 02 44
00 03 01 04 44
00 00 01 02 44
00 06 01 05 44
00 07 01 0b 44
00 08 01 0c 44
00 09 01 0d 44
02 0a 01 43 44
01 0e 10 12 44
02 0f 11 13 44
01 14 15 43 44
00 14 17 43 44
02 16 18 43 44
01 19 1a 1b 44
00 19 1c 1b 44
00 1d 1e 21 44
02 1d 1e 43 44
01 23 24 25 44
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
00 20 1f 43 44
