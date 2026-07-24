pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--jack of spades
--by bonevolt
srand()
--constants
cartdata("bonevolt_jack_of_spades")
last_tile=peek(0x5eb5)
if stat(100)=="challenge mode" and #stat(6)>0 then
 poke(0x5ee2,stat(6))
 poke(0x5ee3,peek(0x5ee3)+1)
end
poke(0x5ee4,0)
poke(0x5ee1,max(peek(0x5ee1),peek(0x5ee2)))

function peekbit(i)
 return band(1,shr(peek(0x5e00+i/8),i%8))
end

function pokebit(i,v)
 local byte,bit=peek(0x5e00+i/8),2^(i%8)
 byte=band(byte,0xff-bit)
 poke(0x5e00+i/8,bor(byte,bit*v))
end

function peeknil(i)
 return peek(i)>0 and peek(i) or nil
end

function irnd(n)
 return flr(rnd(n))
end

function irnd1(n)
 return irnd(n)+1
end

function shuffle_table(t)
 for i=#t,1,-1 do
  local j=irnd1(i)
  t[i],t[j]=t[j],t[i]
 end
 return t
end

function str_to_table(str)
 local tab,sptab={},{}
 for i=1,#str do
  if sub(str,i,i)=="," then
   for j=i+1,#str do
    local strn=sub(str,j,j)
    if(strn=="|")add(sptab,tab)tab={}i+=1 break
    if strn=="," then
     local s=sub(str,i+1,j-1)
     if tonum(s) then
      s=tonum(s)
     elseif s=="" then
      s=0
     elseif s=="t" then
      s=true
     elseif s=="f" then
      s=false
     elseif s=="{" then
      s={}
     end
     add(tab,s)
     i=j
     break
    end
   end
  end
 end
 if (#sptab>0) return sptab
 return tab
end

function unpack(list,from,to)
 from,to=from or 1,to or #list
 if from<=to then
  return list[from],unpack(list,from+1,to)
 end
end

function to_tab_unp(tab)
 return unpack(str_to_table(tab))
end

function checkered_floor(c,ww,hh,mn1,mn2,mx1,mx2,ox1,oy1,ox2,oy2,cc)
	for i=mn1-1,mx1 do
	 for j=mn2-1,mx2 do
	  if (i+j)%2==0 then
	 		rectfill(ww*i+ox1+c,hh*j+oy1,ww+ww*i+ox2+c,hh+hh*j+oy2,cc)
	 	end
	 end
	end
end

function cam(xx,yy)
 camera(cam_x+(xx or 0),cam_y+(yy or 0))
end

--          1   2    3        4     5    6               
draw_funct={cls,rect,rectfill,fillp,sspr,checkered_floor}

message,hplay,hcanc,wait,n=nil,to_tab_unp(",0,0,0,1,")

fade_c=str_to_table(",,1,1,1,1,13,6,2,4,9,3,13,5,8,14,1,13,8,11,9,13,7,7,14,10,15,10,6,12,15,7,")

fade_in=0

en_group=str_to_table(",15,|,15,15,15,|,16,15,16,|,16,16,16,|,17,17,16,|,15,17,17,15,|,17,17,17,17,|,15,18,18,15,|,16,16,16,16,|,15,19,16,17,18,|,19,19,19,19,|,15,19,16,19,18,|,8,19,19,17,8,|,8,18,9,17,8,|,8,9,9,8,|,8,8,9,7,9,8,8,|")

--gfx
csprb={nil,nil,nil,nil,to_tab_unp(",0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,")}
chtr=str_to_table(",11,11,11,11,11,11,11,11,11,0,0,0,0,0,0,0,0,11,0,")
char_vptc=str_to_table(",6,14,6,13,14,6,14,6,14,14,6,6,7,1,14,6,6,14,6,")

mousep,hcol,kcol,kposx,kposy,kflip=0,str_to_table(",1,9,10,13,"),str_to_table(",1,8,9,3,"),{},{},{}
poke(0x5f2d,1)
kposx,kposy,kflip=str_to_table(",7,7,7,7,7,7,7,11,11,11,11,11,11,11,15,15,15,15,15,15,15,11,11,"),str_to_table(",6,9,12,15,18,21,24,6,9,12,15,18,21,24,6,9,12,15,18,21,24,10,20,"),str_to_table(",false,false,false,false,true,true,true,false,false,false,false,true,true,true,false,false,false,false,true,true,true,false,true,")

c_hue=str_to_table(",1,2,4,3,5,5,5,2,3,3,4,1,5,2,2,")
c_hue[0]=5
c_val=str_to_table(",1,1,1,1,1,3,5,2,2,3,3,3,2,3,4,")
c_val[0]=0

--b,r,y,g,gray,fire,elec,earth,wind,ice
to_col=str_to_table(",1,1,2,1,1,2,4,1,13,13,1,1,2,4,3,5,8,7,2,6,13,2,13,8,9,11,13,9,9,5,13,12,13,12,14,9,11,6,10,6,4,6,6,14,6,15,15,6,6,15,10,9,7,7,6,7,7,7,7,7,7,7,13,7,7,7,")

--sx,sy,w,h,offx,offy
sprv=str_to_table(",41,0,35,11,|,60,11,11,6,|,76,0,52,11,|,71,11,5,5,|,0,0,14,16,|,14,0,15,16,|,0,16,25,15,|,25,16,12,14,|,76,11,16,18,|,92,11,18,16,|,0,47,17,16,|,0,32,12,15,|,12,32,17,14,|,29,32,14,14,|,17,46,15,18,|,32,46,15,18,|,56,30,24,24,|,80,30,24,24,|,104,30,24,24,|,56,54,24,24,|,80,54,24,24,|,104,54,24,24,|,80,78,24,24,|,104,78,24,24,|,56,96,24,24,|,37,11,20,20,|")

--position of each kind on the card
kpos=str_to_table(",11,|,9,13,|,8,11,14,|,1,7,15,21,|,1,7,15,21,11,|,1,7,15,21,4,18,|,1,7,15,21,4,18,22,|,1,7,15,21,4,18,22,23,|,1,3,5,7,15,17,19,21,11,|,1,3,5,7,15,17,19,21,22,23,|")
party_add=str_to_table(",0,0,0,3,2,4,5,0,0,0,6,")
map_tile=
{
 str_to_table(",3,,,8,4,1,,13,,1,|,13,1,1,,,8,,8,1,1,|,13,2,,1,1,1,,,,1,|,1,,,8,,5,8,1,8,,|,1,1,1,1,13,1,,,1,,|,11,,8,,,,1,,1,,|,8,,1,,1,8,1,8,1,6,|,,1,1,,8,9,1,,,,|,,8,,1,1,1,,8,1,1,|,1,,8,,12,8,,,,7,|"),
 str_to_table(",5,1,,1,,1,1,,1,2,|,,1,8,,8,1,,8,,1,|,1,,,1,,,8,1,4,1,|,3,8,1,,1,1,,,1,1,|,1,1,,,1,1,,8,,,|,,1,,6,,1,,1,1,,|,8,,,8,1,,1,,,8,|,,1,1,,,8,,8,1,,|,4,1,8,1,1,,,1,,8,|,1,1,,-2,1,1,,1,4,1,|"),
 str_to_table(",03,17,00,17,00,17,17,00,17,18,|,00,17,08,00,03,17,00,00,00,17,|,17,00,00,17,00,00,00,17,00,17,|,02,08,17,00,17,17,00,00,17,17,|,17,17,00,00,17,17,00,00,00,00,|,00,17,00,19,00,17,00,17,17,00,|,00,00,00,17,17,00,17,00,00,00,|,00,17,00,00,00,00,00,00,17,00,|,00,-2,14,14,14,14,14,30,00,00,|,17,-1,00,08,00,12,17,-1,00,17,|")
}

cart=
{
	"#josw1",
	"#josw2",
	"#josw3"
}

messgs=
{
	",i don't know where these\n\"monsters came from\nbut they're not friendly,i came to the forest\nto chop some wood\nand when i came back\neveryone was gone...\nthere's just monsters!,the joker must have\nsomething to do with\nthese monsters\n\nlet's find him!,these monsters must have\nbeen brought to this\nworld through the same\nportal we chessfolk have!,i opened a portal to\nother worlds? of course\ni did! hahaha! let's\nhave an interdimensional\nparty!,the white king came to\nseize this land. we must\nstop him!,ok.\nthings got out of hand\ni admit it...\nhahaha!!,the queen of hearts joined\nyour party!\n\nshe can use hearts cards!,the king of diamonds joined\nyour party!\n\nhe can use diamonds cards!,the jack of clubs joined your\nparty!\n\nhe can use clubs cards!,you found the super glove!\n\nyou can now hold 7 cards at\nonce!,the black king joined your\nparty!\n\nhe can't use cards but he's\nvery strong in combat!,the joker joined your party!\n\nhe can use any card!,dark forest\n\nonly monsters allowed!\ngo away!,",
	",,what? my house looks\nlike a mushroom?\n\nhow insulting!,the white queen has\ntaken over the castle of\ndiamonds while the king\nwas away!\nyou need to stop her!,got item!,bark bark\n*you're strong*\n\nbark bark bark!\n*but lance is stronger!*,the one who wields the\nlegendary weapon!\nwearing his hypnotizing\ncrimson red scarlet\nscarf!,the one who does not\ndemand attention\nbut attention demands\nhim!,you guessed it... i'm\nlance! the protagonist\nof this game,ghwhaht!?\nyou never heard of me?\nthis is beyond\nimpossible!,...not my game? now\nthat you mention it...\nthe camera stopped\nfollowing me a while\nago...,well.. could you help me\nfind my friend chester?\nhe disappered just after\nwe came to this land,take this torch! it\nwill help you dispel\nthe darkness!,",
	",jack of spades,queen of hearts,king of diamonds - 1 armor,jack of clubs - crit x3,black king,joker,white king - fear,white pawn - pierce,white bishop - heal,sleeping flower,static cactus,muncher,multi flower,dummy,floaty,snaky - poison,pumpky,batty - lifesteal,skully - kill <13 hp,mouthface - stone form 3 turns,furkniceght - splash attack,cyclopt - pierce,daymon - confused,tombzord - sleep,skelly,swordslime - double attack,spellslime - sp immunity,wardrobber - detroy 1st card,jimmy - crit chance x3,rook,knight - allies att+1,white queen - splash att/heal,stumpy,chester,",
	",silver sharp: ally att+3\n8“,fireball: 8 dmg and 4 to\nneighbors,honor: ally att x2\n2“,empower: allies att+2\n4“,fire bomb: 7 dmg 3x3,metal blade: 12 pierce dmg,soul blade: 1 dmg/self hp\nmissing,fire storm: dmg enms\n5 dmg,u blade: pierce enms\n7 dmg,s armor: def+2 allies\n4“,u sharp: ally att+8\n2“,u fire: dmgs self and enms\n7 dmg,u armor: ally dmg/2\n4“,|,heal: ally hp+8,sleeping seed\nhp:10 att:5,heal allies: hp +5,corrosion: enm def-3\n4“,static cactus\nhp:10 att:3,barrier: 12 dmg,flood: kills enms\n 15 hp or less,rust: enms def-1\n6“,heartbreak: enms spdef-3\n4“,muncher\nhp:15 att:3,multi flower\nhp:5 att:5,s barrier: detroyed if\ndmg 9 or more. 4“,flood bubble: 1 dmg/hp missing,|,s focus: crit chance x3\n4“,thunder:\n15 dmg to enm,boulder: push enm back\n10 dmg,taunt: enms att ally\n1“,fissure: dmg 1 collumn\n8 dmg,shock: dmg 3 lines\n6 dmg,stone form: att and damage\nreduced t0 1. 3“,confusion: 50% enm att allies\n4“,electrify: return dmg received\n4“,fear: enms att-2\n4“,static: 20 dmg spread between\nenms (3 rows; r"
}
--262 chars, messg 2 pode usar 762
item_txt=str_to_table(",  twin sword\ndouble attack,  crystal heart\n50% chance to heal\n+2 att,  grand king's crown\natt causes fear x3,  humble pouch\npoison x2\n+1 att,  silver edge\npierce att\n+6 att,  pocket ocean\nattack causes rust x2\n+2 att,  sparkling mantle\nreturn dmg\n+2 att,  perpetual wind\natt clears buffs\n+2 att,  heat blade\n50% splash dmg\n+4 att,  living whip\nsummon stumpy,  stone mask\n4 armor,  winter star\ncrit att freezes 2 turns\n+1 att,  red raindrop\ncrit att lifesteal,  scarlet shadow\n75% crit chance,  black pearl\nallies att+1,  magic mirror\njoker mirrors allies\nsuits,  ultra glove\nhold 9 cards\n+4 att,  chaos scepter\nreshuffe hand 2 times\nper turn,")

--[[scene_text=
{
 "    entering the dark forest",
 "    entering the white castle",
 "        congratulations!\n  you defeated the white queen!\n\n       new game+ unlocked!",
}]]
will_start,will_start_tut=0,0
-->8
--init
function _init()
	t_loop,messgok,cam_x,cam_y,ptc,vfx,handsz,curr_mp,m_bg_col,m_bg_col2,m_char_x,m_char_y=to_tab_unp(",,{,,,{,{,9,1,11,3,3,2,")
 world=peek(0x5eb6)
 check_chars()
 --
-- poke(0x5ec9,3)
-- scene=peek(0x5ec9)

 --if stat(100)==nil then
 if peek(0x5ec9)==0 then 
  init_title()
 elseif peek(0x5ec9)==1 then
  scene=1
  --curr_tile=peek(0x5eb5)
		poke(0x5eb3,1) --m_char_x
		poke(0x5eb4,5) --m_char_y
		local exptiles=0
		for i=0,199 do--fog
		 if (i<100 and peekbit(i)==1) exptiles+=1
		 pokebit(i,0)
		end
		poke(0x5ece,exptiles)
		poke(0x5ecb,peek(0x5e8c)-1)
		poke(0x5eb6,2)
		world=2
		poke(0x5e8c,1+min(peek(0x5eca)*7,7))--en_group
  init_cutscene()
 elseif peek(0x5ec9)==2 then
  scene=2
  --curr_tile=peek(0x5eb5)
		poke(0x5eb3,5) --m_char_x
		poke(0x5eb4,10) --m_char_y
		local exptiles=0
		for i=0,199 do--fog
		 if (i<100 and peekbit(i)==1) exptiles+=1
		 pokebit(i,0)
		end
		poke(0x5ecf,exptiles)
		poke(0x5ecc,peek(0x5e8c)-1)
		poke(0x5eb6,3)
		world=3
		poke(0x5e8c,1+min(peek(0x5eca)*10,10))--en_group
  init_cutscene()
 elseif peek(0x5ec9)==3 then
  scene=3
  --curr_tile=peek(0x5eb5)
		poke(0x5eb3,3) --m_char_x
		poke(0x5eb4,2) --m_char_y
		local exptiles=0
		for i=0,199 do--fog
		 if (i<100 and peekbit(i)==1) exptiles+=1
		 pokebit(i,0)
		end
		--mark super glove as already acquired
		if (peek(0x5e8d)==7) pokebit(100,1)
		poke(0x5ed0,exptiles)
		poke(0x5ecd,peek(0x5e8c)-1)
		poke(0x5eb6,1)
		world=1
		poke(0x5e8c,6)--en_group
  init_cutscene()
 end
 menu=0
 if (world==0) clear_data()
end

function init_title(ending)
 update,draw,fade,g_time,cam_pos,camx1,camx2=upd_title,drw_title,to_tab_unp(",-128,0,25,0,0,")
 if ending then
  if ending==0 then
   music(19)
  else
   music(23)
  end
 else
  music(0)
 end
end

function init_cutscene()
 update,draw,fade,g_time=upd_scene,drw_scene,-128,0
 poke(0x5ec9,0)
 music(2)
 dialog=1
 messg_char2=nil
 if scene==1 then
  jackspr=5 jackf=false
  clubspr=14 clubf=false
  jokerspr=16
  if peek(0x5eca)==0 then
	  messg=
	  {
	  "dark forest.\nonly monsters allowed...",
	  "only monsters? well,\nmy castle is this way,\nso we'll have to go\neventually",
	  "defeating the white king\ndidn't change much...\nthe monsters must have\nanother master!",
	  "the dark forest...\nthere is a village in\nthere. i hope nobody\nis hurt",
	  "let's go! we have to\nfind out who's behind\nthis!",
	  "the monsters are getting\nstronger each time we\nfight them! stay alert!",
	  "this will be fun!"
	  }
	  messg_char=str_to_table(",1,3,5,2,1,4,6,")
	  new_message(1)
  end
 elseif scene==2 then
  lancex=128 lancey=70 lancef=true
  jackspr=5
  if peek(0x5eca)==0 then
	  messg=
	  {
	  "my castle looks so\ndifferent in such a\nshort time. these\nmonsters make formidable\nservants...",
	  "wait! card dudes!\ni found chester!\nthanks for your help!\nsorry i can't help you\nnow, i'm in a hurry.",
	  "please take this amulet.\nit will help you in\nthe final battle!",
	  "i was expecting you,\n\"heroes\".\nthe white army is much\nstronger with the\nmonsters as allies!",
	  "come in! my new friends\nare getting anxious for\nyour arrival!",
	  "only one monster is\nenough to defeat this\nteam.",
	  "the other monsters can\njust watch as i smash\nthem with my cursed\nstaff! i have waited\n999 years for this!",
	  "and tomorrow is my\nbirthday!",
	  "the monsters are even\nstronger now!\n\nwe must go!",
	  "white queen, the\nstrongest chess piece...\nget ready, she's\npowerful and merciless",
	  "am i the only one\nweirded out by her\ntalking through\ntelepathy?"
	  }
	  messg_char=str_to_table(",3,7,7,9,9,8,8,8,1,5,6,")
  else
	  messg=
	  {
	  "ah, heroes!\ncome in, my servants\nmiss you"
	  }
	  messg_char=str_to_table(",9,")
	  messg_char2=str_to_table(",9,")
  end
	 new_message(1)
	elseif scene==3 then
	 bgc=7
		 messg=
		 {
		 "is this it..?",
		 "will i stop... being?",
		 "you know the answer...\nwhen the game ends we\njust wait for the next\nsession.",
		 "you are being controlled,\nheroes. and i too am\nonly a mere pawn to my\nmaster.",
		 "but who controls the\nones controlling us?",
		 "behind the curtains you\nwill always find just\nmore curtains...",
		 "the shackles will only\nbe broken when the game\nof games finally ends",
		 "next time it won't be as\neasy, heroes!",
		 "sounds like insanity to\nme! she forgot the mad\nlaughter at the end!\nhuge missed opportunity!\nhahaha!",
		 "alright, picture time!\ndo your best battle\npose, everyone!",
		 "what about my face? is\nthis a good expression?",
		 "it's the same face you\nalways make...\n'hearts is really good\nat it though!",
		 "this is my time to shine!\nmy bow is ready!\njumpin' in 3!",
		 "you're all are taking\nthis way too seriously...",
		 "you are the one too\nserious! loosen up!\nhahaha"
		 }
		 messg_char=str_to_table(",9,9,9,9,9,9,9,9,6,2,1,3,4,5,6,")
		 messg_char2=str_to_table(",9,9,9,9,9,9,9,9,6,2,1,1,4,5,5,")
	 if peek(0x5eca)==1 then
		 new_message(1)
		else
		 new_message(10)
  end
 end
end

function init_map()
 music(-1,400)
 poke(0x5ec9,0)
 if world==2 then
  item_str={}
	 for i=peek(0x5eb2)+1,min(peek(0x5eb2)+6,18) do
	  item_str[peek(0x5eb6+i)-6]=true
	 end
  for i=1,18 do
   if (item_str[i]) messgs[2]=messgs[2]..item_txt[i]
   messgs[2]=messgs[2]..","
  end
 end
 draw_fade_out()
 draw_fade_out()
 draw_fade_out()
-- load("josw3.p8","back to title","megastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\nmegastring megastring megastring\n")
 if challenge_mode then
  load("#josch","back to title",tostr(rnd(0xffff.ffff),true)..messgs[4])
 elseif world<=3 and world>0 then
  load(cart[world],"back to title",messgs[world])
 end
 --run()
end
-->8
--init functions
function clear_data()
	for i=0x5e00,0x5edf do
	 poke(i,0)
	end
	--world
	poke(0x5eb6,1)
	world=1
	--loop
	poke(0x5eca,0)
 
	--torch
--	pokebit(200,1)
--	for i=0,99 do--fog
--	 pokebit(i,1)
--	end
	
	poke(0x5e80,1) --char available
	
	
	poke(0x5e86,2) --ch lvl
	poke(0x5e87,3)
	poke(0x5e88,4)
	poke(0x5e89,4)
	poke(0x5e8a,5)
	poke(0x5e8b,5)
	
	
	poke(0x5e8c,1) --next_en_gr
	poke(0x5e8d,5) --hand size
	
--	poke(0x5e8d,7) --hand size

	poke(0x5eb3,3) --m_char_x
	poke(0x5eb4,2) --m_char_y
	
	item={}
	item[1]={7,11,15}
	item[2]={8,12,16}
	item[3]={9,13,17}
	item[4]={10,14,18}
	item[5]={19,20,21}
	item[6]={22,23,24}
	itemget={}
	
	for i=1,6 do
	 shuffle_table(item[i])
	 add(itemget,i)
	 add(itemget,i)
	 add(itemget,i)
	end
	shuffle_table(itemget)
	
	for i=0,5 do
		for j=1,3 do
		 --item char order
		 poke(0x5e8d+i*3+j,item[i+1][j])
		 --item char get order
		 poke(0x5e9f+i*3+j,itemget[i*3+j])
	 end
	end
	
	--items aqquired
	poke(0x5eb2,0x00)
--	poke(0x5eb2,0x12)
--	--item order
	chitem={0,0,0,0,0,0}
 for i=1,18 do
  local ch=itemget[i]
  chitem[ch]+=1
  poke(0x5eb6+i,item[ch][chitem[ch]])
 end
 check_chars()
-- poke(0x5ecb,20)
--	poke(0x5ecc,20)
--	poke(0x5ecd,20)
--	poke(0x5ece,100)
--	poke(0x5ecf,100)
--	poke(0x5ed0,100)
-- poke(0x5eca,3)

end
-->8
--update
function _update()
 --if (btn()>0) clear_data() _init()
 --mouse
 wait,mousex,mousey=max(0,wait-1),stat(32),stat(33)
 mousep+=1
 if (stat(34)==0)mousep=0
 
 if (stat(31)=="") poke(0x5ee4,1)
 
 if (stat(6)=="tow1") init_map()
 
 g_time+=1
 t22,t4=flr(g_time/2%2),g_time%4
 --if message==nil then
  if messagetim then
  if messagetim~=4 then
   messagetim+=1
   messagesz+=10
   if (messagetim>4) messagesz-=20
   if messagetim>10 then
    messagetim=nil
    if messagenum<#messg_char then
     new_message(messagenum+1)
    end
   end
  else
   if mousep==1 then
    if messagenum<#messg_char and messg_char[messagenum]==messg_char[messagenum+1] then
     messagetxt=messg[messagenum+1]
     messagenum+=1
    else
     messagetim+=1
    end
   end
  end
 else
	 if (g_time==2640) g_time,t_loop=0,1
	 	update()
 end

 if fade_in>0 then
  fade_in+=1
  if (fade_in>13) fade_in=0
 end
 
-- --achievements
-- --1: all max
-- local maxed=0
-- for i=0x5e86,0x5e8b do
--  maxed+=peek(i)
-- end
-- if (maxed==78) poke(0x5ee0,1)
-- --2: finish
-- if (peek(0x5eca)>0) poke(0x5ee1,1)
-- --3: 100%
--	--poke(0x5ee2,1)
--	--4: no glove
--	if (peek(0x5eca)>0 and peek(0x5e8d)==5) poke(0x5ee3,1)
-- --5: finish with 4
--	if (peek(0x5eca)>0 and peek(0x5e84)==0) poke(0x5ee4,1)
-- --6: 2 vs queen
--	if (peek(0x5eb6)==3 and peek(0x5e8c)==21 and peek(0x5e82)==0) poke(0x5ee5,1)
--	--7: finish loop 4
--	if (peek(0x5eca)>=4) poke(0x5ee6,1)
-- --8: beat challenge mode
end

function upd_title()
 menup=0
 if (g_time<=100 and t_loop==0) cam_pos+=22/(g_time+11)
 if will_start==0 and will_start_tut==0 then
	 --if mousep==1 then
	  if menu==0 then
	   if (mousep==1) menu=1
	  elseif menu==1 then
	   if mousex>=26 and 
	   mousey>=39 and
	   mousex<=101 and
	   mousey<=62 then
	    if mousep==1 then
	     if peek(0x5ee0)==0 then
			    menup=3
			    will_start_tut=1
	     else
			    menup=1
			    will_start=1
			   end
		    sfx(60)
		   else
	     if peek(0x5eb6)==1 and peekbit(12)==0 then
					  if peek(0x5eca)==0 then
					   --new game
			     new_hint_text(1,"start a new adventure in story\nmode!")
					  elseif peek(0x5eca)==1 then
					   --new game+
			     new_hint_text(1,"new game+: harder battle groups.\nenemies have +5 hp and +1 att")
					  else
					   --new game++
			     new_hint_text(1,"new game++: each time you beat\nthe game adds +5 hp and +1 att")
					  end
					 else
			    new_hint_text(1,"continue your adventure!")					  
					 end
	    end
	   elseif mousex>=38 and 
	   mousey>=65 and
	   mousex<=89 and
	   mousey<=80 then
	    if mousep==1 then
		    menup=2
		    if hint_c1 then
		     clear_data()
		     new_hint_text(70,"data cleared sucessfully!")
			   else
		     new_hint_text(130,"this will erase your progress.\nclick again to confirm",8,7)
		    end
		    sfx(60)
		   end
	   elseif mousex>=38 and 
	   mousey>=84 and
	   mousex<=89 and
	   mousey<=99 then
	    if mousep==1 then
		    menup=3
		    will_start_tut=1
		    sfx(60)
		   end
	   elseif mousex>=38 and 
	   mousey>=103 and
	   mousex<=89 and
	   mousey<=118 then
	    --unlocked
--				 new_hint_text(1,"see how far you can get!\n".."best:"..peek(0x5ee1).." last:"..peek(0x5ee2).." tries:"..peek(0x5ee3))
     if mousep==1 then
      --unlocked
--		    menup=4
--		    will_start=1
--		    challenge_mode=1
		    --locked
--		    new_hint_text(70,"option unavailable in this\nversion")
		    new_hint_text(70,"option unavailable.\njoin discord for the beta!")
		    sfx(61)
		   end
	   end
	  elseif menu==2 then
    if mousep==1 then
	    menu=1
	   end
	  end
	 --end
	elseif will_start>0 then
  will_start+=1
	 if (will_start>8) init_map()
	elseif will_start_tut>0 then
  will_start_tut+=1
	 if will_start_tut>8 then
		 music(-1,400)
		 draw_fade_out()
		 draw_fade_out()
		 draw_fade_out()
	  load("#jostu")
	 end
	end
 if (g_time==500 and menu==0) music(-1,7000)
 if (g_time==750 and menu==0) init_title()
 camx1,camx2=sin(cam_pos/100)*-20+20,sin(cam_pos/100)*20-20
end

function upd_scene()
 if mousep==1 then
  if scene~=3 then
   init_map()
  else
   if messagetim==nil and score_prog and score_prog>240 then
    load("#jostitle")
   end
  end
 end
end
-->8
--update functions
function bool_to_num(bool)
 if (bool) return 1
 return 0
end

function new_hint_text(tim,str,clr1,clr2)
 hint_time=tim
 hint_text=str
 hint_c1=clr1
 hint_c2=clr2
end

function new_message(num)
 messagenum,messagetim,messagesz,messagetxt,messagechar=num,99,0,messg[num],messg_char[num]
 if ((char_in[messagechar] or messagechar>6) and (messg_char2==nil or char_in[messg_char2[num]] or messg_char2[num]>6)) messagetim=0
end

function check_chars()
 char_in={}
 for i=1,6 do
  local char=peek(0x5e7f+i)
  char_in[char]=true
 end
end
-->8
--draw
function _draw()
	pal()
	draw()
	pal()
	
	if messagetim then
	 --rectfill(52-messagesz,64-messagesz,76+messagesz,64+messagesz,1)
	 rectfill(0,128-messagesz,128,128,1)
	 if messagetim==4 then
	  print(messagetxt,4+bool_to_num(messagechar>0)*25,94,7) xtspr(messagechar+16,to_tab_unp(",2,94,0,101,1,f,"))
	  --if (messagechar>0) draw_char(messagechar,56,30)
	 end
	end
	--mouse cursor
	cam_x,cam_y=0,0
	if (draw~=drw_scene)outline(xspr,0,1,4,mousex+1,mousey+1)

 if hint_text and hint_time then
  if hint_time>0 then
   hint_time-=1
   aux_text(hint_text,hint_c1,hint_c2)
  else
   hint_time,hint_c1=nil
  end
 end
 --?#messgs[4],0,0,0
-- for i=1,18 do
--  ?#item_txt[i],flr((i-1)/6)*20+20,(i-1)%6*6
-- end
 if world==2 then
 	for i=1,15 do
		 if (i~=10) poke(0x5f10+i,0x80+i)
		end
 end
 if (peek(0x5ee4)==1) spr(236,120,0)
 --?#(messgs[4].."oxffff.ffff"),0,0,0
end

function drw_title()
 camera(0,cam_pos/2-40)
 if world==1 then
  draw_chain(",1,12,|,4,0x5a5a.8,|,3,0,2,128,4,6,|,4,|,3,0,-100,128,1,6,|,")
 elseif world==2 then
  pal(3,1) pal(11,3) pal(13,0) pal(6,1) pal(1,0) pal(12,2) draw_chain(",1,2,|,4,0x5a5a.8,|,3,0,2,128,4,6,|,4,|,3,0,-100,128,1,6,|,")
 end
 if world==3 then
  cls(1)
 else
	 --mountains
	 for j=1,40 do
	  local i=0
	  while i<=7 do
	   local k=i%2*2
	   rect(i*20-j,j+k*2,i*20+j,j+k*2,3+k*5)
	  	i+=2
	  if (i==8) i=1
	  end
	 end
	 draw_chain(",3,0,39,128,128,3,|,")
	 --far
	 checkered_floor(camx1,to_tab_unp(",10,5,-4,7,11,15,8,4,7,3,5,"))
	 draw_chain(",3,0,34,128,36,3,|,3,0,76,128,120,3,|,4,0x5a5a.8,|,3,0,34,128,40,3,|,3,0,72,128,80,3,|,4,|,")
	 for i=1,10 do
	  for j=1,10 do
	   local hh,ww=1,1
	   local tile=tonum(map_tile[world][i][j])
	   if (tile==5) hh=2
	   if (tile==-2) hh=2 ww=2
	   if (tile==7) palt(0,false) palt(11,true)
	   if ((tile<8 or tile==11) and tile~=0 and (tile~=5 or world==1)) spr(tile+191+world*16,i*10-1+camx1,j*5+33-hh*8,ww,hh)
	   pal()
	  end
	 end
 end
 if (world==2) pal(3,1) pal(11,3) pal(1,0)
 --close
 camyy=cam_pos*1.5-115
 camera(0,camyy)
 draw_chain(",3,0,79,128,128,11,|,")
 clip(0,195-cam_pos*1.5,128,128)
 checkered_floor(camx2,to_tab_unp(",16,10,0,8,9,12,8,4,7,3,3,"))
 if world==3 then
  clip(0,0,128,195-cam_pos*1.5)
  checkered_floor(camx2,to_tab_unp(",16,5,0,-14,9,15,8,1,7,1,5,"))
  checkered_floor(camx2,to_tab_unp(",16,5,0,-14,9,15,9,1,6,3,5,"))
  checkered_floor(camx2,to_tab_unp(",16,5,0,-14,9,15,9,2,6,-2,13,"))
  rectfill(camx2+8,10,camx2+71,80,1)
  checkered_floor(camx2,to_tab_unp(",6,2,2,7,11,18,5,2,2,0,5,"))
  for j=10,60 do
	  local clr=0
	  local t,nn,i,jj,cc,n=0,0,0,80-j
	  if (cos(80/j)>.0001) nn=1
	  while (i<40) do
	   n=i
	   nn+=1
	   t+=1
	   i+=j/2
	   local clr1,clr2=(clr+nn)%2,(clr+nn+1)%2
	   if t<3 then clr1,clr2=clr1*6+2,clr2*6+2
	   else clr1+=5 clr2+=5
	   end
	   rectfill(camx2+40+n,j+30,camx2+i+40,j+30,clr1)
	   rectfill(camx2+40-n,j+30,camx2-i+40,j+30,clr2)
	  end
  end
	 line(camx2+32,40,camx2-8,80,10)
	 line(camx2+48,40,camx2+88,80,10)
	 rectfill(camx2,11,camx2+8,80,4)
	 rectfill(camx2+6,11,camx2+8,80,2)
	 rectfill(camx2+4,11,camx2+4,80,2)
	 rectfill(camx2+72,11,camx2+103,80,4)
	 rectfill(camx2+72,11,camx2+74,80,2)
	 for i=1,5 do
	  rectfill(camx2+70+i*6,11,camx2+70+i*6,80,2)
	 end
	 sspr(24,64,11,14,camx2+35,27)
 end
 clip()
 draw_chain(",2,0,79,128,79,1,|,")
 pal()
 palt(11,true)
 palt(0,false)
 --party
 if (char_in[2]) xspr(6,camx2+28,75)
 if (char_in[1]) xspr(5,camx2+9,71)
 if (char_in[3]) xspr(7,camx2+1,91)
 if (char_in[5]) xspr(9,camx2+41,107)
 if (char_in[6]) xspr(10,camx2+35,94)
 if (char_in[4]) xspr(8,camx2+14,107)
 camera(0,camyy)
 
 --xspr(36,camx2+9,71)
 --chars
 --local xc,yc=to_tab_unp(",0,20,40,50,75,90,"),to_tab_unp(",0,90,80,90,70,80,")
 --for i=2,#party do
  --sspr(party[i]*16,32,16,16,camx2+xc[i],yc[i],true)
  --draw_char(party[i],xc[i],yc[i])
 --end
 --camera()
 --title
 pal()
 cam()
 
 --title
 if menu==0 then
	 monoc=1
	 outline(xspr,to_tab_unp(",1,1,1,46,32,"))
	 outline(xspr,to_tab_unp(",1,1,2,58,44,"))
	 outline(xspr,to_tab_unp(",1,1,3,38,51,"))
	 monoc=nil
	 outline(xspr,to_tab_unp(",1,1,1,46,29,"))
	 outline(xspr,to_tab_unp(",1,1,2,58,41,"))
	 outline(xspr,to_tab_unp(",1,1,3,38,48,"))
	 --click to start
	 if g_time>60 then
	  if (g_time%20<12) print(to_tab_unp(",click to start,36,80,7,"))
	 end
	elseif menu==1 then
	 --new/continue
	 filltr(26,39,100,62,3,1+bool_to_num(menup==1))
	 rect(27,40,100,61,10)
	 if peek(0x5eb6)==1 and peekbit(12)==0 then
	  if peek(0x5eca)==0 then
	   --new game
	  	outline(sspr,1,1,16,87,55,9,36,46)
	  elseif peek(0x5eca)==1 then
	   --new game+
 	  outline(sspr,1,1,16,87,62,9,34,46) 
	  else
	   --new game++
	   outline(sspr,1,1,16,87,62,9,30,46) 
	   outline(sspr,1,1,72,88,7,7,93,47) 
	  end
  else
	  outline(sspr,1,1,16,78,52,9,38,46)   
  end
	 --clear data
	 filltr(38,65,89,80,3,1+bool_to_num(menup==2))
	 rect(39,66,88,79,10)
	 outline(print,1,1,"clear data",44,71,10)
	 outline(print,1,1,"clear data",44,70,10)
	 print("clear data",44,71,4)
	 print("clear data",44,70,10)
	 
	 --tutorial
	 filltr(38,84,89,99,3,1+bool_to_num(menup==3))
	 rect(39,85,88,98,10)
	 outline(print,1,1," tutorial",44,90,6)
	 outline(print,1,1," tutorial",44,89,6)
	 print(" tutorial",44,90,4)
	 print(" tutorial",44,89,10)
	 
	 --challenge mode
	 filltr(38,103,89,118,5,1+bool_to_num(menup==4))
	 rect(39,104,88,117,13)
	 outline(print,5,1,"challenge",45,109,6)
	 outline(print,5,1,"challenge",45,108,6)
	 print("challenge",45,109,13)
	 print("challenge",45,108,6)
	 
	 --achievements
--	 outline(spr,2,0,223,115,105,1,2)
 end
 --by bonevolt
 if (g_time>60) print(to_tab_unp(",by bonevolt,80,121,7,"))
-- for i=0,7 do
--  if (peek(0x5ee0+i)>0) spr(240+i,i*10+2,2)
-- end
end

function drw_scene()
 --cls(1)
 --local txt=scene_text[scene]
 --print(txt,0,61,7)
 
 if scene==1 then
  cls()
  srand(7)
  rectfill(0,0,128,128,2)
  for j=10,108 do
	  local t,nn,i,jj,cc,n=0,0,0,j
	  if (cos(180/j)>.0001) nn=1
	  while (i<70) do
	   local clr=1
	   n=i
	   nn+=1
	   t+=1
	   i+=j/3
	   local clr1,clr2=(clr+nn)%2,(clr+nn+1)%2
	   --if t<3 then clr1,clr2=clr1*6+2,clr2*6+2
	   --else clr1+=5 clr2+=5
	   --end
	   rectfill(60+n,j+20,i+60,j+20,clr1*2+1)
	   rectfill(60-n,j+20,-i+60,j+20,clr2*2+1)
	  end
  end
  rectfill(0,40,128,50,1)
  rectfill(0,0,128,6,1)
  fillp(0x5faf.a)
  rectfill(0,12,128,18,1)
  fillp(0x5a5a.a)
  rectfill(0,50,128,56,1)
  rectfill(0,50,47,65,1)
  rectfill(111,50,128,66,1)
  rectfill(0,0,128,12,1)
  fillp()
  pal(3,1)
  for j=0,9,3 do
   if (j>3) pal()
   for i=0,128,6 do
    spr(224,i,24+j+rnd(4))
   end
  end
  for j=0,6,2 do
	  for i=-15,128,14 do
	   if i+j*2<32 or i-j*2>72 or j==0 then
	    if j<6 then
	    	spr(128,i+rnd(7),34+j+rnd(4),2,2,false,false,4,4)
	    else
	    	sspr(0,64,16,16,i+rnd(7),24+j+rnd(4),32,32)
	    end
	   end
	  end
  end
  if (messagenum==2) jackspr=11 jackf=true
  if (messagenum==5) jackf=false
  if (messagenum==6) clubspr=8 clubf=true
  if (messagenum==7) clubspr=14 clubf=false
  if (messagenum==8) jokerspr=10
  
  spr(130,75,60)
  palt(0,false)
  palt(11,true)
  xspr(jackspr,60,60,jackf)
  xspr(jokerspr,-2,63)
  xspr(15,27,60)
  xspr(12,20,70)
  xspr(13,40,70)
  xspr(clubspr,0,73,clubf)
 elseif scene==2 then
  camx2=16
  cls(1)
  checkered_floor(camx2-16,to_tab_unp(",16,5,0,-14,9,15,8,1,7,1,5,"))
  checkered_floor(camx2-16,to_tab_unp(",16,5,0,-14,9,15,9,1,6,3,5,"))
  checkered_floor(camx2-16,to_tab_unp(",16,5,0,-14,9,15,9,2,6,-2,13,"))
  rectfill(camx2+8,10,camx2+71,80,1)
  checkered_floor(camx2,to_tab_unp(",6,2,2,7,11,18,5,2,2,0,5,"))
  local maxx,wav=40,80
  for j=10,112 do
	  local clr=0
	  local t,nn,i,jj,cc,n=0,0,0,80-j
	  if (cos(wav/j)>.0001) nn=1
	  while (i<maxx) do
	   n=i
	   nn+=1
	   t+=1
	   i+=j/2
	   local clr1,clr2=(clr+nn)%2,(clr+nn+1)%2
	   if j>50 then
	    maxx=75
	    wav=170
     if j>50 then
		    clr1=clr1*8+3
		    clr2=clr2*8+3
		   end
	   else
		   if t<3 then clr1,clr2=clr1*6+2,clr2*6+2
		   else clr1+=5 clr2+=5
	   	end
	   end
	   rectfill(camx2+40+n,j+30,camx2+i+40,j+30,clr1)
	   rectfill(camx2+40-n,j+30,camx2-i+40,j+30,clr2)
	  end
  end
	 line(camx2+32,40,camx2-8,80,10)
	 line(camx2+48,40,camx2+88,80,10)
	 rectfill(camx2-22,11,camx2+8,80,4)
	 rectfill(camx2+6,11,camx2+8,80,2)
	 --rectfill(camx2+4,11,camx2+4,80,2)
	 rectfill(camx2+72,11,camx2+103,80,4)
	 rectfill(camx2+72,11,camx2+74,80,2)
	 for i=1,5 do
	  rectfill(camx2+70+i*6,11,camx2+70+i*6,80,2)
	  rectfill(camx2-26+i*6,11,camx2-26+i*6,80,2)
	 end
	 sspr(24,64,11,14,camx2+35,27)
	 
  palt(0,false)
  palt(11,true)
  xspr(jackspr,35,68)
  xspr(12,55,77,true,false)
  xspr(16,70,80,true,false)
  xspr(15,3,75)
  xspr(13,20,90)
  xspr(14,15,73)
  if messg_char[messagenum]==7 and lancex>90 then
   lancex-=5
   jackspr=11
  end
  if (messagenum>3 and lancex<128) lancex+=5 lancef=false
  palt(10,true)
  xspr(26,lancex,lancey,lancef)
  palt()
 elseif scene==3 then
  cls(bgc)
  if messagenum==10 then
   if messagetim==0 then
    for i=0,15 do flip() end
    fade_out(0) 
    for i=0,75 do flip() end
   end
   bgc=0
  elseif messagenum==15 then
   if messagetim==nil then
    if photo==nil then
	    for i=0,15 do flip() end
	    fade_out(16)
	    photo=0
	    photoy=32
    else
     if (photo==0) rectfill(0,32,128,95,7) flip()
     while photo<5 do
	     for i=0x2000,0x3000 do
	      local clr=peek(i)%16
	      for i=1,4-photo do
	       clr=fade_c[clr+16]
	      end
	      poke(i+0x2300,clr)
	      local clr=flr(peek(i)/16)
	      for i=1,4-photo do
	       clr=fade_c[clr+16]
	      end
	      poke(i+0x2300,peek(i+0x2300)+clr*16)
	     end
	     for i=1,8 do flip() end
	     memcpy(0x6800,0x4300,0x1000)
      photo+=1
     end
     rectfill(0,64,128,128-photoy*2,1)
	    memcpy(0x6000+photoy*64,0x4300,0x1000)
	    if photoy>0 then
	     photoy-=1
	     score_prog=0
	    else
	     if (score_prog<1000) score_prog+=1
	     if (mousep==1) score_prog+=10
		    chars_unl=0
		    for i=0x5e81,0x5e85 do
		     if (peek(i)>0 and score_prog/5+0x5e80>i) chars_unl+=1
		    end
		    battleswon=min(peek(0x5ecb)+peek(0x5ecc)+peek(0x5ecd),(score_prog-30)*3)
		    tilesexp=min(peek(0x5ece)+peek(0x5ecf)+peek(0x5ed0),(score_prog-60)*12)
		    itemsacq=min(peek(0x5eb2)+bool_to_num(peek(0x5e8d)==7)+peekbit(200),(score_prog-90))
		    totalperc=min(chars_unl+battleswon+tilesexp/20+itemsacq,(score_prog-120))
		    print("characters unlocked:"..chars_unl.."/5",6,68,13)
		    if score_prog>30 then
		    print("battles won:"..battleswon.."/60",6,76)
		    if score_prog>60 then
		    print("tiles explored:"..tilesexp.."/300",6,84)
		    --if score_prog>90 then
		    --print("bosses defeated:2/2",6,92)
		    if score_prog>90 then
		    print("items acquired:"..itemsacq.."/20",6,92)
		    if score_prog>120 then
		    compltxt="completion:"..totalperc.."%"
		    if (peek(0x5eca)>=2 and score_prog>230) compltxt=compltxt.."+"
		    if (peek(0x5eca)>2 and score_prog>240) compltxt=compltxt.."+"
		    print(compltxt,6,113,7)
		    if (totalperc>=100) poke(0x5ee2,1)
		    end
		    end
		    end
		    end
		    rectfill(0,0,95,5,0)
		    print("credit screen wip. sorry",0,0,7)
	    end
    end
   end
  end
	end
end
-->8
--draw functions
function draw_chain(c)
 local t=str_to_table(c)
 for i=1,#t do
 	draw_funct[t[i][1]](unpack(t[i],2))
 end
end

function draw_fade_out()
 for i=0,11 do
  flip()
  rectfill(0,0,i*13,127,0)
 end
 fade_in=1
end

function aux_text(txt,c1,c2)
 c1,c2=c1 or 1,c2 or 13
 rectfill(0,115,130,128,c1)print(txt,2,116,c2)
end

function tpx(x,y,h,v)
	local sc=band(pget(x,y),15)
 local val=mid(0,v-1+c_val[sc],5)
 pset(x,y,to_col[h+val*11])
end

--[[
function tspr(s,x,y,w,h,phue,pval,tr)
 local sx,sy=s%16*8,flr(s/16)*8
	stspr(sx,sy,w*8,h*8,x,y,0,0,phue,pval,tr)
end]]

function stspr(sx,sy,w,h,x,y,dw,dh,phue,pval,tr,fl)
 local func=tpx
	if (pval>=99) func=pset
 fl,tr=fl or false,tr or 0
 
	for j=0,h-1 do
		for i=0,w-1 do
	  local pc=peek(flr((sx+i)/2)+(sy+j)*64)
	  pc=(sx+i)%2==1 and flr(pc/16) or pc%16
	  --local pc=sget(sx+i,sy+j)
	  if (tr<99 and pc!=tr) or (tr>=99 and band(pc,tr-100)>0) then
	   if (fl) i=-i+w-1
	   if (pval>=99) phue=pc
	   func(x+i,y+j,phue,pval)
	  end
	 end
	end
end

function filltr(x1,y1,x2,y2,phue,pval)
	for j=0x6000+y1*64,0x6000+y2*64,64 do
		for i=j+flr(x1/2),j+flr(x2/2) do
		 clr1=to_col[phue+mid(0,pval-1+c_val[peek(i)%16],5)*11]
		 clr2=to_col[phue+mid(0,pval-1+c_val[flr(shr(peek(i),4))],5)*11]
		 poke(i,clr2*16+clr1)		 
	 end
	end
end

function xfunc(func,n,x,y,...)
 local n=sprv[n]
 func(n[1],n[2],n[3],n[4],x,y,n[3],n[4],...)
end

function xtspr(...)
 xfunc(stspr,...)
end

function xspr(...)
	xfunc(sspr,...)
end

function outline(draw,c,t,...)
 if c then
  --t:0 normal t:1 bold
  pal_all(c or outl)
  for i=-1,1 do
   for j=-1,1 do
    if ((i==0 or j==0) and i~=j) or t==1 then
     cam(i,j)
     draw(...)
    end
   end
  end
 end
 cam()
 cpal()
 pal(0,outl)
 if ch_pal then
	 for i=0,15 do
	  pal(i,to_col[ch_pal+c_val[i]*11])
	 end
 end
 ch_pal=nil
 if (monoc) pal_all(monoc)
 draw(...)
 cpal()
end

function pal_all(p)
 for i=0,15 do
  pal(i,p)
 end
end

function cpal()
	for i=0,15 do
		pal(i,i)
	end
end

function hlight_area(x1,y1,x2,y2,cc)
 local col=cc or 9+t22
 x2,y2=x2 or x1,y2 or y1
 rect(x1*16-8,y1*10+4,x2*16+7,y2*10+13,col)
end

function hlight_chars(algn)
 local cc=14+t22
	for ch in all (char) do
  if ch.algn==algn or algn==3 then
		 hlight_area(ch.tx,ch.ty,ch.tx,ch.ty,cc)
		end
 end
 if algn==4 then
  hlight_area(5,1,7,7,cc)
 end
end

function fade_out(c)
 for i=1,5 do
  local n=0
  for j=0,63 do
   for k=0+c*2,127-c*2 do
    function fd(j)
    	pset(j,k,fade_c[pget(j,k)+c])
    end
    fd(j+c*4)
    fd(127-j-c*4)
   end
   n+=1
   if (n%32==16) flip()
  end
 end
end
__gfx__
bbbb0b00b0bbbbbbbbb00000bbbbb000000000000000777770000777000000777770777007770077777707777770000077700007777700007777777000777777
bbbbb0000bbbbbbbb00888880bbbb000000000000000777770000777000007777770777007770777777707777777000077700007777777007777777007777777
bbbbbbbbbbbbbbbb0288888890bbb000000000000000777770007777700077777770777077707777777707777777700777770007777777707777777077777777
bbb00000000bbbbb0888888880bbb000000000000000777770007777700077770000777077707770000007770777700777770007770777707770000077700000
bb0aaaaaaaa0bbb028888888890bb000000000000000777770077777770077700000777777007777770007770777707777777007770077707777700077777700
b0aaaaaaaaaa0bb028888888890bb000000000000000777770077707770077700000777777000777777007777777707770777007770077707777700007777770
b0aaaaaaaaaa0bb022888888890bb000000000000007777770777707777077700000777777000077777707777777077770777707770077707777700000777777
b0aaaaaaaaaa0bb022228888800bb000000000000777777770777777777077770000777077700000777707777770077777777707770777707770000000007777
09aaaaaaaaaa90bb022222888220b000000000000777777700777777777077777770777077707777777707770000077777777707777777707777777077777777
0aaaaaaaaaaaa0bb0222288882220000000000000777777000777000777007777770777007777777777007770000077700077707777777007777777077777770
b018181818100bb02228882888220000000000000777770000777000777000777770777007777777770007770000077700077707777700007777777077777700
b081818181870b02212888888820000000000bbbbbbb0b0bbbbbbbbbb0000777700777779990bbbbbbbb00000bbbbbbbbbbbbbb00bbbbb000000000000000000
b018181818170b0a212288888880b00000000bbbbbb010100bbbbbbbb00077007707777aa400bb00bbb05555d0bbbb000bbbb00440bbbb000000000000000000
bb0000000000bb07a00222228aa0b00000000bbbb000551510bbbbbbb00077007707700a7940b0110b0d11111d0bb02230bb033340bbbb000000000000000000
bbb0000000bbbbb00bb00000a70bb00000000bbbb0511551550bbb0bb00077007707770a0794015550550000050b02223300333340bbbb000000000000000000
bbb00bbb00bbbbbbbbbbbbbb00bbb00000000bbb0015515ddd50b070b00077007707700000a9015d50111555d10b0224333133300bbbbb000000000000000000
bbbb0000000bbbbbbbbbbbbbbbbbb00000bbbbbb0515d5ddddd0b060b0000777700770000000b0551001d111110b044033333330bbbbbb000000000000000000
bbb099949990bbbbbbbbbbbbbbbb0aaa9a0bbbbb05555ffffff0066d00000000000000000000b0155110555550bbb00b033333310bbbbb000000000000000000
bb09777777790bbbbbbbbbbbbbb09aaaaaa0bbbb015dfffffff005d500000000000000000000bb0555115dd510bbbbbbb03943330bbbbb000000000000000000
bb09767767690bbbbbbbbbbbbbb0aaaaaaa0bbbbb05ff555ff50b0d0b0000000000000000000bb0155155dd5110bbbbbb037a3330bbbbb000000000000000000
bb09707767090bbbbbbbbbbbbbb09aaaaaa0bbbb055ff701ff00b280b0000000000000000000bbb01515dd551500bbb00388872300bbbb000000000000000000
b049777667790bbbbbbbbbbbbbb0982aaaa0bb8bb054effffff08820b0000000000000000000bbbb0115dd511510b0033777787233000b000000000000000000
b044977997940bbbbbbbbbbbbbb0928a44960b8880888effff202050b0000000000000000000bbbb0115dd511510066310770e72333660000000000000000000
bb0299999990bbbbbbbbbbbbbb000442aa4208888822888888800050b0000000000000000000bbb00115dd51110b067a1777778e80a760000000000000000000
b028499999480bbbbbb00bbbb0644442aa220b8888dd288888555ff0b0000000000000000000bb011115dd1110bbb09131777d88e8890b000000000000000000
0822244444220bbbbb05500bbb044242aa40bbbb8dd5dddddd155ef0b0000000000000000000b01155111155110bbb00131122d80000bb000000000000000000
077122820770bbbb0055dd50bbb002244a0bbbbb0ff0444444000050b0000000000000000000b0155dddddd5510bbbbb00000000bbbbbb000000000000000000
077000000000bb0044dd55560bbbb012220bbbbb0ef011111110b050b0000000000000000000bb05dddddddd50bb000000000000000000000000000000000000
b0000000000b004400055560bbbbb020020bbbbbb00111001110b050b0000000000000000000bbb0000000000bbb000000000000000000000000000000000000
bbbb000bbbb04400bb06600bbbbbb00bb00bbbbbbb0442002440b050b00000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbb00bbbbb00bbbb000000000000bbbbbb000bb000bbb0ba9933333301300310333399aa9900000022888882200099aa9933333333333333333399a
00000000000000000000000000000000000000000000000000000000933333333000000003333339900000228888888888800009933333399999999999933339
bbbb00000bbbbbb0000000bbbbbbbbbbb00000bbbbb0000000000000933333333100000013333339900008888888888888882009933399999999999999999339
bb00288820bbbb099949990bb00bbbbb0aaa9a0bbbb0000000000000333333333300000033333333000288888888888888888200339999999999999999999933
b0288888820bb097777777900560bbb0aa777770bbb0000000000000333333333333333333333333002888888888888888888820334999999999999999999933
b088aaaaa80bb0977776779055d60bb0a77776700bb0000000000000333333333333333333333333008888888888888888888880344999999444ffffff449993
028a66666a20b0970776709055d60bb09707760040b0000000000000333399aaaaaaa93999aa9333088888aaaaaa888888888882344449ff77777777777ff993
0896077702900497776677905d560b04977766700400000000000000339aaaaaaaaaaaaaaaaaaa93088aaaaaaaaaaaaa8888888234444f777777777777777f93
089ee777e2900449779979404d60b022d677776004000000000000003aaaaaaaaaaaaaaaaaaaaaa98aaaaaaaaaaaaaaaaa888882344447777777777777777793
08867777680bb02999999904000bb0244dd66d0077000000000000009aaaaafff77777f77fffaaaaaaaaa9d6666d99aaaaa88882344447777767777f77677799
b0888a88890b0284999994040bbbbb04477dd4447700000000000000aaaa9f77777777777777f9aaaa9d66666666666d9aaa8822344447710077777f77100799
b088a7788a700877444442770bbbbbb0477564220400000000000000aaa9f7777777777777777f9a99d667777777776669aaa222344447770077777f77700799
028896688960b067282820770bbbbbb0225652000400000000000000aaaf777767777777777767fa91d6d0077777d00d669aaa22444447722577777f77225799
02229298890bbb0000000000bbbbbbbb022220b040b0000000000000aa9f77777d777777767d77f921d670077777700766d9aa22994447777777777f77777799
02222928820bbb00000000bbbbbbbbbb020020b00bb0000000000000aa9f7775117777777675117921d722177777221776699aa299944f777777ffff77777f99
b0022222200bbb00bbbb00bbbbbbbbbb00bb00bbbbb00000000000009a477776007777777676007421deee7777777eee766d9aa2999949777777999997777999
bbb000000bbb00000bbbbbb0000bbbbbbbb000bbb000bbb0000000009a477771157777777d71157491d777777777777776dd9a229999499f77f9999999ff9999
bbbb0b00b0bbbbbbbbbbb00555d00bbbbb031100088e0bb0000000009a477777777777777d777774921677777777777766d99222999449999999444499999949
bbbbb0000bbbbbbbbbbb0d111111d0bbb031131188e880b0000000009a4f7777777777777d7777f4921d6677777777666dd94222444449999999999999999941
bbbbbbbbbbbbbbbbbbbb0500000050bbb01131131e88e0b0000000004a4677777777776ddd7777644911d66666666666dd992222122444999999999999999942
bbb00000000bbbbbbbbb010555d010bb0910113777808900000000004a46f777777dd55557777f640499dd66666666ddd9922211222444999999999999999442
bb0aaaa9aaa0bbbbbbbb0155555550bb07a013777770a70000000000aa2d6ff7777777777777f6d9900499999999999944221119922244499999999999999449
b0aa777777aa0bbbbbbb01ddd55dd0bbb00017e0770000b00000000099888181000d666d000111e9900022244444222222211119988844444999999999994489
b0a77777677a0b00bbbb0151155000bb077017877770bbb000000000999818880006d6d60008199aa9922222222222222222299aa9984444449999999944499a
b0a70777670a00770bbb01dd155010bb07733178880bbbb000000000a9955555aaaaaaaa5555599aa9933333355555551110399aa99331111000000088ff899a
09a77776677a07d70bb05ddd511d100bb033331110bbbbb00000000095555aaaaaaaaaaaaa55555993335dd3355555551110333991331111333300ee8ee888f9
0a977667777a7d60bb0511dddddd100bbb013399000bbbb0000000009555aaaaaaaaa9aaaaa5555993315dd3355555551110313993311133311112e88e88fee9
b01818176197d70bb0dd515ddddd5010b03333a71770bbb0000000005555aaa77777aaaaa777555533115dd5555555551110013313111331111133e8ee88e888
b0817716716a70bbb0dd515ddddd1110044333331770bbb000000000555aaa7777777a9a7777555533115dd555555555111001333311331111333188e88ee88e
b0187717117690bbb05511155551110002240133000bbbb000000000555aaa77777777777777755533115dd555555555111001333103311133311128e88e88ee
bb00000000000bbbbb01155111115510b02203330bbbbbb000000000559a9777777777777777755533115d115555555511100133301311133116777688e822e2
bbb0000000bbbbbbbb0155dddddd5550bb002330bbbbbbb000000000559aa77777777777777775553311111dd55d55555511113331110131d777777776e22282
bbb00bbb00bbbbbbbbb05dddddddd50bbbbb04440bbbbbb0000000005599a777777677777667755533111d555555555555551133101013167777777777722202
00000000000000000bbb0000000000bbbbbbb000bbbbbbb0000000005599a777710067777610055533111d555555555555551133a00111d777777777777d200a
0000bbbbbbb30000ffffffff00000a0000000000000000000000000052977a77770077777670055533111d551111155555111133901011677100777771002009
003bbbbbbbbbbb30444444440000a9a000000000000000000000000022977777711177777611155533111d110000155555000133000111777700777777002000
0bbbbbbbbbbbb3334424244400a09990a000000000000000000000002447777777777777767775553311550000001555550000330011167ee111777771112000
3bbbbbbbbbb3333342242424009988899000000000000000000000004449677777777777767765553311550000001555550000333001067eee77777777762000
33bbbbbb3b3b313344444444a098888890a0000000000000000000004444d667777777776677d5553311555555511555550111333001107787777777777d0000
3333b3b3b3331313444444449a8882888a900000000000000000000044444d67777776666676555533115555555115555501113333000167e877777777780000
31333b33313131310002200009882888890000000000000000000000444444d67777666677755555331155555551155555011133333310177e8e77777e810000
13333333131311110004400009882888890000000000000000000000244444466777777777442555335ddd555551111111011113133331017778888888100000
1131313131311311000000000948888849000000000000000000000022244444d66777776444445535ddddd55551111111011551113333301677777761000000
1111131311111111000000000a9288829a000000000000000000000024442445d5d66664224444445dddddd55551555555115dd5111333330111111100000000
011111111122111000000000a849222948a0000000000000000000004444444d5ddd5224224444445ddddddd555dddddddd5dddd111133333333331000000000
0011122222220000000000009928888829900000000000000000000094444425d5d5d4442244444995ddddddddddddddddddddd9901113333339a93300000769
0000022222120000000000000999999999a0000000000000000000009444442ddd5d24442222444995ddddddddddddddddddddd99001133333a7aa9300006779
00001221211210000000000009000000090000000000000000000000a994422dd5d522422222299aa99dddddddddddddddddd99aa991333333aaa9433103799a
00000212211122000aaaaa00aaaaa00aa00aa0aaaaaa0aa0aa00aa0aa00aa0aaaaaa000000000000a9930100055111111333399aa9900000000000000000099a
0000200121000000aaaaaa0aaaaaaa0aaa0aa0aaaaaa0aa0aaa0aa0aa00aa0aaaaaa000000000000933301551555551555133339900000000000000000000009
0000000550000000aaa4440aa444aa0aaa0aa044aa440aa0aaa0aa0aa00aa0aa4444000000000000933301555515555155510339900000000000000000000009
0022229dd9222200aaa0000aa000aa0aaaaaa000aa000aa0aaaaaa0aa00aa0aaaa00000000000000331101155551555515551033000000000000000000000000
02222bfddfb22220aaa0000aa000aa0aaaaaa000aa000aa0aaaaaa0aa00aa0aaaa00000000000000331111155555555555555103000000006777600000000000
2222bbffffbb2222aaa0000aa000aa0aa4aaa000aa000aa0aa4aaa0aa00aa0aa440000000000000033015551155555dddddd5513000000677777776600000000
2223bffffffb3222aaaaaa0aaaaaaa0aa0aaa000aa000aa0aa0aaa0aaaaaa0aaaaaa000000000000330155d5555dddddddddd513000067777777777760000000
2233ffffffff33224aaaaa04aaaaa40aa04aa000aa000aa0aa04aa04aaaa40aaaaaa000000000000330055dd55dffffffffff553000077666667777776000000
22bf7ffffff7fb220444440044444004400440004400044044004400444400444444000000000000311015555fffffffffffff53000677777777777776600000
0bffffffffffffb0aa00aa0aaaaaa0aa0000aa00000aaaa0000aa000aa0000aa0aaaaaa00000000031101555ffffffffffffff23000676666666777777600000
0bffffffffffffb0aaa0aa0aaaaaa0aa0000aa0000aaaaaa00aaaa00aaa00aaa0aaaaaa000aa000031555555ffffffffffffff43000667777777766777600000
09bffffffffffb90aaa0aa0aa44440aa0000aa0000aa44aa0aaaaaa0aaaaaaaa0aa4444000aa00003155d555ff555ffffffff553000dd67776dddd6777600000
099bffffffffb990aaaaaa0aaaa000aa0aa0aa0000aa00440aa44aa0aaaaaaaa0aaaa000aaaaaa0033555dd55f55555ffff55553000611ddd111167776600000
0999bffffffb9990aaaaaa0aaaa000aaaaaaaa0000aa0aaa0aaaaaa0aa4aa4aa0aaaa000aaaaaa0033155d5f5f55555ffff55553000611676111177776600000
00999b6ff6b99900aa4aaa0aa44000aaaaaaaa0000aa04aa0aaaaaa0aa0440aa0aa4400044aa4400330155fffff7600ffff60743000611676111177766600000
000000ffff000000aa0aaa0aaaaaa0aaa44aaa0000aaaaaa0aa44aa0aa0000aa0aaaaaa000aa0000333015fffff7101ffff117e300061177711117666d5d0000
0000099ff9900000aa04aa0aaaaaa0aa4004aa00004aaaa40aa00aa0aa0000aa0aaaaaa0004400003300115fffffffffffffff4300077711777777d6d55d6000
0000011551100000440044044444404400004400000444400440044044000044044444400000000030011112efffffffeeffff3300007711677776dd5d66d660
00000000000000000000000000000000000000000000000000000000a9926222777777772226299a330002224eff4ffffffff433000007777776dd55166d6777
000000000000000000000000000000000000000000000000000000009222662777777777726622292330088224fff4444ffff333000007777777661d66666676
000000000000000000000000000000000000000000000000000000009222667777777777776622292211282882efffffffff283300000676767661d55d66dd5d
00000000000000000000000000000000000000000000000000000000252266677777777776662252928128888824fffffff2888990000660660665d666666669
0000000000000000000000000000000000000000000000000000000025d266677777777776662d5298821288888824fff42882899000000000005565d666dd69
0000000000000000000000000000000000000000000000000000000025dd6667777777777666dd52a9981228822888888888299aa99000000000dd66666dd99a
0000000000000000000000000000000000000000000000000000000025dd6666777777776666dd52000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000025dd6666666666666666dd52000000000000000000000000000000000000000000000000
0bbbbb300024210000000000660660660000788000282100bb555dbb25dd6666555555555666dd52aaaaaaaa000000000bbbbb306606000e2000606600aaa900
bbbbbbb3244422210000000065d55d560000682028882221d111111d25dd66dddddddddddd56dd52a88bb88a00000000bbbbbbb36d56008e220065d60a7aaa90
bbbbbb3344442222000000001dddddd1000060008899992250000005225dd5ddd6666666ddd5d522abb88bba00000000bbbbbb33d5d508e882205d5da777aa99
bbbbb3b344494222000000006dddddd6000060008844442210555d01225d5dd6667777766dddd522aaaaaaaa00000000bbbbb3b3665d5ee88221d566aa77aa49
3b3b3b33499664420000000066d66d66000e80008e444482b155551b225ddd666777777766ddd52293311339000000003b3b3b331dd55de882515dd19aaaa949
033333309677776400000000d515515d008e8200ed6666d8b511115b2225dd6677777777766dd222933113390000000003333330565d51ddd551d56599aa9449
0004200007722770000000001152251104ee824007722770bdd55ddb2225dd6677777777766d222291133119000000000004200056d555d155215d6509494490
0004200007744770000000000554455098ee882907744770bb1111bb22222d6677777777766d22229999999900000000000420005d5d5dd55541d5d5089999c0
03333310026626600012144000000000aee8882a008000000000000022222d667777777776d2222200000000000000000000000066d551dd55155d660888ccc0
3333333162662662122214410000000007e888a00000802000000000222222d67777777776d22222000000000000000080008000d55dd511115dd55d0888ccc0
333333116222222d22221221000000000da7aa5000289800000000002222225dd7777777dd2222220000000000000000880088006dd6566556656dd60888ccc0
3333313126626d2d22242111000000000d6616d0028aa92000000000222266d5dd66666dd5d6222200000000000000008880888066565115511d6d6608800cc0
131313112dd2dd21244dd221000000000d16d6d0089a7a80000000002266766d5ddddddd5d6666220000000000000000888288821151115115111511080000c0
01111110066666604d6666d20000000005d666d008a779800000000096777766d55ddd5d66777769000000000000000088208820511551155115511500000000
000420000662266006611660000000000d6226d02449a442000000009777777766dddd6677777769000000000000000082008200155111511511155100000000
00042000006446000662266000000000006446000024420000000000a9977767777777777767799a000000000000000020002000511550000005511500000000
0000000000000000000000000000000000000000000000000000000033a7aa33000000000c7ccc000efeee000a7aaa000077776000776600088888a807878787
000000000000000000000000000000000000000000000000000000003942249300000000cc7cccc0eefeeee0aa7aaaa077777760077766600888a8880777e777
000000000000000000000000000000000000000000000000000000003a7a942300000000cdddddc0e88888e0a99999a0777777667777666608a8888807878787
000000000000000000000000000000000000000000000000000000007a7a942200000000dd11ddd088228880994499907777dd66777dd6660eeeeeee06666666
00000000000000000000000000000000000000000000000000000000a3a9923400000000001ddd0000288800004999007dddddd67dddddd6022222220ddddddd
00000000000000000000000000000000000000000000000000000000423a43240000000000ddd0000088800000999000ddddddd6dddddddd024222420d8d8d8d
00000000000000000000000000000000000000000000000000000000333943330000000000ccc00000eee00000aaa0000ddddddd0dddddd0022242220dddeddd
0000000000000000000000000000000000000000000000000000000033a794330000000000ddd000008880000099900000ddd00000dddd00024222420d8d8d8d
__gff__
0000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
333333333333333333333333333333333333333333333333333355553333333333333333333333333333535533333333333333333333333333333333333333333333333333333333333333333333939a999933333333333333335355333333333333333333333333333353553333333333333333333333333333333333333333
33333333333333333333333333a3aaaaaaaa9a33333333333333535533333333333333333333333333335355333333333333333333333333333333333333333333333333333333333433333393aaaaaaaaaaaa3a4344444433333355353333335555353333333355555553553333333333333333333333333333333333333333
333333333333334344333333a4a9aaaaaaaaaaaa444444543433335535335355555555333353535555555555333333333333333333333333333333333333333333333333333333434433333399aaaa7a77a7aaaa2a22424425333353553355555555353333553555555555353333333333333333333333333333333333333333
333333333333334344333343a9aa7a777777a7aa2a22224425323353553353551511113333553513111151353333333333333333333333333333333333333333333333333333334344333343a9aa77777777a7aa9a22224425323353553333131111113133553511111111353333333333333333333333333333333333333333
3333333333333344443333d3a97777777777a79aaa242244253233535535331111111131335535111111113533333333333333333333333333333333333333333333333333333344343333d3767777777777a7aaaa24224425313333553533111111113133553511111151353333333333333333333333333333333333333333
3333333333333344343333d37677776777777aa79a244254223133335535331311111131535535113133553533333333333333333333333333333333333333333333333333333344343333d376777756117777779a24542522333333555533333311113153553511313355353333333333333333333333333333333333333333
3333333333333344343333537d777777007777779a2222222232333353553333331111315355351131335555333333333333333333333333333333333333333333333333333333443433336360777717117677679924222244223333535533333315111153551511313353553333333333333333333333333333333333333333
333333333333334434333333617777777777779699222244442433333353333353551111555511113333535533333333333333333333733733333333333333333333333333333344343333336d777777777767964972774744243333335335dddd5d151111111151553353555533333333333333333373773333333333333333
333333333333334434333333d36666777777776729777777442433335555d5dddddd55111111115555dd5d555535333333333333333363763733333333333333333333333333334434333333d3667677777777676477777744323353555555dddddd5d1511115155dddddd555555353333333333333363663733333333333333
33333333333333443433333344647777777777d664777777323333555555d5dddddddd555555d5dddddddd5d55553533333333333333d36d763333333333333333333333333333443433333344d466767777674d44777767333333555555dddddddddddd5555dddddddddd5d55553533333333333333d56d7633333333333333
33333333333333443433334344446d7777674644426d6636333353555555d5dddddddddddddddddddddddd5d55333344949999994954d5dd76333333333333333333333333333344343333444444446d66d624224244444444335555555555dddddddddddddddddddddddd355353449999999999999944dd7633333333333333
33333333333333443433334444443333444422224244444444445555555555d5dddddddddddddddddddd5d333345999999999999999999d4753333333333333333333333333333444433434444443333222222224444444444444455555553dddddddddddddddddddddd35333394999999999999999999593533333333333333
33333333dddd3d434444444444443333333333434444448888884854555533dddddddddddddddddddddd33335399999999999944999999993333333333333333333333dddddd3d434444444444343333333333434484888888888848333533dddddddddddddddddddddd333343999999999944ffff4f94993333333333333333
3333d3dddddd33434444444444333333333333448488888888888888383333dddddd0dd5005dd03ddddd333343949949ffff77777777ff9434333333333333333333d3dd333333434444664434333333333343448888888888888888883233dddddd0d000000d0dddd3d3333434444ff7777777777f7779f4433333333333333
3333333333dddd3344446646333333333333448488eeee88888e8888882833d3dddd1d000000d1dddd3333334344f47f777f77777f74779f453433333333333333333333dddddd33444466663333333333333388eeeeeeeeeeee888888243333d3dddd000000dddd3d3333334344f477774777777f5711976576673333333333
333333d3dddd33334444646633333333333383eeeeffffafaaeaee88882433333333d3dddddddddd333333335344f477157177777fd700976977773633333333333333d3dd33333346446466333333333333e4feffffffffffafea8e482433333333333333333333333333335544f4770d7077777f275247d977773633333333
3333333333d3dddd43446436333333333333f8fff677776f1d11af8e4834333399aaaaaa9a9399aa393333535445f477227577777f777747d9766734333333333333333333dddddd334344363333333333339f6d777777f7d611a18a443233a9aaaaaaaaaaaaaaaaaa39334359459477777777777f777749d46d564433333333
33333333d3dddd3d333343333333333333332f76767777776f1df18a4432a3aaaaaaaaaaaaaaaaaaaa9a3393994494997777df44f47f774921d55d453433333333333333d3dd3d33333343343333333333332fd6527677d6521d11aa4433a9aaaaff7f77777ff7ffaaaa3393999994997ff7999999f9f7591112115535333333
3333333333333333333333e43e33333333332f7f00777777001611af2433aaaaf9777777777777779faa3a4399994499f99f49112199995421281122333333333333333333333333333333ee3e33333333332f2f1277772712d611af2493aa9a7f77777777777777f7a93a539449449999991411229999152218313333333333
3333333333333333333333333333ee3e33332fee7e777777eede119f2293aafa777776777777777776af3a3345544594999924229299991522123333333333333333333333333333e33e333333e3eeee3333f3ed7e777777eed6119f1293aaf97777d777777767d7779f3a331111554499999999999949111111333333333333
3333333333e3ee33e33e333333e3eeee3e33336e7777777767d6a1493193aaf9775711777777675711973a1311221265666699999999592111313333333333333333333333eeee3333333333777777e73ee33eef7f7777776fadfa243193a974776700777777676700473a111122127677679999999914221133333333333333
3333333333eeee33338888e87777777744eefff46e7f77f7faff4f123399a974771751777777d71751471a2122886877776799999954111231333333333333333333333333eeee33888888e8ee77777788f48e8effffffffff89243193aaa974777777777777d7777747292211227d7777674444151152313333333333333333
6666663633ee3e8388888877e77e77e7eeee8ee4e8eeeeee88241231a92aa9f4777777777777d777774f291911d277777767dd1d11221533333333333333333366666666363333888888887777ee766687feef888428ee8e22121133a94aa4647777777777d6dd7777464949116d777d77d66621121131333333333333333333
66666666363333888888ee7e77e777e7eeeefeeeeeee7fe748221133a92aa4647f7777d75d557577f746992ad167d777671dd621121131333333333333333333776766dd3d33838888f8ff7f77e77e7e77e7feeee8ff7fe78e241731a4aaaad2f67f7777777777776f2daa247d677d77d6121d22121133333333333333333333
7777dddd3d33838888f8ffef7777ee7777f7ffef8effffef7e28223193aa9a88181800d066d60010111e441276d777678d2822882811333333333333333333337777ddddedee838888f8ef887e77777777777777ee7777ff7e48771233441481818800606d6d008081ee2161767d77d622282288253133333333333333333333
66d7dddde3ee8388888888eeee77777777777777e7feffff7e7767173133121811180060d666008818d8446dd66666152112112211013333333333333333333366dddddd33ee836876888888fe7f777777777777777e7777776788271123e528811100606d0d0081112194146d66561011000000111130333333333333333333
66dddddd33338377d68d8888ffefee7f77777777778e7777678872221213dd5e227707d6660600111282a42a6dd6010011010000001100303333333333333333d6dddddd33337377d68d8888f8eefeffff77777777ee67f7ee7722222231eddd6577776d6d0d2021222196a7141d000010010000000000003333333333333333
d6dddddd33337667dd8d888888e8ffffeffe7f777fe777ffee8e48222232eeded4777766d606201213116d799a04000010313303000000003333333333333333dddddd6d663367d6dd8d88888888ffffeeee7ff777e7ff77ef8e28182232e3ed5876776d6d0021313311d1964902000010303333000000003333333333333333
dddddd66666666dddd8d88888888f8ffeefe77ff77e7ff77ef8e8824213333dd526d065ddd000133333333332203000001333333030000303333333333333333dddd6d666676d6dddd8888888888888888f877ff77e7ff77efee8882123333131101000000003033333333333303000133333333330030333333333333333333
dddd6d666666dddddd88888888888888887ff7ff77e7ff77efee8848183333131100000000003033333333333303000033333333333333333333333333333333dddd66666666dddd8d88888888888888887ff7ff77e7ffefeeee8828183333131101000000000033333333333333000033333333333333333333333333333333
dddd666666d6dddd8888888888888888887ff77f77e7ffffeeee8818323333331101000000110030333333333333033033333333333333333333333333333333dd6d666666dddd6d888888888888888888ffff7f77fe77f7eeee8e38333333331101303333110130333333333333333333333333333333333333333333333333
dd66666666dd6d6686888888888888888888ff7f77fe7777eeee8e38333333131101333333100130333333333333333333333333333333333333333333333333dd666666666666668688888888888888888888f8efff7777eeee8e33333333111130333303100033333333333333333333333333333333333333333333333333
__sfx__
0002000013631146311963128631366313c6313e6313f6313f6413f6413f6213e40106001080010c0010b00110001170011b0011d001220011a0012300128001240012b0012d0013000132001340012360124601
0002000022610226202263020630206401e6501c65019650146600f6600a660096700a67009670076700667005670056700567004670046600466004660036600365003650036500365003640026400264002640
000100001214213152151621717218172171721417212172101720f1720f1720f1721017211172121721417216172181721b17221172261622b1622f152311523314235142241020010226102001022910200102
0010000020322203322032220312203022030220302233021d3021c3021b3021a30219302183021730216302153021430213302123023e30225302253022530225302253020d3020a30209302073020730206302
000200001b0701e070200702107021070200701d0701a0701b57021570295702e5701a50020500125001850023000280002c0002e0002f000300002e0002b000270002b50032500365002a3002a3002830026300
00020000106700e6700c6700b67009670122701b2701c2701b27018270142701127012270172701e270222702727027260272602a250370503a0403a040000000000000000000000000000000000000000000000
00020000085700c5700e5701057011670146701467014670136701367013670136701367013670136701467017670186601b66021650266502d6402f640316303263035620386203850038500385000000000000
0002000026170201701c1701817015170121700f1700b1700b1700917009170071700717006170061700517005170041700417005170051700517006170051600616005160021500215001150011400114001140
00100020280422804228042260422604226042240422404229042290422904228042280422804226042260421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f0421f042
0110000028032280322803226032260322603224032240322b0322b0322b032290322903229032260322603228032290322803229032280322803228032280322803228032280322803228032280322803228032
01100020103431060010643103431000310343106430c000103430c000106431034310000103431064310343103430c00010643103430c000103431064310003103430c00010643103430c000103431064310643
0120002115022180221c02215022180221c022150221802215022180221c02215022180221c022150221802215022180221c02215022180221c022150221702213022170221a02213022170221a0221302217022
0120002009412094120941209412094120941209412094120c4120c4120c4120c4120c4120c4120c4120c41211412114121141211412114121141211412114120e4120e4120e4120e4120e4120e4120e4120e412
01101820000000c00000000000000000000000000000000000000000000000000000280402604024040260402804000000210400e000210300000021020000002101000000210100000021010000002101000000
010800200037309303093030930309303093030037309303003730900309003090030967309003096030960309000090000037309300003730900009000090000967309000090000900000373090000900009600
014000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000202973524735217352973524735217352973524735217352973524735217352473521735297352173528735247352173528735247352173528735247352173528735247352173524735217352873521735
018000002b02228022230222102229022280222602226022280222b0222402221022290222b0222602226022280222b02226022240222b0222d02229022290222d0222f022300221f02221022230222402224022
018000002450123501215011f5011d5011c5011a50118501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001a6701a671016710167101671016710167101661016510164101631016210160101601016010160101601016010160101601043010430104301043010230102301023010230100301003010030100301
01090000152501525013250132501025010250152501525013250132500f2500f250152501525013250132500e2500e2500e2500e2500e2500e2500e2500e2500e2500e2500e2500e2500f2500f2500f2500f250
01120020092400c2400e240092400c2400e2400f24009240092400c2400e2400c2400f2400e2400c24009240092400c2400e240092400c2400e240092400f2400f2430f2400e2400c2400f2400e2400a24008240
010900200035300303003530035318650000000035300353003530030000353000531865000300003530030300300003000035300353186500030000353003530035300300003530035318650000001865018650
002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01120000284302843028430264302643026430244302443029430294302943028430284302843026430264301f4301f4301f4301f4301f4301f4301f4301f4302143022430214302243021430214302143021430
011200002843028430284302643026430264302443024430294302943029430284302843028430294302943028430284302843028430284302843028430284302c4302c4302c4302c4302c4302c4302c4302c430
011200002d4302d4302d430294302943029430264302643023430234302343023430234302343023430234302b4302b4302b43028430284302843024430244302143021430214302143021430214302143021430
0112000029430294302943028430284302843026430264302b4302b4302b430294302943029430274302743028430284302843028430284302843028430284302c4302c4302c4302c4302c4302c4302c4302c430
0112002005450094500c45005450094500c4500545009450074500b4500e450074500b4500e450074500b45004450074500b45004450074500b450044500745005450094500c45005450094500c4500545009450
0148000027400244302843028400234001f43021430234002440024430284302840026400294302843026400244002443028430284002140023430244301f4002940029430284302840026400264302843028430
011400200e4400c440104400c440114400c440134400c4400e4400c440104400c440114400c440134400c44010440054401144005440134400544015440054400c440074400e4400744010440074401144007440
015000203012230122301222f122301223012230122321223012230122301222f122301223012230122321223412234122341223212234122341223412235122341223412234122321223412234122341222f122
01140020247600c760187600c7601a7600c7601c7600c760187600c760187500c750187400c740187300c73005760117601f7601176021760117601f760117602476013760237601376021760137601f76013760
012800000040300403000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114002000273003033c6133c6133c630000003c6133c61300273003033c6133c6133c630000003c6133c63300273003033c6133c6133c630000003c6133c61300273003033c6133c6133c630000003c6303c630
011000202b0521ff002b0521f80029052000002b052000002b0520000029052000002b05200000290520000026052000002605200000240520000026052000002605200000240520000026052000002905200000
011000202b052000002b0520000029052000002b052000002b0520000029052000002b052000002e052000002d052000002d052000002b052000002d052000002d052000002b052000002d052000002905200000
0120002007332133321f33207332133321f33207332133322133209332153322133209332153322133209332113321d33205332113321d33205332113321d332023320e3321a332023320e3321a332023320e332
011400000e352113520e352153520e352113520e35215352103521435210352173521035214352103521735211352153521135218352113521535211352183521335217352133521a3521335217352133521a352
011000200037321203003731f203246731f203003731f203003732120300373212030037321203246732120300373003030037300303246730000300373000030037300003003730030300373000032467300003
011000202605216322260521632226052163222605216322260521632226052163222905216322290521632226052163222905216322290521632226052163222905216322260521633229052290522b0522b052
0110002030545245452f5452454530545245452f5452454530545245452f545245453054524545325452454532545265453054526545325452654530545265453454528545325452854534545285453554528545
0110002035545295453454529545355452954534545295453554529545345452954535545295453454529545375452b545355452b545375452b545395452b5453b5452b545395452b5453b5452b5453c5452b545
011000200037300000000000000000000000000037300000006730000000000000000000000000006730000000373000000000000000000000000000373000000067300000000000000000673000000067300673
01200000357423574235742357423474232742307422f742377423774237742377422f7422f7422f7422f74234742347423474234742347423574234742357423274232742327423274234742347423474234742
01200020307423074230742307422f7422d7422f7422b7422d7422d7422d7422d7422f7422f7422f7422f7423274232742327423274235742377423474235742327423274232742327422f7422f7422f7422f742
002000000c3000c3000c30010300103001030013300133000c3000c3000c30010300103001030013300133000c3000c3000c30010300103001030013300133000c3000c3000c3001030010300103001330013300
0110002000222002220c2220c22200222002220c2220c22200222002220c2220c22200222002220c2220c22200222002220c2220c22200222002220c2220c22200222002220b2220b22200222002220b2220b222
012000202b0522b0522b0522d05226052260522605226052260522b0522b0522d052260522605226052260522905229052290522b052260522605226052260522605229052290522b05226052260522605226052
011000201542015420154201342013420134201542015420154201342013420134201542015420134201342013420134201342011420114201142013420134201342011420114201142013420134201142011420
01080000214202142015420154201f4201f42015420154201d4201d42015420154201c4201c42015420154201a4201a4201542015420184201842015420154201742017420174201742017420174201842018420
011000200000200002290222902228022280222402224022290222902229022280222802228022240222402221022210222102221022210222102221022210222302223022230222302223022230222302223022
001000202d32028320213202d32028320213202d32028320213202d32028320213202d3202832021320283202b32028320213202b32028320213202b32028320213202b320283202132028320213202b32028320
000200003e6203c6303a6403664034640316402b64027640216401d6401a6401664512645106450e6450c6450b645096350963508635076350662506625056250462504615026150161501615001000010000100
000800000244303453054630547304473024730147302473044730447304473014730147302473044730547304463024530144301433014230141304403024030140302403044030440302403014030140302403
000200000d07012070160701d070266702b6402f6403264036650386503b6503d3603e3603f3603f3703f3703f373013003f373013003f3003f37301300013003f3003f373013000130001300013003f30003300
000200000f64011640146401665017650196501b6601c6601c6601c670196701767017670196701c6701f67022670256702a6702e67030670306703367035660366603766038650396503a6503a6403a6403a640
000200003d77038770307702a77036770317702b77027770227701f7702e7702a76024750207501d74019730177302a70024700207001c70018700157001270025700217001e7001a70016700117000e7000c700
00010000017700177028370284702a6702a6702967028670276602565024640226302162000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000200001715318153191531a1531b1531c1531d1531f15321153221532415325153261532815329153291532a1432b1432c1432d1432d1332e13330133311333212333123351233512336113371133811339113
000100002705025050220502505028050250502e0502c05030050380503705032050390503d0503f0503f0503f0503f0503f0503f0503f0503f0403f0303f0203f01000000000000000000000000000000000000
000100001b37018370163701537016370163701037010370103701037010370103701037010370103701037011370113701137011370113701137011370113701137011370113701137011370113701137011370
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 2e 08 0a 44
00 0f 0a 09 44
01 41 0c 0d 0b
00 0f 0c 0e 0b
00 0f 0c 0e 10
00 12 0e 0b 11
02 0f 0c 10 0b
00 41 14 43 44
01 17 15 16 44
00 41 15 16 1d
00 41 15 16 18
00 41 15 16 19
00 41 1c 16 1a
02 41 1c 16 1b
01 21 1e 43 22
00 21 1e 20 22
00 41 22 26 44
00 41 1e 20 1f
02 41 22 26 44
01 41 23 25 27
00 41 24 25 27
00 41 2e 28 27
02 0f 27 25 30
01 2e 2b 2f 44
00 2e 29 2b 2f
00 0f 2f 2b 2d
00 2e 29 2b 2d
02 41 2a 2b 2c
00 41 32 43 44
01 2e 31 0a 44
00 2e 31 0a 33
02 2e 31 0a 34
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
