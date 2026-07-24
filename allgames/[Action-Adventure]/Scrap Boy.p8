pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--scrapboy
--by bonevolt
cartdata"bonevolt_scrapboy"
poke(0x5f2e,1)
poke(0x5f5c,255)
power_messg={}
msg=split("charge: hold the shooting\nbutton to charge!\n\n\ndouble jump: jump then\njump again!,bomb: use your movement\nto throw bombs further!\n\n\narmor: this form is immune\nto spikes,jet: dash into enemies\nto defeat them!\n\n\nyou can dash in any\ndirection!,boomerang: throw it in\nany direction!\n\n\nhover jump: jump higher\nand floatier!,magnet: pull enemies and\nthrow them into other\nenemies!\n\nwall jump: the magnet\nsticks to walls!,autoaim laser: try to\nhit multiple enemies\nwith one shot!\n\njetpack: air jump for\nunlimited flight!")
-->8
function _init()
s,f_btn,title,stage,dt,collect,diff="ÃÃÃÃÃÃÃ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¿ÃÃÏ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¿]UmUUU≈\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]UUÏ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\÷]\\÷››U\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0÷››≈·\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ug÷}ff]\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0vvfÏŒ≈\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0eU≈·ÃUU≈\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0W≈ÃŒÃ]\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]UU¬U’≈\0\0\0ÃÃÃÏ\0ÃÃ\0\0ÃÃ\0\0\0¿Ã¿Ã¿ÃÃÃÃ\0\0\0V]≈\\Õ‹\0\0–≈ÃÃÓ\0\0¿Ã\0\0\0\0Ã]UU,\\UU≈\0\0Ã]UU≈–UUÃUU\0¿\\U≈]U$\"\"\"\"¬\0\0]UU\\≈U\r\0\0l]UU≈\0]U\0\0¿U≈UUU\\\\UU≈\0¿U÷››Õp››≈U››\0\\UmU÷›JDDDD\"\0\0]UUU≈’\0¿}›››]Ï\0÷›Ï\0\0\\›U]UU\\\\U’≈\0\\›gffV`gf]›ff¿’››gf©©ôôID¬\0]UÂ^UU\0\\}gf›’≈gf≈¿’w]UUU\\≈ÃÃÃ¿’mUUU≈`UU‹g≈UP}VÏg]U)\"\"\"\"\"$\0]UÂ·≈U\0’WUU≈\\]VU]Ï\\}U≈UUU\\≈Ó\0PmU]U’≈–’UlU≈]–WUeUU] $,ÃÃ,B\0≈UÂ‹UU\0mU]U’\\’]]’≈’VU≈PUUUUÏ\0–VU\\UU≈–≈UﬁUUU`’U≈UUU)\"¬ÃÃÃ,¬\0,U’VU≈\0VUUUU\\U]UU]m]U≈\0UUUU≈Ó`’U\\UU≈–UUUUU]eUU≈UUU)ÃÃÃÃÃÃ\"\0,\\UUUUÏ]UUUU\\]UUU‹÷\\U≈\0PUUUUÏ–≈UUUU≈–UU\\UUU’UUUUUU)¬Ã\"\"ÃÃB\0,\\UUUU≈]]UUUUU]UU≈Ã\\U≈¿ÏUUUU≈Ó–UUUÂÓÓ–UUUUÂÓ’UUÓUUU$Ã,Ï.\"ÃB\0,\\UUUUU]UUÓ^UUU]U≈ÃUU≈\\Ã^UUU≈ÏPUUU–’UU\\\0\0UUÂ^UU$Ã,·\"Ã,\0%UUUUU]]U≈¡UU¿UUU\\U’≈›Õ^UUU≈≈–’UÂÓÓ–UUUÓ\0\0\0’UÓQU]$¬,Œ\"Ã,\0ÕUÂÓUU≈]U≈ÓﬁUU‡\\UU\\UUÂ}f]UUUUUPUU≈ÃÃÏ–UUU\0\0\0UU’Ã]UU$ƒ,ÏL\"Ã,\0]UÂ\\UÃUUU›VUU≈ŒUUUUUVUUUUU≈≈PUUU››ÕPUU≈\0\0\0\0UUU›UUU$\",D)¬Ã¬\0U]Â¡]ÃÃ]UUUUUU]Ï\\UUÂÓ\0]]UUUUU≈¿U≈\"\"\"¬–U≈‚\0\0\0\0≈UUUUUU$¬,\"¬ÃÃ‚\0]U’mÃÃ≈U]UUUU]g÷UUU\0]UU≈UU,‚‡U,,¬\"ÃPU%\0\0\0\0‡UUUUUU$¬ÃÃÃÃ,\0UUUU\\ÃÃ\\UUUUUUVUUUÏ·\0\0UU\\UU%\"\0Œ,\"\"¬ÏPU\"\0\0\0\0\0\\]UUU]$ÃÃÃÃ,¬\0U≈ÃÃÏŒÏ\0¿U]U‹UÂ\0]UU,\"\0\0\\U\\U,\"Ï\0\0‡\"\",,Ó¿≈\"\0\0\0\0\0¿UUÂ\\U$Ã\"Ã\"\"Ó\0\0\\U≈ÃÓ\0\0\\U^U\0]UU,‚\0\0\0‡ÓÓÓÓÓ\0\0\0ÓÓÓÓ\0ÓÓ\0\0\0\0\0\0ÓÓÓÓ\0$ƒ\"ÓÓÓ\0\0\0‡ÓÓÓ··\0\0\0‡Ó··Ó\0\0UU≈,\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0$\"¬\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‡ÓÓÓ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0$\"Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0$,Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0$¬Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\"¬Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0$ÃÃ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¬ÃÃ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‡Ó\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0",{},true,spl_unp"1,0,0,0"
music()
for i=0,0x7ff do
poke(i+0x1000,ord(s,i))
end
end
function spawn_char()
hp,obj,double_jump,charge,dash_dur,stage_init,char_mode,hp,hurt,invinc,grab,pull,show_collect=maxhp,{},true,spl_unp"240,-30,90,-1"
music(split"16,0,8"[stage])
c=
{
x=xstart,
y=ystart,
xs=0,
ys=0,
}
for i=0,127 do
for j=0,47 do
local ii,jj=i<<3,j<<3
local tile=mget(i,j)
if tile==32 and not xstart then
c.x,c.y=ii,jj-2
end
if tile>=74
and tile<80 then
new_obj(tile-74,ii,jj)
elseif tile==210 then
new_obj(6,ii,jj)
elseif tile==211 then
new_obj(7,ii,jj)
elseif tile==248 then
new_obj(8,ii,jj)
end
end
end
upd_cam()
end
function init_stage()
str={
"zw\0\0xz|}~|d~|}~xyz\0\0\0xyz|}~pr|d~|}~xz|d~|}~ptrpqrpqrwxyz|d}}~wxyzptrxuzxyyuyzpqrw|d~|}~hijhiijxuzpqrxzptr|d~|d~xyz|d~|}~xuz|}~|dmn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`b\0\0\0\0\0\0\0Ã`ab\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xyzxyyzhUj\0\0\0\0\0\0\0\0\0\0\0\0\r\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`ad~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pr\0\0\0\0\0\0\0\0ptr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xyz\0\0\0\0\0\0\0\0\0Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¯\0pqij\0\0\0\0\0\0\0\0\0\0\0“\0\0\0\0\0\0\0xz\0\0\0PR\0\0\0hij\0\0¯\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0C\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‰\0\0\0\0hiyz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`b\0\0\0`b\0\0\0xyz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ê\0\0AD\0\0\0\0“\0D@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0PFRPQRPQRXYZXYZxyij\0\0\0\0\0\0\0‚\0\0\0\0\0\0\0\0\0\0\0pr\0\0\0pr\0\0\0`abXGYZ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0AD@DD\\H^@@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ê\0\0\0\0\0\0\0\0\0\0\\]^PQR\0\0\0\0\\-^`Tbptrpqrxuzxyz`ayz\\]^\0\0\0\0XZ\0\0\0\0\0\0\0\0\0\0hj\0\0\0gg\0\0\0pqrxyuz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0AD@@@|d~@DB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0PQRPFRlmnptr\0\0\0\0|}~pqr\0\0\0\0\0\0\0\0\0\0\0\0pqUjlmn\0\0\0\0xz\0\0\0\0\0\0\0\0\0\0xz\0\0\0ww\0\0\0xuz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XGZ\0\0\0\0\0A@@DDD@\0DDB\0‚\0XYZ\\]^\0\0\0\0\\]^\0\0\0pqrptr|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hiyz|d~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0\0ln\0\0\0`ab\0\0\0\0\0\0\0\0\0\0XYYZW\0\0\0\0xuz\0\0\0\0\0A@D\0\0EEEDEBXYZhijlmn\0\0\0\0|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xy`abhj\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0|~\0\0\0ptr\0\0\0\0\0\0\0\0\0\0\0hiijg\0\0\0\0\0\0\0\0\0\0\0\0A@DEEE\0ED‰Bhijxuz|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ê\0\0\0\0”\0\0lmpqr[z\\]^\0\0\0\0\0\0\0\0\0\0\0\0\0|~\0\0\0gg\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xuyzw\0\0\0\0\0\0\0\0\0\0\0\0A@\0DDDDDE\\HxuzD\0\0hijœœœœœ‡‡‡ŒŒ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\H^\\H^\0\0\0\0\0\0\0\0\0\0\0\0|}Ujhcjlmn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ww\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0·glmVn\0\0\0\0\0\0\0\0\0\0\0A@@@@@XYZlVnhjD¯Dxuzﬂﬂﬂﬂﬂﬁﬁ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|d~|d~\0\0\0\0\0\0\0\0\0\0\0\0lmuzxc[|}~Z\\]^\0\0\0\0\0\0\0\0\0\0\0\0L\0hj\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0w|}d~\0\0K\0\0\0\0\0\0\0\0\0A@@@@@hij|}~xz\0DEhjlmnlVn`Tbhj‡‡‡ŒŒŒœœœ\0\0Ã\0\0\0\0g`abhj\0\0\0WXYZ\0\0\0\0\0|}hijccbhijlmn\0\0\0\0\0\0\0\0\0\0\0\0\0xz\\]^PFR\\]^ŒŒŒŒŒŒœœlmmngœœŒŒŒŒŒŒŒŒŒ\\]^\\]^XxyzhjlmnXYZxz|d~|}~ptrxzﬁﬁﬁﬂﬂﬂ\0\0\0\0\0M\0wpqrxzŒŒŒghijŒŒœœœhixy[ccrxuz|d~XGZXYZ\\]^\\H^\\^hjlmn`TblVnﬁﬁﬁﬁﬁﬁﬂﬂ|d}~wﬂﬂﬁﬁﬁﬁﬁﬁﬁﬁﬁlVnlmnhUjwxz|d~hijhj@DEED@hj`Tb`abhijlmnPQRPFRWhUj`TbﬁﬁﬁwxyzﬁﬁﬂﬂﬂxyhicccjhijhijhUjhizlmnlVnlnxz|d~pqr|d~xuzhijlVnhijlVnhijhijhij|}~|d~xyzlnhijhxyzxzDEEEEDxzpqrptrxyz|d~`ab`Tbgxuzptrhijlmnhijlmnhi\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hcjlcn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ï\0\0\0\0\0\0lmnhj\0\0\0\0\0Ï\0\0\0\0\0\0\0x\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0J\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xcz|c~\0\0\0\0\0\0Ï\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0¯\0\0|}~xz\0\0\0\0\0\0\0\0\0\0\0\0\0l\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hcjln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hjlmn\0\0¯\0\0\0\0\0\0\0\0\0\0|\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XYZ\\^XGZ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0·xcz|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xz|}~\\^\\^\0\0\0\0\0\0\0\0\0`\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hijlnhUjXYZ\0\0\0\0\0\0\0\0XYZ\\]^XYZ\\]^W\0\0\0`sb\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã\0\0`TablVnln·\0\0\0\0\0\0\0\0p\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xyz|~xyzhij\0\0\0\0\0\0\0\0hij|d~xyz|d~w\0\0\0ptr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pttr|}~|~\0\0\0\0\0\0\0\0\0`\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xuz^\0\0\0\0\0\0\0xyz\0\0\0\0\0\0\0\0\0\0\0\0\0lmn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xyzxuzpqr\0\0\0\0\0\0\0\0\0p\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0C\0\0\0\0\0\0\0C\0\0\0\0\0\0\0\0|~lnPR\0\0\0\0\0hUj\0\0\0\0\0\0\0\0\0\0\0\0\0|d~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\r\0\0\0\0\0\0\0\0\0\0\0\0\0‚\0\0g\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@@@@@@@B\0\0\0\0\0\0\0\0\0\0|~pr\0\0\0\\Hxuz\0\0\0\0\0\0\0\0\0\0\0\0\0`Tb\0\0\0\0K\0\0\0\0\0\0\0\0\\]^W\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\]^w\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@@@@@@@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0lVnhj·\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0\0\0\0\0\0\0\0\0|}~w\0\0\0\0\0\0\0\0\0\0\0\0PR\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0J\0\0\0\0\0\0\0lmn`\0 \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@@@@@WPQR\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|_~[z\0\0\0\0PQRPQRPFR`ab\0\0\0\0\0\0XYZ\0\0¯\0g`ab\0\0\0\0\0XYZ\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|_~p\\]^\0\0\0\0\0\0\0\0\0\0\0XZPQR@@@XYZg`ab\0\0\0\0\0\0\0\0\0\0\0\0\0\\]^hk`cb\0\0\0\0pqrptrpqrptr\0\0\0\0XZhij\0\0\0\0wSqr\0\0\0\0\0hij‡‡‡ŒprXYZ\0\0\0\0\0\0\0\0\0\\-^\\]^\0\0\0\0\0\0\0\0\0gcSblmn\0\0\0PR\0‡Œ\0\\^hj`abXGZhijwSqr\0\0\0\0\0\0\0\0\0\0\0\0\0lmn[kpcr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hjxyzŒŒŒŒlcngŒŒ‡‡‡xyzﬁhjhij\0\0\0\0\0\0\0\0\0lmnlmn\0\0\0\0\0\0\0\0\0wccr|}~PFR`bPRlnxzSqrhUjxyz[obg\0\0\0\0\0\0\0\0\0\0\0‰\0|}_ckjcj\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XZxzlmnﬁﬁﬁﬁ|c_wﬁﬁlmn`abjx[xyz^\0\0\0\0\0XGY|}~|}~YYZ\\H^\\]^`csghij`Tbpr`aab|~h[cjwxyzlmncorwZ\\H^\\]^\\]^XYZ`acckzc[\0\0\0\0\0\0\0\0\0\0‰\0\0\0\0\0\0\0hjpr|d~jhijhcchij`ab|d~ptrzhcjlmn\0\0\0\0\0hUij`bhiUiijlVnlmnpcrwxuzpqrhjptqr`bxcczlmng|}~{ohijlVnl_nlmnhijpqccklccWXYZ\\]^WXYZXGZ\\^PRxzlmnhijxyzxccxyzSSr`abwxuzxcz|}~\0\0\0\0\0xuyzprxyyyuz|d~|}~gcabk}~|}~xzxyyzprxuyz|}~wxuuzwxyz|}~|d~|d~xyz`abxz|d~wxyzlmnwxuzxyz|~prxz|d~xyzzzzzzzzzptrwpqrln|~xyz`Tb\0\0\0\0\0pqrxzptrxuzpqr|d~wwptrkb\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ptr\0\0\0\0\0\0\0\0\0|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADDDDDD|~Khjlnpqr\0\0\0\0\0\0\0\0\0Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xkr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ï\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0“\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0AEEEDD@@wYxz|~`ab\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hkj\0¯\0Ê\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADE\0EDE@xyz`abpqr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ê\0\0“\0\0xkz\0\0\0\0\0\0\0\0\0\0\0\0\0PQR\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A\0\0EE@@@@@@pqrlmn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0C\0\0\0\0\0\0`ab\0\0\0\0\0\0\0\0\0\0XGZ\\]^\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‚\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0AEEE@@DDD@@`Tb|d~PFRPQR\0\0\0PQQR\0\0\0\0\0\0\0\0\0\0M\0\0|d~\0\0\0\0\0\0ADDD\0DDpqr\0\0\0\0\0\0\0\0\0\0hUjlmn·\0\0\0\0\0\0\0\0\0\0\0PFQR\\]^\0\0\0\0\0\0\0L\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADD@@DEEED@pqr`ab`Tb`ab\0\0\0`aab\0\0\0\0\0\0\0\0\0\0\0\0\0hgg\0\0\0\0\0\0ADEDDD@`bg\0\0\0\0\0\0\0\0\0\0xuz|}~\0\0\0\0\0\0\0\0\0\0\0\0`Tablmn\0\0\0\0\0XZPQRPFR\0\0\0\0\0\0\0\0\0\0XYZPFRXYZD@@DDE\0ED@@@@ptrpqrptr\0\0\0pqqr\0\0\0\0\0\0\0\0\0\0PFRxww\0\0PQR\0A@DDED@prw\0\0\0\0\0\0\0\0\0\0\0\0\0`ab\0\0\0\0\0\0\0\0\0\0\0\0pqtr|}~\0\0\0\0\0hjpqrpqr\0\0\0\0\0\0\0\0\0\0xuz`Tbhij‚@@DE\0EED@@@@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`Tblmn\0\0`ab\0ADDED@Wgln\0\0\0\0\0\0\0\0\0\0\0¯\0ptr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0\0\0\0\r\0\0\0\0\0\0\0\0\0\0\0\0\0pqr[yz\\]^DE\0\0ED@@@DB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\\]^ptr|d~\0\0pqr\0A@@D@@gw|~\0\0\0\0\0\0\0\0\0\0\0\0\0`Tb·\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0“\0hijcTblmnDDEEDD@DE@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0lmnhijlij\0\0`abPQRXGZXwlmn\0\0\0\0\0\0\0\0\0\0ŒXZpqrXYZPQR\0\0\0PQR\0\0\0\0\0\0\0\0\0\0\0\0|~\0O\0\0\0\0\0\0\0\0\0\0\0\0\0PQRxyzcSr|}~\\]^DD@@@D@B\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0PQRPFR|}~xuz|yz\0\0ptr`abxuzhj|}~\0\0\0\0\0\0\0œœŒﬁhjlmnhij`abXYZ`abXYZ\\H^‰\0\0\0\0\0hj\0\0\0\0\0\0\0\0\0‰\0œ‡‡‡`ablmnccj`TblmnDD@@@@@B‰\0\0\0\0‰\0\0\0\0\0\0\0\0\0\0`ab`Tbhij@@DDmn\0\0lmnpqrlmnxz`abW\0\0PQR\\ﬂﬂﬁwxz|_~xyzptrhijpqrhijlVnXYZ\\]^xzZXZ\\]-^XYZ\\]ﬂpqr|_~cczpqr|}~XGZPQRXGZ\\H^\\H^\\]^XGZXGZptrpqrxuzDEEDd~\0\0|}~hij|}~hjptrg\0\0`ablmnhUjlmc`ablmnjxuzhijxuz|}~hijlmnhijhjlmmnhijlmn`abhijhkjccn`ab`abhUj`abhUjlVnlVnlmnhUjhUjhjhij`ab\0E\0EDjg\0\0xyzxuzxyzxzhijw\0\0pqr|}~xuz|}cptr|}~zhUjxyzxz`aTbxyz|d~xyzxz|}_~xyz|_~pqrxyzxkzcc~ptrpqrxuzptrxyz|d~|d~|}~xuzxuzxzxuzpqrEDE\0@",
"~\0\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0\0[\0\0\0w\0\0\0xuzxzpqrwpqrptrpqrpqr|}~|}~pqrxyzxyz|~|~\0\0\0|}~xyzwpqrpqrxyzxyzw|}~pqrpqrpqr\0\0\0\0lmn\0\0\0xyzxuzxyzxuzb\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0c\0\0\0g\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0`r\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0PQRWc\0\0\0w\0\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0C\0\0\0\0\0\0\0C\0\0\0|~\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0·l_n\0\0\0\0\0\0\0\0\0\0\0\0\0\0pn\0\0O\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pqrw{\0\0\0g\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0A@@@@@@@B\0\0\0hj\0¯\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0|c~\0\0\0\0\0\0\0\0\0\0\0Ê\0\0g~·\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0w\0\0\0|~\0\0\0PQRPQRPQRXZ\\^\\]^\\]^W\\]^\0\0\0\0|~\0\0\0\0\0XZXZ\0\0\0A@@@@@@@B\0\0xz\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0\0lcn\0\0\0\0\0\0\0XZ\0\0\0\0\0wn\0\0\0\0\\]^\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0g\0\0\0hj\0\0\0pqrptrpqrxzln|d~|}~w|d~\0\0\0\0hj\0\0\0\0\0xzxz\0\0\0A@@@@@@@B\0\0\0\0\0\0\0\0\0gg\0\0\0\0\0\0\0\0\0\0\0\0\0|c~\0\0\0\0\0\0\0hj\0\0\0\0\0`~\0\0\0\0|d~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0“\0w\0\0\0xz\0\0\0\0\0\0\0\0\0\0\0\0\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0\0\0xzH^\0\0\0\0\0\0\0\0\0PQR@@@@@@B\0\0\0\0\0\0\0·ww\0\0\0\0\0PQR\0\0\0\0·lcnXYZ\0\0\0\0xz\0\0\0PFpj·\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‰\0\0\0\0\0\0g\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0\0xlVn\0\0\0\0\0\0\0\0\0pqrPQRXYZXZ\0\0\0\0\0\0\0\0`b\0\0\0\0\0pqr\0\0\0\0\0|c~hij\0\0\0\0|~\0\0\0`Tbz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0C\0PRPQRPQQw\0C\0|~\0\0\0\0\0\0‰\0\0\0\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0\0,.|d~\0\0\0\0\0\0\0\0\0\rxzptrxyzxz\0\0\0\0\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0\0xczxuz\0\0\0\0hj\0\0\0pqrn\0\0\0\0\0\0\0\0\0XYZ\0\0\0\0A\0prpqrpqqr\0B\0hjPQRPQRPQRPR\0\0\0`b\0\0\0PQRPQRW\\]^<>jprPR\0\0\0Ã\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0PQxz\0\0\0xyz~·\0\0\0\0\0\0\0\0xyz\0\0\0\0ADEEDDD\0\0\0\0\0B\0xzptrpqrpqrpr\0\0\0pr\0\0\0pqrptrw|}~xuz\0\rpr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|}~\0\0\0\0\0`abg\0\0\0,./j\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADDEEDED\0\0\0DB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hj\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0PFRW\0\0\0\0\0\0\0\0\0\0\0\0\0\0pqrw\0N\0<>?z\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADEEEEEED\0DDB\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0\0\0\0\0\0\0\0\0Ã\0\0\0\0\0\0\0\0\0\0\0\0XZ\\-^XZ\0\0”\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0\0`Tbg\0\0\0\0\0\0\0\0\0\0\0\0PQw`ab\0\0\0hijj·\0¯\0ŒŒŒŒŒŒŒŒ\0\0\0\0ADDDDEDDDDDDB\0\0\0\0\0\0J\0\0‰\0\0\0\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0K\0\0\0\0\0\0\0\0\0hjlmnhj\0\0\0\0\0ln\0\0\0\0‰\0\0\0\0\0\0\0\0pqrw\0\0\0\0\0\0\0\0\0\0\0\0`abpqr\0\0\0xyzz]^XGﬁﬁﬁﬁﬁﬁﬁﬁGZXYZ\\]^\\H^\\^XZ\\]^PQR\\]^XYZXYZ\\H^Xpr\\H^XYZXGZXYZ\\]^W\\-^XZ\\^Xxz|}~xzPQRPQ|~YZPFRPQRXYZ\\]w`TbPQRWXYZPQRXYpqrhij\\]^hijlmnhUjxyzhijhUjhizlmnlVnlnxz|d~pqr|d~xuzhijlVnhijlVnhijhUjhij|}~glmnhjlnhijhj`ab`ab`abxyz`Tbptrxyz|d~pqr`Tbgxuz`abhijlnxyzlmnxyzb\0\0\0\0\0\0\0\0\0\0\0\0\0lVn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`abpqrw\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0\0g`ab`abr\0¯\0\0\0\0“\0\0\0\0¯\0|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pqrg`ab\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0\0\0wptrpqrb\0\0\0\0\0\0\0\0\0\0\0\0\0lmn\0Ã\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ï\0\0\0\0\0\0\0\0\0\0\0\0`abwpqr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`b\0\0\0\0\0\0\0\0\0\0\0\0\0\0`ab`Tbgr\0\0\0\0\0\0\0\0\0\0\0\0\0|d~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0“\0\0\0\0\0\0\0‚\0‚\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pqrDEDS\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pr\0\0\0\0\0\0\0\0\0\0\0\0\0\0pqrpqrwb\0\0\0\0\0\0\0\0\0\0\0\0,./w\0\0\0\0\0\0\0“\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0PQQR\0\0\0\0\0\0\0\0\0\0\0\0\0PFRW\0\0\0\0\0\0\0\0\0\0\0\0`abEÃEc\0\0\0\0\0\0PQRPFRPQR\0\0\0\0\0\0\0\0\0\0PQR\0\0\0\0\0\0\0\0\0\0\0\0\0`r\0\0\0\0\0\0\0\0\0\0\0\0<>?g\0\0\0\0\0\0XZ\0\0\0\0WXYZ\0\0\0\0\0\0\0\0\0\0\0\0\0pqqr\0\0\0\0\0\0\0\0\0\0\0\0\0`Tbg\0\0\0\0\0\0\0\0\0\0J\0pqrDE\0c\0\0\0\0\0\0`ab`Tb`ab\0\0\0\0\0\0\0“\0\0`ab\0\0\0\0\0\0\0\0\0\0\0“\0pg\0\0\0\0\0\0\0\0\0\0\0\0xyzw\0\0\0\0\0\0hj\0\0\0\0wxyz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ptrw\0\0\0\0\0\0\0\0\0PQR`ab`abc\0\0\0\0\0\0pqrpqrptr\0\0\0\0\0\0\0\0\0\0ptr\0\0\0\0\0\0\0\0\0\0\0\0\0`w\0\0\0\0\0\0\0Ê\0\0\0\0\0`ab\0\0\0\0\0\0xz\0\0ŒŒlmng\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0x[yz\0\0\0\0\0\0\0\0\0pqrpqrpqrs\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Œ\0\0\0PFRpb\0\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0Œhj\0\0ﬁﬁ|d~w^\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ADEEÊEEEDB\0XYZc\0\0\0\0\0\0\0\0\0\0\0,./g`ab`ab\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ﬁ\0\0\0`Tb`r\0\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0ﬁxz\0\0xyyzlVn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@DDEEED@B\0xyzc\0\0\0\0\0PQR\0\0\0<>?wpqrpqr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0`\0\0\0ptrpn\0\0\0\0\0\0\0\0\0\0\0,./g\0\0\0\0\0whj\0\0\0\0\0\0|}~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@@DEDDDB\0,./c\0\0\0\0\0ptr\0\0\0xyz\0\0\0\r\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\r\0\0\0\0\0\0w~\0\0\0\0\0\0\0\0\0\0\0\0<>?w\0\0\0\0\0\0xz\0\0\0\0¯\0ln\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@\0@DEEEB\0<>?c\0“\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0K\0`g\0\0\0\0\0\0\0\0\0\0\0\0xyzgŒ\0\0\0\0\0hj\0\0\0\0\0\0|~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0A@@@@DE\0EB\0xyzsQR\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0pw\0\0\0\0\0\0\0\0\0\0\0\0\0lnwﬁ\0\0\0\0\0xz\0\0\0PQRln·\0\0\0œ‡\0\0\0ŒŒ\0\0\0\0\0\0A@@@@@DEEB\0\0\0g`ab\0\0\0\0‰\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ŒŒŒŒŒ‡‡ŒŒŒ‡‡‡œœŒŒŒœœœœŒŒŒŒŒ`n\0\0\0\0\0\0\0\0\0\0\0\0\0|~xz\0\0\0\0\0lnŒ\0\0pqr|~ZW\\]ﬂRWXﬁﬁXGZPQRXGZXYZPFR\\]H^wptr\\H^\\^XGZ\\]^XYZ\\-^WPQR\0\0\0\0XYZXGZXﬁﬁﬁﬁﬁﬁﬁﬁﬂﬂﬁﬁﬁﬂﬂﬂ-ﬂﬁﬁﬁﬁﬁp~\0\0\0\0\0\0\0\0\0\0\0\0\0hj_\0\0\0\0\0\0|~ﬁ\0\0`Tbhijglmn`bghijhUj`abhUjhij`TblmVnghijlVnlnhUjlmnhijlmng`ab\0\0\0\0hijhUjhijhij`bhij`ablnhijlnlmnhijhij_\0\0\0\0\0\0\0\0\0\0\0\0\0xzc\0\0\0\0\0Œ`bw\0\0pqrxyzw|}~prwxuzxyzptrxyzxuzpqr|d}~wxuz|d~|~xyz|}~xuz|}~wpqr\0\0\0\0xuzxyzxuzxyzprxuzptr|~xuz|~|}~xyzxuzc\0\0\0\0\0\0\0\0\0\0\0\0\0hjc\0\0\0\0\0ﬁpr\0\0\0\0\0\0`ab¯\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hj\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0g\0\0\0\0`c\0\0\0\0\0\0\0\0\0\0\0\0\0xzc\0\0¯\0\0wln\0\0\0\0\0\0pSr\0\0\0Ï\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0w\0¯\0\0pc\0\0\0\0\0\0\0\0\0\0\0\0\0|~c\0\0\0\0\0\0|~\0\0\0\0\0\0lcn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0¯\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0L\0\0\0\0\0g\0\0\0\0`c\0\0\0\0\0\0\0\0\0\0\0\0\0lncŒ\0\0\0\0\0gg\0\0\0\0N\0|c~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0M\0|~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0w\0\0\0\0pc\0\0\0\0\0\0\0\0\0\0\0\0|~sﬁ\0\0\0\0\0ww\0\0\0\0\0\0lcn\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0‚\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0ln\0\0\0\0‡Œ\0\0\0\0\0\0\\^\\]^PQR\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hc\0\0\0\0\0\0\0\0\0\0\0\0\0pqqr\0\0\0\0\0`bPQR\0\0\0|c~\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XGZPQRWPFR\0\0\0\0\0\0\0XY|~FRPQﬁ\0\0\0\0\0\0lnlmn`ab‡‡‡‡‡\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xc\0\0“\0\0\0\0\0\0\0“\0\0`ab\0\0\0\0\0\0prpqr\0\0\0`sb\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XYZ\0\0\0hUj`abg`Tb\0\0\0\0\0\0\0hij`Tb`abg\0\0\0\0\0\0_~|}~ptr\0\0\0\0\\]]^XZ\0\0\0\0\0\0\0\0\0\0\0hc\0\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0\0`Tabg\0\0\0pqr\0\0\0\0\0\0\0\0\0\0\0\0\\]^PR\0\0\0hij\0\0\0xyzpqrwpqr\0\0\0\0\0\0\0xuzpqrpqrw\0\0\0\0\0\0clVnxyzpqrptr\0\0\0\0lmmnhjYZ\0\0\0\0\0\0\0\0\0xc\0\0\0\0\0\0\0\0\0\0\0\0\0wln\0\0\0\0\0\0pqtrw\0\0\0lmn\0\0\0\0XYZW\0\0\0\0lmn`b\0\0\0xuz\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0|}\0\0\0\0\0\0\0\0\0\0\0\0{|}~\0\0\0\0\0\0\0\0\0\0\0\0\0___~xz[[\0\0\0\0Œ\0\0\0\0lc\0\0\0\0\0\0\0\0\0\0\0,.|~\0\0\0\0\0\0\0\0\0\0\0\0\0\0|}~\0\0\0\0xuzw\0\0\0\0|}~pr\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hj\0\0\0\0\0\0\0\0\0\0\0\0xyzg\0\0\0\0\0\0\0\0\0\0\0\0\0ook\0\0\0ck\0\0\0\0ﬁ\0\0\0\0|c\0\0\0\0\0\0\0\0\0\0\0\0<>?g\0\0\0\0\0\0\0\0\0\0\0\0\0\0hij \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0XYZW\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0“\0L\0\0\0\0\0\0\0,./w\0\0\0\0\0\0\0\0\0\0\0\0\0ooo\0¯\0cc\0\0\0\0g\0\0\0\0hc\0\0\0\0\0\0\0\0\0\0\0\0xyzw\0\0\0“\0\0\0\0\0\0\0\0\0\0xuzGZ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0hijg\0\0J\0\0\0\0\0\0\0“\0\0hj\0\0\0“\0\0\0\0\0\0\0\0<>?g\0\0\0\0\0\0\0\0\0\0\0\0\0ooo\0\0\0cc\0\0\0\0w\0\0\0\0xc\0\0\0\0\0\0\0\0\0\0\0\0\0`ab\0\0\0\0\0\0Œ\0\0\0Œ\0\0\0hjhUj\0\0\0\0\0\0‰\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0xuzw\0\0\0\0\0\0\0\0\0\0\0\0\0xz\0\0\0\0\0\0\0ŒŒŒŒŒhijw·\0\0\0‰\0\0\0\0\0\0\0\0ooo\0\0\0ccŒŒŒŒgŒŒŒŒl\0\0\0\0\0\0\0\0\0\0\0\0\0pqr\0\0\0\0\0\0ﬁ\0\0\0ﬁ\0\0\0xzxyz\0\0\0\0PFRPQR\0\0\0\0\0\0\0\0\0‰\0\0\0\0\0\0glmn\0\0\0\0\0\0\0\0\0\0\0\0\0hjPFRPQRXﬁﬁﬁﬁﬁxyzwPQRPQRPQR\0\0\0\0ooo\0\0\0ccﬁﬁﬁﬁwﬁﬁﬁﬁ|n\0\0\0\0\0\0\0\0\0\0\0\0\0`ab\0\0\0\0\0\0g\0\0\0g\0\0\0hijhjPQRW`Tb`abPQRPQR\\]^\\]^PQRXw|}~Z\\^\\^\0\0\0\\]^XYxz`Tb`abhijhijglmn`ab`ab`ab\0\0\0\0ooo\0\0\0{{jhijhUjhij",
}
if stage<3 then
local n=1
for i=0x1000,0x2fff do
local t=ord(str[stage],n,n)
if i<0x1800 or i>=0x2000 then
n+=1
poke(i,t)
end
end
else
reload()
end
charlight,camx,camy,dt,xstart,ystart=spl_unp"23,0,0,0"
spawn_char()
spawn_screen()
end
function spawn_screen()
if boomer_obj then
if boomer_obj.typ<6 then
del(obj,boomer_obj)
else
boomer_obj.x,boomer_obj.y=boomer_obj.ix,boomer_obj.iy
end
end
roomdt,roomdt480,enm,lgt,shot,trail,ptc,boomer_thrown,closest,boomer_obj,lamp=0,0,{grab or pull},{},{},{},{}
local x,y=camx\8,camy\8
for i=x,x+15 do
for j=y,y+15 do
local ii,jj=i<<3,j<<3
local tile=mget(i,j)
if tile==2 then
new_enm(0,ii,jj)
elseif tile==225 then
local e=new_enm(1,ii,jj)
if is_solid(i-1,j) then
e.flip=true
end
elseif tile==226 then
new_enm(2,ii,jj)
elseif tile==228 then
new_enm(3,ii,jj)
elseif tile==230 then
new_enm(4,ii,jj)
elseif tile==236 then
new_enm(5,ii,jj)
elseif tile==204 then
new_enm(6,ii,jj)
elseif tile==11 or tile==203 then
lamp=true
elseif tile==59 then
lamp=false
end
end
end
end
-->8
function new_ptc(x,y)
return add(ptc,
{
x=x\1+rnd(2),
y=y\1+rnd(2),
g=0,
dt=rnd(10),
typ=2,
dur=8,
ys=0,
xs=0,
clr=11,
siz=2,
}
)
end
function new_light(x,y,r,dt)
return add(lgt,
{
x=x,
y=y,
r=r,
dt=dt,
}
)
end
function new_shot(typ,x,y,xs,ys,is_enm)
if typ==4 then
new_expl(x+4,y+4)
else
sfx(split"52,53,54,54,0,56,57,52"[typ+1],-1,split"16,0,0,16,0,0,0,16"[typ+1],split"16,16,16,16,16,16,13,16"[typ+1])
end
local tt=typ+1
return add(shot,
{
typ=typ,
x=x,
y=y+4,
xs=xs,
ys=ys,
is_enm=is_enm,
dt=0,
spr=split"28,74,0,75,-10,9,0,73,"[tt],
siz=split"1,1,2,1,5,2,0,1"[tt],
spd=split"5,4,3,0,0,0,0,0"[tt],
dur=split"30,42,55,9999,2,9999,75,120"[tt],
wal=({false,false,false,true,false,false,false,false})[tt],
lgt=split"15,25,45,0,0,30,0,15"[tt],
dmg=split"1,2,3,5,5,1,1,.61"[tt],
flinch=split".1,.1,1,1,.1,.1,.05,.1"[tt]*60,
}
)
end
function new_enm(typ,x,y)
local tt=typ+1
return add(enm,
{
typ=typ,
x=x,
y=y,
xs=0,
ys=0,
dt=0,
ang=0,
sprt=split"2,225,226,228,230,236,204"[tt],
sprx=split"16,8,16,32,48,96,96"[tt],
spry=split"0,112,112,112,112,112,96"[tt],
w=split"1,1,2,2,2,2,2"[tt],
h=split"1,2,2,2,2,2,2"[tt],
cdwn=split"0,60,120,120,120,30,120"[tt],
mxcd=split"0,120,120,120,120,120,120"[tt],
hp=split"1,3,3,3,3,3,3"[tt],
}
)
end
function new_obj(typ,x,y)
return add(obj,
{
typ=typ,
ix=x,
iy=y,
x=x,
y=y,
}
)
end
-->8
function _update60()
if title then
if (btnp(ó) or btnp(é)) and dt~=1 then
if sel_diff then
tim,maxhp,title=0,5-diff*2
init_stage()
else
sel_diff,diff=0,0
end
end
if btnp(î) then
diff-=1
elseif btnp(É) then
diff+=1
end
diff%=3
else
if message then
if message.dt~=90
or btnp(ó)
or btnp(é) then
message.dt+=1

