pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
//got-ya!‡
//@enargy
//may ::_:: have mercy on us all

poke(0x5f2d, 1)
cartdata("enargy_endofcivilization")

function deluser()
 poke(0x5e00,0)
 poke(0x5e01,0)
 local mem=0x5e02
 for i=0,11 do
  poke(mem+i,0)
 end
 delgallery()
 _init()
end
function delgallery()
 local mem=0x5ec0
 while mem<0x5f00 do
  poke(mem,0)
  mem+=1
 end
 poke(0x5ebf,band(peek(0x5ebf),0b11100111))
 _init()
end
function _init()
 if peek(0x5e02)==0 then
  poke(0x5e17,9)
  poke(0x5e18,0)
 end
 
 bgc1=peek(0x5e17)
 bgc2=peek(0x5e18)
 
 descs={"pico-8 starburst - used to create deceptively technically interesting things someone may someday enjoy. and tweetcarts",
"crow - brave but reluctant hero. perennial favorite for a clandestine dueling circuit that may be found in the far corners of space.",
"mimi - one of a million girl. her motto: 'henchin' ain't easy! ‡‡‡'",
"cassandra - she can fly! and maybe.. suck the soul out of things iunno we don't really talk about that part.",
"wark - a large chicken-like creature that inspired a new genre: the wark-ing simulator.",
"wark rider - they're fast.. and delicious! guess that makes this unit.. 'fast food'?! ha wow jokes about eating sentient creatures never gets old, does it?",
"l-bug - genius inventor from a future where crime is mostly caused by jerks invading from the past. most assume they must be a robot.",
"l-bug - (pink armor) player 2 color variant with.. mysterious lore maybe iunno!",
"l-bug - (helmetless) gasp! pink hair?! how.. entirely inevitable of a heroine in this particular palette.",
"l-bug - (peh variant a) cute little bugger.",
"l-bug - (peh variant b) arguably even cuter little bugger.",
"nami - blue-skinned mage. rather forgetful, so she's not much use without that book.",
"archer - deadly at a distance. squishy up close. pair them with a unit that has a game-breaking ability like dance and you're good to go..",
"lana - l-bug's alter ego has been sent back in time. and forced to use a cobbled together suit of armor.",
"sparkle heroine - unnamed heroine of 'time to sparkle' who uses a phone that opens dimensionsal rifts to help her travel around town, solve mysteries, and fight evil. y'know, typical girl stuff.",
"l-bug - (pstvania variant a) monochrome little friend who engages in gameboy-style adventures, exploring landscapes that are unlocked via 'oddly shaped keys' --- like rockets, grapple hooks, and super lasers!",
"l-bug - (pstvania variant b) monochrome little friend who may hurt your eyes but will never let you down.",
"kitten - learning to fly but.. he ain't got wings :(",
"courier - courageous fellow, tossing boxes and taking names. and there aren't any more box -- oh, nevermind! there are more over there.. see you later!",
"airy gato - the horrific lengths some will go to make a bad pun. no use feline sorry for them; cats just how some folks are.",
"mighty miner - hero of cafe quest -- wishes to collect all the coffee beans in a given area. why? to unlock the next area! why? because that's where more coffee beans are -- were you even listening?!",
"gloomy - phantasm type companion. tends to be useful for finding things others have misplaced. keys, socks, embarassing notes.. but he'll never tell. because ghost friends are great friends!",
"pumpkitty - questionably cute, but definitively delicious pumpkin type companion. ... but seriously don't eat it, you'll get sick.",
"steppy - player 1 in bunny bounce. who got hops? steppy got hops. ohhhhh the hops.. they are.. here. friend. you betcha..",
"monique - player 2 in bunny bounce. can fly, but -- watch out for aerial hazards!",
"hormiga - player 3 in bunny bounce. can walk on walls like a champ!",
"walky - lil orange friend trapped in a world he never made",
"honey - she can fly forwards. never looks back. that is.. true strength. as well as an engine limitation.",
"::_:: - gasp! the patron deity of #tweetcarts has smiled up thee! i.. think that's a smile at least..?",
"irs - irene the rat skater. seems 2 cool 4 u, but is really a friend in need. gotta get that cheddar!",
"jam - star of a silly little sim where you farm candy. will it make it out in time for #mmamjam??! definitely maybe iunno! ‡‡‡",
"fluff - there are many fluffs like it, but each is adorable in its own small, puff-like way.",
"wandering fluff - the wandering fluffy-guy! after years of travel, he has dueled his way across the 4 corners of the land. so far, none have bested him in battle. for all have stood aside at the sight of its cuteness. very zen, no?",
"miranda clue - one of the stars of an upcoming edutainment/mystery game. only truly inquisitive individuals can unlock this card.. (owning this card marks you as an egghead -- congratulations!)",
"sylvia (portrait) - bright-haired slacker-witch! armed with her grandmother's powerful grimoire, this witch is always brewing wild potions and crafting curses and charms. her work-avoiding schemes may have (temporarily) resulted in sending beloved pets to far-off planes, swapping bodies with arch-enemies, summoning ancient evils, or even slightly kinda sorta breaking the whole timeline... but despite that, she's shown time and again that she's a valuable ally and an irreplaceable friend. because the true mark of a hero is how they rise to the occasion when the going gets tough .. even if they'd really rather be gently levitating on the balcony and catching some zzz's...",
"sylvia (chibi) - bright-haired slacker-witch! this girl has potential.. and she knows it. her friends know it. and the rest of the village seems to know it as well. despite this, sylvia appears content to get by on her natural gifts and a few choice acquired artifacts. after all, if you were supposedly going to live for thousands of years.. would you really think twice about taking the ocassional day -- or even every other day -- off?",
"faria (portrait) - the mind of this undead queen spent centuries sealed within the pages of a book. but these days she seems to be back in one piece. her powers are related to the sun.",
"faria (chibi) - an undead queen! okay, so she's basically a cute mummy. but with sun powers. like flight and shooting beams of heat and light. yes flight is a sun-based power. the sun flies.. like all the time, okay? you ever seen it land? anywhere. no. no you haven't.",
"mummy - for you mummy purists. it isn't just a mummy, though. it's so.. so much more. ... yes it's description is 50% a reference to the next card. sorry, mummy :(",
"s‡more - why would you write lore for an anthropomrphic campfire snack? i mean really now.. is it avenging their friends? or running an ophanage? trying to find true love, perhaps? -- what's that? it's doing all three?? that.. that is one brave little snack-fellow. godspeed, treat-filled one!",
"vera (portrait) - vera is a vampire. she's also faria's roommmate. they have a lot of fun adventures together. unfortunately, while some magic goggles allow her to spend time in non-direct sunlight, faria's solar aura makes it a bit complicated for her and vera to.. give each other hugs.",
"vera (chibi) - flight, super strength, enhanced speed and agility, hypnosis, the ability to commune with animals -- being a vampire is pretty keen! unfortunately, the weakness to sunlight can get in the way. especially when your best friend is a solar-powered entity. fortunately, one of their journeys was able to provide them with a frost-enchanted ring. allowing faria and vera to hold hands without vera being incinerated.",
"cecilia (portrait) - a teen in the 1980s, cecilia lives in a small town that seems to experience an uncanny amount of odd happenings. ghosts, fairies, cursed items, monsters.. she and her friends uncover the unseen, solve mysteries, and fight things that would threaten innocents. she's a busy girl. and then there's the prophecy she found in her missing mother's diary.. 'when the 13 come together -- all will be made clear..'",
"cecilia (chibi) - scheduled to one day inherit the cursed label of one of 13 fated archetypes. until then? she solves crimes, uncovers mysteries and does what we all must: try to have a good time. oh, and fight the forces of evil. that, too.",
"felicia (portrait) - a werewolf! quick, melt down the silver! now cast it into bullets! noone knows how to do those things these days?! then we better run!",
"felicia (chibi) - under the light of the moon, this mild-mannered young lady becomes a feral engine of destruction. fortunately, she retains her amazing fashion sense.",
"valentina (portrait) - valentina was a normal girl who wished to be something more. powerful, popular, beloved. and now she is! ..at a price. paying off a debt to a trickster god doesn't come cheap; to pay those bills, she's got to reap.",
"della muerte (chibi) - ferrying lost souls to the afterlife and resolving supernatural threats. when her power is needed, valentina becomes..undead magical girl-- 'della muerte'.",
"conductor (portrait) - ghost of a train conductor. well, a train robber. and well.. an electric ghost. many powers at his disposal, including functional immortality. some ancient texts refer to him as 'the livewire.'",
"conductor (chibi) - the conductor has a long history of causing trouble, being trapped using grade school level science, released, and then.. well, trapped again. he also happens to be one of the fated 13 to be active through many generations.",
"'blessing' - horrid creatures who force unlucky persons to participate in games with consequences that are oft deadly-- or worse. according to some research, their name loosely translates to 'blessings'.",
"queen of hearts - a fallen goddess. or maybe just one which finally learned her true purpose. who is to say?",
"cc queen (portrait) - this candied queen has lore sooo deep i havent. even. thought of it yet. (or maybe she turns people to candy and then gives them out on halloween a-- and now we're in creepy fanfic territory well that's just wonderful)",
"cc queen (chibi) - happy halloween to all the g/f out there. guardian force? galley fiends? girl fridays? whatever!‡",
"sphinx (portrait) - you did it, charlie! y-y-you passed the test! a winner is you! you answered some basic questions and didn't get devoured!          ..now for date #2..",
"sphinx (chibi) - don't let her cute exterior fool you -- this centuries-old creature will rend you limb from limb if you aren't good at silly quizzes! (or question her choice of palette)"
}

 menuitem(4,"!!delete user!!",deluser)
 menuitem(5,"!!reset gallery!!",delgallery)
 cclim=30
 pchars="1234567890 !@#$%^&*() qwertyuiop asdfghjkl\b _zxcvbnm\r"
 maxparts=550
 
 streak=peek(0x5e16)
 mouse=1
 button=2
 mode=button
 
 outlined={16,17,24,25,26,30,32,33,64,34,35,37,41,43,45,47,49,50,52,53,55}
 
 ic={[0]=7,0,0,0,9,6,5,6,0,10,7}
 chars="\0\1\2\3\4\5\6\7\8\9\16\11\12\13\14\15\10\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\32\33\34\35\36\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55\56\57\58\59\60\61\62\63\64\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92\93\94\95\96\97\98\99\100\101\102\103\104\105\106\107\108\109\110\111\112\113\114\115\116\117\118\119\120\121\122\123\124\125\126\127\128\129\130\131\132\133\134\135\136\137\138\139\140\141\142\143\144\145\146\147\148\149\150\151\152\153\154\155\156\157\158\159\160\161\162\163\164\165\166\167\168\169\170\171\172\173\174\175\176\177\178\179\180\181\182\183\184\185\186\187\188\189\190\191\192\193\194\195\196\197\198\199\200\201\202\203\204\205\206\207\208\209\210\211\212\213\214\215\216\217\218\219\220\221\222\223\224\225\226\227\228\229\230\231\232\233\234\235\236\237\238\239\240\241\242\243\244\245\246\247\248\249\250\251\252\253\254\255"
 username=""
 last=false
 if peek(0x5e02)!=0 then
  mem=0x5e03
  for i=0,10 do
   char=_ts(peek(mem+i))
   if peek(mem+i)==255 then
    last=true
   elseif not last then
    username=username..char
   end
  end
 end
 

 tokens=peek(0x5e00)

 
 token_p=peek(0x5e01)
 
 ppart={}
 title=1
 menu=2
 newaccount=3
 dologin=4
 dopull=5
 reveal=6
 gallery=7
 dashboard=8
 roulette=9
 bgc1n=10
 bgc2n=11
 pickset=12
 
 count=0
 
 choices={"make an account",
          "login",
          "reveal (1 token)",
          "gallery",
          "background color",
          "window color"}
 states={newaccount,
         dologin,
         pickset,
         gallery,
         bgc1n,
         bgc2n}
 inits={newaccount_i,
        dologin_i,
        pickset_i,
        gallery_i,
        bgc1n_i,
        bgc2n_i}
 state=title
 if peek(0x4300)==1 then
  state=dashboard
 else
  music(0)
 end
 
 xo,yo=0,0
 
 a=0
 mcoff=1
 
 pips={}
 for iy=0,47 do
  pips[iy]={}
 end
 
 pipx,pipy=38,40
 
 fp=0
 
 unlocked={}
 for id=1,#descs do
  unlocked[id]=check_unlocked(id)
 end
 
