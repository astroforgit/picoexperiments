pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--forgotten hill pico
--by fm-studio
		
local oliver="bbbbbb0000000000000000bbbbbbbbbbb001112225522211100bbbbbbbbbb001112225522211100bbbbbbbbbb001112225722211100bbbbbbbbbb001112227762211100bbbbbbbbbb001112225722211100bbbbbbbbbb001112225722211100bbbbbbbbbb001112667766611100bbbbbbbbbb001112225722211100bbbbbbbbbb001112225722211100bbbbbbbbbb001112227762211100bbbbbbbbbb001112225722211100bbbbbbbbbb001112225522211100bbbbbb00000000000000000000000000b0001111222255555522221111000b00000000000000000000000000bbbbbb012222222222222210bbbbbbbbbb01f00000ff00000f10bbbbbbbbbb01f06664ff46660f10bbbbbbbbbb01f46064ff46064f10bbbbbbbbbb0ff41114ff41114ff0bbbbbbbbbb0fff4444ff4444fff0bbbbbbbbbbb0fff44f77f44fff0bbbbbbbbbbbb0ffffff22ffffff0bbbbbbbbbbbbb0ffffffffffff0bbbbbbbbbbbbbb0eff4ffff4ffe0bbbbbbbbbbbbbbb0ef4f22f4fe0bbbbbbbbbbbbbbbbb0ffffffff0bbbbbbbbbbbbbbb0000000000000000bbbbbbbbbbb0d012220dd022210d0bbbbbbbbb0d6012252002522106d0bbbbbbb0d660122522025221066d0bbbbbb0d660122522025221066d0bbbbb0d66d01225290252210d66d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252902522100d6d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252902522100d6d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252202522100d6d0bbbb0d6d0012252902522100d6d0bbbb0d6d0012252202522100d6d0bbbb000000122522025221000000bbbb0d6d0011122202211100d6d0bbbb0d6d0000000050000000d6d0bbbb000000125555555521000000bbbb0fee4012525555252104eef0bbbb0fff4012552222552104fff0bbbbb0ff0012552002552100ff0bbbbbbb00b01255200255210b00bbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb01255200255210bbbbbbbbbbbbbb000000bb000000bbbbbbbbbbb000044420bb024440000bbbbbbb0944444420bb0244444490bbbbbb0222222220bb0222222220bbbbbb0000000000bb0000000000bbb"
local title="77777777bb777777bb7777777bbbb7777777bbbb777777b7777777777777777777777777777777bb7777bbbb7777bb777777777777bbbb7777bbbb7eeeeee7b77eeee77b7eeeee77bb77eeeee77bb77eeee777eeeeeeee7eeeeeeee77eeeeee77ee7777ee7bbbb7ee7bb7ee77ee77ee7bbbb7ee7bbbb7888888777e8888e77788888e7777e88888e7777e8888e7788888888788888888778888887788ee77887bbbb7887bb788778877887bbbb7887bbbb788777777e887788e77887778e77e8877788e77e887788e77778877777778877777887777778888e7887bbbb7887bb788778877887bbbb7887bbbb7887777778877778877887b788778877b778877887777887bb7887bbbbb7887bbb7887bbbb788788e887bbbb7887bb788778877887bbbb7887bbbb788eeee77887bb78877887778877887bbb77777887bb7887bb7887bbbbb7887bbb788777777887788887bbbb788777788778877887bbbb7887bbbb788888877887bb7887788eee7777887b7777777887bb7887bb7887bbbbb7887bbb788eeee77887778887bbbb788eeee88778877887bbbb7887bbbb788777777887bb7887788888e777887b7eeee77887bb7887bb7887bbbbb7887bbb788888877887b77887bbbb788888888778877887bbbb7887bbbb7887bbbb7887bb78877887778e77887b7888877887bb7887bb7887bbbbb7887bbb788777777887bb7887bbbb788777788778877887bbbb7887bbbb7887bbbb78877778877887b7887788777778877887777887bb7887bbbbb7887bbb7887bbbb7887bb7887bbbb7887bb788778877887bbbb7887bbbb7887bbbb7d8e77e8d77887b7887788e777e887788e77e887bb7887bbbbb7887bbb788777777887bb7887bbbb7887bb7887788778877777788777777dd7bbbb77ddeedd777dd7b7dd777ddeeedd7777ddeedd77bb7dd7bbbbb7dd7bbb7ddeeee77dd7bb7dd7bbbb7dd7bb7dd77dd77ddeeee77ddeeee77dd7bbbbb77dddd77b7dd7b7dd7b77ddddd77bb77dddd77bbb7dd7bbbbb7dd7bbb7dddddd77dd7bb7dd7bbbb7dd7bb7dd77dd77dddddd77dddddd77777bbbbbb777777bb7777b7777bb7777777bbbb777777bbbb7777bbbbb7777bbb777777777777bb7777bbbb7777bb777777777777777777777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777777bb7777bb7777777bbbb777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7eeeee77b7ee7b77eeeee77bb77eeee77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb788888e77788777e88888e7777e8888e77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7887778e778877e8877788e77e887788e7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7887b7887788778877b778877887777887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb78877788778877887bbb77777887bb7887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb788eee88778877887bbbbbbb7887bb7887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb78888887778877887bbbbbbb7887bb7887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb78877777b78877887bbb77777887bb7887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7887bbbbb788778877b778877887777887bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7887bbbbb7887788e777e8877d8e77e8d7bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7dd7bbbbb7dd777ddeeedd7777ddeedd77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7dd7bbbbb7dd7b77ddddd77bb77dddd77bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb7777bbbbb7777bb7777777bbbb777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
local ritratto="111111dd111111111111dd99dd111111111d994499d1111111d94444449d11111d944442244d11111d44442222d111111d4442e272ed11111d444eee22eed5151d244eefeeed111151d242eee88d5151151d242eeed51515515d24444d515151555d322444d5555515d33332444d15155d333333244d55555d3333333244d555"
local pend="bbb1bbbbbbbbb1bbbbb101bbbbbbb101bbb10601b1b1b10601b1064401010104460110444006060044401b104004404400401b10242442224424201b100000000000001b1066666666666660110222444444422201102424400044242011024400656004420110240567776504201102406779776042011020677797776020110205777599750201102067777777602011025067777760520110240567776504201102450065600542011024255000552420110222445554422201b104444444444401b1022222222222220110000000000000001b111111111111111b"
local fiori="bbbbbbbbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbbbbb090bbbbbbbbbbbbbbbbbbbbbbb09900bbbbbbbbbbbbbbbbbbbb0988990bbbbbbb0bbbbbbbbbb0998890bbbbbbb090bbbbbbbbbb00990bbbbbbbb09900bbbbbbbbbb090bbbbbbb0988990bbbbb0bb0300bbbbbb0998890bbbbb090b030bbbbbbb000990bbbbbb0990030bbbbbbb033090bbbbb0988990bbbbbbbb03300bbbbb0998890bbbbbbbbb0330bbbbbbb00990bbbbbbbbbbb0330bb0bbbb0090b0bbbbbbb0bb0330090bb0330b090bbbbb090bb030099000330b09900bbb0990003098899030b0988990b098899009988903300998890b099889000009900330000990bbb00990333030900330333090bbbbb090033333033333330b0bbbbbbb0b0000000000000000bbbbbbbbb044444444444444440bbbbbbbb022222222222222220bbbbbbbbb0000000000000000bbbbbbbbbbb02222222222220bbbbbbbbbbbb02244444444220bbbbbbbbbbbbb022444444220bbbbbbbbbbbbbb022444444220bbbbbbbbbbbbbbb0222222220bbbbbbbbbbbbbbbbb00000000bbbbbbbb"
local finestra="bb0000000000000000000000000000bbb066666666666666666666666666660b02444444444444444444444444444420024444444444444444444444444444200244422222222222222222222224442002442000000000000000000000024420024420666666660000000000000244200244206666666600000000000002442002442066666666000000000000024420024420666666600000000000000244200244206666666000000000000002442002442066666600000000000000024420024420666660000000000000000244200244206660000000000030000002442002442000000000000000300000024420024420000555555500003000000244200244200555555555500333000002442002442055555555555003330000024420024420555555555555033300000244200244205555555555553333305502442002442055555555555533333555024420024420555555555555333335550244200244205555555555553333335502442002442055555555555533333355024420024420555555555553333333550244200244203555555555333333333502442002442033555555533333333333024420024420333555555555333335550244200244203555555555553333355502442002442035555555555333333355024420024420335555555333333333350244200244203335555533333333333302442002442033335533333333333355024420024420355555555533333333350244200244203355555555333333333302442002442033555555533333333333024420024420333355555553333333350244200244203333555555333333333302442002442033555553333333333333024420024420333333333333333333330244200044000000000000000000000000440004004444444444444444444444440040044444444444444444444444444444400222222222222222222222222222222002222222222222222222222222222220b000000000000000000000000000000b"
local gatto="bbbbbbbbbbbbb0bbbbb0bbbbbbbbbbbbbb0a0bbb0a0bbbbbbbbbbbbb09a0000a0bbbbbbbbbbbbb099aaaaaa0bb000000000b0999999990b0aaaaaaaaa009990090000a99a9a9a9aa09999999900909a9a9a9a909a9ff8ff00a09a9a9a9a94099ff4ff0090999099999940444440b0a099900940999400000bb044044440404404040bbbbb0000000000000000bbbbb"
local libro="bbbb000000000bbbb0eeeeeeeee0bb0ee0e0eeee50b0ee0e0eeee5600eeeeeeeee5650089988888865e008998888885e0b0899888888e0bbb0000000000bbb"
local logo="bbbbbbbbb88888888888888888888888888888888888888888888888888888888888888bbbbbbbbbbbbbbbb880000000000000000000000000000000000000000000000000000000000000088bbbbbbbbbbbb8800000000000000000000000000000000000000000000000000000000000000000088bbbbbbbbb800000000000000000000000000000000000000000000000000000000000000000000008bbbbbbb80000000000000000000000000000000000000000000000000000000000000000000000008bbbbb8000000000000000000000000000000000000000000000000000000000000000000000000008bbbb8000000000000000000000000000000000000000000000000000000000000000000000000008bbb800000000000000000000000000000000000000000000000000000000000000000000000000008bb800000000000000000000000000000000000000000000000000000000000000000000000000008b80000000000000000000000000000000000000000000000000000000000000000000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000880888888888888888888888888888888888888888888888888888888888888888888888888888808808888888888888888000000000000000000008888888888888888888888888888888888888888088088888888888888880000000000000000000088888888888888888888888888888888888888880880888888888888888800000000000000000000888888888888888888888888888888888888888808808888888888888888000000000000000000008888888888888888888888888888888888888888088088888888888888880000000000000000000088888888888888888888888888888888888888880880888888888888888800000000000000000000888888888888888888882288888888888888888808808888888888888888000000000000000000008888888888888888822222888888888888888888088088888888888888880000000000000000000088888888888888822222288888888888888888880880888888888888888800000000000000000000888888888888822222228888888888888888888808808888888888888888000000000000000000008888888888222222222288888888888888888888088088888888888888880000000000000000000088888888222222222228888888888888888888880880888888888888888800000000000000000000888888222222222222288888888888888888888808808888888888888888000000000000000000008882222222222222228888888888888888888888088088888888888888880000000000000000000082222222222222222888888888888888888888880880888888888888888800000000000000000000822222222222222228888888888888888888888808808888888888888888000000000000000000008222222222222222888888888888888888888888088088888888888888880000000000000000000082222222222888888888888888888888888888880880888888888888888800000000000000000000822222222280000000000008888888888888888808808888888888888888000000000000000000008222222288000000000000008888888888888888088088888888888888880000000000000000000082222228000000000000000000888888888888880880888888888888888888888888888888888888822222800000000000000000000888888888888808808888888888888888882222222222222222222222280000000000000000000000888888888888088088888888888888822222222222222222222222222800000000000000000000008888888888880880888888888888822222222222222222222222222280000000000000000000000008888888888808808888888888882222222222222222222222222228000000000000000000000000008888888888088088888888888222222222222222222222222222280000000000000000000000000088888888880880888888888888222222222222222222222222222800000000000000000000000000888888888808808888888888888222222222222222222222222228000000000000000000000000008888888888088088888888888888222222222222222222222222280000000000000000000000000088888888880880888888888888888222222222222222222222222800000000000000000000000000888888888808808888888888888882222222222222222222222228000000000000000000000000008888888888088088888888888888882222222222222222222222280000000000000000000000000088888888880880888888888888888882222222222222222222222800000000000000000000000000888888888808808888888888888888882222222222222222222228000000000000000000000000008888888888088088888888888888888822222222222222222222280000000000000000000000000088888888880880888888888888888888822222222222222222222800000000000000000000000000888888888808808888888888888888888822222222222222222228800000000000000000000000088888888888088088888888888888888888822222222222222222288800000000000000000000008888888888880880888888888888888888888222222222222222228888000000000000000000000088888888888808808888888888888888888888222222222222222288888000000000000000000008888888888888088088888888888888888888888222222222222228888888000000000000000000888888888888880880888888888888888888888888222222222222288888888800000000000000888888888888888808808888888888888888888888882222222222228888888888800000000000088888888888888888088088888888888888888888888882222222222888888888888888888888888888888888888888880880888888888888888888888888882222222228888888888888888888888888888888888888888808808888888888888888888888888822222222888888888888888888888888888888888888888888088088888888888888888888888888822222228888888888888888888888888888888888888888880880888888888888888888888888888822222888888888888888888888888888888888888888888808808888888888888888888888888888822288888888888888888888888888888888888888888888088088888888888888888888888888888222888888888888888888888888888888888888888888880880888888888888888888888888888888288888888888888888888888888888888888888888888808808888888888888888888888888888888888888888888888888888888888888888888888888888088088000000088008880088888880000888800000088008880088000008888000000888000008880880880088888880008000888888008800888880088880088800880088008888800888800888008808808800888888800000008888880088888888800888800888008800888008888008888008880088088088000008888000000088888880000088888008888008880088008880088880088880088800880880880088888880080800888888888880088880088880088800880088800888800888800888008808808800888888800888008888880088800888800888800888008800880088888008888008880088088088008888888008880088888880000088888008888800000888000008888000000888000008880880888888888888888888888888888888888888888888888888888888888888888888888888888808800000000000000000000000000000000000000000000000000000000000000000000000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000008b800000000000000000000000000000000000000000000000000000000000000000000000000008bb800000000000000000000000000000000000000000000000000000000000000000000000000008bbb8000000000000000000000000000000000000000000000000000000000000000000000000008bbbb8000000000000000000000000000000000000000000000000000000000000000000000000008bbbbb80000000000000000000000000000000000000000000000000000000000000000000000008bbbbbbb800000000000000000000000000000000000000000000000000000000000000000000008bbbbbbbbb8800000000000000000000000000000000000000000000000000000000000000000088bbbbbbbbbbbb880000000000000000000000000000000000000000000000000000000000000088bbbbbbbbbbbbbbbb88888888888888888888888888888888888888888888888888888888888888bbbbbbbbb"
img=title