if message.dt>120 then
message=nil
end
end
elseif stage_init==0 then
upd_game()
else
stage_init-=1
end
if wait_sound then
wait_sound+=1
if wait_sound>30 then
ssfx,wait_sound=osfx
end
end
end
end
function upd_game()
roomlight=stage<3 or camy==0 or lamp
if swap_mode_eff then
swap_mode_eff-=1
if (swap_mode_eff<=0) swap_mode_eff=nil
end

if show_collect then
show_collect-=1
if (show_collect<=0) show_collect=nil
end
roomdt+=1
roomdt480=roomdt%480

dt+=1
if dt%60==0 then
tim+=1
end
if hp<=0 then
wait_death=wait_death and wait_death+1 or 0
if wait_death==0 then
music"30"
end
if wait_death>25 then
for i=0,120 do
wait_death+=1
flip()
for x=0,128,16 do
for y=0,128,16 do
circfill(x,y,(wait_death-25)/2+y/8-12,0)
end
end
end
if t_att then
_init()
else
spawn_char()
spawn_screen()
end
wait_death=nil
end
end

if invinc and invinc>0 then
invinc-=1
else
invinc=nil
end

charlight,walk=23
prev_spd=max(.75,abs(c.xs)-.05)
if hurt then
hurt-=1
if (hurt<=0) hurt=nil
else
if dash_dur<0 then
if btn(ã) and not btn(ë) then
c.xs-=.2
c.flip,walk=true,true
elseif btn(ë) and not btn(ã) then
c.xs+=.2
walk,c.flip=true
elseif dash_dur==-30 then
c.xs*=.8
end