end
function _update()
 fp+=.2
 mousex,mousey=stat(32),stat(33)
 olmb=lmb
 ormb=rmb
 lmb=band(stat(34),1)==1
 rmb=band(stat(34),2)==2
 if not olmb and lmb then
  lclick=true
 else
  lclick=false
 end
 if not ormb and rmb then
  rclick=true
 else
  rclick=false
 end
 if lmb then mouseshow=true end
 if state==title then
  xo-=.5
  if xo<0 then
   xo=15
  end
  yo-=.5
  if yo<0 then
   yo=15
  end
  
  if btnp(—) or lclick then
   state=menu
   music(2)
   sfx(14)
  end
  
 elseif state==menu then
  choices[4]="gallery"..get_unlocked()
  a-=.125
  //menu:
  oyear=peek(0x5e0f)*100
  oyear+=peek(0x5e10)
  omonth=peek(0x5e11)
  oday=peek(0x5e12)
  ohour=peek(0x5e13)
  omins=peek(0x5e14)
  osecs=peek(0x5e15)
  
  year=stat(80)
  month=stat(81)
  day=stat(82)
  hour=stat(83)
  mins=stat(84)
  secs=stat(85)
  if username=="" then

   choices[2]="(please make account)"
  elseif ohour<hour
    or oday<day
    or omonth<month
    or oyear<year then
    choices[2]="login (ready!)"
  else
   local dm=tostr(60-mins)
   local ds=tostr(60-secs)
   
   if #dm==1 then dm="0"..dm end
   if #ds==1 then ds="0"..ds end
   choices[2]="login ("..dm..":"..ds..")"
  end
  if band(peek(0x5ebf),1)==1 and band(peek(0x5ebf),8)!=8 then
   if mousex>=60 and mousex<=68
     and mousey>=3 and mousey<=11 then
     if lmb then
      poke(0x5ebf,bor(peek(0x5ebf),8))
      tokens+=8
      sfx(25)
      poke(0x5e00,tokens)
      unlock(34)
     end
   end
 	elseif band(peek(0x5ebf),4)==4 and band(peek(0x5ebf),16)!=16 then
   if mousex>=52 and mousex<=60
     and mousey>=3 and mousey<=11 then
     if lmb then
      poke(0x5ebf,bor(peek(0x5ebf),16))
      tokens+=8
      sfx(25)
      poke(0x5e00,tokens)
      unlock(55)
     end
   end
  end
  if lclick then
   for k,v in pairs(choices) do
    if mousey>=41+k*12
     and mousey<=49+k*12 then
     if mousex>=13
      and mousex<=18+#v*5 then
      if mcoff==k then
       sfx(25)
       state=states[mcoff]
       inits[mcoff]()
      end
      sfx(25)
      mcoff=k
     
     end   
    end
   end
  end
  if btnp(”) then
   mcoff-=1
   sfx(14)
  elseif btnp(ƒ) then
   mcoff+=1
   sfx(15)
  end
  mcoff=max(1,min(#choices,mcoff))
  
  if btnp(—) then
   state=states[mcoff]
   inits[mcoff]()
  end
 
 elseif state==newaccount then
  if lclick then
   if mode==button then
    mode=mouse
    lclick=false
    newkey=nil
    oldkey=nil
   end
  end
  if mode==mouse then
   mx,my=mousex,mousey
  end
  if btn(‹) then
   mode=button
   mx-=1
  elseif btn(‘) then
   mode=button
   mx+=1
  end
  if btn(”) then
   mode=button
   my-=1
  elseif btn(ƒ) then
   mode=button
   my+=1
  end
  if mode==button then
   mousex,mousey=mx,my
  end
  
  if (lclick and mode==mouse) or (btnp(—) and mode==button) then
   for k=1,#pchars do
    local char = sub(pchars,k,k)
    if char=='_' then char=' ' end
    if mousey>=63+flr(k/11)*12
     and mousey<=69+flr(k/11)*12 then
     if mousex>=9+((k%11)*9)
      and (mousex<=14+((k%11)*9) or ((char=='\b' or char=='\r') and mousex<=16+((k%11)*9))) then

       sfx(25)
       clickedkey=char
      selkey=char
      seloff=k
     end   
    end
   end
  end
  
  
  
  
  
  if (stat(30) and mode!=mouse and mode!=button) or clickedkey or pressedkey then
   oldkey=newkey
   newkey=pressedkey or clickedkey or (stat(31) and mode!=button)
   clickedkey=nil
   pressedkey=nil
   if newkey=='p' then
    //suppress pause
    poke(0x5f30,1)
   end
   
   if username!="" and newkey=="\r" then
    state=menu
    music(2)
    //suppress pause
    poke(0x5f30,1)
    //user made
    poke(0x5e02,1)
    username=username.."\255"
    
    
    mem=0x5e02
    for i=1,#username do
     char=sub(username,i,i)
     poke(mem+i,c2b(char))
     
    end
    username=sub(username,1,#username-1)
    tokens+=5
    poke(0x5e00,tokens)
    
   elseif oldkey!=newkey or (keyup>5 or clickedkey) then
    
    keyup=0
    pass=false
    exclude={'\r','\n','\t'}
    for k,v in pairs(exclude) do
     if v==newkey then
      pass=true
     end
    end
    if not pass then
     if newkey=='\b' then
      username=sub(username,1,#username-1)
     else
      username=username..newkey
      username=sub(username,1,10)
     end
    end
   end
  else
   keyup+=1
  end

 elseif state==dologin then
  
 elseif state==roulette then
  //roulette game logic..
  if not chosen then
   pick+=1
   if pick>chances then
    pick=1
   end
  end
  if btnp(—) or lclick then
   if not chosen then
    chosen=true
    tokens+=pick
    poke(0x5e00,tokens)
   else
    state=menu
    
   end
  end
 elseif state==pickset then
  if lmb then
   mode=mouse
   
  end
  if mode==mouse then
   mx,my=mousex,mousey
  end
  
  
  if btn(‹) then
   mx-=1
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  elseif btn(‘) then
   mx+=1
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  end
  if btn(”) then
   my-=1
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
   
  elseif btn(ƒ) then
   my+=1
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  end
  if btnp(—) or lclick then
   if my>=48 and my<=72 then
    if mx>=40 and mx<=56 then
     set=sets[1]
     state=reveal
     reveal_i()
    elseif mx>=72 and mx<=88 then
     set=sets[2]
     state=reveal
     reveal_i()
    end
   end
  end
 
 elseif state==reveal then
  if lmb then
   mode=mouse
   scratch(mousex,mousey)
   nomove=0
  else
   nomove+=.5
  end
  
  
  if btn(‹) then
   mx-=1
   nomove=0
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  elseif btn(‘) then
   mx+=1
   nomove=0
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  end
  if btn(”) then
   my-=1
   nomove=0
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
   
  elseif btn(ƒ) then
   my+=1
   nomove=0
   if mode==mouse then
    mx,my=mousex,mousey
   end
   mode=button
  end
  opercent=percent
  percent=tostr((count/(48*48))*100)
  
  
  if percent=="100" then
   if new then
    if not sflag then
     sfx(13)
     
    end
    sflag=true
    
    txt="you got ["..name.."](#"..id..") !"
    tx=64-(#txt*2)
    ty=100
   else
    if not sflag then
     sfx(12)
    end
    sflag=true
    
    txt="another ["..name.."] :/"
    tx=64-(#txt*2)
    txt=txt.."\nhave a token piece!‡"
    ty=100
   end
   if (opercent==percent and (lclick or rclick)) or (btnp(Ž) and not held) then
    state=menu
    music(2)
   end
  elseif tonum(percent)>=80 then
   txt="(pssst! hold Ž(z)\n or right-click\n for auto-scratch)"
   tx=2
   ty=108
  end
  if btn(Ž) then held=true
  else held=false end
  timer-=1
  if timer<=0 then
   timer=0
  end
  if btn(—) then
   
   if mode==mouse then
    mx,my=mousex,mousey
   end
   scratch(mx,my)
   mode=button
  elseif btnp(Ž) then
   local iy=0
   local ix=-1
   found=false
   while not found do
    ix+=1
    if ix>47 then
     ix=0
     iy+=1
    end
    
    if iy>47 then
     found=true
    end
    if not pips[iy] then
     found=true
    else
     if not pips[iy][ix] then
      found=true
     end
    end
   end
   scratch(ix+pipx,iy+pipy)
   
   mode=button
  elseif rmb and timer<=0 then
   local iy=0
   local ix=-1
   found=false
   timer=5
   while not found do
    ix+=1
    if ix>47 then
     ix=0
     iy+=1
    end
    
    if iy>47 then
     found=true
    end
    if not pips[iy] then
     found=true
    else
     if not pips[iy][ix] then
      found=true
     end
    end
   end
   scratch(ix+pipx,iy+pipy)
   
   mode=mouse
  end
  
  if mode==button then
   mousex=mx
   mousey=my
  end
  
  foreach(ppart,pu)
  

 elseif state==gallery then

  //   * table with
  //     faux perspective
  
  if btnp(Ž) or rclick or (lclick and mousey<6) then
   state=menu
   music(2)
  end
  if lclick then mode=mouse end
  
  if btnp(”) or btnp(‹)
    or btnp(‘) or btnp(ƒ) then
    mode=button
  end
  
  if btnp(”) or stat(36)>0 then
   toff+=3
   
  elseif btnp(ƒ) or stat(36)<0 then
   toff-=3
  end
  
  
  toff=max(-theight+6,min(0,toff))
  
  if btnp(‹) or (lclick and mousex<24) then
   sfx(14)
   coff-=1
   toff=0
   if coff==34 then
    gbg=12
    make_lava(12,13,14,15)
   end
  elseif btnp(‘) or (lclick and mousex>90) then
   sfx(15)
   coff+=1
   toff=0
   if coff==35 then
    gbg=1
    make_lava(9,14,1,9)
   end
  end
  coff=max(1,min(#descs,coff))
  
  
 
 end
end
function _draw()
 
 palt(0,false)
 palt(11,true)
 
 if state==title then
  
 
  cls(2)
  pal(3,11)
  c=0
  for ix=-16,144,16 do
   for iy=-16,144,16 do
    c+=1
    if c%2!=1 then
     spr(224,ix+xo,iy+yo,2,2)
    end
    
   end
  end
  pal(3,3)
  
  circfill(64,64,55,0)
  fillp(0b0100010001000100)
  circfill(64,64,53,0x79)
  fillp()
  
  for i=0,15 do
   pal(i,0)
  end
  
  for ix=-1,1 do for iy=-1,1 do
   sspr(16,112,40,16,24+ix,48+iy,80,32)
  end end
  for i=0,15 do
   pal(i,i)
  end
  sspr(16,112,40,16,24,48,80,32)
  
  rectfill(14,88,111,97,13)
  rect(13,87,112,98,0)
  for ix=-1,1 do for iy=-1,1 do
   print("press — to start!", 28+ix,90+iy,0)
  end end
  print("press — to start!", 28,90,7)
  
 elseif state==menu then

  cls(bgc1)
  
  pprint("streak: ",32,122,0,14)
  pprint("’’’’’’’’",64,122,7,bgc1)
  for i=1,streak do
   pprint("’",64+(i-1)*8,122,bgc1-6,7+i)
  end
  if band(peek(0x5ebf),1)==1 and band(peek(0x5ebf),8)!=8 then
   pspr(253,60,3)
  end
  if band(peek(0x5ebf),4)==4 and band(peek(0x5ebf),16)!=16 then
   pspr(252,52,3)
  end
  
  circfill(116,10,10,0)
  circfill(116,10,9,12)
  rectfill(115,1,117,19,0)
  rect(106,10,125,11,0)
  
  pprint(token_p..'/4',111,24,0,7)
  
  for i=1,token_p do
   i-=1
   local sx=(i%2)*8
   local sy=flr(i/2)*8
   sspr(sx,sy,8,8,100+(sx*2),(sy*2)-6,16,16)
  end
  spr(0,0,0,2,2)
  for ix=-1,1 do for iy=-1,1 do
   print(" x "..tokens,10+ix,5+iy,0)
  end end
  print(" x "..tokens,10,5,7)
  
  if username!="" then
   length=max(#("logged "..'['..username..']')*4,#("logged in as.. ")*4)
   rectfill(12,18,length+16,40,bgc2)
   rect(12,18,length+16,40,1)
   pprint("logged in as..",15,22,1,7)
   pprint('['..username..']',42,31,1,14)
  end
  
  rectfill(12,48,121,119,bgc2)
  rect(12,48,121,119,1)
  
  for k,v in pairs(choices) do
   for ix=-1,1 do for iy=-1,1 do
    if k==mcoff then
     print("‡",ix+14,iy+40+k*12,0)
     
     for char=1,#v do
      if (k==3 and tokens<=0) or (k==1 and username!="") then
       print(sub(v,char,char),((char-1)*4)+ix+24,iy+40+k*12,5)
      else
       print(sub(v,char,char),((char-1)*4)+ix+24,1*sin((a+(char/4)))+iy+40+k*12,9)
      end
     end
    elseif (k==3 and tokens<=0) or (k==1 and username!="") then
     print(v,ix+24,iy+40+k*12,5)
    else
     print(v,ix+24,iy+40+k*12,0)
    end
   end end
   
   if k==mcoff then
    print("‡",14,40+k*12,14)
    c=rnd(16)
     for char=1,#v do
      if (k==3 and tokens<=0) or (k==1 and username!="") then
       print(sub(v,char,char),((char-1)*4)+24,40+k*12,6)
      else
       print(sub(v,char,char),((char-1)*4)+24,1*sin((a+(char/4)))+40+k*12,0)
      end
     end
    
   else
    if (k==1 and username!="") then
     print(v,24,40+k*12,6)
    elseif (k==3 and tokens<=0) then
     print(v,24,40+k*12,6)
    else
     print(v,24,40+k*12,7)
    end
   end
  end
  if lmb then
   spr(235,mousex,mousey)
  else
   spr(251,mousex,mousey)
  end
  
 elseif state==newaccount then

  cls(13)
  rectfill(14,20,127-14,40,14)
  rect(14,20,127-14,40,0)
  
  pprint(" ‡enter your name!‡",20,26,0,7)
  
  dname=""
  for i=1,#username do
   dname=dname..sub(username,i,i).." "
  end
  while #dname<20 do
   dname=dname.."_ "
  end
  pprint(dname,24,54,0,7)
  
  for k=1,#pchars do
   local x=10+((k%11)*9)
   local y=63+flr(k/11)*12
   oc=7
   char=sub(pchars,k,k)
   if selkey==char then
    oc=9
   end
   if char=='\r' then
    pspr(237,x,y,oc)
   elseif char=='\b' then
    pspr(236,x,y,oc)
   else
    pprint(char,x,y,oc,0)
   end
  end
  
  if lmb or btn(—) then
   spr(235,mousex,mousey)
  else
   spr(251,mousex,mousey)
  end
 elseif state==dologin then
 elseif state==roulette then
  cls(3)
  draw_lava()
  for i=1,chances do
   oc=7
   if pick==i then oc=9 end
   pprint(i,63-(chances*8)+(16*i),48,oc,0)
  end
  if not chosen then
   pprint("— or mouse to stop!",23,14,1,7)
  else
   pprint("— or mouse to return",18,14,1,7)
  end
  pprint("login once a day!\nthe more days you login in a\nrow, the more tokens you can\nwin each day!\ncheck the forum for updates\nwith even more characters soon!",4,90,1,14)
  
 elseif state==pickset then
  cls(13)
  draw_lava()
  for k,v in pairs(sets) do
   local id=233
   if v>2 then
    id=231
   end
   
   local x=8+k*32
   pspr(id,x,48,0,2,2)
   local r=(v+1)*10
   local txt=(r-9).."-"..r
   if(r==10)txt="0"..txt
   if r==0 then
   	txt=" any"
   else
   	txt=txt.." ("..get_unlocked(v)..")"
   end
   //if pass offset then
   //get delta..
   
   pprint(txt,x-2,68,7,0)
  end
  if lmb or btn(—) then
   spr(235,mx,my)
  else
   spr(251,mx,my)
  end
 elseif state==reveal then

  cls(rbg)
  draw_lava()
  
  
  if percent=="100" then
   pprint("Ž(z) or click to exit!",9,14,0,7)
  else
   pprint("use cursor + — or mouse!",15,14,0,7)
  end

  circfill(pipx+24,pipy+24,40,0)
  circfill(pipx+24,pipy+24,36,1)
  rectfill(pipx,pipy,pipx+47,pipy+47,12)
  draw_card(id)
  local xo=foil.x
  local yo=foil.y
  for iy=0,47 do
   for ix=0,47 do
    if not pips[iy][ix] then
     
     local c=sget(xo+flr(ix)/3,yo+flr(iy)/3)
     pset(pipx+ix,pipy+iy,c)
     if nomove%30>28 then
      pset(pipx+ix,pipy+iy,ic[c] or 0)
     end
    end
   end
  end
  
  
  if lmb or btn(—) then
   spr(235,mousex,mousey)
  else
   spr(251,mousex,mousey)
  end
  
  for k,v in pairs(ppart) do
   circfill(v[1],v[2],v[6],v[5])
  end
  
  pprint(sub(percent or "0%",1,4).."%",1,1,0,14)
  
  if #txt>0 then
   pprint(txt,tx,ty,7,0)
  end
 
 elseif state==gallery then

  //   * table with
  //     faux perspective
  cls(gbg)
  
  draw_lava()
  
  pprint("‹/‘ : nav | Ž (z) : return",6,1,0,7)
  rectfill(19,8,107,120,0)
  
  clip(22,21,83,67)
  rectfill(22,21,22+83,21+67,gbg)
  draw_lava()
  clip()
  rectfill(21,90,105,118,6)

  circfill(96,25,9,14)
  circ(96,25,9,0)
  
  numx=91
  if #tostr(coff)==1 then
   numx+=2
  end
  pprint('#'..coff,numx,23,0,7)
  rectfill(21,10,105,18,9)
  if coff>1 then
   pprint("‹",6,56,0,7)
  end
  if coff<#descs then
   pprint("‘",127-12,56,0,7)
  end
  cclim=22
  if unlocked[coff] then
   
   //draw card
   draw_card(coff)
   nm=descs[coff]
   for i=1,#nm do
    if sub(nm,i-1,i+1)==' - ' then
     flag=i-2
    end
   end
   name=sub(nm,1,flag)
   pprint(name,23,12,0,7)
   
   desctxtcpy=sub(descs[coff],flag+4,#descs[coff])
   
   desctxt=""
   word=""
   ccount=0
   spaceoff=1
   theight=0
   for i=1,#desctxtcpy do
    char=sub(desctxtcpy,i,i)
    ccount+=1
    
    if char==' ' or i==#desctxtcpy or char=='\n' then
     
     if ccount>=cclim then
      theight+=6

      desctxt=desctxt..'\n'..sub(desctxtcpy,spaceoff,i)

      ccount=#sub(desctxtcpy,spaceoff,i)
     else
      desctxt=desctxt..sub(desctxtcpy,spaceoff,i)
     end
     spaceoff=i+1
    end
    
   end
   clip(22,91,90,25)
   for ix=-1,1 do for iy=-1,1 do
    print(desctxt,23+ix,toff+92+iy,0)
   end end
   print(desctxt,23,toff+92,7)
   clip()
  
  else //not unlocked
   draw_card(64)
  end
  if mode==mouse then
   if lmb then
    spr(235,mousex,mousey)
   else
    spr(251,mousex,mousey)
   end
  end
 end
 
 
 
end

function pu(p)
 p[1]+=p[3]
 p[2]+=p[4]
 
 p[4]+=.1
 
 if p[1]>=130
  or p[1]<=-8
  or p[2]>=130
  or p[2]<=-8 then
  del(ppart,p)
 end
end

function scratch(x,y)
 x-=pipx
 y-=pipy
 pr=6
 
 prl,prh=-flr(pr/2),flr(pr/2)
 for ix=prl,prh do
  for iy=prl,prh do
   if abs(ix)+abs(iy)<pr-1 then
    if pips[y+iy] then
     if not pips[y+iy][x+ix] then
      if y+iy<=47 and y+iy>=0
       and x+ix<=47 and x+ix>=0 then
        local c=pget(pipx+x+ix,pipy+y+iy)
        pips[y+iy][x+ix]=true
        sfx(10)
        count+=1
        if c>0 and #ppart<maxparts then
         add(ppart,{pipx+x,pipy+y,rnd(4)-rnd(2),-rnd(3),c,rnd(2.5)})
        end
      end
     end
     
     
    end
   end
  end
 end
end

function newaccount_i()
 
 if username=="" then
  clickedkey=nil
  mx,my=mousex,mousey
  keyup=0
  oldkey=""
  newkey="x"
  username=""
 else
  state=menu
 end
end
function dologin_i()
 if username=="" then state=menu return end

 oyear=peek(0x5e0f)*100
 oyear+=peek(0x5e10)
 omonth=peek(0x5e11)
 oday=peek(0x5e12)
 ohour=peek(0x5e13)
 omins=peek(0x5e14)
 osecs=peek(0x5e15)
 
 year=stat(80)
 month=stat(81)
 day=stat(82)
 hour=stat(83)
 mins=stat(84)
 secs=stat(85)
 if ohour<hour
    or oday<day
    or omonth<month
    or oyear<year then

   //check for streak..
   if oyear==year and omonth==month and day<=oday+1 then
    streak+=1
    streak=min(8,streak)
    poke(0x5e16,streak)
   else
    streak=1
    poke(0x5e16,streak)
   end
   poke(0x5e0f,sub(tostr(year),1,2))
   poke(0x5e10,sub(tostr(year),3,4))
   poke(0x5e11,month)
   poke(0x5e12,day)
   poke(0x5e13,hour)
   poke(0x5e14,mins)
   poke(0x5e15,secs)
   //setup roulette game
   chances=streak
   state=roulette
   roulette_i()
 else
  state=menu
 end
   
end
function reveal_i()
 foil={x=72,y=112}
 rbg=12
 timer=0
 sflag=false
 make_lava(12,13,14,15)
 
 nomove=0
 
 
 music(1)
 pips={}
 for iy=0,47 do
  pips[iy]={}
 end
 
 count=0
 percent=""
 txt=""
 
 if set>-1 then
  name=flr(rnd(10))+1
  name+=set*10
  while name==34 or name==55 or name>#descs do
   name=flr(rnd(10))+1
   name+=set*10
  end
 else
  name=flr(rnd(#descs))+1
  while name==34 or name==55 do
   name=flr(rnd(#descs))+1
  end
 end
 
 
 if name>=35 then
  rbg=1
  foil.x=56
  make_lava(9,14,1,9)
 end
 
 id=name
 new=true
 if unlocked[id] then
  token_p+=1
  if token_p>=4 then
   tokens+=1
   token_p-=4
  end
  poke(0x5e00,tokens)
  poke(0x5e01,token_p)
  new=false
 end
 unlock(id)
 tspr=((name-1)%16)*2
 tspr+=flr((name-1)/8)*32
 
 
 if descs[name] then
  nm=descs[name]
  for i=1,#nm do
   if sub(nm,i-1,i+1)==' - ' then
    flag=i-2
   end
  end
  name=sub(nm,1,flag)
 end
end
function gallery_i()
 coff=1
 theight=-26
 toff=0
 gbg=12
 make_lava(12,13,14,15)
end
function unlock(id)
 unlocked[id]=true
 
 //start at 0x5ec0
 
 id-=1
 offset=flr(id/8)
 remainder=id%8
 mem=0x5ec0+offset
 poke(mem,bor(peek(mem),shl(1,remainder)))
 
end
function check_unlocked(id)
 id-=1
 offset=flr(id/8)
 remainder=id%8
 mem=0x5ec0+offset
 return band(peek(mem),shl(1,remainder))!=0
end
function draw_lava()
 
 for i=1,20 do
  v=lava[i]
  v[1]+=v[5]
  v[2]+=v[6]
  if v[1]<0 or v[1]>128 then
   local ang=rnd(1)+1
   v[5]=cos(ang)
  end
  if v[2]<0 or v[2]>128 then
   local ang=rnd(1)+1
   v[6]=sin(ang)
  end
  circfill(v[1],v[2],v[3],v[4])
 end
end
function pprint(txt,x,y,b,c)
 for ix=-1,1 do for iy=-1,1 do
  print(txt,x+ix,y+iy,b)
 end end
 print(txt,x,y,c)
end
function _ts(byte)
 return sub(chars,tonum(byte)+1,tonum(byte)+1)
end
function c2b(char)

  
  for i=1,#chars do
   local c=sub(chars,i,i)
   if c==char then
    byte=i-1
   end
  end
  
  
  return byte


end
function pspr(id,x,y,oc,w,h)
 oc=oc or 0
 w=w or 1
 h=h or 1
 
 for i=0,15 do pal(i,oc) end
 for ix=-1,1 do for iy=-1,1 do
  spr(id,x+ix,y+iy,w,h)
 end end
 for i=0,15 do pal(i,i) end
 spr(id,x,y,w,h)
end

function roulette_i()
 tips={}
 anginc=1/chances
 a=0
 for i=1,chances do
  add(tips,{i,a,a+anginc})
  a+=anginc
 end
 lava={}
 la=0
 for i=1,20 do
  local ang=rnd(1)+1
  add(lava,{rnd(128),rnd(128),rnd(40),flr(rnd(4))+8,cos(ang),sin(ang)})
 end
 pa=0
 pavel=1
 chosen=false
 pick=1
end
function bgc1n_i()
 bgc1+=1
 poke(0x5e17,bgc1)
 state=menu
end
function bgc2n_i()
 bgc2+=1
 poke(0x5e18,bgc2)
 state=menu
end
function make_lava(c1,c2,c3,c4)
 lava={}
 la=0
 cs={c1,c2,c3,c4}
 for i=1,20 do
  local ang=rnd(1)+1
  add(lava,{rnd(128),rnd(128),rnd(40),cs[flr(rnd(4))+1],cos(ang),sin(ang)})
 end
end
function pickset_i()
 tokens-=1
 poke(0x5e00,tokens)
 if tokens<0 then
  tokens=0
  poke(0x5e00,tokens)
  state=menu
  return
 end
 mx,my=mousex,mousey
 sets={-1} //any
 add(sets,flr(rnd(#descs/10)))
 make_lava(7,2,1,7)
end
function draw_card(id)
 tspr=((id-1)%16)*2
 tspr+=flr((id-1)/8)*32
 sprx=(tspr%16)*8
  
 spry=flr(tspr/32)*16
 needout=false
 oc=0
 for k,v in pairs(outlined) do
  if v==id then
   needout=true
   if v==17 or v==16 or v==49 or v==50 then oc=7 palt(11,false) palt(14,true) end
  end
 end
 
 if needout then
  local scale=3
  clip(pipx-scale,pipy-scale,48+scale+scale,48+scale)
  for i=0,15 do pal(i,oc) end
   for ix=-scale,scale,scale do for iy=-scale,scale,scale do
    sspr(sprx,spry,16,16,pipx+ix,pipy+iy,48,48)
   end end
  for i=0,15 do pal(i,i) end
 end
 
 sspr(sprx,spry,16,16,pipx,pipy,48,48)
 palt(11,true)
 palt(14,false)
 clip()
end
function get_unlocked(rng)
	local c=0
	if not rng then
		for k,v in pairs(unlocked) do
			if v then c+=1 end
		end
		return " ("..c.."/"..#descs..")"
	else
		for k,v in pairs(unlocked) do
			if flr((k-1)/10)==rng then
				if v then c+=1 end
			end
		end
		if (rng+1)*10>#descs then
			return (#descs%10) - c
		else
			return 10-c
		end
	end
end
__gfx__
bbbbbbbbbbbbbbbbbbb0000000000bbbbbbbb000000bbbbbbbbbbbb000000bbbbbbbbbbbbb000bbbbbbbbb00000bbbbbbb0bbbbbbbbbb0bbbb0bbbbbbbbbb0bb
bbbbbbbbbbbbbbbbbb001111111100bbbbb00eeeeee0bbbbbbbbb002222220bb000bbb000004000b000bb00eee00bbbbb080bb0000bb080bb0c0bb0000bb0c0b
bbbbbbbbbbbbbbbbbb011111000110bbbb0eeee000ee0bbbbbbb02222000220b0400bb05444444000400b0eeffe0bbbbb080b0aaaa0b080bb0c0b0eeee0b0c0b
bbbbbbbbbbbbbbbbbb011110440010bbbb0eee0ff00ee0bb00bb02220dd002200440bbb0544444400440b0eeff0000bbbb080aaaaaa080bbbb0c0eeeeee0c0bb
bbbbbb000bbbbbbbbb011104444400bbbb0ee0fffff0e0bb06000220ddddd0200440b000044044000440000ecc00400bbb0290aaaa0920bbbb0dd0eeee0dd0bb
bbbbb00800bbbbbbbb01104044040bbbb0ee0f0ff0f0e0bb0660220d0dd0d02004400004444044000044000ccc444400bb02070aa07020bbbb0d070ee070d0bb
bbbb0097f00bbbbbbb01044044040bbbb0ee0f0ff0f0e0bb0660220d0dd0d0200444444444444990b00400ccfff44440b0b00c0aa0c00b0bbbb00d0ee0d00bbb
bbbb0a777e0bbbbbbbb0044044040bbbb0ee0f0ff0f0e0bb0660220d0dd0d0200544444444400990bb0444cccc444040060090aaaa090060b0b020eeee020b0b
bbbb0037d00bbbbbbbbb044444440bbbbb0ee0fffff0e0bb06002220ddddd0200044444444450090bb0044dddc444440056519aaaa915650060512eeee215060
bbbbb00c00bbbbbbbbb000222220bbbbbb00e099990e0bbb0600222055550220b054444444444000bbb04444dd440490b05001999911050b0550012222110550
bbbbbb000bbbbbbbbbb0aa00000000bbbb0300000000bbbb0600022000002220b0000544444450bbbbb0444ddd400090bb090100001090bbb00e01000010e00b
bbbbbbbbbbbbbbbbbb000555555040bbb000cccccc0bbbbb0600d2033dd30200bbb0955444450bbbbbb0448dd4440000bb0905cccc5090bbbb0e05eeee50e0bb
bbbbbbbbbbbbbbbbbb040555555000bbb0f0cccccc0bbbbbb00d0033355330d0bb00990000000bbbbbb00488044440bbbb050999999050bbbb020222222020bb
bbbbbbbbbbbbbbbbbb00055555500bbbb000cccccc00bbbbbb00003333330000bb0999900b0000bbbbb009440009900bbbb0044aa4400bbbbbb0022112200bbb
bbbbbbbbbbbbbbbbbbb0ddd000dd0bbbbb0888000880bbbbbbbbb0dd000dd0bbbb0009990b0990bbbbb090990b00990bbbbb05d11d50bbbbbbbb05e11e50bbbb
bbbbbbbbbbbbbbbbbbb00000b0000bbbbb00000b0000bbbbbbbbb0000b0000bbbbbb00000b0000bbbbb0000000b0000bbbb0288008820bbbbbb01cc00cc10bbb
bbbbb00000bbbbbbbb0bbbbbbbbbb0bbb000bbbbbbbb000bbbbb000000bbbbbbbbbb000000bbbbbbbbbbb000000bbbbbbb00000000bbbbbbe000eeeeeeee000e
bbbb0eeeee0bbbbbb080bb000000080bb0800b000000080bbb009999990bbbbbbb003333330bbbbbbbbb00eeee00bbbbb0008044440bbbbbe060000000e0060e
bbb0eeeee2e0bbbbbb08000aaaa0080bb008000aaaaa080bb09999000990bbbbb03333000330bbbbbb000eeeeee00bbbb08888444240bbbbe06055555000600e
bb0eeee299ee0bbbbb0800aaaaaa080bbb0800aaaaaaa80bb09990cc00990bbbb033309900330bbbbb0ee00000ee00bbb008444299440bbbe0655555550060ee
bb07e72fff7e70bbbb0809aaaaaaa0bbbb0809a0aaaa080bb0990ccccc090bbb03330999990300bbb00e0fffff0ee0bbbb07472fff7470bbe0605555055060ee
bb0e7e0ff0e7e0bbbbb088aa0aa0a0bbbbb088070aa0700b0990c0cc0c090000093090990900440bb0ee0f0ff0f0e0bbbb04740ff04740bbe007055070660eee
b00eee0ff0eee00b0000889a0aa0a0bb0000880c0aa0c0bb0990c0cc0c090740093090990903040bb0ee0f0ff0f0e0bbbb04440ff04440bbe007055070660000
06e7e70ff0ee70600666009a0aa0a0bb066600a0aaaa00bb0990c0cc0c090640033090990903040bb0ee0f0ff0f0e0bbbb07470ff04470bbe000555505006660
05ee7e9fff27e05006666099aaaaa0bb06666099aaaaa0bb00990cccc0090740b033099999030440b0ee0ffffff0e0bbbb00749fff2740bbee05555555066660
b05e0e9fff1e050b0066000999990bbb0066000999990bbbb099000009900640b003044440300440b0ee0999990ee0bbbbb0049fff140bbbee00555550006600
bb090100001090bbb0600dd00000d000b0600dd00000d00000990eccce0c07400110000000000040b0ee0000002e0bbbbb000100001000bb000566666650060e
bb0905cccc5090bbbb0aa066ccc60aa0bb0aa066ccc60aa00900eeeceecc0640011eeee11e099440b00e06ccc6000bbbbb070672276070bb055067766605500e
bb050999999050bbbb00a04449940a00bb00a04449940a00090ceeeee0000740011ee11eee00040bb0f04449940f0bbbbb060777777060bb005065566605060e
bbb0044aa4400bbbb06000556665000bb06000556665000bb00eeeeee00b0000b0111eeeee0b040bb000556665000bbbbb0f0d11dd10f0bbe000566655006600
bbbb05d11d50bbbb06600444000440bb06600444000440bbbb0cc000cc0bbbbbbb0880088000440bbb0444000440bbbbbbb0d11dd11d0bbbee06600066606660
bbb0288008820bbb000b00000b0000bb000b00000b0000bbbb0000b0000bbbbbbb00000000bb00bbbb00000b0000bbbbbbb0444004440bbbee0000e000000000
e000eeeeeeee000ebbbbbbbbbbbbbbbbbbbb00000000bbbbbb0000bbbbbbbbbb000bbbbbbbbb000bbbbbbbbbbbbbbb0bbbbbbbbbbbbbbbbbbbbb77bbbbbbbbbb
e0b0000000e00b0ebbbbbbbbbbbbbbbbbbb0099999900bbbb00ee00bbbb0000b050b0000000b050bbbbbbbbbbbb000d0bbbbb00b0b0bbbbbbbbb77bbbbb777bb
e0b033333000b00ebbbbbbbbbbbbbbbbbb009999999900bbb07eee0bbb00ee0005000ddddd00050bbbbbbbbbbb0ddd20bbb00f0030f0bbbbbbbb7777b7777bbb
e0b333333300b0eebbbbbbbbbbbbbbbbb00999999999900bb0e7ee000007eee00500ddddddd0050bbbbbb000000dd200bbb0ff9339ff0bbbbbbbb7777777bbbb
e0b033330330b0eebbbbbbbbbbbbbbbbb09990999909990bb0eeee00ee007ee0050ddd9a9ddd050bbbb00dddddddd00bbb099433334990bbbbbbb777777bbbbb
e007033070bb0000bbbbbbbbbbbbbbbbb09990999909990bb00ee007eee0eee005dddd999dddd50bbb0ddddddddd20bbb04099433490400bbbbbbb7777bbbbbb
e007033070bb0bb0b0bbb0bbbbbbbbbbb09990999909990bb000000e7ee0ee00b00cfffffffc00bbbb0ddddddddd20bbb00999944994090bbbbb777777bbbbbb
e00033330300bbb0000b000bbbbbbbbbb09999999999990b000b000eeee0000bbb0ff0fff0ff0bbbbb0d8dddd8d00bbbb09499999949090bbbbb777777bbbbbb
00033333330000b00900090bbbbbbbbbb00999999999900b09000900ee00bbbbbb0880fff0880bbbbb088dddd880bbbbb04909999094040bbbbb777777bbbbbb
03003333300030000999990bbbbbb00bbb000eeeeee000bb09999990000bbbbbb0000fffffff0000bb08d8dd8d80bbbb090909999099900bbbbb777777bbbbbb
0033bbbbbb33000e0909090000bb0000bbbb0eeeeee0bbbb0909090000bb0000b0ff0eeeee000770b0dddddddddd00bb04090999909990bbbbb7777777bbbbbb
0300b77bbb00300e00999009990b0bb0bbb00eeeeee00bbb00999000800b0990b0ff0eeeee0f0770b0dddddddddd20bbb00499e99994090bbbb7777777bbbbbb
0000b33bbb00000eb0000099990b0bbbbb00eeeeeeee00bbb0000090a00b090bb0000eeeee000770b02ddddddddd200bb00949999949090bbbb77777777bbbbb
eee03bbb330bbbb0bbb099999990bbbbb00999900999900bbbb09900809000bbbb04444e44440000bb02ddd222d2220bb0909fffff90900bbbbb7777b777bbbb
eee0bb00bb00bb00bbb090099990bbbbb09999900999990bbbb0900880900bbbbb04444044440bbbbbb022200022200bbb0400ff000400bbbbb77777bb777bbb
eee000000000000ebbb000000000bbbbb00000000000000bbbb000000000bbbbbbb0000b0000bbbbbbbb000bbb000bbbbbb00b000bb00bbbbb777bbbbb777bbb
bbbbddbbbbbddbbbbbbbddbbbbbddbbbbbbbbbbbbbbbbbbbbb0bbb0000bbb0bbbbbbbbbbbbbbbbbbbbbb111111bbbbbbbbbbb000000bbbbbbbbbb4bbbbbbbb4b
bbbbbdddbdddbbbbbbbbbdddbdddbbbbbbbbbb000bbbbbbbbb8b000ee000b8bbbb0bbb00000bbbbbbbb111111122bbbbbbbb0eeeeee0bbbbbb4444bbbb7bb44b
beebbbbdbdbbeeebbbbbbbbdbdbbbbbbbbbb000900000bbbbbb000eeeee000bbb0b0b0555550bb0bbbb1111111422bbbbbb0eeeeeeee0bbbb444b7b7b7b7744b
beeeeebdbdbeeeebbbbbbbbdbdbbbbbbbbb00999999900bbbb00eeeeeeee0bbbb0bb0555555500b0bbe1411114e4bbbbbb0eeee00eeee0bbb4447777777774bb
beeeeeddddeeeeebbbbbbbdbbdbbbbbbbbb09999999990bbbb0eeee999ee00000b005555555550b0bbb44444444bbbbbbb0eee0cc0eee0bbbb7777777777747b
beeeeeeddeeeeebbbddbbbbddbbbbdbbbb099999990990bb000e099990ee0070b0b08585558580b0bbb70447044bbbbbbb0ee000000ee0bb777777777777777b
bbeeeeeddeeeebbbbbdbbbbddbbbddbbbb099099990990bb070e099990ee0770b0b05555555550bbbbb0044004bbbbbbbb0000ffff0000bbb777777777777777
bbeeeeeddeeebbbbbbbdddbddbbddbbbbb09909999990bbb0700999999ee77700b0085855585800bbb44444444ebbbbbb0cc0f0ff0f0cc0b7770777777707777
bbbeeeeddeeebbbbbbbbbdddddddbbbbbb09999999990bbb0002099900ee77000b005555555550b0bbb40444eee4bbb40c0ccf0ff0fcc0c0b7707777777077b7
bbbbdddddddbbbbbbbbbbddddbbbbbbbbb0999999990bbbb0922200002ee700bb0b05557775500b011bb444ee9e44bb4b00000ffff00000bb77077777770777b
bbbeeeedeeeebbbbbbbbbddddbbbbbbbbbb0999999000bbb0922222222ee990bb0bb05555550bb00111b66e999e4ff44bbb0010000100bbbb7707777777077bb
bbeeeeebeeeeebbbbbbbbddddbbbbbbbbbb00000000b00bb00222222222e000bb0bbb000000bbb0b911b4e999aeefb4bbb0ff010010ff0bb7777777777777777
bbeeeebbbeeeeebbbbbbbdbbddbbbbbbbbb0bbbbbbbbb0bbb00ddd222220bbbbb0bbbbbbbbbbbb0bb1144ee9aeec444bbb0ff011110ff0bb7777777777777777
beeeebbbbeeeeebbbbbbddbbddbbbbbbbbb0bbbbbbbbb0bb0000000ddd00bbbbbbbbbbbbbbbbbbbbb1ff4beeeeccbbbbbbb0000000000bbb7b7777777777777b
beeeebbbbbeeeebbbbbbdbbbbddbbbbbbbb0bbbbbbbbb0bb090bbb000090bbbbbbbbbbbbbbbbbbbbb91f1bccccc4bbbbbbbb04400440bbbbbffff777777ffffb
beeebbbbbbbeebbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbbb000bbbbbbbbbbbbbbbbbbbbbb11b444bb444bbbbbbbb00bb00bbbbbf5f5ffb7bbff5f5f
bb44bbbbbbbbbbbbbbbb44444444bbbbbbbbb22e22222bbbbbb000000bbbbbbbbbb11119119bbbbbbbbb000000000bbbbbbbb000000bbbbbbbb000000bbbbbbb
b44bbbbbbb7bb4bbbbb4444444444bbbbbbb2222222222bbbb00eeee00b000bbb11111191991bbbbbbb00119191100bbbbbb05556660bbbbbbb0444000bbbbbb
b44bb7b7b7b7444bbbb44554444444bbbbb222ff2222eebbb00eeeeee0009000b111119999911bbbbb0011191991100bbbbb06665550bbbbbb007744400bbbbb
b4447777777744bbbb4455555444ee4bbbb2e2fff2eeeeeb00eeeeeeee494940b111999144191bbbbb0199199911110bbbbb05056060bbbbbb04477744000bbb
bb4447777777447bbb4455555444eee4bbbeefffff2ee22b0eeeffffee9494901999111444419bbbbb0111444499910bbbbb06065050bbbbb0044555774400bb
b777777777777777b445555555444444bbb22ffffff2222b0eef0ff0ee49494011111004440011bbb00114044041100bbbbb05066060bbbbb04944455557400b
bb7077777777077bb457555575444444bb22f0ffff0f222b0eef0ff0fee4940011111dd040dd11bbb0111404404110bbbbbb06555650bbbbb044444444455700
b777007777007777b477555577544444bb22f0ffff0f222b0eef0ff0fee0400b1111170d447011bbb01114044041100bb00000566500000b0040449440445570
bb7707777770777bb457555575554444bb22f0ffff0f222b0ee8ffff8ee040bb1111170d447011bbb01114444441110005656565556556500440444440444470
b55707777770755bb455555555554444b222ffffffff222b0ee9ffffeee040bb1111177d447711bb001110444401111006556655665655600440444440494470
5885777777775885b445555555554444b2228ffffff8222b0ee00000ee0040bb11114ddd444411bb0441666666464410b06005665656060b0944444444444770
5995855555585995b4455ccc55554444b222fffccff22eeb0eeddfddee0040bbb1114d4d444411bb0441665566564400b0500655556500500044494444444700
5555888888885555b444555555554444b22e2fffff2e2e2b0fedddddeff040bbb9111444444411bb006105665656160bbb0505660656050bb04444444444700b
b77589999998577bb444455555544444bee2e29999e2e22200ddddddd00040bbb1911544444511bbb050065555650050bbb00560006500bbb0004444944700bb
bff555555555fffb4445555555554444be2222f99f2222220fff000ff0b040bb1191115544511bbbbb0505660656050bbbbb0650b0650bbbbbb0044444700bbb
f5f5ffbbbbff5f5f4445555555555444bbb22ddffdd2222b00000b0000b000bb119911445511bbbbbbb00440004400bbbbbb0000b0000bbbbbbb00000000bbbb
bbbee555eee555bbbbbbb00000000bbbbbbbbb999999bbbbbbbb000000bbbbbb4bbbbbbbbbbbb4bbbb00bbbbbbbb0bbbbbbdddddddbbbbbbbbbbb000000bbbbb
bbee45c75444c7bbbbb00555ee5550bbbbbb999999999bbbbbb09999990bbbbb4444bbbbbbbb44bbb0e400b000b040bbbbd777ddddddbbbbbbbb0dddddd0bbbb
bee4e5c75444c5bbbb0045c5445c500bbbb9999999949ebbbb09ee999990bbbbb4e444bbbbb444bbb0e24004440040bbbd7787dddddddbbbbbb078dddddd0bbb
be4ee5cc57e5c5bbbb04e555ee555e0bbb9994f999994eebb09ee99999990bbbb4ee444444444bbbb0224444444420bbd777777dd75dddbbbb0777dddddd0bbb
b2eee555577555bbbb0eee7777eeee0bbb994ffff49ee49bb09e99ffff990bbbb422444444444bbbbb04444444440bbbd787575e7775ddbbbb087dc77cddd0bb
22eee7777777ebbbb00ee707707ee00bbb94ffffff99e94bb0999f0ff0f90bbbbb42040444440b0bbbb0440444040bbbd7777dc7777c5dbbbb0dd307703dd0bb
2eeee7707770ebbbb0eee707707ee0bbbb0400ff0040994bb0999f0ff0f90bbbbbb44000444000bbbbb04404440400bbddd70500770050bbb0ddd207702dd0bb
2eeee7707770eebbb0eee707707ee00bbb9037ff3709999bb0999f0ff0f90bbbbbb4447804087bbbbb044404440440bbdd55d07877780dbbb0ddd907709dd0bb
2eeeee707770eeebb0eee777777eee00bb9637ff3769999bbb099ffffff90bbbbb44447844487bbbb04444447044440bdd5dd67877786dbbb0ddd187781ddd0b
22eeee777777ebbbb00eee77771eeee0bb94fffffff4994bbbb099ffff90bbbbb44444444444470bbb002444004000bbd55d537777775dbbb0ddd0ceec0dddd0
22eeee667776ebbb0771ee11111ee770bb94fffffff9994bbb01111555110bbbb22244444444402bbbbb02444400bbbbd5d5d27777775ddb07762662626267d0
b2eeeee77777eebb07711e11111e1770bb94f9fffff9994bbb01111e5e110bbbbbb22444444422bbbbb0400000040bbb5d55d98777d75ddb077226662662270b
b22eeee7777eeebbb00001111111000bbb944feeff9994bbb0110115e51110bbbbb224444000bbbbbb044eeeeee440bb5d5ddd17ee765ddbb0ddd6666666d0bb
b2222ee777beeebbbbbb011111110bbbbbb94bfff9944bbbb0ff0222222ff0bbbbb22222222bbbbbbb044cccccc440bb5d5dd5d77765ddddb0dd2222222220bb
bb2222e666bbeebbbbbb011101110bbbbbbbb16669411bbbbb00022202200bbbbbeee222222ebbbbbbb00ccc0cc00bbbdd5dd5d6665dddddbb0222220222220b
bb2b1116611bbbbbbbbb011000110bbbbbb11155511111bbbbbb0fff0ff0bbbbbeeee77777eeebbbbbbb04440440bbbbdd5dd5d226255dddbbb00770b07700bb
bbeee333333333ebbeee000000eeeebebbbbbbbbbbbbbbbbbbbbb1111111bbbbbbbbb7777999bbbbbbbb000000bbbbbbbbbb444444bbbbbbbbbbbb000000bbbb
ebb33333333733beebe03333330eebeebbbb00bb0000bbbbbbb1111111111bbbbbbb777799999bbbbbb00999770bbbbbbbb444444444bbbbbbbbb04444440bbb
bb3333333373333eee0333333330eeeebbb010000440bbbbbb199198818919bbbbb77779999999bbbb0099999770bbbbbb44d44444444bbbbbbb0444444440bb
ee333333333355abe03aa33335550eebbb01d0dd0400000bb1999998828999bbbb7777999999999bbb0999999970bbbbb44d4444494444bbbbb044444444440b
555555333333555ee0333355555550bbb01d1dd0ddd0440bb111111c828111bbbb77999999999aabb00a994499990bbbb4d44449999d44bbbbb044999944440b
55555533d55dddeee0dddd7dd7dd0ebeb000d1dd1ed9000bb11110ccc2cc01bbbb9999999999aaabb0aaa40449990bbbbd444499999944bbbbb049299294440b
bee55dd5555ddddbe0dddd7dd7dd0eeeb0dddd1de8edd40bb1110000cc0000bbbb999999997aaaabb0aaa40440990bbbbd4444009900d0bbbbb049299294440b
bbe75dd575dddddbee0ddd7dd7dd0eeeb0d0ddd1de0d0400b11770a0cca007bbbb999994070aaaabb0aaa40440990bbbb4444072997204bbbbb049299294440b
ebddddddddd7dddebe0ddddddddd0eee000dd1ed1d0d0440b77716a06ca061bbbb990744076aaaabbb0aa44444a90bbbb4444572997254bbbbb049999994440b
eedd7ddddd7ddddebbe0ddddddd0eebe044dde8eddd04040b1111c8cccc8c1bbbb994444444aaaabbb00aa4444a000bbb44449999999d4bbbb04449999444440
bbedddddd7dddbeeeb0333a555330eeb040ddde00d097000b11118cccccc81bbbb94444444aaaaabbb0447744774440bb44449999999d4bbbb044ee99eee4440
beeddddd7ddddbbee0333333333330ee000099ddd09000bbb1111ccccc2cc1bbbbaa494444aaaabbb04447777777440bb44449999959d4bbbbb09eeeeee99000
eee7d7ddddddddebe0550333333550eebb0400d00470bbbbb11111cc22cc11bbbbaaa4ee44aaaabbb0449999999900bbb44d4499449944bbbb0cc9eeee90dd0b
beedddddd5555d5ee0dd0555555dd0ebbb0400444000bbbbbb11111cccc11bbbbbbaa44449aaabbbbb099999999990bbb44d4449999d44bbbb099aaaaaa0990b
bbe555555555a55bee00055505500eebbb000000440bbbbbb1111115551111bbbbbbbb999aa4bbbbb0aaaaaa0aaaaa0b444dd44999e44444bbb00aa0aaa000bb
eb55555555555555bbee05550550ebeebbbbbbb0000bbbbb111111122211111bbbb774444444777bbb004440004400bb44444ee999eee444bbbb09909990bbbb
bbbbbbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2dddddddddddddd2a99999999999999ab000bbbbbbbbbbbbbbbbbbb3bbbbeeeeee1bbbbb
bbbbbbbb0b00000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbd22d99999999d22d9569aaaaaaaa9659b070bbbb88bbbb88bbbbbb33bbbeeeeeeee1bbbb
0bbbbbbb000000bbb49999bbbbbbbbbbbbbbbbbbbbbbb94bbb94bbbbd2dd00000000dd2d969aa4444447a969b07000bbb88bb88bbbbbb33bbbbee1111ee1bbbb
00b0bbbbb00000bb4994499bbbbbbbbbbbb777777bbbb94bbb94bbbbddd007ee7ee00ddd99aa444444447a990077700bbb8b88bbbbbbb33bbbbee1bbbee1bbbb
b0bb00bbb00000bb49bbb49bbbbbbbbbbb77777777bbb94bbb94bbbbd99073eeeee3099d9aaa447777447aa90777770bbbb88bbbb33b33bbbbbbbbbbbee1bbbb
b00bb00b000b000b49bbb49bbbbbbbbbb7777777777bb9999994bbbbd990d77eee7d099d9aaa447aaa447aa90777770bbb888bbbbb3333bbbbbbbeeeeee1bbbb
b00bbbb0000bbb0b49bbbbbbbbbbbbbbb7757777577bbb99994bbbbbd9906577e756099d9aaaaaaaaa447aa90077770bb88b88bbbbb33bbbbbbbbeee111bbbbb
bb00bbb000bbbbbb49bbbbbbbbbbbbbbb7557777557bbbb994bbbbbbd99065a77a56099d9aaaaa4444447aa9b000000b88bbb88bbbbbbbbbbbbbbeee1bbbbbbb
bb0000000bbbbbbb49bbbbbbbbb9999bb7557777557bbbb994bbbbbbd990f677576f099d9aaaaa444777aaa9b00000bbbb67c6bbbb67e6bbbbbbbeee1bbbbbbb
bb000000bbbbbbbb49b49999bbb449bbb7777777777bbbb994bbbbbbd99011976790099d9aaaaa4447aaaaa9b077700bb677cc6bb677ee6bbbbbb111bbbbbbbb
b000000bbbbbbbbb49bbbb49499949bbbbb775577bbbbbb994bb9994d99081111118099d9aaaaa4447aaaaa9b077770bb6c7776bb6e7776bbbbbbeee1bbbbbbb
b00000000bbbbbbb499bbb49494949bbb7bb7777bb7bbbb994bb9494d99007c777c0099d9aaaaa777aaaaaa90077770b6cc777c66ee777e6bbbbbeee1bbbbbbb
b000b0000000000bb499b499494949bbbb77bbbb77bbbbb994bb9994ddd9000686009ddd99aaaa4447aaaa990777770b6777777667777776bbbbb111bbbbbbbb
bb00bbbb00000bbbbb49999b499949bbbbb777777bbbbbb994bb9494d2dd99000009dd2d969aaa4447aaa9690777770b6777cc766777ee76bbbbbbbbbbbbbbbb
b000bbbbb000bbbbbbbbbbbbbbbbbbbbbbbb7777bbbbbbbbbbbbbbbbd22d99999999d22d9569aa777aaa96590077770bb6c77c6bb6e77e6bbbbbbbbbbbbbbbbb
000bbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb2dddddddddddddd2a99999999999999ab000000bbb6776bbbb6776bbbbbbbbbbbbbbbbbb
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000965400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400604006040060400000
00100010240502b7503555030750000000000000000000002b750000000000000000000002f750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000025755257552575531755217551e7550000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500000000000000000000
001000000000220552215522855236552365523655200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000400001355023500205000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
000400001655000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000217512175121751217511c7511c7511c7511c75129751297512975129751217512175121751217512c7512c7512c7512c751207512075120751207512075120751207512075120751207512075120751
012000002335423354233542335423354303543035430354303541b3541b3541b3541b3542a3542a3542a3542a354223542235422354223541635416354163541635427354273542735427354193541935419354
000100201365000000000000000000000000000000000000000000000000000000000000000000000001265000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000012052120521205212052120521205212052120521d0521d0521d0521d0521d0521d0521d0521d0521d0521d0521d0521d0521e0521e0521e0521e0521e0521e0521e0521e0521e0521e0521e0521e052
0010000c1c550000001e5500000023550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002000121975219752000021e7521e752000021a7521a7522470223752237521b7021b7521b752000022375223752000020000200002000020000200002000020000200002000020000200002000020000200002
000800201d650006001d45000600236501d4001d450006001d4501d4001d4501c4001d4500e4001d450006001d450006000060000600006000060000600006000060000600006000060000600006000060000600
0110000019455194551945519455004050040500405204552045520455204550040500405164051645516455164551645500405004052c4051f4551f4551f4551f45500405004050040516455164551645516455
0110000020052200520000200002000020000200002200522005200002000020000200002000021f0521f0521f00200002000021900219002190521905202002000021f0021f002000022405224052000021f002
01040000120550000518455000051f2552510527155000050f5550f5550f555000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
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
03 10 42 43 44
03 15 14 43 44
01 17 42 43 16
02 17 18 43 16
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