function _init()
mobile=false
menu=true
camera(128,128)
tbx_init()
--music(0,2)
poke(0x5f2d, 1)
stanzax=128
stanzay=128
stanza=1
nextst=stanza
selez=0
pointerx=0
pointery=0
create_obj()
clicked=true
sfx(18)
click_reset=0
click_time=80 --tempo di reset click
obj={"","ruby","golden key","ring","","knife","key","","","","flower","key","","","","cup","steak","empty jar","jar of flies","","","cup of blood","shovel","","","","","","","","","spider","skull","saw","mandrake","","","","","","","ornament","","","","","","skull","skull","skull","skull"}
skulls={26,48,49,50,0,}
fadeout=false
fadein=false
fadec=0
goldkey=true 
floorcolor=4
m1down=true
m1y=16
m2down=true
m2y=16
m3down=true
m3y=16
m4down=true
m4y=16
masks=false
text1="the creature of my last experiment escaped. find it and put it back to its cage before it does any damage"
text2="sigh, sob, creator didn't make my legs, i never been anywhere ...please show me something beautiful..."
text3="oh, thank you very much! this is much nicer than the rhyme the creator always sings."
text4="it only says 5,3,1,4 these are the number i need to store..."
text5="oh pretty, beautiful flower, you'll stay with me forever..."
fetot=text2
textfin="good job! you are an excellent servant, i will miss your services when you move to the ostergard family next month."
ang=0
ang1=0.125
ang2=-0.125
calice=true
sport_c=true
bistecca=true
knife=true
blood=false
blood_count=0
blood_time=21
bx=604
fiore=176
set={}for i=0,12 do add(set,0)end
libri=0
rubino=false
arloi=true
ingkey=true
vasetto=true
mosca=189
moscac=0
ragno=true
moscapos=0
quadretto=false
chiavetta=true
ciccia=false
anello=0
por=0

rd=0
dog=0
badile=true
skullsabi=true
sega=true
teschio=false
mandra=true
pad=true
coin=true
sport4=false
sportabi=true
lo_abi=true
secret=0
abba=false
bau=false
gabbia=false
pico=0
intro=false
fin=false
olix=0
endtime=0
pe=-0.125
anda=true
shac=2
docu1=false
splash=true
end

function _update()
if(menu and not fin)then
if(endtime<30)then endtime+=1 else endtime=0 end
end
if(endtime==400)then 
stanzax=128 stanzay=128
menu=true img=title
fade_out()
end
if(not lo_abi and secret>-16)secret-=1

 if(mosca==189)then moscac+=1
 if(moscac>5)then if(rd<40 and moscapos==2)then rd+=3 end mosca=190 moscac=0 end 
 else moscac+=1
 if(moscac>5)then if(rd<40 and moscapos==2)then rd+=3 end mosca=189 moscac=0 end
 
end 

	if(fadeout) then 
	  if (fadec<=1) then
	   	fadec+=0.1
  				fade_scr(fadec)
  				else
  				fadeout=false
  	  	stanza=nextst
  	  	shac=2
  				floorcolor=4
  				if(stanza==1 and intro) mset(15,6,80)
  				if(stanza==9) img=oliver
  				if(stanza==11)shac=1
  				if(stanza==11 or stanza==10) floorcolor=1 
  			 if(stanza==13 or stanza==12) floorcolor=5   
  			 if(stanza==7 or stanza==8)floorcolor=3
  			 if(stanza==15 or stanza==16)floorcolor=5 
  			 if(stanza==13)blood=true
  			--	pointerx=stanzax+64
  			--	pointery=stanzay+52
      camera(stanzax,stanzay)
  			 fade_in()
	 	 	 end
    end
    
	if(fadein) then
	  if(fadec>0) then
				fadec-=0.1
					fade_scr(fadec)
					else
					fadein=false
					fadec=0
					
					end
   end
   
tbx_update()
move_pointer()
reset_click()
null_click()
click_circle()
end

function _draw()
cls()
if(stanza==7 or stanza==8)draw_stars(35)
map(0,0)
draw_floor()
if(stanza==11)spr(152,320,208)  
  if(stanza==16)outline_sprite(137,0,1000,214,1,1)
  if(stanza==15)then 
  outline_sprite(138,0,840,214,1,1)
  outline_sprite(137,0,776,210,1,1)
  outline_sprite(138,0,860,205,1,1,true,false)
  end
  if(stanza==9)then 
  draw_img(finestra,16,144,32) 
  if(lo_abi)draw_img(img,18,148,28) 
  outline_sprite(13,0,70,189,3,3) 
  draw_img(gatto,72,180,22)
  end

 if(stanza==3)then
 fillp(0b1101110111011101) 
 rectfill(319,22,360,49,37)
 fillp() 
 draw_img(fiori,328,53,26)
 a=0
 repeat 
 line(321,25+a,358,25+a,0)
 a+=5 until(a==25) 
 print("ç",323,27,9)
 print("ç",331,42,9)
 print("ç",340,37,9)
 print("ç",349,32,9)
 end
 
draw_door()
draw_obj()
draw_inventory()
if(docu)then
rectfill(128,128,256,256,0)
rectfill(144,136,247,248,5)
rectfill(147,139,244,245,6)
print_cent("pico experiment notes.",197,157,0)
print_cent("the creature is not",197,175,0)
print_cent("very cooperative,but it ",197,183,0)
print_cent("is extremely attracted",197,191,0)
print_cent("by mandrake seedlings",197,199,0)
spr(150,240,136)
end
if(docu1)then
rectfill(128,128,256,256,0)
rectfill(144,136,247,248,14)
rectfill(144,136,150,248,8)
rectfill(151,150,247,170,9)
print_cent("the fly",196,153,0)
print_cent("and the spider",196,163,0)
print_cent("by jonah thompson",196,240,0)
spr(150,240,136)
end

if(menu)then 
if(not splash)then 
rectfill(128,128,256,256,0)
draw_stars(25)
circfill(220,146,18,5)
circfill(218,144,16,6)
outline_sprite(128,0,225,151,3,3,true,false)
draw_img(img,133,138,118)
rectfill(128,175,256,256,0)
line(128,175,256,175,8)
for i=0,6 do
spr(152,128+(i*24),175,3,1)
end