if dash_dur==-30 then 
c.xs=mid(c.xs,.75,-.75)
else
c.xs=mid(c.xs,prev_spd*.9,-prev_spd*.9)
end
else
charlight=40
mini_expl(c.x+6,c.y+6,rnd(5)+10)
if btn(ã) and not btn(ë)
and not c.flip then
dash_dur=0
elseif btn(ë) and not btn(ã)
and c.flip then
dash_dur=0
end
end
end

if dash_dur>-30 then
dash_dur-=1
if dash_dur>0 then
c.xs,c.ys=dash_h,dash_v
end
end
if (dash_dur<0) c.ys+=jetp and 0.05 or char_mode~=3 and .1 or (abs(c.ys)>.5) and .08 or .075

if type(ground)=="number" then
ground-=1
if (ground==1) ground=true
else
ground=false
end
wmag=nil
if char_mode==4 then
for i=(c.x-1)\8,(c.x+3+1)\8+1 do
for j=ceil(c.y+8)\8,ceil(c.y-2)\8+2 do
if is_solid(i,j)
and (i*8>c.x+6 and btn(ë)
or i*8<c.x+6 and btn(ã)) then
if (c.ys>0) c.ys=0 wmag=true
ground=10

goto _mag
end
end
end
end
::_mag::

c.y+=c.ys
c.y=max(c.y,-40)
nextcy,spike_hurt=c.y
for i=c.x\8,(c.x+3)\8+1 do
for j=ceil(c.y+4)\8,ceil(c.y+1)\8+2 do
local tile=mget(i,max(0,j))
if tile==248 then
mset(i,j,0)
end
if fget(tile,7) then    
if c.ys>0 and j>=(c.y+8)\8 then
nextcy,ground,double_jump,dash_dur,hurt,jetp=j*8-18,10,true,min(dash_dur,-25)
end
if c.ys<0 and j<=(c.y+8)\8 then
nextcy=j*8+4
end
c.ys=0
spike_hurt=char_mode~=1 and fget(mget(i,j),6)
end
end
end
::_y::
for i=(c.x+4)\8,(c.x-1)\8+1 do
for j=ceil(c.y+4)\8,ceil(c.y+1)\8+2 do
local tile=mget(i,max(0,j))
if char_mode~=1
and fget(mget(i,j),6) then
spike_hurt=true
end
end
end
c.y=nextcy
if spike_hurt then
char_hurt()
end
if btnp(é) and not hurt then
if (ground or double_jump and char_mode==0) then
c.ys=char_mode~=3 and -2.5 or -3.1
if not ground then
double_jump=false
end
ground=ssfx"52,-1,0,16"
elseif char_mode==5 then
jetp=true
end
end
if c.ys<-1
and not jetp
and dash_dur<=-30
and not btn(é) then
c.ys=-1
end
if btn(é) and jetp and char_mode==5 then
ssfx"53,-1,16,16"
local exp=mini_expl(c.x+(c.flip and 12 or -1),c.y+12,4+rnd(2))
exp.xs,exp.ys=c.flip and .5 or -.5,1
c.ys-=(c.ys>0) and .15 or .075
end

if (char_mode==5 and jetp) c.ys=max(c.ys,-1.5)

c.x+=c.xs
c.x=max(c.x,-2)
for i=c.x\8,(c.x+3)\8+1 do
for j=ceil(c.y+4)\8,ceil(c.y+1)\8+2 do
if is_solid(i,max(0,j)) then
c.x,c.xs,dash_dur=i*8+(c.xs>=0 and -12 or 8),0,min(0,dash_dur)
goto _x
end
end
end
::_x::

if waitshot then
waitshot-=1
if (waitshot<=0) waitshot=nil
end
if char_mode==-1 then
if btnp(ó) and
not waitshot then
waitshot=6
local s=new_shot(7,c.x+(c.flip and -4 or 8),c.y,c.flip and -1 or 1,0)  
s.xs*=2
end
elseif char_mode==0 then
if btnr(ó) then
ssfx"-1,0"
end
if not waitshot
and (btnr(ó) and charge>=30
or btnp(ó)) then
waitshot=6
local charge_lvl=min(charge\30,2)
local s=new_shot(charge_lvl,c.x+(c.flip and -4 or 8),c.y,c.flip and -1 or 1,0)
s.xs*=s.spd
end

if btn(ó) then
charge+=1
if charge==20 then
ssfx"57,0,13"
end
else
charge=0
end
elseif char_mode==1 then
charge=min(charge+1,30)
if btnp(ó) and charge>=30 then
new_shot(3,c.x+3,c.y,c.xs/2+(c.flip and -1.25 or 1.25),min(0,c.ys)/1.5-2)
charge=0
end
elseif char_mode==2 then
if btnp(ó) and double_jump then
double_jump=ssfx"55,-1,16,16"
dash_dur,dash_h,dash_v=20,get_btn_dir(2.5)
end
elseif char_mode==3
and not boomer_thrown then
if btnp(ó) then
boomer_thrown=new_shot(5,c.x,c.y,get_btn_dir(5))
end
elseif char_mode==4 then
if btnp(ó) then
if grab then
ssfx"54,-1,16,16"
grab.thrown,grab.xs,grab.ys,grab=true,c.flip and -3 or 3,-1.5
else
if not pull
and closest then
ssfx"56,-1,16,16"
pull=closest
end
end
end
elseif char_mode==5 then
charge=min(charge+1,180)
if (charge==120) ssfx"57,0,13"
if btnp(ó)
and charge>=180 then
if closest then
local s=new_shot(6,c.x,c.y,0,0)
s.tgt,charge=closest,0
end
end
end
for o in all(obj) do
local otyp=o.typ
if boomer_thrown 
and o==boomer_obj then
o.x=boomer_thrown.x
o.y=boomer_thrown.y
end
if abs(o.x+4-(c.x+4))<10
and abs(o.y+4-(c.y+6))<10 then
if otyp<6 then
swap_mode(otyp)

if not power_messg[otyp] and not t_att then
power_messg[otyp]=true
message=
{
dt=0,
typ=otyp,
}
end
for i=d128m16(o.x),d128m16(o.x)+15 do
for j=d128m16(o.y),d128m16(o.y)+15 do
if mget(i,j)==48 then
xstart,ystart=i*8,j*8-3
end
end
end
elseif otyp==7 then
for i=180,-50,-2 do
outline(circ,0,0,(o.x+4)%128,(o.y+4)%128,i,0)
flip()
end
if stage==3 then
cls()
?"     congratulations!\n\n         you win!\n\n\n\n        time: "..tim\60 ..":"..tim\10%6 ..tim%10 .."\n\n"..(t_att and "" or "  time attack unlocked!").."\n\n"..(collect<28 and "" or "you got all special orbs!").."\n\n\nby bonevolt and julio maass",spl_unp"12,40,13"
sel_diff=nil
dset(diff,1)
if collect==26 then
dset(diff+3,1)
end
if t_att then
dset(diff+6,dget(diff+6)==0 and tim or min(dget(diff+6),tim))
end
while not btn(é) 
and not btn(ó) do
flip()
end
_init()
else
stage+=1
init_stage()
end
end
if o==boomer_obj then
boomer_obj=nil
del(obj,o)
end
if (otyp==6) hp=min(hp+1,maxhp)
if (otyp==6 or otyp==8) ssfx"61" del(obj,o)
if (otyp==8) collect+=1 show_collect=180
end
end
closest=nil
for e in all(enm) do
local etyp=e.typ
if e.invinc then
e.invinc-=1
if e.invinc<=0 then
e.invinc=nil
end
end
local dx=mid(c.x+6-e.x-e.w*4,-127,127)
local dy=mid(c.y+8-e.y-e.h*4,-127,127)
e.range=sqrt(dx^2+dy^2)
if char_mode~=4
or (abs(e.y-c.y)<30
and abs(e.x-c.x-(c.flip and -25 or 25))<30)
then
if not closest
and not e.thrown then
closest=e
end
if not e.thrown then
if e.range<=closest.range then
closest=e
end
end
end
if e==pull then
local fflip=(c.flip and -4 or 8)
local ang=atan2(dx+fflip,dy)
e.xs,e.ys=cos(ang)*1.5,sin(ang)*1.5
local distx=(c.x+fflip)-(e.x+e.w*4)
local disty=c.y+6-(e.y+e.h*4)
if abs(distx)<8
and abs(disty)<8 then
grab,pull=e
end
e.x+=e.xs
e.y+=e.ys
elseif e==grab then
e.xs,e.ys,e.x,e.y=0,0,c.x+(c.flip and -4 or 8)-e.w*4+4,c.y+10-e.h*4
elseif e.thrown then
e.ys+=.1
e.x+=e.xs
e.y+=e.ys
else
if e.cdwn>0 then
e.cdwn-=1
end
if etyp==0 then
local ang=atan2(dx,dy)
e.xs,e.ys=cos(ang)*.1,sin(ang)*.1
e.x+=e.xs
e.y+=e.ys
e.flip=c.x>e.x
elseif etyp==1 then
if e.cdwn==0
and abs(e.y-c.y)<10 then
local s=new_shot(7,e.x,e.y,e.flip and 1 or -1,0,true)
s.dur,e.cdwn=120,e.mxcd
end
elseif etyp==2 then
if e.cdwn==0 then
e.flip=c.x>e.x
local dist=c.x-e.x
local s=new_shot(3,e.x+(e.flip and 8 or 0),e.y,dist/80,-abs(dist)/80-.5,true)
e.cdwn=e.mxcd
end
elseif etyp==3 then
e.ys+=.075

e.y+=e.ys
e.ground=false
for i=(e.x+3)\8,e.x\8+1 do
for j=ceil(e.y+4)\8,ceil(e.y+2)\8+2 do
local tile=mget(i,j)
if fget(tile,7) then
e.y=j*8+(e.ys>=0 and -19 or 4)

if e.ys>0 then
e.ground=true
e.xs=0
end

e.ys=0

goto _y
end
end
end
::_y::

if e.ground then
if e.cdwn<=0 then
local dist=c.x-e.x
e.ys,e.xs=mid(-2,-1,-abs(dist)/35),mid(1,-1,dist)
e.cdwn=e.mxcd
end
else
e.cdwn+=1
end

e.x+=e.xs

for i=(e.x+3)\8,e.x\8+1 do
for j=ceil(e.y+4)\8,ceil(e.y+2)\8+2 do
if is_solid(i,j) then
e.x=i*8+(e.xs>=0 and -9 or 5)
e.xs*=-.9
goto _x
end
end
end
::_x::
elseif etyp==4 then
local ang=atan2(dx,dy)
e.xs,e.ys=cos(ang)*.05,sin(ang)*.05
e.x+=e.xs
e.y+=e.ys
if e.cdwn==0 then
for i=0,.75,.25 do
local s=new_shot(7,e.x+3,e.y+1,sin(i+e.ang),cos(i+e.ang),true)
s.dur,s.wal=120
end
e.cdwn,e.ang=e.mxcd,e.ang+.125
end
elseif etyp==5 then
if e.xs==0 then
e.xs=.25
end
for i=e.x\8-1,e.x\8+3 do
for j=ceil(e.y+4)\8,ceil(e.y+2)\8+2 do
if is_solid(i,j) then
e.xs*=-1
goto _hx
end
end
end
::_hx::
if e.x%128>110
or e.x%128<10 then
e.xs*=-1
end
e.x+=e.xs
e.y+=sin(dt/40)/6
if e.cdwn==0
and abs(e.x-c.x)<10 then
local s=new_shot(7,e.x+4,e.y+4,0,1,true)
s.dur,e.cdwn=120,e.mxcd
end
elseif etyp==6 then
local ang=atan2(dx,dy)
if e.cdwn==0 then
local s=new_shot(7,e.x+4,e.y,cos(ang),sin(ang),true)
s.dur,e.cdwn,s.wal=120,e.mxcd
end
e.x+=sin(dt/120)/5
e.y+=sin(dt/70)/5
end
if dash_dur<=-30
and abs(e.x+e.w*4-(c.x+6))<6
and abs(e.y+e.w*4-(c.y+6))<e.h*4 then
char_hurt()
elseif dash_dur>-30
and abs(e.x+e.w*4-(c.x+6))<10
and abs(e.y+e.w*4-(c.y+6))<e.h*4+4 then
dmg_enm(e,{dmg=1,flinch=.05})
end
end
end
local expl_en=nil
for t in all(enm) do
if t.thrown then
for e in all(enm) do
if e~=t
and e~=pull
and abs(e.x-t.x)<10
and abs(e.y-t.y)<10 then
expl_en=t
goto _en
end
end
t.wal=true
if wall_coll(t) then
expl_en=t
goto _en
end
end
end
::_en::
if expl_en then
new_shot(4,expl_en.x+expl_en.w*4,expl_en.y+expl_en.h*4,0,0)
end
for l in all(lgt) do
l.dt-=1
l.y-=.25
if (l.dt<0) del(lgt,l)
end
for s in all(shot) do
local styp=s.typ
if styp<3 then
s.xs*=.96
s.xs-=sgn(s.xs)/50
local p=new_ptc(s.x+rnd(s.siz*4)-s.siz*2+4,s.y+rnd(s.siz*4)-s.siz*2+4)
p.clr,p.siz=10+rnd(2)\1*5,styp+1
p.dur+=styp*3
for i=0,3 do
if mget(s.x\8+i\2,s.y\8+i%2)==59 then
lamp=true
end
end
end
s.x+=s.xs
s.y+=s.ys
s.dt+=1
if styp==7 then
new_ptc(s.x+3,s.y+3)
end
if s.dt>=s.dur or wall_coll(s) then
if styp==3 then
new_shot(4,s.x,s.y,0,0,s.is_enm)
end
del(shot,s)
end
if styp==3 then
s.ys+=s.is_enm and 0.05 or .1
elseif styp==5 then
local ang=atan2(c.x+4-s.x,c.y+4-s.y)
local dir_ang=atan2(s.xs,s.ys)
local dif=dif_ang(ang,dir_ang)
local mult=dif>.5 and .05 or .1
s.xs+=cos(ang)*mult
s.ys+=sin(ang)*mult
s.xs,s.ys=mid(s.xs*.985,4,-4),mid(s.ys*.985,4,-4)

trail[1]={x=s.x,y=s.y}
if abs(s.x-2-c.x)<10
and abs(s.y-4-c.y)<10
and s.dt>30 then
del(shot,s)
boomer_thrown,trail[1]=false
if boomer_obj then
boomer_obj.x=c.x
boomer_obj.y=c.y
end
end
if not boomer_obj then
for o in all(obj) do
local ox,oy=o.x,o.y
if abs(s.x-ox)<8 
and abs(s.y-oy)<8
and ox>camx
and oy>camy
and ox<camx+128
and oy<camy+128
and o.typ~=7 then
boomer_obj=o
if o.typ<6 then
new_obj(o.typ,ox,oy)
end
break
end
end
end
elseif styp==6 then
roomlight=true
local e=s.tgt
local aim=atan2(e.x+e.w*4-c.x-5,e.y+e.h*4-c.y-9)
s.ang=s.ang or aim

for e in all(enm) do
if circ_line_coll(c.x+5,c.y+9,c.x+5+cos(s.ang)*200,c.y+9+sin(s.ang)*200,e.x+e.w*4,e.y+e.h*4,e.h*5) then
dmg_enm(e,s)
end
end
s_laser,c.flip=true,(s.ang-.25)%1<.5
end
if styp~=6 then
if s.is_enm then
if abs(c.x+5-(s.x+4))<s.siz*4+4
and abs(c.y+7-(s.y+4))<s.siz*4+4 then

if styp==0
or styp==1
or styp==3
or styp==7 then
if styp==3 then
new_shot(4,s.x-4,s.y-4,0,0,s.is_enm)
end
del(shot,s)
end
if dash_dur<=-30 then
char_hurt()
end
end
else
for e in all(enm) do
if abs(e.x+e.w*4-(s.x+4))<e.w*4+s.siz*4
and abs(e.y+e.w*4-(s.y+4))<e.h*4+s.siz*4 then
dmg_enm(e,s)
if styp==0
or styp==1
or styp==3
or styp==7 then
if styp==3 then
new_shot(4,s.x-4,s.y-4,0,0,s.is_enm)
end
del(shot,s)
end
break
end
end
end
end
end
for i=6,2,-1 do
trail[i]=trail[i-1]
end

local xx,yy=d128m16(camx),d128m16(camy)
for i=xx,xx+15 do
for j=yy,yy+15 do
local mm=mget(i,j)

if mm==7 then
xstart,ystart=i*8,j*8-3
end

if mm==44
and roomdt480>120
and roomdt480<=240
or (mm==11
or mm==203) and lamp then
roomlight=true
end
end
end

for p in all(ptc) do
p.dt+=1
p.ys+=p.g
p.x+=p.xs
p.y+=p.ys
if p.typ==1 then
p.siz=p.siz*.97-.1
if (p.siz>10) p.siz*=.9
p.x+=sin(p.dt/42)/4
if (p.dt>=p.dur) del(ptc,p)
end
end

for i=0,5 do
f_btn[i]=btn(i)
end

local last_camx,last_camy=camx,camy
upd_cam()
if last_camx~=camx
or last_camy~=camy then
spawn_screen()
end
end
-->8
menuitem(1,"swap buttons éó",function() ó,é=é,ó end)
function btnr(b)
return not btn(b) and f_btn[b]
end