--if(not splash)then
if(endtime<15)then 
print_cent("ó or click to start",192,208,7)
elseif(endtime>31)then
print_cent("thank you for playing",192,187,9)
print_cent("developed with pico-8",192,197,8)
print_cent("by fm-studio",192,205,8)
print_cent("special thanks",192,213,9)
print_cent("music : evil  by @gruber_music",192,221,8)
print_cent("pic2pico by nodepond",192,229,8)
print_cent("simple textbox by level27geek",192,237,8)
end 
print_cent("- www.forgotten-hill.com -",192,250,8)
else
rectfill(128,128,256,256,0)
draw_img(logo,152,152,80)
end
end
if(not mobile)outline_sprite(1,0,pointerx+stanzax,pointery+stanzay,1,1,false,false) 
click_circle()
if (#tbx_lines>0) tbx_draw()
pal(1,1+128,1)
pal(2,2+128,1)
pal(3,3+128,1)
pal(4,4+128,1)
pal(5,5+128,1)
pal(6,6+128,1)
pal(11,11+128,1)
pal(12,12+128,1)
pal(13,13+128,1)
pal(14,14+128,1)
pal(15,15+128,1)
draw_blood()
end

function draw_blood()
if(blood)then
blood_count+=3
if(blood_count<54)then
pset(bx,156+blood_count,8)
pset(bx,157+blood_count,8)
else
if(blood_count>blood_time)then
if(stanza==13)then sfx(13)
blood_count=0 
blood_time=rndb(54,200)
if(rndb(0,100)<50)then bx=604 else bx=620 end
draw_blood()
else 
blood_count=0
blood=false
end end
end end
end

function draw_floor()
if(stanza!=14)then
if(stanza==7 or stanza==8)then
  fillp(0b1111001111111100)
  rectfill(stanzax,stanzay+80,stanzax+128,stanzay+96,53)  
  fillp(0) 
  else
  rectfill(stanzax,stanzay+80,stanzax+128,stanzay+96,floorcolor)
  end
if(stanza!=7 and stanza!=8)then 
if(stanza!=10)then
rectfill(stanzax-1,stanzay+80,stanzax+128,stanzay+83,shac)
rect(stanzax-1,stanzay+86,stanzax+128,stanzay+91,shac)
rect(stanzax+66,stanzay+86,stanzax+68,stanzay+90,shac)
line(stanzax+39,stanzay+90,stanzax+37,stanzay+96,shac)
line(stanzax+41,stanzay+90,stanzax+39,stanzay+96,shac)
line(stanzax+8,stanzay+86,stanzax+5,stanzay+90,shac)
line(stanzax+10,stanzay+86,stanzax+7,stanzay+90,shac)
line(stanzax+94,stanzay+91,stanzax+96,stanzay+96,shac)
line(stanzax+96,stanzay+91,stanzax+98,stanzay+96,shac)
line(stanzax+118,stanzay+86,stanzax+120,stanzay+90,shac)
line(stanzax+120,stanzay+86,stanzax+122,stanzay+90,shac)
end
rect(stanzax-1,stanzay+80,stanzax+128,stanzay+82,0)
rect(stanzax-1,stanzay+85,stanzax+128,stanzay+90,0)
line(stanzax+67,stanzay+86,stanzax+67,stanzay+90,0)
line(stanzax+40,stanzay+90,stanzax+38,stanzay+96,0)
line(stanzax+9,stanzay+86,stanzax+6,stanzay+90,0)
line(stanzax+95,stanzay+91,stanzax+97,stanzay+96,0)
line(stanzax+119,stanzay+86,stanzax+121,stanzay+90,0)
end end
end

function set_sprite(xx,yy,v)
mset(flr(xx/8),flr(yy/8),v)
end

function get_spritexy(xx,yy)
return mget(flr(xx/8),flr(yy/8))
end

function get_flag()
return fget(mget(flr((pointerx+stanzax)/8),flr((pointery+stanzay)/8)))
end

function get_sprite()
return mget(flr((pointerx+stanzax)/8),flr((pointery+stanzay)/8))
end



function checkmask()
if(not masks)then if(m1y==24 and m2y==48 and m3y==40 and m4y==32)then sfx(9) masks=true end end
end

function click_circle()
if(not menu)circ(pointerx+stanzax,pointery+stanzay,click_reset-3,7)
end

function reset_click()
if(clicked)
then  click_reset+=1 
if(click_reset>click_time)
then
click_time=8
click_reset=0
clicked=false
abba=false
bau=false
if(menu and not fin and not splash)then
img=oliver  stanzax=0 stanzay=0 menu=false camera(0,0)  end
if(pico==2)pico=3
if(sport4)sportabi=false
set={}for i=0,12 do add(set,0)end
if(splash)then
splash=false
music(0,2)
end
end 
end 
end

function create_obj()
-- 0 aperta - 1 chiusa - 2 locked
doors={door5x=728,door5y=16,door5=2,door4x=656,door4y=16,door4=1,door3x=560,door3y=16,door3=2,door2x=272,door2y=16,door2=1,door1x=80,door1y=16,door1=1}
inventory={}
end

bordox=0
bordoy=0

function draw_inventory()
a=0
for item in all(inventory) do
   if(item==131)then outline_sprite(item,0,12+stanzax+(a-4),108+stanzay-4,2,2)
			else	outline_sprite(item,0,12+stanzax+a,108+stanzay,1,1)
			end
			a+=24	
			end
			if(selez!=0 and selez!=nil) then 
			if(selez==131)then
			print("mandrake",stanzax+2,stanzay+1,7) 	
			else
			print(obj[selez],stanzax+2,stanzay+1,7) 	
			end
			spr(141,stanzax+bordox,stanzay+bordoy,2,2)
			if(not mobile)then
			if(selez==131)then
			outline_sprite(selez,0,pointerx+stanzax+2,pointery+stanzay+2,2,2)
   else
   outline_sprite(selez,0,pointerx+stanzax+2,pointery+stanzay+2,1,1)
   end end
   end 
end


function draw_door()
  if ( doors.door5==0)
  then rectfill (doors.door5x+6,doors.door5y+5 ,doors.door5x+25,doors.door5y+64,0)
  end
  if ( doors.door1==0)
  then rectfill (doors.door1x+6,doors.door1y+5 ,doors.door1x+25,doors.door1y+64,0)
  end
  if ( doors.door2==0)
  then rectfill (doors.door2x+6,doors.door2y+5 ,doors.door2x+25,doors.door2y+64,0)
  end
  if ( doors.door3==0)
  then rectfill (doors.door3x+6,doors.door3y+5 ,doors.door3x+25,doors.door3y+64,0)
  end
  if ( doors.door4==0)
  then rectfill (doors.door4x+6,doors.door4y+5 ,doors.door4x+25,doors.door4y+64,0)
  end
end



function move_pointer()

mouse_btn = stat(34)
if(mouse_btn==1)pad=true
if(pad)then
pointerx=stat(32)
pointery=stat(33)
end

if(btn(é) and selez!=0)then selez=0 sfx(0) end
if(btn(ë))then pointerx+=3 pad=false  end
if(btn(ã))then pointerx-=3 pad=false  end
if(btn(î))then pointery-=3 pad=false  end
if(btn(É))then pointery+=3 pad=false  end


end

function fade_out()
fadec=0.5
fadeout=true
end

function fade_in()
fadec=0.5
fadein=true
end

function draw_img(data,imgx,imgy,leng)
x=0 
y=0
  for i=0,#data do
  x+=1
   local ch=sub(data,i+1,i+1)
    if(ch!="b") then
    pset(x+imgx,
        y+imgy,
              convert_hex2num(ch))
       end
       if(x>(leng-1))then x=0 y+=1 end
  end
end

local str2hex_table={}
str2hex_table["0"]=0
str2hex_table["1"]=1
str2hex_table["2"]=2
str2hex_table["3"]=3
str2hex_table["4"]=4
str2hex_table["5"]=5
str2hex_table["6"]=6
str2hex_table["7"]=7
str2hex_table["8"]=8
str2hex_table["9"]=9
str2hex_table["a"]=10
str2hex_table["b"]=11
str2hex_table["c"]=12
str2hex_table["d"]=13
str2hex_table["e"]=14
str2hex_table["f"]=15

function        convert_hex2num(value)
        return str2hex_table[value]
end


function draw_2chr(c1,c2,x,y,otc,c,l,s)
printout(c2,x,y+4,otc,c,l,s)
printout(c1,x,y,otc,c,l,s)
end
-->8

function tbx_init()
tbx_counter=1
tbx_width=22 --characters not pixels
tbx_lines={}
tbx_cur_line=1
tbx_com_line=0
tbx_text=nil
tbx_x=nil
tbx_y=nil
end


function tbx_update()
 if tbx_text!=nil then 
 local first=nil
 local last=nil
 local rows=flr(#tbx_text/tbx_width)+2
 
 --split text into lines
 for i=1,rows do
  first =first or 1+i*tbx_width-tbx_width
  last = last or i*tbx_width
   
  --cut off incomplete words
  if sub(tbx_text,last+1,last+1)!="" or sub(tbx_text,last,last)!=" " and sub(tbx_text,last+1,last+1)!=" " then
   for j=1,tbx_width/3 do
    if sub(tbx_text,last-j,last-j)==" " and i<rows then
     last=last-j
     break
    end
   end
  end
  
  --create line
  --if first char is a space, remove the space
  if sub(tbx_text,first,first)==" " then
   tbx_lines[i]=sub(tbx_text,first+1,last)
  else
   tbx_lines[i]=sub(tbx_text,first,last)
  end
   first=last
   last=last+tbx_width
 end
 
 --lines are now made
 
 
 --change lines after printing
 if tbx_counter%tbx_width==0 and tbx_cur_line<#tbx_lines then
  tbx_com_line+=1
  tbx_cur_line+=1
  tbx_counter=1
 end
 --update text counter
 tbx_counter+=1
 if (sub(tbx_text,tbx_counter,tbx_counter)=="") tbx_counter+=1
 
 end
end


function tbx_draw()
 if #tbx_lines>0 then 
if(mosca==189)then 
spr(105,298,200)
spr(121,26,171,2,1)
end
  --print current line one char at a time
  for cx=-1,1 do
    for cy=-1,1 do
  print(sub(tbx_lines[tbx_cur_line],1,tbx_counter),tbx_x+cx-(#sub(tbx_lines[tbx_cur_line],1,tbx_counter) * 2),tbx_y+(tbx_cur_line*6-6)+cy,0)
    end end
  print(sub(tbx_lines[tbx_cur_line],1,tbx_counter),tbx_x-(#sub(tbx_lines[tbx_cur_line],1,tbx_counter) * 2),tbx_y+(tbx_cur_line*6-6),tbx_col)

 
  --print complete lines
  for i=0,tbx_com_line do
   if i>0 then
     for cx=-1,1 do
    for cy=-1,1 do
    print(tbx_lines[i],tbx_x+cx-(#tbx_lines[i] * 2),tbx_y+(i*6-6)+cy,0)
    end end
    print(tbx_lines[i],tbx_x-(#tbx_lines[i] * 2),tbx_y+i*6-6,tbx_col)
   end
  end
 end 
end


function textbox(text,x,y,col)
 tbx_init()
 tbx_x=x or 4
 tbx_y=y or 4
 tbx_col=col or 7
 tbx_text=text
end


function print_cent(str,xx,yy,col)
  print(str, xx - (#str * 2), yy,col) 
end
-->8

function rndb(low,high)
return flr(rnd(high-low+1)+low)
end

function draw_stars(n)
srand(1)
for i=1,n do
pset(stanzax+rndb(0,127),stanzay+rndb(0,80),rndb(5,7))
end
srand(time())
end

function draw_grass(n)
srand(2)
for i=1,n do
outline_sprite(rndb(176,177),0,stanzax+rndb(0,127),stanzay+rndb(82,88),1,1)
end
srand(time())
end

function check_lo()
if(get_spritexy(824,144)==220 and get_spritexy(824,168)==220 and get_spritexy(824,192)==220 and get_spritexy(848,144)==207 and get_spritexy(848,168)==220 and get_spritexy(848,192)==207 and get_spritexy(872,144)==220 and get_spritexy(872,168)==220 and get_spritexy(872,192)==220)then 
lo_abi=false sfx(2)
end
end
-->8


function draw_obj()
if(stanza==11)then
outline_sprite(192,0,290,192,2,3) 
if(fetot==text3 or fetot==text4 )outline_sprite(11,0,306,203,1,1) 
end
if(stanza==4)then 
circfill(420,31,19,0)
circfill(420,29,19,0) 
circfill(420,29,18,6)
circfill(420,31,18,2)
circfill(420,30,18,4)  
circfill(420,30,16,0) 
circfill(420,30,15,6) 
print("ì",417,16,2)
print("Ö",417,40,2)
print("Ü",429,28,2)
print("á",405,28,2)
print("í",409,20,9)
print("à",409,36,9)
print("è",426,37,9)
print("ä",426,20,9)
line(420,30,420+flr(8*cos(ang)),30+flr(8*sin(ang)),8)
line(420,30,420+flr(8*cos(ang1)),30+flr(8*sin(ang1)),3)
line(420,30,420+flr(8*cos(ang2)),30+flr(8*sin(ang2)),12)
circfill(420,30,1,9)
rectfill(456,80,487,88,0)
rect(456,56,487,88,0)
spr(92,456,80)
spr(94,480,80)
if(sportabi)then
rectfill(463,72,480,87,4)
outline_sprite(42,0,464,72,1,1)
outline_sprite(42,0,468,79,1,1)
   if(not sport4)then 
   circfill(476,76,3,0) 
   else 
   outline_sprite(42,0,472,72,1,1)  end
else
if(mandra)outline_sprite(131,0,464,72,2,2)
end
outline_sprite(27,0,469,37,1,3) 


if(arloi)then spr(99,464,24,2,2) 
         else if(ingkey)then spr(7,468,28) end
end
end
if(goldkey) then if(masks)then if(stanza==2) then outline_sprite(3,0,156,28,1,1) end end end
if(stanza==2) then 
outline_sprite(13,0,149,61,3,3) 
draw_img(libro,154,58,14)
if(not masks)then 
draw_img(ritratto,151,24,16)
end
draw_2chr("Ç","É",184,m1y,0,4,6,2)
draw_2chr("Ç","á",200,m2y,0,4,6,2)
draw_2chr("Ç","å",216,m3y,0,4,6,2)
draw_2chr("Ç","ww",232,m4y,0,4,6,2)
end
 if(stanza==6)then
 outline_sprite(13,0,696,60,3,3)
 outline_sprite(56,0,700,57,2,1)
 outline_sprite(fiore,0,704,51,1,1)
 if(quadretto)then 
   outline_sprite(32,0,704,24,1,1) 
   if(chiavetta)then outline_sprite(12,0,704,46,1,1) end
   outline_sprite(37,0,704,51,1,1,false,true)
   end
 end
if(stanza==13)then
outline_sprite(163,0,536,144,2,2,false,false)
circfill(544,153,4,6)
print("á",541,150,12)
fillp(0b1000010000100000)
rectfill(528,185,576,216,21)
fillp(0) 
rect(528,176,576,216,0)
if(not teschio)then outline_sprite(136,0,536,172,3,2) else outline_sprite(137,0,544,172,2,2) end
outline_sprite(44,0,568,164,1,2,false,false)
printout("ò ò ò",537,192,0,5,6,1)
printout("ò ò ò",537,203,0,5,6,1)
outline_sprite(61,0,600,206,3,1)
a=0
repeat
outline_sprite(5,0,600+a,136,1,3)
a+=16
until a==32
if(moscapos==0)spr(mosca,544,160)

end
if(stanza==14)then
rect(728,144,759,167,0)
rect(640,176,703,216,0)
rect(728,175,759,191,0)
outline_sprite(5,0,728,136,1,1)
outline_sprite(5,0,752,136,1,1)
outline_sprite(40,0,664,172,2,1)
if(knife)outline_sprite(20,0,728,178,1,2)
rectfill(715,140,717,160,0)
rectfill(716,141,716,160,6)
circfill(716,160,8,0)
circfill(716,160,7,6)
circfill(716,160,5,5)
if(calice)outline_sprite(16,0,736,149,1,1)
if(sport_c)then
spr(125,648,200,1,1)
spr(123,656,200,1,1)
spr(123,648,208,1,1)
spr(123,656,208,1,1)
else
if(bistecca)then outline_sprite(17,0,652,204,1,1)end
end
end
if(stanza==8)then
rectfill(961,33,1006,79,0)
fillp(0b1011101110110000)
rectfill(961,33,982-por,79,6)
rectfill(984+por,33,1005,79,6)
fillp()
if(anello==3)then
if(por<20)then por+=1 end

end
outline_sprite(194,0,972,16,3,3)
k=0
while(k<112) do 
outline_sprite(60,0,952+k,16,1,1)
outline_sprite(mosca-138,8,952+k,7,1,1)
k+=56
end
outline_sprite(40,0,936,75,2,1)
if(badile)outline_sprite(202,0,1014,59,1,3)
if(anello==3)outline_sprite(4,0,940,44,1,1)
         if(skullsabi)then
           if(ciccia)outline_sprite(17,0,940,74,1,1) 
--[[cane]] outline_sprite(199,0,976-dog,67,3,2)
--[[cane]] if(bau)then 
           if(mosca==189)outline_sprite(232,0,976-dog,67,1,2) 
           end
if(ciccia)then if(dog<29)then dog+=2 end  end
end
draw_grass(10)
end
if(stanza==7)then 
for z=0,1 do
for zz=0,1 do
spr(251,800+(z*8),80+(zz*8),1,1)
end end 
draw_grass(10)
circfill(stanzax+26,18,18,5)
circfill(stanzax+24,16,16,6)
   if(vasetto) then  outline_sprite(18,0,824,75,1,1) end 
   if(ragno)then line(852,14,852,8+rd) outline_sprite(32,0,848,8+rd,1,1) end 
   if(moscapos==2)then spr(mosca,848,48) end              
   if(rd>39)then moscapos=3 end
if(anello==1)outline_sprite(4,0,804,84,1,1)
end
             
if(stanza==1 and not menu and not splash)then
if(anda)then 
if(pe>-0.375)then 
pe-=0.005 else anda=false sfx(17)  end 
else
if(pe<-0.125)then pe+=0.005 
else
anda=true sfx(17)
end
end
for i=-1,1 do
if(i==0)then col=9 else col=0 end
line(67+i,39,67+flr(10*cos(pe))+i,39+flr(10*sin(pe)),col)
end
circfill(67+flr(10*cos(pe)),39+flr(10*sin(pe)),3,0)
circfill(67+flr(10*cos(pe)),39+flr(10*sin(pe)),2,9)
circfill(66+flr(10*cos(pe)),38+flr(10*sin(pe)),1,10)
draw_img(pend,58,16,17)

if(libri==100)outline_sprite(2,0,32,24,1,1)
outline_sprite(178,0,24,24+set[1],1,1)
outline_sprite(181,0,41,24+set[3],1,1)
outline_sprite(182,0,24,40+set[4],1,1)
outline_sprite(187,0,32,40+set[5],1,1)
outline_sprite(178,0,41,40+set[6],1,1)
outline_sprite(182,0,24,56+set[7],1,1)
outline_sprite(187,0,32,56+set[8],1,1)
outline_sprite(171,0,41,56+set[9],1,1)
outline_sprite(187,0,24,72+set[10],1,1)
outline_sprite(181,0,32,72+set[11],1,1)
outline_sprite(178,0,41,72+set[12],1,1)
end


if(stanza==15 and secret>-16)then
         fillp(0b1111001111111100)
rectfill(784,160,800+secret,207,81)
fillp()  end
if(stanza==5)then
rectfill(531,27,540,36,6)
rectfill(611,27,620,36,6)
outline_sprite(143,0,536,58,1,3)
if(rubino)then 
outline_sprite(2,0,536,49,1,1)
print("ì",533,30,14)
print("í",613,30,3)
end
outline_sprite(143,0,608,58,1,3)
outline_sprite(127,0,608,49,1,1)
end

if(stanza==16)then
if(skullsabi)then
spr(155,952,152,2,1,false,true)
spr(155,952,160,2,1)
else 
if(coin)spr(42,956,156,1,1)
end
for i=0,4 do
j=0
repeat
outline_sprite(202,0,920+(i*16),192+j,1,1)
j+=8
until j==24 
end
for s=1,#skulls do 
outline_sprite(skulls[s],0,904+(s*16),184,1,1)
end
end
outline_sprite(5,0,992,136,1,1)    
if(sega)outline_sprite(206,0,992,144,1,2)

if(pico==1 and selez!=131)pico=0
if(stanza==10)then 
if(selez==131)then pico=1 else pico=0 end
outline_sprite(128,0,216,192,3,3,true,false) 
if(abba and clicked)outline_sprite(38,0,215,193,2,2,true,false)
else
end

if(stanza==12)then
if(fin)then
draw_img(oliver,356+olix,148,28)
if(olix<40) then olix+=2 else if(olix==40)then olix=41 textbox(textfin,464,144,7) end   end 
if(olix==41)endtime+=1
end
rect(440,160,495,216,0)
rectfill(440,208,494,215,0) 
spr(219,440,208)
spr(221,488,208)
for i=0,4 do
spr(172,448+(i*8),208)
end
outline_sprite(163,0,460,140,2,2)
end
if(pico>1)then 
if(pico==3)outline_sprite(128,0,464,190,3,3,true,false) 
outline_sprite(131,0,452,188,2,2) 
end
if(gabbia)then 
for i=0,4 do
for a=0,4 do
spr(106,448+(i*8),176+(a*8))
end
end
end


if(pico==1 or pico==2)then
if(stanza!=10)then
if(stanza==15 or stanza==16)then
outline_sprite(128,0,stanzax+16,stanzay+69,3,3) 
else
outline_sprite(128,0,stanzax+96,stanzay+69,3,3,true,false) 
end
end
end


end 



-->8

function null_click()
if(not clicked ) then
if(btn(ó)or mouse_btn==1 and not fadein and not fadeout)then
clicked=true 
 --inevntario click
 if(not menu and not docu and not docu1) then
--[[ slot1 ]]    if(get_flag()==2) and pointerx+stanzax>stanzax+8 and pointerx+stanzax<stanzax+24 then if(selez==0)then sfx(0) selez=inventory[1] bordox=8 bordoy=104  else selez=0 end end    
--[[ slot2 ]]    if(get_flag()==2) and pointerx+stanzax>stanzax+32 and pointerx+stanzax<stanzax+48 then if(selez==0)then sfx(0) selez=inventory[2] bordox=32 bordoy=104 else selez=0 end end 
--[[ slot3 ]]    if(get_flag()==2) and pointerx+stanzax>stanzax+56 and pointerx+stanzax<stanzax+72 then if(selez==0)then sfx(0) selez=inventory[3]  bordox=56 bordoy=104 else selez=0 end end
--[[ slot4 ]]    if(get_flag()==2) and pointerx+stanzax>stanzax+80 and pointerx+stanzax<stanzax+96 then if(selez==0)then sfx(0) selez=inventory[4]  bordox=80 bordoy=104 else selez=0 end end           
--[[ slot5 ]]    if(get_flag()==2) and pointerx+stanzax>stanzax+104 and pointerx+stanzax<stanzax+120 then  if(selez==0)then sfx(0) selez=inventory[5] bordox=104 bordoy=104  else selez=0 end end  
 end
--[[ dx ]] if(get_sprite()==80 and pointerx<128 and pointerx>120 and fadec==0 and not fin) then sfx(1) stanzax+=128 nextst+=1 fade_out() end
--[[ sx ]] if(get_sprite()==88 and pointerx>0 and pointerx<8 and fadec==0) then sfx(1) stanzax-=128 nextst-=1 fade_out() end
--[[ back ]] if(get_sprite()==97 and fadec==0) then sfx(1) stanzay-=128 nextst-=8 fade_out() end
if(stanza==7)then
if(get_flag()==129 and vasetto)then vasetto=false sfx(0) add(inventory,18) end
if(get_flag()==128 and selez==19)then moscapos=2 sfx(15) selez=0 del(inventory,19)end
if(get_flag()==128 and moscapos==3 and ragno)then moscapos=4 ragno=false sfx(0) add(inventory,32)end
if(get_sprite()==128 and anello==1)then add(inventory,4)  sfx(0) anello=2 end
if(get_sprite()==128 and selez==23)then del(inventory,23) selez=0 sfx(1) anello=1 end
end
if(stanza==10)then
if(get_sprite()==31)then sfx(1) stanzax=768 nextst=15 fade_out() end
if(get_sprite()==133 or get_sprite()==134) then
sfx(16) abba=true 
--elseif(selez==35)then sfx(0) del(inventory,35) selez=0 pico=true

end
end
if(stanza==15)then
if(get_sprite()==29 and secret<-15 and not fadein and not fadeout )then sfx(1) stanzax=128 nextst=10 fade_out() end
 if lo_abi then
   if(get_sprite()==220 or get_sprite()==207) then 
     sfx(0)
     rx=pointerx+stanzax
     ry=pointery+stanzay
     for i=-1,1 do
     if(get_spritexy(rx+(i*24),ry)==207)then set_sprite(rx+(i*24),ry,220) 
     else if(get_spritexy(rx+(i*24),ry)==220)then set_sprite(rx+(i*24),ry,207) end
     end end
     for i=-1,1 do
     if(i!=0)then
     if(get_spritexy(rx,ry+(i*24))==207)then set_sprite(rx,ry+(i*24),220) 
     else if(get_spritexy(rx,ry+(i*24))==220)then set_sprite(rx,ry+(i*24),207) end
     end end end
     check_lo()
   end
 end
end
if(stanza==8)then
    if(get_sprite()==31 or get_sprite()==89)then if(anello!=3 and ciccia==false)then bau=true sfx(11) end end
    if(anello==3 and get_sprite()==31)then
   sfx(1) stanzay+=128 nextst+=8 fade_out()
   end
   if(selez==17)then
   if(get_sprite()==89 or get_sprite()==188)then
   del(inventory,17) sfx(0) selez=0 ciccia=true
   end
   end
   if(get_sprite()==89 and ciccia and pointerx>117 and badile)then sfx(0) badile=false add(inventory,23) end
   if(get_flag()==16 and selez==4)then sfx(19) del(inventory,4) anello=3 selez=0  end

end
if(stanza==4)then 
if(get_flag()==224 and selez==42)then sport4=true sfx(0) selez=0 del(inventory,42) end
if(get_flag()==224 and selez==0 and not sportabi and mandra)then mandra=false sfx(0) add(inventory,131) end

if(arloi) then
if(get_sprite()==83)then ang+=-0.125 sfx(0) if(ang==-1)then ang=0 end end
if(get_sprite()==84)then ang1+=-0.125 sfx(0) if(ang1==-1)then ang1=0 end end
if(get_sprite()==85)then ang2+=-0.125 sfx(0) if(ang2==-1)then ang2=0 end end
if(rubino==true and ang==-0.75 and ang1==-0.625 and ang2==-0.5)then arloi=false sfx(9) end end
if(ingkey and not arloi)then if(get_flag()==4) then ingkey=false sfx(0) add(inventory,7) end end
end
--[[ porte ]]  
if(stanza==3) then if(get_flag()==1)then if(doors.door2==1) then doors.door2=0 sfx(3) elseif (doors.door2==0) then sfx(1) stanzay+=128 nextst+=8 fade_out() end end end
if(stanza==1) then if(get_flag()==1)then if(doors.door1==1) then doors.door1=0 sfx(3) elseif (doors.door1==0) then sfx(1) stanzay+=128 nextst+=8 fade_out() end end 
  if(libri<10)then
  for i=172,174 do 
  if(get_sprite()==i) then 
  if(pointery>24 and pointery<32)then sfx(1) set[i-171]=-2 if(i==174 and libri==0)then libri+=1 else libri=0 end
  elseif(pointery>40 and pointery<48)then sfx(1) set[i-168]=-2 if(i==172 and libri==1)then libri+=1 else libri=0 end
  elseif(pointery>56 and pointery<64)then sfx(1) set[i-165]=-2 if(i==174 and libri==2)then libri+=1else libri=0 end
  else sfx(1) set[i-162]=-2 if(i==174 and libri==3)then libri+=1 else libri=0 end end
  if(libri==4 and fiore==0 )then libri=100 sfx(2) end
  end
  end end
  if(get_sprite()==173 and libri==100)then libri=101 sfx(0) add(inventory,2) end
  end
         if(stanza==6) 
         then 
         if(get_sprite()==111 and selez==32)then quadretto=true del(inventory,32) selez=0 sfx(1) end 
         if(get_sprite()==112)then 
         if(quadretto and chiavetta)then add(inventory,12) chiavetta=false sfx(0) end 
         if(selez==22) then selez=0 del(inventory,22) sfx(12) fiore=11  end 
         if(selez==6 and fiore==11)then del(inventory,6) add(inventory,11) sfx(0) selez=0 fiore=0 end
         end 
   if(get_flag()==1)then if(doors.door4==1) then doors.door4=0 sfx(3) elseif (doors.door4==0) then sfx(1) stanzay+=128 nextst+=8 fade_out() end end 
   --[[ porta key ]]   if(get_flag()==8)then if(doors.door5==1) then doors.door5=0 sfx(3) elseif (doors.door5==0) then sfx(1) stanzax+=128 nextst+=1 fade_out() elseif (doors.door5==2 and selez==7) then doors.door5=1 del(inventory,7) sfx(2) selez=0 else sfx(4) end end
   end
if(stanza==11) then o_parla=false
--[[ feto ]] if(get_sprite()==79)then sfx(0)
             if(libri>5)fetot=text5              
             if(selez==0 and fetot==text3)then fetot=text4 end
             if(selez==11)then fetot=text3 del(inventory,11) selez=0 sfx(0)  end
             sfx(14)  textbox(fetot,stanzax+60,stanzay+16,7) else textbox()end --o_parla=true
  end 

if(stanza==12)then
if(docu)then if(get_sprite()==134)then stanzax=384 camera(stanzax,stanzay) docu=false  end   end
if(get_sprite()==191 and not fin)then sfx(0) docu=true camera(128,128) stanzax=128  end
if(get_sprite()==83 and selez==0)then
sfx(3)
if(not fin)then
if(not gabbia)then 
gabbia=true
if(pico==3)fin=true
else
gabbia=false
end end
end
if(get_sprite()==135 and selez==131 and not gabbia and pico==1)then
pico=2 sfx(0) selez=0 del(inventory,131)
end
end  
  
if(stanza==13) then
 if(get_sprite()==10 and pointerx<40 and selez==34)then sfx(4) del(inventory,34) add(inventory,33) selez=0 teschio=true end
   if(get_sprite()==191 and selez==18)then moscapos=1 sfx(15) del(inventory,18) add(inventory,19) selez=0 end  
   if(get_flag()==4)then 
      if(selez==16) then sfx(12) del(inventory,16) add(inventory,22) selez=0 end 
                    end 
                end
if(stanza==14) then
   if(knife)then
   if(get_flag()==16)then
   sfx(0) knife=false
   add(inventory,6)
   end end
   if(calice)then 
     if(get_flag()==8)then
     sfx(0) calice=false
     add(inventory,16)
     end
    end
  if(get_flag()==4)then 
    if(sport_c) then 
    if selez==12 then sfx(1) sport_c=false del(inventory,12) selez=0 end
    else
      if(bistecca)then
      sfx(0) bistecca=false
      add(inventory,17)
      end
    end 
  end 
end

    if(stanza==16 and not fadein and not fadeout)then
    if(selez==0 and get_flag()==4 and not skullsabi and coin)then sfx(0) add(inventory,42) coin=false end
    if(sega and get_flag()==144 and selez==0)then sfx(0) add(inventory,34) sega=false end 
     if(skullsabi)then
      if(get_sprite()==252)then
        if(pointerx>40 and pointerx<48)then
        if(selez==0)then
          if(skulls[2]!=0)then
           sfx(0) add(inventory,skulls[2]) skulls[2]=0
          end 
        else
        if(skulls[2]==0)then sfx(0) skulls[2]=selez del(inventory,selez) selez=0
        end end
      end 
      end
      
       if(get_sprite()==252)then
        if(pointerx<32)then
        if(selez==0)then
          if(skulls[1]!=0)then
           sfx(0) add(inventory,skulls[1]) skulls[1]=0
          end 
        else
        if(skulls[1]==0)then sfx(0) skulls[1]=selez del(inventory,selez) selez=0
        end end
      end 
      end
      
       if(get_sprite()==252)then
        if(pointerx>56 and pointerx<64)then
        if(selez==0)then
          if(skulls[3]!=0)then
           sfx(0) add(inventory,skulls[3]) skulls[3]=0
          end 
        else
        if(skulls[3]==0)then sfx(0) skulls[3]=selez del(inventory,selez) selez=0
        end end
      end 
      end
      
      if(get_sprite()==252)then
        if(pointerx>72 and pointerx<80)then
        if(selez==0)then
          if(skulls[4]!=0)then
           sfx(0) add(inventory,skulls[4]) skulls[4]=0
          end 
        else
        if(skulls[4]==0)then sfx(0) skulls[4]=selez del(inventory,selez) selez=0
        end end
      end 
      end
    
    if(get_sprite()==252)then
        if(pointerx>88 and pointerx<96)then
        if(selez==0)then
          if(skulls[5]!=0)then
           sfx(0) add(inventory,skulls[5]) skulls[5]=0
          end 
        else
        if(skulls[5]==0)then sfx(0) skulls[5]=selez del(inventory,selez) selez=0
        end end
      end 
      end
  if(skulls[1]==49 and skulls[2]==33 and skulls[3]==50 and skulls[4]==48 and skulls[5]==26)then
   skullsabi=false sfx(9)
  end
   end
    end

  if(stanza==5) then
--[[ porta key ]]   if(get_flag()==1)then if(doors.door3==1) then doors.door3=0 sfx(3) elseif (doors.door3==0) then sfx(1) stanzay+=128 nextst+=8 fade_out() elseif (doors.door3==2 and selez==3) then doors.door3=1 del(inventory,3) sfx(2) selez=0 else sfx(4) end end
  if(get_sprite()==95 and selez==2)then  selez=0 rubino=true del(inventory,2) sfx(0)  end 
  end
if(stanza==9) then o_parla=false
--[[ oliver ]] if(get_sprite()==112 and lo_abi)then 
   sfx(0)  textbox(text1,88,144,7) 
intro=true
else textbox()end --o_parla=true
end 
if(stanza==2)then
if(get_sprite()==166 and not docu1 )then sfx(0) docu1=true camera(128,128) stanzax=128 stanzay=128 end
if(docu1)then if(get_sprite()==134)then stanzax=128 stanzay=0 camera(stanzax,stanzay) docu1=false  end   end

--[[ goldkey ]] if(goldkey and masks) then if(get_sprite()==8 or get_sprite()==9) then sfx(0) goldkey=false add(inventory,3)  end  end
 
--[[ maschere ]] if(get_sprite()==82 and not masks)then
      if(pointerx<72)then sfx(10)
     if(m1y==16) m1down=true 
     if(m1y==48) m1down=false 
     if(m1down)then m1y+=8 else m1y-=8 end
     checkmask()
     end 
      if(pointerx>72 and pointerx<80)then  sfx(10)
     if(m2y==16) m2down=true 
     if(m2y==48) m2down=false 
     if(m2down)then m2y+=8 else m2y-=8 end
     checkmask()
     end 
       if(pointerx>88 and pointerx<96)then  sfx(10)
     if(m3y==16) m3down=true 
     if(m3y==48) m3down=false 
     if(m3down)then m3y+=8 else m3y-=8 end
     checkmask()
     end 
      if(pointerx>105 and pointerx<111)then  sfx(10)
     if(m4y==16) m4down=true 
     if(m4y==48) m4down=false 
     if(m4down)then m4y+=8 else m4y-=8 end
     checkmask()
     end 
   end
end    
end
end

end
-->8
function fade_scr(fa)
	fa=max(min(1,fa),0)
	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1
	local fades={
		{1,1,1,1,0,0,0,0},
		{2,2,2,1,1,0,0,0},
		{3,3,4,5,2,1,1,0},
		{4,4,2,2,1,1,1,0},
		{5,5,2,2,1,1,1,0},
		{6,6,13,5,2,1,1,0},
		{7,7,6,13,5,2,1,0},
		{8,8,9,4,5,2,1,0},
		{9,9,4,5,2,1,1,0},
		{10,15,9,4,5,2,1,0},
		{11,11,3,4,5,2,1,0},
		{12,12,13,5,5,2,1,0},
		{13,13,5,5,2,1,1,0},
		{14,9,9,4,5,2,1,0},
		{15,14,9,4,5,2,1,0}
	}
	
	for n=1,pn do
		pal(n,fades[n][fi],0)
	end	
end

-->8

function outline_sprite(n,col_outline,x,y,w,h,flip_x,flip_y)
  -- reset palette to black
  for c=1,15 do
    pal(c,col_outline)
  end
  -- draw outline
  for xx=-1,1 do
   -- for yy=0, 0 do
      spr(n,x+xx,y,w,h,flip_x,flip_y)
   -- end
  end
  for yy=-1,1 do
  spr(n,x,y+yy,w,h,flip_x,flip_y)
  end
  -- reset palette
   if(not fadeout)pal()
   
  -- draw final sprite
 if(stanza!=10)then 
 spr(n,x,y,w,h,flip_x,flip_y)	
 else
 pal(8,1)
 pal(14,12)
 pal(2,0)
 pal(7,6)
 spr(n,x,y,w,h,flip_x,flip_y)
 end
end

p1=0
p2=0

function printout(t,x,y,col_outline,col,light,shad)
  -- reset palette to black
  for c=1,15 do
    pal(c,col_outline)
  end
  for xx=-1,1 do
      print(t,x+xx,y,col_outline)

  end
  print(t,x,y+2,col_outline)
  print(t,x-1,y+1,col_outline)
  print(t,x+1,y+1,col_outline)
  print(t,x+1,y-1,col_outline)
  print(t,x-1,y-1,col_outline)
  for yy=-2,1 do 
  if(not fadeout)then if(yy==-1)then pal(c,light) end end
  if(not fadeout)then if (yy==1)then pal(c,shad) end end
  print(t,x,y+yy,col_outline)
  end
  -- reset palette
   if(not fadeout)pal()
  -- draw final sprite
  print(t,x,y,col)
end
__gfx__
0000000077000000007ee8000000000000000000006d600000040024000000002222222200000000666666660a0090a000000000000000066666666660000000
000000007000000007eeee80000000000008800000606000000042420000000020202020000000005555555500a99a0000000000000666644444444446666000
000000000000000077eeee88707007770079970000d6d00000007420770007700202020200000000555555550998290070700070066444444444444444444660
000000000000000022822282aaaaaa0a07000070000600000007564066006ee600000000000000005555555500922990a0a00a0a644444444444444444444446
0000000000000000ee888822999999090a0000a0006d6000007560046666688600000000000000005555555500a99a0099999909244444444444444444444442
000000000000000007e8822000000eee090000900060600007560000000052250000000002020202555555550a0930a0000000e0022444444444444444444220
000000000000000000788200000000000099990000d6d00065600000000005500000000020202020777777770003300000000000000222244444444442222000
0000000000000000000e200000000000000000000006000066000000000000000000000022222222666666660003300000000000000000022222222220000000
0aaaaaa000000000000000000000000000024200006d60000aaaaaa000000024000000004444444406aaaa600000000000000000000000000000000000000000
a999999a0000000007777707077777070004440000606000a888888a000002422222222244400444776996770000000001111111000000000022220000000000
aaa77aaa0088888070000077705050770002420000d6d000aaa77aaa000024202525252544077044700660070000000001000001000000000022220000000000
0aa77aa088888788707770077577700700044400000600000aa77aa0066242005252525244066044705665070000070001011101000000000024220000000000
00a77a00e888888e7000000770050507000242000008800000a77a00666520005555555544066044766776670000060001000101000000000022420000000000
000aa0000e8888e07000007770505077004444400088e000000aa0006656600025252525440550446777077600076a6701111101000000000024220000000000
000aa00000eeee000777770707777707000656000088f000000aa000656660005555555544200244066666600000360000000001000000000024420000000000
09aaaa9000000000000000000000000000065600008ef00009aaaa90666600005555555544422444060600600003070011111111000000000024420000000000
500990050777777000000000006d600000065700008ef0000000eeeeeeee00000006666666666000000000000003000000000000000000000024420000000000
504aa40577777777000000005060605500065700000ef000000e88888888e000066555555555566000aaaa000030000000000000000000000024420000000000
60499406700660076666644450d6d05500065700000ef00000e888822222220065555555555555560a9999a00030000000077000000000000244442000000000
0504405070566507d66664041106011100065700000ef0000e8888822a22a2006555555555555556099449900000000000077000066000004444444400000660
00499400766776670d6d6404006d60000006570000feef000e888888222222807555555555555557099aa9900999900000077000644400044422224440004446
058aa850677707760000d222506060500006570000ee0e0008888888828828806777755555577776049999400099000000077000244400444200002444004442
60922906066666600000000050d6d050000657000e0e00f008888eeeeeeeeee006666777777666600044440000aa000000077000024404422000000224404420
5020020506060060000000001106011000007000000e00e00888e0000000000000666666666666000000000009aa900000077000002222200000000002222200
06cccc6006bbbb6006eeee6000000000000000000000000008880207070707000022222222222200000000009a77a90000077000000666666666666666666000
77611677776336777768867700000000000aa000dd0dddd508880207002007000253535353535320660666669a77a90000077000066222222222222222222660
70066007700660077006600700000000000aa000dd0dddd508280220020200004535353535353534660666669aaaa90000aaaa00622888888888888888888226
70566507705665077056650700000000000770005505555500028020707070002453535353535342550555559aaaa90000099000688888888888888888888886
766776677667766776677667000aa0000007700000000000002028000000000022444444444444220000000009aa9000000990007eeee88888888888888eeee7
67770776677707766777077600a77a00000aa000ddddddd00002022222222000224444444444442266666660009900000009900067777eeeeeeeeeeeeee77776
0666666006666660066666600097790000099000ddddddd000002000000000000224444444444220666666600999900000a99a00066667777777777777766660
06006060060600600606606000099000000880005555555000000000000000000022222222222200555555500000000009999990006666666666666666666600
21551551111001110055555555555500555555555555555500000004400000004242424222424242099990444444444411000000000000000000001100000000
15551555110000110555555555555550555555555555555524242420042424242424242004242424090090444222244410666666666666666666660155055555
55511155100110015555555555555555555555555555555542424240024242424242424222424242090090442000024402444444444444444444442055055555
55122215001111005555555555555555555555555555555524242420042424242424242224242424099090440a77a04402444444444444444444442011011111
11121211115555115555555555555555555555555555555542424242224242424242424222424242099990440900904402444555555555555554442000000000
5512221551155115555555555555555555555555555555552424242004242424242424266424242420000244007a004402442000000000000002442055555550
55511155551111555555555555555555055555555555555042424240024242426666666446666666422224440099004402442022222222222202442055555550
15551555555115555555555555555555005555555555550024242422242424244444444444444444444444440900904402442024444444444202442011111110
00000000022222202005501155000055550000555500005500000000000000000000000000000000551555555551155502442024444224444202442021551551
07700000233333311055005550aaaa0550aaaa0550aaaa0522022222222222220000077055055555551111555511115502442024444224444202442015551555
0777000023333331100550550a9009a00a9009a00a9009a022022222242424240000777055055555511551115115511502442024444224444202442055511155
070770002333333150550015090e8090090b30900906c09011011111424242420007707011011111515225151155551102442024444224444202442055122215
0700770023333331100550210908809009033090090cc09000000000444444440077007000000000515225151155551102442024444224444202442011121211
07077000233333315055001509900990099009900990099022222220242424240007707055555550111551155115511502442024444224444202442055122215
07770000233333311005505550999905509999055099990522222220444444440000777055555550551111555511115502442024444444444202442055511155
07700000011111101055005555000055550000555500005511111110444444440000077011111110555551555551155502442024555555554202442015551555
52211225000000008884884410000000000000011000000000000001100000000000000188888000005d65004400004402442024444444444202442002200220
22111122777777708484848406666666666666600666666666666660066666666666666087278000005d650040aaaa0402442022222222222202442002000020
21155112770007708484884404444444444444400444444444444440044444444444444082228000005d65004099990402442000000000000002442002000020
11522511077077008884884404211aaaaaa112400421144444411240042111fffff1124028882100005d65004200002402444222222222222224442020200202
11522511007770004444848404219aaa99991240042124442222124004211feeeeef124012221200005d65004422224402444444444444444444442022000022
21155112000700008884884404219aaeeee912400421244eeee2124004211eeeeeee124081118e00005d65004444444402444444444444444444442020000002
2211112200000000484444440421944ee44912400421222ee222124004211555e555124088888808005d65004444444410555555555555555555550102000020
5221122500000000884444440421970ff70912400421207fe072124004211e07f07e1240eeee8202005d65004444444411000000000000000000001102022020
52211225000000002115151104219eeffee112400421eeeffeee124004211eeefeee1240000000000000000044444444444444444444444444444444007bb300
22111122666666661555155504211eaaaae112400421fe2222ef124004211e00000e124000000000000000004444444444400444440000044444444407bbbb30
21155112444444441551215504211ee88ee112400421ee2882ee124004211000800012401fffff22fffff100444444444406604440a777a04444444477bbbb33
115225114444444455122215042676eeee76724004267ee22ee67240042176eeeee672401eff4f88f4ffe100444444444405504440a000a04444444455355535
11522511444444441122122104267676767672400426767676767240042676767676724001ef4f88f4fe1000444444444420024440a000a044444444bb333355
211551124444444455122215044444444444444004444444444444400444444444444440001fff22fff10000444444444442244440aa0aa04444444407b33550
2211112254545454155121550222222222222220022222222222222002222222222222200001ffffff1000004444444444444444409999904444444400733500
522112255555555515551555100000000000000110000000000000011000000000000001000011111100000044444444444444444400000444444444000b5000
000000000000000000000000000000000bbb00000000001000000000006d6000007770000000000000000000000077777777000000777777777777005d6776d5
000000000000000000000000000bbb00b33300000000001001111111006060000700777700000000000000000077555555556600077000000000077000000000
000000000000000000000000000033b033300000000000100100000100d6d0000722777000070700000000000755555225555560770000000000007700566500
00000000000000eeee00000000000030300000001111111101011101000600000777707607070707000000770555555555555550700000000000000700566500
000000000000ee8888ee000000000222220000000010000001000101000600600600777207777777007707205555555115555555700000000000000700566500
00000000000e88888888e000000004f2f40000000010000001111101000600600622766606260626000067775555515225155555700000000000000700566500
0000000000e888822222220000000422240000000010000000000001000d66d00266622202062682666626225555121221215555700000000000000700566500
00000000008888822a22a200000000484000000011111111111111110000dd000022288808028288222202665551662662661555700000000000000700566500
00000000088888882222228000004444444000004444444401111110333333330088888000088888800808085555552552555555700000000000000700566500
00000000088888888288288000042444442400004444444415555551333333330000808000000888000808005555556556555555700000000000000700566500
000000000888888eeeeeeee004420440440244004444444415855851333333330000800000000808000808005555555555555555700000000000000700566500
00000000e88888e0000000000040044444004000000004441558e551333333330000800000000008000808001555005050005551700000000000000700566500
0000000e888028807022070000004244424000009aaa9044155e8551333333330000800000000008000008001555555555555551700000000000000700566500
00000ee8888202220222200000044022204400009999904415855851333333330000800000000008000008001150005050005511770000000000007700566500
0000e888888820000000000000004000004000000000024415555551333333330000800000000008000008001111555555551111077000000000077000566500
00008eee888882222220000000222000002220002222244401111110333333330000000000000000000000001111111111111111007777777777770000566500
0008eeeee80888888882000000000000000000004400004421151511215515552155155121551551000244200000222010101010101010101010101000566500
000e88888e80888888820000000555055005550040aaaa0415551555155515551555155515551555660244200000666001010101010101010101010100566500
0008888888808eeeee82000000556656655665500a9009a015512155555100000000000000001155440244200000222010101010101010101010101000566500
000888888880eeee0ee200000056666666666500090aa00055122215551066666666666666660215440244200000222001010101010101010101010100566500
0002888888802eeeee220000005660060060065009099aa911221221110244444444444444442011440244200000222010101010101010101010101000566500
00002888800002eee200000000056666666666500990999955122215550244444444444444442015440244200000222000000000000000000000000000000000
0000022222222000002222200005606066666500409900001551215555024445555555555444205554024420000022201111111111111111111111115d6776d5
0000000000000000000000000005666660006500440002221555155555024420000000000244205555024420000022202222222222222222222222225d6776d5
000b000b000000003330666000566666666665006660ccc03330ddd021024420000000000244205102442000ccc0000033333333000000000000000000000000
0003b0b3000500006660222000560060060066505550666066606660150244204444444402442055024420666660000033333333006060000000000022022222
0b003b30000500003330666000566666666666506660ccc03330ddd055024420444444440244205502442044ccc0000033333333000500000065600022022222
03b0330000050500333022200005600600606500555066606660ddd0550244202222222202442015024420446660000033333333000000000000000011011111
003b3000500505003330666000566666666666506660ccc03330ddd011024420000000000244201102442044ccc0000033333333000006060000000000000000
00033000050550003330222000556655665665505550ccc03330ddd055024420000000000244201502442044ccc0000033333333000000500000065622222220
00033000005500003330222000055500550555005550ccc03330ddd055024420000000000244205502442054ccc0000033333333606000000000000022222220
00033000005500003330222000000000000000005550ccc03330ddd015024420000000000244205502442055ccc0000033333333050000006560000011111110
00000eeeeee00000000000000ddddd00000000000dddddd00dddddd0002000020000000000000000000420001100000000000000000000110000000011111111
0000e888888e0000000000dddd6666ddd000000016666661d666666d0000002400000000000000000004200010dddddddddddddddddddd010999999015555551
00088888888880000000dd6666d666666dd0000016555561665665660244424400000000000000000004200001555555555555555555551004444440155aaa51
0008888888888000000d666666ddd666666d00001656666165566556042224440000000000000200000420000155555555555555555555100400004015a55951
00008882222220000006666666666666666d0000165655616656656604a4a4440000000000004400000420000155511111111111111555100499994015955951
00220882a22a200000d666666666666d6dd6d0001666666156666665044444440222222222224000000420000155100000000000000155100444442015999551
000828822882200000d66666666666666666d0001555555115555551400044440444444444400000000420000155101111111111110155100222220015555551
00008e882882800000dd6666666666666666d0000111111001111110740474420444444444000000000420000155101555555555510155100d666d0011111111
000008888888800000d66d66666666666d66d0000d6666100d666610788874202444444444000000000420000155101511111111510155100d66d00000000010
000020888555800000d66d66666666666d6dd000d6111151d6111151222222024444444444000000000420000155101515555551510155100d666d0000000010
000822022222000000d0666666666666d6d0d000d6655551d6655551000000224402222044000000000420000155101515eeee51510155100d66d00000000010
00e882200000200000d006d666666666dd00d000d6666651d6666651000022202402222024000000000420000155101515555851510155100d66600011111111
0e8888822222e20000d01000666666600010d000d6656651d6666651000022002400000024000000000420000155101515ee5851510155100d6d000000100000
0e80008888888e0000d011110d666d011110d000d6555651d6666651000002000400020002000000000420000155101515885851510155100d66d00000100000
0e88ee088888880800d0111110ddd0111110d000d6565651d6666651000002000200020002000000000650000155101515555551510155100d6d000000100000
0002220eeeee820200d60011106a60111006d000d6666651d6666651000000000000000000000000000650000155101511111111510155100d66d00011111111
000000eeee0ee200000d660006606600066d00000dddddd000000000000000000020000211101110566656650155101555555555510155100000000000000000
0020228eeeee2020000dd666dd000666d6dd0000d666666d01111111111111100000002400000000566566650155101111111111110155100220222200000000
045300000000053400000d6d660606666d0000006666666601555555555555d00244424455555055566656650155100000000000000155100000000000000000
0245355353535342000000d666666666d000000066666666015d1555555d15d00422244455555055566566650155511111111111111555106666666600000000
02244444444444220000000d6666666d000000006666666601511555555115d004a4a4441111101156665665015555555555555555555510dddddddd00000000
02244444444444220000000d6060606d000000005666666501555550055555d04000444400000000056566500155555555555555555555105555555500000000
00224444444442200000000dd0d0d0dd000000001555555101555500005555d04404444455505550005665001055555555555555555555010000000000000000
00022222222222000000000060606060000000000111111001555055550555d08888844255505550000550001100000000000000000000110111111100000000
dd442442d44444220000000000000000d00000000000000d01555055550555d0788874004440444044104410442004441110111022222222005d6500005d6502
dd442442d44244220000000000000000ddddd000000ddddd01555055550555d0788870000000000022002000420d02240000000011111111205d6502205d6500
d4444442d4444442dddddd00dddddddd24444dddddd4444201555500005555d000000000888880888855805520d4d0025555505500000000205d6502205d6655
d4444422dd444442444444dd44444444022244444444222001555555555555d000000000888880888555805504444dd05555505501010101105d6501105dd666
d4444422dd44444244444444444444440000224444220000015d1555555d15d0000000004444404441111011d024440d1111101110101010005d65000005dddd
dd444422d44444422222444422222222000000222200000001511555555115d0000000000000000020000000440220d40000000001010101205d650222205555
dd424422d4244422000022dd00000000000000000000000001555555555555d000000000888088808550555044400d445550555010101010205d650222220000
d4424422d42444220000000d00000000000000000000000001ddddddddddddd0000000008880888055505550444204445550555001010101105d650111111110
__gff__
0000000000000000040400000000080000000000000000000800000000810080000000000000000000000000000000000000000000000000000000000000000000000202020201010101010100000000000000000000000800000000001000000000000000010100000000010000000000000000000000000000000110080800
0001020000000000000000000000000000010100000800000000000000000000000000000008000000000000e000000000000000000000000000000081000000000000000000000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000101000909000c0e00000
__map__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0000000000000354f3a3a3a4f4f4f4f3a3a3a
404040404040404040404040404040407272727272727272727272727272727240404040404040404040404040404040727272727272727272727272727272724040404040404040404040404040404060606060606060606060606060606060000000000000000000f4f3f3f2f1000000000000353a3a3a3a3a4f4f3a3a3a3a
4040a7a8a8a8a94040404c4d4d4e404072724c4d4d4e7252725272527252727240404c4d4d4e404c4d4d4d4d4d4e40407272727272727272724c4d4d4e7272724040404040404c4d4d4e40404040404060604c4d4d4e604c4d4e604c4d4d4e6000000000000000000000000000f1f50000000000353a3a3a3a3a3a3a3a3a3a3a
4040b7acadaeb94040405c47465e404072725c08085e7252725272527252727240405c47465e405c00000000005e40407272727272727272725c08085e7272724040636440405c47465e40406768404060605c47465e605c6f5e605c0e0e5e6000000000000000000000000000f000000000000035593ac5e5c6e5e5c6e5c53a
4040b7b8b8b8b94040405c49485e404072725c09095e7252725272527252727240405c49485e405c00000000005e40407272727272727272725c09095e7272724040757640405c49485e40407778404060605c49485e606c6d6e605c0e0e5e600000000000000000000000f4f2f0000000000000354f59d61f1f1f1f1f1fd659
4040b7acadaeb94040405c7b7b5e404072726c6d6d6e7252725272527252727240405c7b7b5e405c00000000005e40407272727272727272726c6d6d6e7272724040404040405c7b7b5e40404040404060605c7b7b5e60606060605c7e7e5e6000000000000000001f1f1f1f00f1f5000000000035e6e7d51f1f1f1f1f1fd54f
4040b7b8b8b8b94040405c4b7b5e40405872727272727252725272527252725058405c4b7b5e406c6d6d6d6d6d6e4050587254727272557272727272727272505840405f40405c4b7b5e40404040405058605c4b7b5e60607060605ca5955e6058000000000000001f1f1f1ff4f000505800000035f6f7d61f1f1f1f1f1fd64f
4040b7acadaeb94040405c4a7b5e4040727272a6a6a67272727272727272727240405c4a7b5e40404040404040404040727272725372727272575757577272724040405f40405c4a7b5e40404040404060605c4a7b5e60607070605c7d7e5e6000000000000000001f1f1f1f00f1000000000000354f4fd61f1f1f1f1f1fd659
4040b7b8b8b8b94040405c47465e4040727272a6a6a67272727272727272727240405c47465e404040404040404040407272727272727272724c4d4d4e7272724040405f40405c47465e40404040404060605c47465e60606060605c0e0e5e60000000008b8c00001f1f1f1f00f0000000000000354f4fd51f1f1f1f1f1fd559
7171aaacadaeba7171715c49485e71717171717171717171717171717171717171715c49485e717171717171717171717171717171717171715cfdfd5e7171717171717171715c49485e71717171717171715c49485e71717171715c0e0e5e7100b0b1009b9c001d00b1b000b1f100b000b100b1355959d61f1f1f1f1f1fd659
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005cacac5e000000000000000000000000000000000000000000000000000000000000000000000097979797808097bc97979797979797979797979797bcbc979797979797979797
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009797979780809797979797979797979797979797979797979797979797979797
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0042430042430042430042430042430000424300424300424300424300424300004243004243004243004243004243000042430042430042430042430042430000424300424300424300424300424300004243004243004243004243004243000042430042430042430042430042430000424300424300424300424300424300
0044450044450044450044450044450000444500444500444500444500444500004445004445004445004445004445000044450044450044450044450044450000444500444500444500444500444500004445004445004445004445004445000044450044450044450044450044450000444500444500444500444500444500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606060606060606060606060606060601c1c1c1c1c1c1c1c1c1c1c1c86868686595923592359592359235923592359595656fe56fe56565656bfbfbf56565656565656565656565656565656565656564d4d4d4d4d4d4d4e5b5b5b5b5b5b5b5bf9f9f9f9fafccbcccdcbcccdcbcccdfaf9f9f9f9fae9e9e9e9faf9f9f9f9f9f9
60606060606060606060606065666060dfdfdfdfdfdfdfdfdfdfdfdfdfdfdfdf595923593159592359235923592359595656fe56fe56565656bfbfbf56565656565656565656565656565656565656560e0e0e6b0e0e0e5e5b5b5b0e0e0e0e5bf9f9f9fafcfcdbdcdddbdcdddbdcddfcf9f9f9fae9e9cbcccccdfaf9f9f9f9fa
606060707070606060676860757660601c1c1c1c1cdfdfdfdfdfdfdfdfdfdfdf595923595959592359325930592359595656fe56fe56565656bfbfbf56565656565656565656565656565656565656566d6d6d6d6d6d6d6e5b5b5b181818185bf9cbcccccdfcebecedebecedebecede9fafafae9e9e9db0808dde9faf9f9fae9
60606070707060606077786060606060df1f1f1fdfdfdfdfdfdfdfdfdfdfdfdf595959595959592159595959591a59595656fe56ff53ee18181818181818565656565656bf565656565656565656565641414141414141415b5b5b6d6d6d6d5bf9db1d1dddfccbcccdcbcccdcbcccde9e9e9e9e9e9e9db0909dde9e9faf9e9e9
60606070707060606060606067686060df1f1f1fdfdfdfdfdfdfdfdfdfdfdfdf595959595959595959595959595959595656fe56565656cbcccccccccccd565656565656bf56565656565656565656565b5b5b5b5b5b5b5b5b5b5b414141415bfadb1d1dddfcdbdcdddbdcdddbdcdde9e9e9e9e9e9e9ebececede9e9e9f9e9e9
60606070707060606060606075766060df1f1f1fdfdfdfdfdfdfdfdfdfdfdfdf59595959595959595959595959595959cbcccccccd5656db0005000000dd565058560a0a0a0a0a0a56565656565656560a0a0a0a0a0a0a0a5b5b5b7c7c7c7c5be9db1d1dddfcebecedebecedebeced5058e9e9e9e9e9e9fae9e9e9e9e9fae9e9
60606070707060606060606060606060df1f1f1fdfdfdfdfdfdfdfdfdfdfdfdf595959594f4f59595959595959595959dbdccfdcdd5656db0087000000dd5656565600000000000056565656565656566d6d6d6d6d6d6d6d5b5b5b5d5d5d5d5be9db1d1dddfccbcccdcbcccdcbcccde9e9e9e9fce9fce9fce9fce9fce9e9e9e9
60606070707060606060606060606060df1f1f1fdfdfdfdfdfdfdf8585dfdfdf5959594f4f4f595959cbcccccccd5959dbdcdcdcdd5656db0000000000dd5656565600000000000056565656565656564c4d4d4e4c4d4d4e5b5b5b5b5b5b5b5be9db1d1dddfcdbdcdddbdcdddbdcdde9e9e9e9fce9fce9fce9fce9fce9e9e9e9
717171717171717171717171717171711c1f1f1f1c1c1c1c1c1c1c8686861c1c5959594f4f4f595959db6a6a6add5959dbdccfdcdd5656db0000000000dd5656565600000000000056565656565656565c08085e5c47465e7171717171717171e9db1d1dddfcebecedebecedebecede9e9e9e9fce9fce9fce9fce9fce9e9e9e9
00000000000000000000000000000000000000000000000000000085858500000000000000000000000000000000000000000000000000dbaeacacacacdd0000000000000000000000000008080800005c09095e5c49485e51515151515151511d1d1d1d1d1d1d1d1d1d1d000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000515151515151515151515151515151510000000000000000000000000000000000000000000000000000000000000000
0000000000000000610000000000000000000000000000000000000000000000000000000000000061000000000000000000000000000000000000000000000000000000000000006100000000000000000000000000000061000000000000000000000000000000000000000000000000000000000000610000000000000000
0042430042430042430042430042430000424300424300424300424300424300004243004243004243004243004243000042430042430042430042430042430000424300424300424300424300424300004243004243004243004243004243000042430042430042430042430042430000424300424300424300424300424300
0044450044450044450044450044450000444500444500444500444500444500004445004445004445004445004445000044450044450044450044450044450000444500444500444500444500444500004445004445004445004445004445000044450044450044450044450044450000444500444500444500444500444500
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00020000054600544011750167501d7502375002700205001f600302001a200082001260009600096000000006000040000600025700207001c70018700121001210013100161001c10022100271002d10032100
00030000076000a6500a6500a6500a6502e600306003160013600136001360013600146002f600096500965009650096500c6000c600156001660015600116001060000600006000060000600006000060000600
000400000b5001650004050011501a65014650066500065022720096202f620266400c64000620006000260001600016000160001600016000160001600016000060000600024000570000700027000440004400
000300000045000450004501565015650156501565005550035500055009750067500375002750017500075000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000136500b6500a650074500f7701477015770107700d7700b77008770067700377000770027700077000000000000000000000000000000000000000000000000000000000000000000000000000000000
008800000074400730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
00640020070140801107011060110701108011070110601100013080120701106511070110801707012060110c013080120701106011050110801008017005350053408010070110601100535080170701106011
008800000073000730007320073200730007300073200732007300073200730007320073000732007320073200732007300073000730007320073000730007300073200732007300073000732007300073200732
0064002006510075110851707512060110c0130801207011060110501108017070120801107011060110701108011075110651100523080120701108017005350053408012070110601100535080170701106511
000100000f350026500265010350016500165000650006501335002650026500265000650123500265003650046500565011350096500c6501065015650196501d650216501d0501e0501d0501b050160500e050
000200000965009650096500965009650096500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000061500d15013150181501a1501915014150101500a150041500015000150001400113001130001200011003110081101210016100171001710015100121000b100011000110001100001000010000100
000200000155003550071500755006550065500c1500a7500d750087501415006550055500355009150027500475006750077500d750151500475005750025500455010150075500955007550045500c15000550
0002000008700107001f700227003b0003b0000a7000d7000c7000a70008700057000170003700000000370003700037000370003700037000370003700047000f700047200c730167303b0303c0200871006740
000f00000300009700015000c70003000050000d000015000b000060000000001000010000770005700025000a70002500077000b7000d7000d70000500090000700005000005000470006700005000e0000b000
000100001120011220122401222012200122001221012230132201320013200132001222012230122201220012200122001222012240122201220012200122001222012230122301321013200132101323013230
000100002365030650150502355025550265502655023750146500e6500965007650066501575006650066500764007640107300563004620046200d710016100160000600006000a70000600006000570000600
000300000000004750087500d640357203c7000a70003700004000670002700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700000605006050060500305003050030500305003050030500305003050020500605006050060500605005050050500505005050050500505005050050500605006050050500505005050050500505005050
00030000146101b6202262029620276202762027620296202c6202e6302e6302a650246501d6501a6501a6501b6501f65022650266502765026650236502765026650266302663029620286201d6201862019620
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
01 05 06 43 44
03 07 08 43 44
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