function is_solid(i,j)
return fget(mget(i,j),7)
end

function char_hurt()
if not invinc then
hp-=1
ssfx"58,-1,0,16"
c.ys,c.xs,hurt,invinc=-1,c.flip and .75 or -.75,60,90
end
end

function new_expl(x,y)
ssfx"55,-1,0,16"
for i=0,10 do
mini_expl(x+rnd(16)-8,y+rnd(16)-8,rnd(8)+10)
end
new_light(x,y,30,30)
end

function mini_expl(x,y,sz)
local p=new_ptc(x,y)
p.siz,p.ys,p.dt,p.typ,p.xs,p.dur,p.g,p.wal=sz,rnd(.5)-.5,rnd(60),spl_unp"1,0,120,-.01"
return p
end

function dmg_enm(e,s)
if not e.invinc then
ssfx"62,-1,0,10"
e.hp-=s.dmg
if e.hp<=0 then
del(enm,e)
new_expl(e.x+e.w*4,e.y+e.h*4)
else
e.invinc=s.flinch\1
end
end
end

function swap_mode(m)
if m~=char_mode then
ssfx"61"
swap_mode_eff,char_mode=120,m
charge,pull=char_mode==0 and 0 or 600
if grab then
grab.thrown,grab.xs,grab.ys=true,c.flip and -1 or 1,-.5
grab=nil
end
end
end

function wall_coll(o)
if o.wal then
for i=(o.x+3)\8,(o.x-3)\8+1 do
for j=(o.y+5)\8,(o.y+3)\8+1 do
if is_solid(i,j) then

if o.typ==3
and mget(i,j)==29 then
for jj=j,j-5,-1 do
if mget(i,jj)==13 then
mset(i,jj,3)
break
else
mset(i,jj,0)
end
end
for jj=j,j+5 do
if mget(i,jj)==45 then
mset(i,jj-1,4)
break
else
mset(i,jj,0)
end
end
end

return true
end
end
end
end
end

function get_btn_dir(n)
local v,h=btn(î) and -1 or btn(É) and 1 or 0,btn(ã) and -1 or btn(ë) and 1 or 0
if h==0 and v==0 then
h=c.flip and -1 or 1
elseif h~=0 and v~=0 then
h*=.75
v*=.75
end
return h*n,v*n
end

function dif_ang(ang,dir_ang)
return min(min(abs(ang-dir_ang),abs(ang-dir_ang+1)),abs(ang-dir_ang-1))
end

function ssfx(s)
sfx(spl_unp(s))
end

function spl_unp(s)
return unpack(split(s))
end

function upd_cam()
camx,camy=mid(0,128*7,(c.x+4)\128*128),mid(0,128*2,(c.y+4)\128*128)
end

function to_time(t)
return t\60 ..":"..t\10%6 ..t%10
end

function d128m16(n)
return n\128*16
end
-->8
function _draw()
dt22,dt84,dt53,dt42,dt2,trand=dt\2%2*2,dt%8<4,dt%5<3,dt%4<2,dt%2,rnd"0xffff.ffff"
srand(dt)
if title then
dt+=1
draw_bg()

if sel_diff then
?spl_unp"normal\n\n hard\n\nbadass,54,44,0"
?"",50,44+diff*12
for i=0,2 do
if dget(i)==1 then
?"í",80,44+i*12
has_t_att=true
end
if dget(i+3)==1 then
?"Ü",90,44+i*12
has_t_att=true
end
if dget(i+6)>0 then
?to_time(dget(i+6)),104,44+i*12
end
end

if has_t_att then
if t_att then
?spl_unp"time attack enabled!,26,100"
else
?spl_unp"press ã to enable\n   time attack\n (no checkpoints),30,100"
end

if btnp(ã) then
t_att=not t_att
end
end

for i=1,5-diff*2 do
spr(210,34+i*9+diff*9,78)
end
else
outline(sspr,spl_unp"0,0,0,64,80,32,25,22")
outline(sspr,spl_unp"0,0,80,64,48,32,40,50")
if dt%40<20 then
?"  press ó or é",spl_unp"30,100,0"
end
end
elseif stage_init>0 then
cls()
?split"    stage 1\n\n  rust harbor,    level 2\n\nscrap labirinth,    stage 3\n\n   last spark"[stage],spl_unp"34,54,7"
else
dt20=dt2==0
cls()
if stage==1 then
draw_bg()
elseif stage==2 or camy==0 then
for i=0,127,16 do
for j=-8,127,16 do
spr(14,i,j+i/2%16,2,2)
end
end
end
local shake=hurt and hurt>53 and 2 or 0
camera(camx+rnd(shake*2)-shake,camy+rnd(shake*2)-shake)

for o in all(obj) do
if o.typ==7 then
pal(split"1,3,8")
for i=10,-6,-2 do
local cx,cy=o.x+4,o.y+4
circfill(cx+sin((dt+i)/60)*(i/2-5),cy+cos((dt+i)/60)*(i/2-5),sin((dt+i)/90)*2+5+i,(i-dt\4)%3)
end
pal()
end
end

if lamp then
local x,y=camx\8,camy\8
for i=x,x+15 do
for j=y,y+15 do
if dt20
and (mget(i,j)==11
or mget(i,j)==203) then
for n=1,7 do
circfill(i*8+4,j*8+4,36-n*4+rnd(2),split"14,12,2,4,10,15,7"[n])
end
end
end
end
end

map(spl_unp"0,0,0,0,128,48,8")

if roomlight then
map(spl_unp"0,0,0,0,128,48,1")

maph=c.y\8+1
map(0,maph,0,maph*8,128,48-maph,2)
else
light(c.x+5,c.y+8,charlight,3)

for p in all(ptc) do
if p.typ==1 then
light(p.x,p.y,p.siz,3)
end
end
for l in all(lgt) do
light(l.x,l.y+4,l.r,3)
end
for s in all(shot) do
light(s.x+4,s.y+4,s.lgt,3)
end
end

local clr=8
for tile_x=(c.x+6)\8-1,(c.x+6)\8+1 do
clr+=1
local r=5.5
for i=c.y\8+2,c.y\8+10 do
if (fget(mget(tile_x,i),6)) break
if is_solid(tile_x,i) then
clip((tile_x*8)%128,spl_unp"0,8,0x7fff")
local r=max(r\1,3)
ovalfill(c.x+10-r*2\1,i*8-1-r,c.x+1+r*2\1,i*8-7+r,14)
break
end
r-=.5
end
end
clip()

if not invinc or dt84
or wait_death or
swap_mode_eff
then
if char_mode==5 and charge>=180 then
for i=1,3 do
for n=0,1 do
circfill(c.x+(c.flip and -3 or 14),c.y+8+n,6-i-dt22,split"11,15,7"[i])
end
end
end
if char_mode==2
or char_mode==5 then
if char_mode==5 then
pal(4,3)
pal(9,8)
pal(10,11)
end
spr(214,c.x+(c.flip and 7 or -3),c.y+5,1,1,c.flip)
end
if char_mode==-1
or char_mode==0
or char_mode==5 then
spr(56,c.x+(c.flip and -5 or 9),c.y+5,1,1,c.flip)
elseif char_mode==4 then
if (wmag or grab or pull)
and dt%10<5 then
pal(6,11)
pal(13,8)
end
spr(213,c.x+(c.flip and -3 or 7),c.y+5,1,1,c.flip)
elseif char_mode==1 then
spr(212,c.x+(c.flip and -2 or 6),c.y-1,1,1,c.flip)
elseif char_mode==3
and not boomer_thrown then
spr(215,c.x+(c.flip and -2 or 6),c.y+5,1,1,c.flip)
end
pal()
spr(32+(walk and dt\8*2%8 or 0),c.x+(c.flip and -4 or 0),c.y,2,2,c.flip)

if (char_mode==0 
or char_mode==2 and dash_dur>-15)
and dt53 then
if (char_mode==0 and charge>=30) spr(5,c.x+(c.flip and -10 or 6),c.y,2,2,rnd()<.5,rnd()<.5)
if charge>=60 or char_mode==2 then
spr(7,c.x+(c.flip and -4 or 0),c.y,2,2,c.flip)
end
end

if (char_mode==5 and charge>=180
or s_laser)
and dt53 then
pal(split"1,2,3,8,5,6,7,8,11,11,11,12,13,14,11,0")
spr(7,c.x+(c.flip and -4 or 0),c.y,2,2,c.flip)
s_laser=nil
end
end
pal()

if roomlight then
map(0,0,0,0,128,maph,2)
end

for i=d128m16(camx),d128m16(camx)+15 do
for j=d128m16(camy),d128m16(camy)+15 do
local ii,jj=i*8+4,j*8+8
if mget(i,j)==44 then
if roomdt480>120
and roomdt480<=240 then
if roomdt480==121 then
ssfx"59"
end
circfill(ii,jj,7+dt22,10)
for x=i*8-12,camx-20,-16 do
spr(238,x,j*8,2,2,dt84,dt42)
end
circfill(ii,jj,6+dt22,15)
circfill(ii,jj,4+dt22,7)

if c.x<i*8
and abs(c.y+8-(j*8+8))<12 then
char_hurt()
end
elseif roomdt480>30
and roomdt480<200
or roomdt480<255
and roomdt480>120 then
new_light(i*8+4,j*8+8,28,2)
circfill(ii,jj,7+dt22,10)
circfill(ii,jj,6+dt22,15)
circfill(ii,jj,4+dt22,7)
end
end
end
end

function heli_pal(e)
if e and e.typ==5 then
clr={[0]=13,6,7,6}
pal(2,clr[dt\4%4])
pal(4,clr[(dt\4+1)%4])
pal(15,clr[(dt\4+2)%4])
end
end
for e in all(enm) do
local etyp=e.typ
if etyp==0 and dt42 then
spr(18,e.x,e.y+8)
end
if e.invinc
and dt42 then
pal(split"12,4,8,9,13,7,7,11,10,15,15,3,6,2,7")
end
heli_pal(e)
if etyp==3 then
local hh=e.cdwn==120 and 0 or e.cdwn<55 and 3 or sin(e.cdwn/30)*1.4+1.5
sspr(32,121,16,7,e.x,e.y+9)
sspr(32,112,16,9,e.x,e.y+hh)
else
if e.cdwn<=10 and dt42 then
if etyp==1 then
pal(split"3,2,8,4,5,6,7,11,9,10,15,12,13,14,7")
elseif etyp==5 then
pal(9,15)
pal(10,7)
end
end
spr(e.sprt,e.x,e.y,e.w,e.h,e.flip)
end
pal()
if etyp==6 then
circ(e.x+8,e.y+8,10+sin(dt/85)*2,7)
end
end

if char_mode==4 then
local e=closest or grab or pull
heli_pal(e)
if (e) outline(spr,11+dt22*2,0,e.sprt,e.x,e.y,e.w,e.h,e.flip)
pal()
end

if char_mode==5
and charge>=180
and dt20 then
for e in all(enm) do
if e==closest then
local ang=atan2(e.x+4-c.x-5,e.y+4-c.y-9)
line(e.x+e.w*4,e.y+e.h*4,c.x+5,c.y+9,11)
break
end
end
end

if trail then
if trail[6] then
pal(7,13)
spr(9,trail[6].x-4,trail[6].y-4,2,2,dt20,dt22==0)
end
if trail[4] then
pal(7,6)
spr(9,trail[4].x-4,trail[4].y-4,2,2,dt20,dt22==0)
end
pal()
end

for p in all(ptc) do
if p.typ~=1 then
circfill(p.x,p.y,p.siz,p.clr)
p.siz*=.9
if p.wal 
and is_solid(p.x\8,p.y\8)
and p.dt>10
or p.dt>p.dur
then
del(ptc,p)
end
end
end

for s in all(shot) do
if s.typ==7 then
pal(15,dt\2*4%12+7)
end
spr(s.spr,s.x-s.siz*4+4,s.y-s.siz*4+4,s.siz,s.siz,dt20,dt22==0)
pal()
if s.tgt then
for w=1,3 do
rr=split"6,4,2"[w]
local clr=split"11,15,7"[w]
circfill(c.x+5+cos(s.ang)*10,c.y+9+sin(s.ang)*10,rr+sin(dt/3)+1,clr)
for i=10+dt2*3,180,rr+1 do
circfill(c.x+5+cos(s.ang)*i,c.y+9+sin(s.ang)*i,rr+sin(dt/3),clr)
end
end
end
end

for i=0,4 do
for p in all(ptc) do
if p.typ==1 then
local x,y,sz,ys=p.x,p.y,p.siz,p.ys
xx,yy=sin(p.dt/60)/sz*2+rnd(1.5)-.75,cos(p.dt/60)/sz*2+rnd(1.5)-.75
circfill(x+xx*i,y+yy*i,sz*(1+max(0,i/10-.1))-i*1.5,i==0 and ((sz>5) and 4 or 5) or split"9,10,15,7"[i])
end
end
end

for o in all(obj) do
local otyp=o.typ
if otyp<6 then
palt(0,false)
local rot=ceil(sin(dt/120)*4-.5)
x1,x2=o.x+3-rot,o.x+4+rot
if x1>x2 then
x1+=1
x2-=1
end
local hh=ceil(cos((dt+40)/90)*3)
rectfill(x1,o.y-1+hh,x2,o.y+8+hh,1+dt\4%2*2)
pal(0,dt\4%2*12)
sspr(otyp*8+80,32,8,8,o.x+4-rot,o.y+hh,rot*2,8)
pal()
elseif otyp==6 or otyp==8 then
spr(otyp==6 and 210 or 248,o.x+sin(dt/95)*2+.5,o.y+sin(dt/60)*2+.5)
end
end

if swap_mode_eff and not message then
local x1,y1,x2,y2=c.x+1,c.y-11,c.x+11,c.y-2
rectfill(x1,y1,x2,y2,0)
rect(x1,y1,x2,y2,1+dt22)
spr(char_mode+74,x1+1,y1+1)
end
camera()

spr(spl_unp"200,1,1,2,3")
palt(0,false)
spr(char_mode+74,4,4)
if (char_mode>=0)spr(char_mode+194,4,14)
pal()
for i=1,maxhp do
spr(i<=hp and 210 or 211,i*9+7,2)
end

if show_collect then
spr(spl_unp"248,108,2")
?collect,spl_unp"118,4,7"
end

if message then
mdt,messagedt=mdt and mdt+1 or 0,message.dt
local h=abs(-sin(messagedt/120)*40)
if messagedt>30 
and messagedt<=90 then
h=40
end
clip(0,64-h,128,h*2,0)
rectfill(spl_unp"0,0,128,128,0")

if messagedt>30
and messagedt<=90 then
palt(0,false)
outline(spr,1,1,message.typ+74,10,41)
outline(spr,1,1,message.typ+194,10,65)
?msg[message.typ+1],spl_unp"25,40,13"

if messagedt>=90 then
pressx=pressx and pressx+1 or 0
if pressx%60<30 then
?spl_unp"press é/ó,40,84,6"
end
end
end

?"ÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅ",0,64-h+2,1
?"ÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅÅ",0,64+h-7,1
clip()
pal()
end

if t_att then
?to_time(tim),spl_unp"16,12,7"
end

end
pal(split"129,132,131,4,5,6,7,3,137,9,11,133,13,128,10",1)
srand(trand)
end
-->8
function draw_bg()
cls"9"
camera()
rectfill(0,64,127,127,5)

for i=1,3 do
circfill(64,32,15-i*2+dt2,split"10,15,7"[i])
end

trand=rnd"0xffff.ffff"
for c=0,1 do
for i=0,20 do
srand(1+i)
local x,y=(i*4+40+dt/100)%160-16,(rnd(15)-2)*sin(i/40)+45+c
circfill(x,y,(rnd(10))*-sin(i/40)+3-c,15+c*-5)
end
end

srand"24"
for i=-8,127,8 do
rectfill(i+rnd(8),30+rnd(32),i+16+rnd(8),63,12)
end

for j=64,127 do
local spc=(j-63)/8+8
for i=0,148,spc do
local n,w=(i+rnd(8)+dt/120*spc)%148-10,sin(rnd(1)+dt/90)*spc/2
if w>0 then
local pxh=192-j*2
rectfill(n-w,j,n+w,j,pxh>0 and pget(n%128,pxh) or 4)
end
end
end
srand(trand)
end

function light(x,y,r,l)
srand(dt)
r=r+rnd(2)
for i=-r+1,r-1 do
local yy,w=y+i,(sqrt(r^2-i^2)-.01)\1
tline(
x-w,yy,
x+w,yy,
(x-w)/8,yy/8,
.125,0,l)
end
srand(trand)
end
-->8
function outline(draw,c,t,...)
local o_pal,camx,camy={},camera()
for i=0,15 do
o_pal[i]=pal(i,c)
end
for i=-1,1 do
for j=-1,1 do
if abs(i^^j)==1 or t==1 then
camera(camx+i,camy+j)
draw(...)
end
end
end
camera(camx,camy)
pal(o_pal)
draw(...)
end


-->8
function circ_line_coll(x1,y1,x2,y2,xc,yc,rc)
local delta_x,delta_y,x_intersect,y_intersect=x2-x1,y2-y1,xc,xc

if delta_x==0 then
x_intersect=x1
elseif delta_y==0 then
y_intersect=y1
else
local slope,right_slope=delta_y/delta_x,delta_x/delta_y*(-1)

x_intersect,y_intersect=(yc+slope*x1-y1-right_slope*xc)/(slope-right_slope),right_slope*(x_intersect-xc)+yc
end

local xx,yy=mid(x_intersect,x1,x2)-xc,mid(y_intersect,y1,y2)-yc

return abs(sqrt(xx*xx+yy*yy))<=rc
end
__gfx__
000000000000000005555550e5dcccce000000000000000000000000000000f0000000000000077777770000007777770ddcddcde5dcccceeeec5d5555cce000
0000aa0009900000c555555ec5dceece0000000000000000000000000000000f000000000007777777777700070000007c665665c5dceeceeeec5d5555cce000
000faaffaff0a000c676d5ce244cccce0244442000000000000000000700fffff00000000077777777777700707767dd5c775775cddcccceeeec5d5555cce000
00afff7777fffa00ed995cce4994422229999442000000000f000000007ff7777f0000000077770007777770707760005c665665cd6ceeceeeec5d5555cce000
0aaf77777777ff00c9f99cee2444222294999494000000f7000f000000ff777f4900000000770000000777707000d0005c6dc6dccd65555eeeec5d5555cce000
9af777777777faaac94495ce0222222042994422000ff077af770000000fa4444f00000000700000000077777000dddd5cd5cd5ccd65ee5eeeec5d5555cce000
9af7777777777fa0cd9955ce000000002244425e0000a777777a0f00000f47f44f0000000700000000007777070000007cd5cd5ccd65555e000e5d5555cc0000
0af7777777777f9005d55ce000000000cd22ee5e0000f77777f00000000f4bf4490000000700000000007777007777770dcedcedcd65ee5eeee5cd5555cee000
af77777777777a9000a77a00000000000000000000f0f77777f00000000fa449ff0000000000000000007777000b8000000f0000cd65555eeeecdcccccece000
a777777777777fa900affa0000000000000000000000f77777f0000000000ffff90000000000000000007777000b800000af4f00cd65ee5eeeec56d555cce000
0af7777777777f00000aa0000000000000000000000007f7777f0000000000ff790000000000000000007770000b80000af77a00cd65555eeeec5d5555cce000
0afa77777777fff00000000000000000000000000000fafff0af00000000000f777000000000000000077770000b8000fa777900cd65ee5eeeec5d5555cce000
9aaff77777ffff00000000000000000000000000000fa00000000000000000f0f70700000000000000077700000b800009777fa9cd65555eeeec5d5555cce000
9000affffffafaa00000000000000000000000000000000f000000000000000f000000000000000000777700000b800090afa400cd65ee5eeeec5d5555cce000
0009affafafa000000000000000000000000000000000000000000000000000000000000000000007777000000083800000a0f00cd65555eeeec5d5555cce000
000000990aaa00000000000000000000000000000000000000000000000000000000000000000777777000000000380000000000cd65ee5eeeec5d5555cce000
00000dd00000000000000dd00000000000000dd00000000000000dd0000000000000000000000550000000000000880000000000cd65555e00005ceeeeeeeeee
00000ddd0000000000000ddd0000000000000ddd0000000000000ddd000000000000000000000555000000000000880000000000cd65ee5e0005ccccccccccce
d609999990000000d609999990000000d609999990000000d609999990000000000000005d022222200000000000b800000000003d65555e00055eeeeeeeee2c
dd699aaaa9000000dd699aaaa9000000dd699aaaa9000000dd699aaaa90000000000000055d22555520000000000b800000000003565ee5e000d5eecececec2c
ddd9aaa41c000000ddd9aaa41c000000ddd9aaa41c000000ddd9aaa41c000000000000005552555c1e0000000008b800000000008565555e094ddeeececece22
ddd921111b000000ddd921111b000000ddd921111b000000ddd921111b000000000000005552e1111b000000000b83000a99000a8c65ee5e4a46deecececec22
0dd917b11b0000000dd917b11b0000000dd917b11b0000000dd917b11b00000000000000055217b11b000000000b8000a7a94c4a8865555e4f976eeececece22
04991bb11c00000004991bb11c00000004991bb11c00000004991bb11c000000000000000c221bb11e0d07d0000b80009aa9429fbbeeeeee494676666464442c
0449211c440000000449211c440000000449211c440000000449211c44000000000000000cc2e11ecced5dd50008800099944249000000004946dccccccccc2e
002444442c000000002444442c000000002444442c000000002444442c0000000000000000ecccccecc5c55c00b3300024442c490000000049465eeeeeeeee2e
000222224c000000000222224c000000000222224c000000000222224c00000000607600000eeeeecc050cc0042300005222c5c40000000024465eccc555ce2e
0024999944c000000024999944c0000000249999445000000024999944500000026d66d000ec2222ccc00000ff9a00005c5c5c5c00000000c2265eeeeeeeee5e
055dd554425500000d55dd5442cc00000dd55dd442cc000005dd55d4425500000c54dd400555555cce55000094f40000d55555c500000000ccc65ecc55d5ce5e
d24424dd22ce0000d424425522ce00005244245522ce0000542442dd22ce000000d044005eccec55eece0000094900006d55d5550000000055cd5eeeeeeeee5e
54244255cee00000c2442455cee00000c42442cccee00000524424cccee00000000000005cecce55cee00000000000007dddddd500000000d55d5ddddddddd2e
0cc55cce000000000c55cc5e00000000055cc55e0000000005cc55ce00000000000000000cc55cce00000000000000006766666600000000666ceeeeeeeeeeee
c000000d0d242c0dc0242cd000000000c000000420000004eeeeeeeeeeeeeeeeeeeeeeee00000000009a0040001191000000ccd600c555c00007000000018bf7
ec0000dc0d242cdccd242cd000000000ec00004ce2000042cccccccccccccccccccccccc0000000090af9a000151a110000cd76dcdddddd5007770000118bf7f
0cd00ce00cd42ce00ec42dc0000000000c400ce0024002e0222222225555555533333333000bfb0000f77fa0111f111100cd765c00005dd60997d07018bbf7fb
00cdce0000cdce0000ecdc000000000000c4ce0000242e0022222222555555553333333300bf7fb00a7f77f09a177f110cd765dc00000d67999d07778bf77fb8
000cd000002cdc0000cdc20000000000000c40000002400044444444dddddddd8888888800f777f09f7777f011f775a90aa65dc000005d7c9940997dbf777b81
00cecd0000cecd0000dcec000002200000cec400002e240044449444dddd6ddd8888888800bf7fb00af77fa91cc5fcc19f7adc00000cd650a99999d0f777fb10
0de00cc00de22ec00ce22ed0009cc20004e00cc004e00220442c2944dd5c56dd83138888000bfb0000aafa0001cacc10a7fac00000cd6c002aa99200777fb810
dc0000ec0c242cecce242cc000292c004c0000ec420000e2994e14a966de1d7631e18bbb000000000090000a00191100fa90000005d500000222200077fb8100
02ceeeeeeeeeeeeeeeeeeee02cccce2222c1ecc255c1ecc5c1e5c33305ceeee005ceeeeeeeeeeeeeeeeeeee05cccce5503ceeeeeeeeeeeeeeeeeeee03cccce33
2cccccccccccccccccccccceec555ce2222c15c2555c12c5cc5cc3335cccccce5cccccccccccccccccccccceec555ce53cccccccccccccccccccccceec555ce3
22222222222222222225255cc5ccc5ce222c5c22555c2c553ccc33335555555c555555555555555552c2ccccc5ccc5ce33333333333333333535555cc5ccc5ce
42222222222222222252555cccdd5ece222c2c22555c5c553c333333d555555cd555555555555555552c222cccdd5ece83333333333333335355555cccdd5ece
4444444444444444444dddd5cd66d5ee222c2c22555c5c55333c3333ddddddd5ddddddddddddddddddd22222cd66d5ee88888888888888888dddddd5cd66d5ee
944444444444444444d4ddd55d66d5ce222c2222555c5555333333336dddddd56ddddddddddddddddd2222225d66d5ceb88888888888888888ddddd55d66d5ce
a9444444444444444d4dddd5cc55ccee22222222555555553333333376ddddd576ddddddddddddddd2d22222cc55ccee6b888888888888888d8dddd5cc55ccee
9a999999999999996966665c5d66d5ce2222222255555555333333336766665c67666666666666664444442c5d66d5ceb6bbddddbbbbbbbbbb6b665c5d66d5ce
942ccccc2c22c222225555ce5d66d5ce33333333d55555556d5b8eccd55cccc56d5ccccc55555555552222ce5d66d5ceb83ccccc33333333335355ce5d66d5ce
9242cc2c2222c22225255d5e5d66d5ce33333333d5555555651b8eccd5d5c5ce65d5cc5c555555555252242e5d66d5ceb383cccc3333333333353d5e5d66d5ce
92c22c22222222222252555ecc55ccee33333333bc55555565cb8ec5d5555c5e65555c555555555555252c2ecc55cceeb3c33ccc335333333333535ecc55ccee
92c22222222222222225c5ce5d66d5ce333333338b3c555565cb8ec5d55c555e655555555555555555525c5e5d66d5ceb3c33cc3333333333333353e5d66d5ce
92c222222222222222222cce5d66d5ce333333338883c55565cb8e55d555c55e65555c555555555555555c5e5d66d5ceb3c33cc3333333333333333e5d66d5ce
4222222222222222222252ce5d66d5ce33333c3333833555d55b8ec5d555555ed5555555555555555555255e5d66d5ce83333c33333333533333533e5d66d5ce
42222222222222222222225ecc55ccee3333ce1cee383e55d55838e5d55c555ed5555555555555555555552ecc55ccee83333333333333333333335ecc55ccee
42422c22222222222222242e5d66d5ceeeeeeeeecee83eeed55538e5d5555d5ed5d555555555555555555d5e5d66d5ce83833c33333333333333383e5d66d5ce
422222222222222222222c2e5d66d5ee2222222255555555d55588e5d555555ed5c55555555555555555555e5d66d5ee833333333333333333333c3e5d66d5ee
422222222222222222222c2ec555cece2222222255555555d55588e5d555555ed5c55555555555555555555ec555cece833333333333333333333c3ec555cece
42222222222222222222222e5d66d5ce2222222255555555d555b8e5d555555ed5555555555555555555555e5d66d5ce83333333333333333333333e5d66d5ce
42222222222222222222222ee5dd5cee22222e2255555555d555b8e5d555555ed5555555555555555555555ee5dd5cee83333333333333333333333ee5dd5cee
42222222222222222222222eeec5cece2222e1425555cc55d558b8e5d555555ed5555555555555555555555eeec5cece83333333333333333333333eeec5cece
42422222222222222222242eeceeecee222e1e425555ced5d5db83e5d5d5555ed5d555555555555555555d5eeceeecee83833333333333333333383eeceeecee
22222222222222222222222e2eccceee22e1e1c2555ce1ed555b8ee55555555e55555555555555555555555e5eccceee33333333333333333333333e3eccceee
ceeeeeeeeeeeeeeeeeeeeee222eeeee2eeeeeeeeeeeeeeeeceeb8eeeceeeeee5ceeeeeeeeeeeeeeeeeeeeee555eeeee5ceeeeeeeeeeeeeeeeeeeeee333eeeee3
c7e7c7d7e7000000000000008736a7071727074727071727778757a777c7d7e7c746e787a7c7d7e70717277777c7d7e70717270717278797a78757a7778696a6
7677c7d7e7074727c746e787a7c746e78757a7c7d78757a7071727c7d7e7074727c7d7e77707172707172787a7c7d7e707172777c746e787a7c7d7e7c746e736
8696a686a600000000000000c6f7e687a700000000000000000000000000c6d6e60000000000000000000000000000000000000000000000000000b0c05657a7
77000000000000000000000000000000000000000000000000000000000000c6e600000000000000000000000000000000000000000000000000000000000036
8797a787a700000000000000c746e7c6e60000000000008f000000000000c7d7e7acbc0000ce0000000000000000000000000000000000000000000000b12dc6
e60000000000ce000000000000000000000000000020000000000000000000c7e7000000000000000000000000000000007000000000000000000000002e0036
e60000000000000000000000000077c7e7000000000000c5e500000000008696a600000000000000000000000000000000000000000000000000000000b200c7
e7000000000000000000000000000000000075c5d5e5c5d5e5000075000000072700002d00000000000000000000008595a5000000000000008f000000c5d5f7
e70000000000000000000000b0c0c665e6000000000000c6e6000000b0c05657a700000000000000000000000000000000000000000000000000000000b31e06
2600002d000000000000000000000000000076c7d7e7c746e7000076000000c6e600006e00000000000000000000008696a60000000000000000000000c6d6e6
e60000000000008595a5c5e50000c7d7e7000000000000c7e700000000006696a6002e0000000000000000000000000525051525051525c5d5e585a500000007
27000000000000000000000000000000000077000000000000000077ecececc7e7000000000000000005152500b0c05697a70000000000000000000000c7d7e7
e70000000000008696a6c6e6000000000000000000000086a600000000006797a7c5d5e500000000000000000000000626071727074727c746e787a700000076
7600000000000000000000000085a505152576000000000005152576ededed86a600000000000000000717270000006696a600000000000000000000000000c6
e60000000000008757a7c7e7000000000000000000000087a700000000006696a6c6d6e6000000000000000000c5840727003400000000000000000034000077
7700000000000000000000000087a7074727770000000000074727778797a787a700008595a50000000000000000006757a700000000000000000000000000c7
e700003400000000000000000034000000000000000000062600000000006757a7c746e7000000000000000000c665e62600144454004e005444440424000006
260000000000000085a5000000c2e2f2062600000075000000000000000000c6e600008797a7000000000000000000b2c6e600000000000000000000000000c6
760000145400000000000054442400000000000000000007270000000000b187a7000000000000000000c5d5e5c7d7e727001404440515258595a58595a5c507
270515250000000086a6000000c3e3f30727ececec76000000000000000000c7e7000000000000000000000000cc00b3f5e7000000000000006e0000000000c7
770000144444540000a44444442400000000000000000086a60000000000b206260000000000008595a5c6d6e6c6f5e6e6001444440717278797a78757a7c7d7
e70747270000000087a70000008696a6c6e6ededed77d5e5c5d5e57500000086a600000000000000008595a50000008536a6000000000000000000c400000076
e60000140444445454544444442400000000000000000087a70000000000b307270000000000008797a7c746e7f5b6e7e7001404445400544444044424000000
0000000000000000000000000087b5a7c7e78797a7c7d7e7c746e77700000087a700000000000000008757a70000008736a70000000000000000000000000077
e700001404444444444444440424000000000000000000000000000000000000000000000000000626c6d6e68636b696a600144404445444445444cc24000000
00000000000000000000000000c6368696a600000000000000000000000000000000000000000000000000000000008636a600000000000000000000002d00c6
7600001404044444444444040424000000000000000000000000000000000000000000000000000727c7d7e78736b697a7001404044444544404044424000000
000000000000ec0e0e0e0e0e0ec7368757a7002d000000cc0000000000000000000000000000000000ecececececec8736a700000000000000000000000000c7
77152505152505642505642505152505642505152505152505642505152505152505642505152586a60626869636b6d6e605152585a5051525c584e5056425c5
d5e585a58595ed0f0f0f0f0f0f8636a6c6e6c5d5e5c5d5e5758595a5758595a5c5d5e58595a5c584e5ededededededc636e6056425051525750525c584e57576
06162606162606452606452606162606452606162606162606452606162606162606452606162687a70727875736b6d7e706162687a7061626c665e6064526c6
d6e686a68696a60616260616268736a7c7e7c6d6e6c6d6e6768696a6768696a6c6d6e68696a6c665e68696a68696a6c736e7064526061626760626c665e67677
00000000000000000000fff00000000000090fff000fff000fff0000006d06d00000000000000000dcddcdd07777770000000000000000000000000000000000
000666dddddd0000000009f007767650000900af0000af000fa00000076d76dd00066666666d0000566566c70000007000000000000000000000000000000000
007cccccccc5c000000090f00765ddce04090a0f00090f000f090ccc06d56d5d007cccccccccc000577577c5dd76770700000000000000000000000000000000
07d11111111e5c0000449000065dd5ce0029a0000090000000009ccc0dd5dd5d07d11111111ec000566566c500067707000000ddccc000000000000000000000
06c1009004015c000400400006dd55ce444f99990090000000004ccc0dd5dd5d06c100900401c000cd6cd6c5000d000700000dddcccc00000007d0000007d000
06c190a9a0015c004000000006d555ce002420000900000000040ccc0a7a0a7a06c190a9a001c000c5dc5dc5dddd00070000ddc7b81cc0000007d0000007d000
06c10a777f015c004000000005ccccce040404000400000000400ccc09f909f906c10a777f01c000c5dc5dc700000070000ddc77b881cc0000776d0000776d00
05c19f777f015c000000000000eeeeee000400000400000000400ccc0090009006c19f777f01c000decdecd077777700000dd777b888cc000077650000776500
05c10af7fa915c0007706660077066600000d4c000999966005ddd500000007006c10af7fa91c0000000000000000000000ccbbbbbbbc500e67665dec67665de
05c100afa0015c00733688367ee6eee6000d6a9c094444dd0056d5c56000006706c100afa001c0000000000000000000000cc888bbbbc50057766d5c57766d5c
05c1009000a15c00737888867e7eeee600d66da4044444dd05dd5cce6700006706c1009000a1c0000000000000000000000cc188bbbc5c0067766d5c67766d5c
05de111111116c006388bb866eeeeee60d66d5dc0444000005dd5c500670006606ce11111111c00000000000000000000000cc18bb55c00067766d5567766d55
00cddddddd66c000638bbb366eeeeee6d66d5dc00444000049d5cce000dd776606ccccccccc5c000000000000000000000000ccc555c00005d666dd53d666dd3
000ccccccccc0000063bb86006eeee6066d5dc00044499664a94c5e00000d66006ceeeeeeeeec0000000000000000000000000cc55100000d5dddd5d83dddd38
000000000000000000683600006ee6006d5dc000044444dd0a9444000000000006ceeeeeeee1c00000000000000000000000000000000000dddddddd88888888
0000000000000000000660000006600005dc0000004444dd000444000000000005ceeeeeeee1c0000000000000000000000000000000000066666666bbbbbbbb
0000000000000ddd000000000000000000000007d0000000000000000000000005ceeeeeeee1c0000000000000000000000000000000000000000000000ff000
00000000000007570000000000000000000000676d000000000000000000000005ceeeeeeee1c00000000000000000000000000000000000000000000ffff000
00000000000056660226013333100000006d4677dd425d0000000d5f95c0000005ceeeeeeee1c00000000000000000000000000000000000a000000aff777ff0
00000000000ddd5d2f92688bbb83000000daaa77daa42c00000fb5c44ccb800005ceeeeeeee1c00000000000000000000000022222200000ffa00afff777777f
0007d00000d6dddd9aa9b63bbbbb3000005faaaaaaaf4c00000885ddd5c3300005ceeeeeeee1c000000000000000000000ff442882444400fffaaff777777777
0007d000087d5ddd1a983b6388bb81000046d77fff9d520000d5566dd55ccc0005de11111111c00000000000000000000fffffb7b8fffff07ffaf77777777777
00776d00fbddc5c5138883b33888830000676daaa4d6d500005c66dd5555cc0000cdddddddddc0000000000000000000044444233444fff077fff77777777777
00776500b355c55501313881133333100076d5aaa4d6650000f96dd55555a900000ccccccccc0000000000000000000000442222222444007777777777f77777
e67665de33cce55501131111388831100065c444222cd6000044dd5555d54400007777000000000000000000000000000003222222211000777777777ffff777
57766d5c885ceccc111111113888311100001dcccc510000005cdd555dd5cc000749947000000000000000000000000000037b88833110007777777ffaaaff77
67766d5c0155ecec131111313333113100005c6d551c0000005cc55ddd5cc10074f999460000000000000000000000000008bb333311300077777fffa00aaff7
67766d5500e5cccc133111111111133100001dcccc510000000b8c5555c8300079999996000000000000000000000000000383c6dc131000f777ffaa00000aff
2d666dd2000eeccc013331111113331000005c6d551c000000033cca9cc1100079aaaa9600000000000000000000000000003cd7d5c10000ff7ffaa0000000aa
42dddd240000e5e5001133333333110000001dcccc51000000000cc44110000074aaaa4600000000000000000000000000000cd995c00000afffa0000000000a
4444444400000555000011111111000000000c6d5510000000000000000000000649946000000000000000000000000000000c9aa9c00000aaaa000000000000
9999999900000eee0000000000000000000000cccc000000000000000000000000666600000000000000000000000000000000c55c0000000aa0000000000000
__gff__
00000082020000000000000a0a82020200000000000000000000000100820202000000000000000000000001028202020000000000000000000000018202828201010101010102020200000000000000020202828282820202020282020202828282828282828282828282828282828282828282828282828282828282828282
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000001010a0a000002020200000000000000020000000000c2c202000000000000000000000000000000c2000000000000000000000000000000
__map__
6700000000000000000000002c2e2f70720000000000000000000000000070717200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077770000000000000000000d707172787a
77000000cc000000000000003c3e3f686a0000000000000000000000000060616200000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000000e60000000000000000000000000000000000000000000000686a0000000000000000001d0000000067
6700f800000000000000000078797a787a00000000000000000000000000707172000000000000000000000000000000000000000000cc0000000000000000000000000000005c5e000000000000000000000000000000000000000000000000000000000000000000000000000000787a00000000e2000000001d0000f80077
7700000000000000000000002c2e2f5f67000000000000000000000000006c6d6ee20000000000000000000000d20000000000000000000000000000cc0000000000000000006c6e00000000000000000000000000000000000000000000000000000000000000000002000000000000000000000050520000001d0000000067
6e00000000000000e60000003c3e3f6377000000000000000000000000007c7d7e5d5e00000000000000000000000000000000000000000000000000000000000000000000007c7e58475a000000d2000000000000000000000000585a00000000000000000000000000000000004a000000000000707200005c2d5e5c5d5e77
7e00f800000000000000000078797a636700000000000000000000000000686a6c6d6e000000000000005051525c5d5e5c5d5e5c5d5e000000000000000000504652570000006c6e68556a000000000000005700000000000000e1686a000000000000000000000000000000e20000000000000000000000007c647e7c647e68
6e000000cc000000000000002c2e2f637700000000000000000000000000787a7c7d7e000000000000007074727c647e7c7d7e7c647e000000000000505152605462770000007c7e78757a00005c485e585a670000000000504652787a52000000000000000000000000002c2e2f5c5d5e000000000000000000000000000078
7e5d5e5758595a00000000573c3e3f6367000000000000000000000000000000000000000000000000000d00000000000000000d000000000000000060616270717267000000000000000000006c566e686a7700000000006054626061625c5e5c5e0000000000000000573c3e3f7c7d7e00000000000000000000000000006c
7c647e6768696a000000006778797a7f77000000000000004f00000000000000000000000000000000001d0000e600000000001d00000000000000007074727c7d7e77000000000000000000007c647e787a6743000000007071727074726c6e6c6e00000000000000007778797a0d00000000000000000000000000d300007c
68696a7778757a00000000776c566e686a000000000000000000000000000000000000000000000000001d00000000000000001d00000000cc00000000000000000000000000000000000000000000707172774140444500454442000d777c7e7c7e0000000000000000000000001d00000000000000e600000000000000006c
78757a7074717200000000777c647e787a000000000000000000000000000000000000000000000000001d00000000000000001d00000000000000000000000000000000000000e400000000000000000000004140444445444042001d000000000000000000000000000000d2001d000000000000000000000000000000007c
5f00000000000000000000000000000000004a00004b00004c00004d00004e0000000000505152585a5c2d5e58475a5051525c2d5e000000000000000000000000000000cecececececece00000000000000004144004444444442e11d0000000000000000000000000000d200001d000000000000000000000000000000005f
6f0000000000000000000000000000000000000000000000000000000000000000000000606162686a6c6d6e68556a6061627c7d7e000000000000000000000000000000dedededededede00000000000000004144444440444442001d00d20000000058475a570000000000005c2d5e57000000000000000000000000000063
6f0000000000000000000000000000000007000000000000000000000000000000000000707453787a7c7d7e78797a707472605462cfcfcfcfcfcfcecece00000000000068696a676c6d6e00000000000000004140e444575c5d5e5c2d5e000000000068556a670000002c2e2f6c6d6e6700000000000000e4000000004f0063
6f0000000000000000005c485e5c5d5e505152505152504652585a5c5e585a5c485e5c5d775363696a7c7d7e6c6d5f68696a707172dfdfdfdfdfdfdedede50515250525878797a777c7d7e525c485e5c5d5e5758475a57676c6d6e6c6d6e58475a585978757a775c5d5e3c3e3f7c7d7e77525c5d5e5758475a58595a5c5d5e63
6f0000000000000000006c566e6c6d6e606162606162605462686a6c6e686a6c566e6c6d6e6363797a68696a7c7d6378797a68696a6c6d6e6c6d6e68696a606162606268696a6c6d6e6061626c566e6c6d6e6768556a67777c647e7c7d7e68556a68696a6c6d6e6c6d6e68696a60626061626c6d6e6768556a68696a6c6d6e63
6f0000000000000000007c7d7e7c645f707472707172707172787a7c7e787a7c7d7e7c647e737f7d7e78797a776863686a6078797a7c7d7e7c7d7e78797a707172707278797a7c7d7e7071727c7d7e7c647e7778797a777071727074727778797a78797a7c647e7c647e78757a70727071727c647e7778797a78757a7c647e7f
6f0000000000000000006c6d6e676c636e000000000000000000000000000000000000000000000000000000007863787a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000068
6f0000000000000000007c647e777c637e000000000000000000000000000000000000000000000000000000006763546200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f80078
7f0000000000000000006700000068636a00000000000000000000000000000000000000000000000000000000776371720000f8ec0000000000000000000000000000ec000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060
6ecacb0000000000000077004f0078637a000000505152570000d2000000d20000000000000000000000ec00006063626700000000000000000000000000000000000000000000000000000000000000000000000000e600000000000000000000000000000000020000000000000000000000000000000000000000000b0c70
7e00000000000000000067505152687b6a000000606162670000000000000000000000000000000000000000007063727700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000068
620000f80000000000007770717278797a0000007074727700000000d2000000000000000000000000000000006c7f6e670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005758595a0000000000e60000000200000000000000000000e6000000000000000078
720000000000000000000000000000000000000000006c6e5c5d5e5046525051520000000000000000000000007c647e7700000000000000000000000058595a505258475a0000005757000000005758475a00000000005c5e00000000007778797a000000000050520000000000505152585a50515200000000000000000060
670000000000000000000000000000000000000000007c7e6c6d6e605462606162000000000000000000000000676c566e00430000000000000000430068696a606268556a0000007777000000006768556a00000000007c7e000000000000000000000002000070720000000000707172787a70747200000000000000000070
77000000000000000000000000000000000000000000787a7c647e707172707472000000000000000200000000777c7d7e00414500000044444440420078757a707278797a0000000000000000007778797a00000000000000000000e600000000000000000000000000000000000d0000000000000d00000000000000000067
6e0000000000000000000000000000000000000000006c6e0000000000000d0000000000000000000000000000000d000000414444454444404040420000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000001d00000000d2001d000000004d0000000077
7e0000000000000000000000000000000000000000007c7e0000000000001d0000000000000000000000000000001d000000414445454440444444420000000000000000000000000000000000001d00000000000000000000cfcfcfe0e0e0cecececececfcfcf000000000000001d0000000000001d0000000000000000006c
6700200000000000000000000000000000000000000000000000000000001d0000000000000002000000000000001d00000041444500454444444542000000000000000000000000000000e400001d00000000000000000000dfdfdff0f0f0dedededededfdfdf000000000000001d0000000000001d00000000000000e6005f
775258595a0000000000000050515258595a000700004b000000000000001d0000000000000000000000000000001d0000004140444544444500e442cececececececfcfcfe0e0e0cfcfcfcececf1d000000cecfcfcececee06c6d6e60546268556a686a6c6d6ee0e0e0e0cececf1d0000000000001dcfcece00000000000063
606278797a0000000000000060616278757a5051525046525758595a575c2d5e5c5d5e585a5c485e50515257575c2d5e50515250515258475a58595adededededededfdfdff0f0f0dfdfdfdededf2d5e5847dedfdfdededef07c647e70747278797a787a7c7d7ef0f0f0f0dededf2d5e504652575c2ddfdede5c485e5c5d5e63
70726c6d6e000000000000007053726061626061626054626768696a676c6d6e6c6d6e686a6c566e60616267676c6d6e60616260616268556a68696a67787a78797a6c566e6061626c566e686a6c6d6e68556a6c6d68696a6061626c566e6061626c6d6e67605462606162686a6c566e605462676c6d6e686a6c566e6c6d6e63
__sfx__
010300101817018170181700000005600000000000000000181701817018170001001817018170181700000005200000000520000000056030000000000000000520300000052030020005603000000560305603
01180000101500e1500c150091500c1500e1500010010150101500e1500c150091500c1500e1500c1500c150101500e1500c150091500c1500e1500010007150071500b1500e15007150081500c1500f15008150
011800000b5700957007570045700757009570075000b5700b570095700757004570075700957007570075700b570095700757004570075700957007500025700257002570025700257003570035700357003570
011800000985009850098500985009850098500286002860048600486004860048600486004860048600786005860058600586005860058600586005860058600785007850078500785008850088500885008850
011800001532015320153201531015315153201c3201c3201a3201a3201c320153201532015310153101732018320173201832017320183201732013320133201a3211a3201a3201a3201a3201a3201a3101a310
011800002173018730157301c73018730157301c730187301c73017730137301c73017730137301c730137301d73018730157301d73018730157301d730187301f7301a730177301f7301a73017730207301b730
0118000009850098500985009850098500985009850098500b8400b8400b8400b8400b8400b8400b8400b84000870008700087000870028700287002870028700487004870048700487005870058700787007870
011800001532015320153201532015325153201c3211c3201a3201a3201c320153201532015310153101732018320173201832017320183201732013320133201532115320153201532015320153201531015310
011800001c73018730157301c73018730157301c730187301f7301a730177301f7301a730177301f7301a7301c73018730137301c73018730137301c730187301f7401c73017730217401d73018730237401f730
011800001183011830118301183011830118301183011830138301383013830138301383013830138300e83010830108301083010830108301083010830108301883018830188301883017830178301783017830
011800002132021320213201c3201c3201c32021320213201f3201f320213201a3201a3201a3201a3101a31018320173201332018320173201332018320133201c3211c3201c3201c3201c3201c3201c3101c310
011800001d73018730157301d73018730157301d730187301f7301a730177301f7301a730177301f7301a7301c73017730137301c73017730137301c73017730247301f7301c73024730237301f7301c73023730
010e000004263286031c6151c61504663000001c6151c61504263000001c6151c6150466300000042630420304263000001c6151c61504663000001c6151c6150426300000046630000004663000000426300000
000e00001c5321c5321c5321553215532155321c5321c5321a5321a5321a5321353213532135321a5321a53219532195321953212532125321253219532195321853218532185321153211532115321853218532
010e000010220102251022010220152201522017220172200e2200e2250e2200e220152201522017220172200d2200d2250d2200d220152201522017220172200c2200c2250c2200c22013220122200e2200e220
000e00001c5321c5321c5321553215532155321c5321c5321a5321a5321a5321353213532135321a5321a53219532195321953213532135321353219532195321a5321a5321a5021a5321a5321a5021a5321a532
000e0000092200922509220092250922009225092200922509220092250922009225092200922509220092250b2200b2250b2200b2250b2200b2250b2200b2250b2200b2250b2200b2250b2200b2250b2200b225
010e00001c2201c2201c2201c2201c2201c2201c2201c22000000000001c2201c2201e2201f22021220212202122023221232202322026220262202122123221232202322021220212201f220212202122021220
010e0000093200932015320153200932009320153201532009320093201532015320093200932015320153200b3200b32017320173200b3200b32017320173200b3200b32017320173200b3200b3201732017320
010e0000102201022510220102251022010225102201022510220102251022010225102201022510220102250e2200e2250e2200e2250e2200e2250e2200e2250e2200e2250e2200e2250e2200e2250e2200e225
010e00002322023220232202322523220232202322021200232212322021221212201f2201f22021220212202322023220232202322023220232202321023210000000000017220172201a2201a2201b2201b220
010e00000432004320103201032004320043201032010320043200432010320103200432004320103201032002320023200e3200e32002320023200e3200e32002320023200e3200e32002320023200e3200e320
000e000010220102251022010225102201022510220102250e2200e2250e2200e2250e2200e2250e2200e2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c225
010e00002322023220232202322026220262202822028220282202822026220262202122021220212202122023221242212422024220242202422024220242200000000000242202422026220262202722027220
000e0000043200432010320103200432004320103201032002320023200e3200e32002320023200e3200e32000320003200c3200c32000320003200c3200c32000320003200c3200c32000320003200c3200c320
000e0000042200422504220042250422004225042200422504220042250422004225042200422504220042250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c2250c2200c225
010e0000000000000028220282250000028220282251c20028221282202622026220232202322021220212202422024220242002422024220242002422000000242202422023220232201f2201f2201c2201c220
010e0000103251032510325103251032510325103251032510325103251032510325103251032510325103250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c3250c325
000e00000422004225042200422504220042250422004225072200722507220072250722007225072200722509220092250922009225092200922509220092250c2200c2250c2200c2250c2200c2250b2200b225
010e000000000000001a2201b2201c2201c2201a2201a2201c2211c2201a2201a2202322123220232202322021220212202122021220212202122021220212202121021210212201f2201a2201a2201b2201b220
000e00000432504325043250432504325043250432504325073250732507325073250732507325073250732509325093250932509325093250932509325093250932509325093250932509325093250932509325
01100020052330000000000000001d633000000520305233052030000005233000001d633002000000000000052330000000000000001d633000000000005233052030000005233000001d633000000000000000
011000200c3050c305213252132524325243250c3050c305213252132524325243250c3050c3050c3050c3050c3050c305213252132524325243250c3050c305233252332526325263250c3050c3052832528325
01100000092350943509235094350923509435092350943509235094350923509435092350943509235094350c2350c4350c2350c4350c2350c4350c2350c4350e2350e4350e2350e4350e2350e4350e2350e435
01100000052330000000000000001d633000000520305233052030000005233000001d633002000000000000052330000000000000001d63300000000000523305203000001d633000001d633000001d6331d633
011000000c3050c305213252132524325243250c3000c300213252132524325243250c3050c3050c3050c3050c3050c305213252132524325243250c3050c3051f3251f32523325233250c3050c3052432524325
011000002802024010210202801024020210102802024010210202801024020210102802024010210202801024020210102802024010210202801024020210102802024010210202801024020210102802024010
011000002b02028010240202b01028020240102b02028010240202b01028020240102b02028010240202b0102f0202b010280202f0102b020280102f0202b0101f4201f4201f4001f40020420204202040020400
01100000214202142021420214202142021420214202142021420000000000000000000000000021420214202b4202b4202b42028420284202842024420244202642026420264202842028420284202642026420
011000002842028420284202842028420284202842028420284200000000000000000000000000264202642028420284202642026420244202442026420264200000000000284202842028400264202642026400
0110000024421244212142121421214202142021420214200000000000000000000000000000001f4202042021420214202342023420214202142020420204200000000000204202042000000204202042000000
01100000214202142021420214202142021420214202140021420214002140021420214000000021420214201a4201c4211a4211a4201a4201a4201a4201a4201a420000001a4201c4201d4201c4201a4201a420
011000000523505435052350543505235054350523505435052350543505235054350523505435052350543507235074350723507435072350743507235074350723507435072350743507235074350723507435
011000002142021420214202142021420214202142021420000000000000000000002342023420244212442023421234201f4201f4201c4201c4201d4201d42000000000001f4201f4201f420214211f4211d421
011000000923509435092350943509235094350923509435092350943509235094350923509435092350943510235104351023510435102351043510235104350e2350e4350e2350e4350e2350e4350e2350e435
011000001c4201c4201c4201c4201c4201c4201c4201c42000000000001c4201a420184201a4201c4201c4201a4201a4201a4200000018420184201842000000174201742017420000001342013420134201d400
011000000523300000000000523300000000001d63300000000000000005233000001d6330000000000000000523300000000000523300000000001d63300000000000000005233000001d633186001d6331d633
011000001d4201d4201d4201d4201d4201d4201d4201d4201c4201c4201d4201d4201d4201c4201c4201c4201a4201a4201a4201a4201a4201a42018420184201a4201a4201f4201f4201f4201f4201a4201a420
011000001c4201d4211c4211c4201c4201c4201c4201c420000001c4201c400184201a420000001c420000001a4201a420000000000015420154200000000000174201742018420184201a4201a4200000018420
011000001842018420184201842018420184200000013420134201342015420154201742017420000001a4201a4201a4201a4201a42000000184201a4201c4201a4201a420184201842017420174201342013420
011000000423504435042350443504235044350423504435042350443504235044350423504435042350443510235104351023510435102351043510235104350823508435082350843508235084350823508435
011000001542017420154201542015420154201542015420154201542015420154201541015410154101541000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000011070120601406016060190501f05023050270402a0402b0302b03000000000000000000000000003b6103b6102f1102e1102e1102e1102e1102d1102c1102b1102a1102a11000100000000000000000
0001000036640356402e2302c2302b2302a22029220272202622025220232202322022220202101f210000000c6700c6700b6700b6700b6700a6500b6500b6500b6500a6500a6500c6500b6500b6500b6500b650
00020000276702067020440236701c44017640196401843016630166301563015620146201462014610146101c5501b5501954017540165401453012530115201c5001a500185001750015500145001640016400
01020000256702567025640256402563025630256302562025620256202562025620256102561025610256101b6601d6601d6601e6501f6501e6501f650206402064020640206402063020620206202062020620
000500002d6502c6102b64029610276302661025620246102362022610226002260022600216002160020600000001e2621e2521e2421e2421e2421e232002000020000200000000000000000000000000000000
000900002466224262242522425224252242422424224232242322422224222242122421215422164221742218422194221a4221b4221c4221d4221e4221f4222042221422224222442224422244222442224412
000200002507023070210601f0501e0501d0501d0501c0501c0301c03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000132760c106132760c106132760c106132660c106132660c106132660c106132560c106132560c106132560c106132460c106132460c106132360c106132360c106132260c106132260c106132160c106
000600002b050290502905027050270502705024050240502205022050220501f0501f0501f0501d0501d0501d0501b0501b05018050180501805016050160501605013050130501305013050130501305013050
000200001c05022050270502a05029050260501d0501d0501f0502205026050290502c05031050330503505000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001c6501b6501a6401a6401963019630196201862018610176103f7503f7503f75000000000003f7403f7403f74000000000003f7303f7303f73000000000003f7203f7203f72000000000000000000000
010c00200525300000000000000005663000000000000000052530000005253000000566300000052530000005203000000525300000056630000000000000000525300000052530020005663000000566305663
__music__
00 3f 01 43 44
00 3f 02 01 44
01 3f 03 04 05
00 3f 06 07 08
00 3f 09 0a 0b
00 3f 03 07 05
00 3f 02 02 01
02 3f 02 02 01
01 0c 0d 0e 44
00 0c 0f 0e 44
00 0c 10 11 12
00 0c 13 14 15
00 0c 10 11 12
00 0c 16 17 18
00 0c 19 1a 1b
02 0c 1c 1d 1e
00 1f 20 21 44
00 22 23 21 44
01 1f 20 21 24
00 22 23 21 25
00 1f 20 21 26
00 22 23 21 27
00 1f 20 21 28
00 22 23 21 29
00 1f 20 2a 2b
00 22 23 2c 2d
00 2e 20 2a 2f
00 2e 23 2c 30
00 2e 20 2a 31
02 2e 23 32 33
00 3c 42 43 44
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
