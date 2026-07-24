pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
--messages - by jusiv
--an odd game about texting.
--you can choose when it ends...
--how far are you willing to go?

mode = 0 --0 is room, 1 is raising phone, 2 is phone, 3 is closing phone
ending = 0
safe = 0
limit = 8 --max value of safe
wait = 0 --delay before accepting input
fork = 0 --tracks which topic the player went through first
a_count = 0 --used for animation
snd_wait = 300 --ambient sound delay

--room vars
quit = 0
e_frame = -1 --used for ending animation

--transition vars
phone_y = 120
phone_s = 0 --phone "scale"

--phone vars
online = 1 --1 = true, 0 = false
alert = 0
--  player actions
wait = 0
e_wait = 0
select = 0
input = 0
options = {"t00","t01","t02"}
--  messages
texts = {0,"t00",0,"t00",0,"t00",2,"t00",2,"t01"}
--    texts entry format: user,text index
--    user = 1 for player; user = 2 for friend, user = 3 for [redacted]
q_count = 100 --delay between incoming messages
q_delay = 100 --delay before friend reads message
s_text = 0 --0 = safe, 1 = read, 2 = unread
s_count = 0 --delay before messages become safe

--text list
p_texts = {t00="sure, i've got time",t01="geez it's been a month",t02="it's kinda late...",t03="lets talk tomorrow",t04="eh fine lets talk",t05="exactly",t06="of course",t07="not really...",t08="what's on your mind?",t09="what've you been up to?",t10="how's ohio been?",t11="missed me?",t12="eh, not much of note",t13="tests and papers :(",t14="i'm not used to the heat",t15="no new friends yet",t16="uh... we have lizards",t17="nah this place is lame",t18="miss working with you",t19="teachers here are nicer",t20="wish i had friends here",t21="definitely kinda strange",t22="i don't really miss it",t23="no need to shovel though",t24="yeah hopefully",t25="not likely",t26="glad i still have you",t27='define "catch"',t28="uh... not really yet",t29="i got bit twice so far",t30="true... ugh",t31="yeah that'd be a hassle",t32="we should still try",t33="i stand by my claim",t34="ok well besides him",t35="right, the cola incident",t36="hey same :p",t37="man that sucks",t38="kinda doubt i'll get any",t39="alright, talk away",t40="can this wait? it's late",t41="good or bad?",t42="can i tell you later?",t43="nothing, really",t44="my parents are fighting",t45="yeah sorry i need sleep",t46="yes, i'm done here",t47="alright, fine. tell me",t48="did she give a reason?",t49="yeah that's weird",t50="and...?",t51="yeah something's wrong",t52="i hope she's okay",t53="true, that is unlike her",t54="crap. any idea why?",t55="how long ago was that?",t56="who talked to her last?",t57="not since i left",t58="way too long ago",t59="no...",t60="what did you talk about?",t61="anyone call her parents?",t62="there must be a reason",t63="did she sound upset?",t64="anything seem unusual?",t65="how'd that go?",t66="sounds like a plan",t67="checked her house yet?",t68="not much else you can do",t69="maybe its her parents",t70="like they were fighting?",t71="go over and check on her",t72="fair enough",t73="so nothing else was odd?",t74="yeah i dunno what's up",t75="glad i could help",t76="hope you guys find her",t77="wish i could be there",t78="i guess i have one thing",t79="actually let's sleep",t80="hmm...",t81="actually, nevermind",t82="sorry, for another day",t83="i'll tell you later",t84="nothing worth discussing",t85="ever since we got here",t86="not right now, but often",t87="i wish it was only now",t88="i wish we'd never moved",t89="not trying to worry you",t90="it's not your fault",t91="yeah sorry about that",t92="i was trying to adjust",t93="hey, cut me some slack",t94="happens at least daily",t95="yelling seems normal now",t96="its never been violent",t97="the move always comes up",t98="they start with anything",t99="just angry at each other",ta0="only mom really likes it",ta1="dad's new job is a pain",ta2="seems like it",ta3="i've tried not to listen",ta4="unhappy about the move?",ta5="i think dad hates ca",ta6="i'm not gonna snoop",ta7="ok, i'll give it a shot",ta8="i really doubt it'd help",ta9="i wish",tb0="i really don't know",tb1="we haven't discussed it",tb2="if it comes down to it",tb3="i'd really rather not",tb4="i have no idea how",tb5="will do. thanks!",tb6="thanks for the advice",tb7="assuming i pull it off",tb8="yeah, exactly",tb9="i'll see what happens",tc0="i'll try if they don't",tc1="not at all",tc2="that won't go over well",tc3="no, but i can try to",tc4="you can't just move",tc5="i guess i could try",tc6="it's alright",tc7="let's sleep on it",tc8="see? this isnt' easy",tc9="fair enough",td0="alright, fine",td1="good idea",td2="anything on your mind?",td3="yes, please",td4="yeah i'm ready for sleep",td5="has been this whole time",td6="let's call it a night"}
f_texts = {t00="hey, wanna chat?",t01="we haven't talked lately",t02="i mean, same over here",t03="i take that as a no?",t04="ok, suit yourself",t05="time flies, doesn't it",t06="wait so do you?",t07="hey, cool. so...",t08="man where do we start",t09="same as always, mostly",t10="schoolwork, hockey, etc.",t11="snowy and cold",t12="it is winter, after all",t13="naaaaah",t14="jk, of course i have",t15="what's new on your end?",t16="you're in ca now though",t17="there must be something",t18="ugh you and me both",t19="school is school i guess",t20="they do call it sunny ca",t21="must be odd without snow",t22="just give it some time",t23="i'm sure you'll get some",t24="managed to catch any?",t25="at least it's warm there",t26="aw... yeah same",t27="but it'd be hard to do",t28="over long-distance",t29="i dunno...",t30="hard to top mr. k",t31="yeah, i'd imagine",t32="at least it's pretty",t33="but yeah, can be a pain",t34="fair point",t35="still no snow days yet",t36="i'm rooting for you!",t37="i'd say lighten up, but",t38="yes glad i have you, too",t39="speaking of friends, you",t40="need to hear something",t41='i take that as a "no"',t42="aw... well, keep trying",t43="oh no",t44="what else is up in ca?",t45="we could try if you want",t46="assuming things line up",t47="ok fine, be that way :p",t48="ok maybe",t49="that was an adventure :p",t50="speaking of school, you",t51="haha :)",t52="yeahhh...",t53="i'd really rather it not",t54="but if you insist",t55="ok, but let's talk soon",t56="goodnight",t57="alright, if you need to",t58="i doubt that, but fine",t59="hey there's something",t60="i wanted to tell you",t61="unfortunately the latter",t62="jade hasn't been seen",t63="or heard from for 4 days",t64="no, not at all",t65="she's just vanished",t66="won't answer her phone",t67="yeah no kidding",t68="...are you serious?",t69="she's so straight-laced",t70="she'd never do this",t71="i'm definitely worried",t72="especially since she was",t73="kinda down last i heard",t74="not really",t75="about a week",t76="i think i was",t77="have you talked to her?",t78="hmm...",t79="i was just calling her",t80="to ask about schoolwork",t81="as far as i'm aware, no",t82="but i've tried her phone",t83="i'll call them tomorrow",t84="now that you mention it",t85="when i called her last",t86="i heard adults shouting",t87="maybe a little?",t88="i didn't focus in on it",t89="the call was kinda quick",t90="with her? no. but",t91="it seemed to go fine",t92="was pretty business-like",t93="hmm... during the call",t94="if i remember right",t95="ok. i'll keep you posted",t96="nope. but i will",t97="if calling doesn't work",t98="you're right",t99="no point stressing more",ta0="that's what i'm fearing",ta1="thanks for listening",ta2="its way too late tonight",ta3="but i'll do it tomorrow",ta4="thanks for the advice",ta5="let's hope this works",ta6="i don't want to think",ta7="what happens if we don't",ta8="yeahhh... ah well",ta9="you've done your part",tb0="ok lets change subject",tb1="alright, let's hear it",tb2="nothing important in ca?",tb3="oh. well in that case",tb4="i guess i should sleep",tb5="wait, just right now?",tb6="or has this been going",tb7="on for a while?",tb8="damn",tb9="i'm so sorry",tc0="it wasn't your idea",tc1="can't wind back time",tc2="i'm glad you're telling",tc3="me now, though. a month",tc4="is a long silence",tc5="well of course not",tc6="it's not yours, either",tc7="no apology needed",tc8="i understand",tc9="it's alright",td0="i'm sure you had reasons",td1="how bad is the fighting?",td2="geez. if you don't mind",td3="me asking, what do",td4="i guess that's not as",td5="bad. anything specific",td6="they argue about?",td7="is ca not working",td8="out well for them?",td9="hmm... sounds like there",te0="is an underlying dispute",te1="any idea what?",te2="yeah that's a problem",te3="sorry to hear that",te4="i think you should try",te5="to figure out what's up",te6="may be some way to help",te7="but it was their idea!",te8="you think you guys might",te9="move back here, then?",tf0="fair enough",tf1="it might be awkward but",tf2="you could ask them",tf3="good luck!",tf4="let me know how it goes",tf5="i mean it's up to you",tf6="if you'd rather let them",tf7="sort it out, that's fine",tf8="have you talked to them",tf9="about it yet?",tg0="if you guys aren't happy",tg1="there, it might be worth",tg2="bringing up",tg3="alright",tg4="suit yourself",tg5="hmmm. sorry, i've got",tg6="no ideas right now",tg7="you're welcome!",tg8="i have faith in you",tg9="well, i'd consider it",th0="you know better than me",th1="true. especially so soon",th2="i vote we return to this",th3="after thinking over it",th4="good plan",th5="yeah actually",th6="doubt this is better but",th7="ok... geez it's late now",th8="true",th9="ok i'm off to bed",ti0="so"}
e_texts = {t04="fine, kill yourself jerk",t14="you never mattered",t22="you've never had friends",t26="you always held me back",t32="no one misses you",t55="i'm so glad you're gone",t56="you can't escape, though",t58="your life is worthless",t66="exactly like you will",t67="it's just as i wanted",t69="this is your fault",t74="you did this to her",t75="you're too late",t76="it should have been you",t79="how terrible you've been",t82="there's no hope for her",t84="quit hiding from reality",t94="jade said she hates you",tb0="i know that was all lies",tb1="how worthless you are?",tb2="you're wasting oxygen",tb9="you know you caused this",tc7="you never wanted us",tc8="you cut us off",tc9="we won't forgive you",td7="they wish they left you",te1="must be about you, idiot",te6="maybe grow a spine, wimp",tf8="they did it to hurt you",tg1="it's because of you"}


function ambience()
 --play ambient sound
 snd_wait = 500+flr(rnd(201-5*safe))-25*safe
 if safe == 0 then return
 elseif safe < limit then sfx(11+flr(rnd(safe)),1)
 end
end


function clear_oldest()
 --clear oldest past message
 local val
 val = texts[1]
 del(texts, val)
 val = texts[1]
 del(texts, val)
end


function pick_end()
 if safe == 0 then ending = 1
 elseif safe < 3 then ending = 2
 elseif safe < 6 then ending = 3
 elseif safe < limit then ending = 4
 else ending = 5 end
end


function respond(input)
 --d e b u g
 --q_delay = 5
 --q_count = 10
 q_delay = 100+flr(rnd(151))
 q_count = 50+flr(rnd(51))
 if input == "t01" then
    add(texts,2)
    add(texts,"t05")
    add(texts,2)
    add(texts,"t06")
    options = {"t06","t07","t08"}
    return
 end
 if input == "t02" then
    add(texts,2)
    add(texts,"t02")
    add(texts,2)
    add(texts,"t03")
    options = {"t03","t04","t05"}
    return
 end
 if input == "t03" then
    add(texts,2)
    add(texts,"t04")
    online = 0
    return
 end
 if input == "t05" or input == "t07" then
    add(texts,3)
    add(texts,"t04")
    online = 0
    return
 end
 if input == "t00" or input == "t04" or input == "t06" then
 			add(texts,2)
    add(texts,"t07")
 end
 if input == "t00" or input == "t04" or input == "t06" or input == "t08" then
    add(texts,2)
    add(texts,"t08")
    options = {"t09","t10","t11"}
    return
 end
 if input == "t09" then
 			add(texts,2)
    add(texts,"t09")
    add(texts,2)
    add(texts,"t10")
 end
 if input == "t10" then
 			add(texts,2)
    add(texts,"t11")
    add(texts,2)
    add(texts,"t12")
 end
 if input == "t11" then
 			add(texts,2)
    add(texts,"t13")
    add(texts,3)
    add(texts,"t14")
 end
 if input == "t09" or input == "t10" or input == "t11" then
    add(texts,2)
    add(texts,"t15")
    options = {"t12","t13","t14"}
    return
 end
 if input == "t12" then
    add(texts,2)
    add(texts,"t16")
    add(texts,2)
    add(texts,"t17")
    options = {"t15","t16","t17"}
    return
 end
 if input == "t13" then
    add(texts,2)
    add(texts,"t18")
    add(texts,2)
    add(texts,"t19")
    options = {"t18","t19","t20"}
    return
 end
 if input == "t17" then
    add(texts,2)
    add(texts,"t25")
 end
 if input == "t14" or input == "t17" then
    add(texts,2)
    add(texts,"t20")
    add(texts,2)
    add(texts,"t21")
    options = {"t21","t22","t23"}
    return
 end
 if input == "t15" or input == "t20" then
    add(texts,3)
    add(texts,"t22")
    add(texts,2)
    add(texts,"t23")
    options = {"t24","t25","t26"}
    return
 end
 if input == "t16" then
    add(texts,2)
    add(texts,"t24")
    options = {"t27","t28","t29"}
    return
 end
 if input == "t18" then
    add(texts,3)
    add(texts,"t26")
    add(texts,2)
    add(texts,"t27")
    add(texts,2)
    add(texts,"t28")
    options = {"t30","t31","t32"}
    return
 end
 if input == "t19" then
    add(texts,2)
    add(texts,"t29")
    add(texts,2)
    add(texts,"t30")
    options = {"t33","t34","t35"}
    return
 end
 if input == "t21" then
 			add(texts,2)
    add(texts,"t31")
 end
 if input == "t22" then
 			add(texts,3)
    add(texts,"t32")
    add(texts,2)
    add(texts,"t33")
 end
 if input == "t23" then
 			add(texts,2)
    add(texts,"t34")
 end
 if input == "t21" or input == "t22" or input == "t23" then
    add(texts,2)
    add(texts,"t35")
    options = {"t36","t37","t38"}
    return
 end
 if input == "t24" then
 			add(texts,2)
    add(texts,"t36")
 end
 if input == "t25" then
    add(texts,2)
    add(texts,"t37")
 end
 if input == "t26" then
 			add(texts,2)
    add(texts,"t38")
 end
 if input == "t24" or input == "t25" or input == "t26" then
    add(texts,2)
    add(texts,"t39")
 end
 if input == "t33" then
 			add(texts,2)
    add(texts,"t47")
 end
 if input == "t34" then
    add(texts,2)
    add(texts,"t48")
 end
 if input == "t35" then
 			add(texts,2)
    add(texts,"t49")
 end
 if input == "t33" or input == "t34" or input == "t35" then
    add(texts,2)
    add(texts,"t50")
 end
 if input == "t24" or input == "t25" or input == "t26" or input == "t33" or input == "t34" or input == "t35" then
    add(texts,2)
    add(texts,"t40")
    options = {"t39","t40","t41"}
    return
 end
 if input == "t27" then
 			add(texts,2)
    add(texts,"t41")
 end
 if input == "t28" then
    add(texts,2)
    add(texts,"t42")
 end
 if input == "t29" then
 			add(texts,2)
    add(texts,"t43")
 end
 if input == "t30" or input == "t31" then
    add(texts,2)
    add(texts,"t45")
 end
 if input == "t30" or input == "t31" or input == "t32" then
    add(texts,2)
    add(texts,"t46")
 end
 if input == "t36" then
    add(texts,2)
    add(texts,"t51")
 end
 if input == "t37" or input == "t38" then
    add(texts,2)
    add(texts,"t52")
    add(texts,2)
    add(texts,"ti0")
 end
 if input == "t27" or input == "t28" or input == "t29" or input == "t30" or input == "t31" or input == "t32" or input == "t36" or input == "t37" or input == "t38" then
    add(texts,2)
    add(texts,"t44")
    options = {"t42","t43","t44"}
    return
 end
 if input == "t40" then
    add(texts,2)
    add(texts,"t53")
    add(texts,2)
    add(texts,"t54")
    options = {"t45","t46","t47"}
    return
 end
 if input == "t45" then
    add(texts,2)
    add(texts,"t55")
 end
 if input == "t46" then
    add(texts,3)
    add(texts,"t55")
 end
 if input == "t45" or input == "t46" then
    add(texts,2)
    add(texts,"t56")
    online = 0
    return
 end
 if input == "t42" then
    add(texts,2)
    add(texts,"t57")
 end
 if input == "t43" then
    add(texts,3)
    add(texts,"t58")
 end
 if input == "t42" or input == "t43" then
    add(texts,2)
    add(texts,"t59")
    add(texts,2)
    add(texts,"t60")
    options = {"t39","t40","t41"}
    return
 end
 -- fork, path #1
 if input == "t41" then
    add(texts,2)
    add(texts,"t61")
 end
 if input == "td2" then
    add(texts,2)
    add(texts,"th5")
 end
 if input == "td3" then
    add(texts,2)
    add(texts,"th6")
 end
 if input == "t39" or input == "t41" or input == "t47" or input == "td2" or input == "td3" then
    add(texts,2)
    add(texts,"t62")
    add(texts,2)
    add(texts,"t63")
    options = {"t48","t49","t50"}
    if fork == 0 then fork = 1 end
    return
 end
 if input == "t48" then
    add(texts,2)
    add(texts,"t64")
    add(texts,2)
    add(texts,"t65")
    add(texts,3)
    add(texts,"t66")
    options = {"t51","t52","t53"}
    return
 end
 if input == "t49" then
    add(texts,3)
    add(texts,"t67")
    add(texts,2)
    add(texts,"t69")
 end
 if input == "t50" then
    add(texts,2)
    add(texts,"t68")
    add(texts,3)
    add(texts,"t69")
 end
 if input == "t49" or input == "t50" then
    add(texts,2)
    add(texts,"t70")
    options = {"t51","t52","t53"}
    return
 end
 if input == "t51" or input == "t52" or input == "t53" then
    add(texts,2)
    add(texts,"t71")
    add(texts,2)
    add(texts,"t72")
    add(texts,2)
    add(texts,"t73")
    options = {"t54","t55","t56"}
    return
 end
 if input == "t54" then
    add(texts,3)
    add(texts,"t74")
 end
 if input == "t55" then
    add(texts,3)
    add(texts,"t75")
 end
 if input == "t56" then
    add(texts,3)
    add(texts,"t76")
 end
 if input == "t54" or input == "t55" or input == "t56" then
    add(texts,2)
    add(texts,"t77")
    options = {"t57","t58","t59"}
    return
 end
 if input == "t57" or input == "t58" or input == "t59" then
    add(texts,2)
    add(texts,"t78")
    options = {"t60","t61","t62"}
    return
 end
 if input == "t60" then
    add(texts,3)
    add(texts,"t79")
    add(texts,2)
    add(texts,"t80")
    options = {"t63","t64","t65"}
    return
 end
 if input == "t61" then
    add(texts,2)
    add(texts,"t81")
    add(texts,3)
    add(texts,"t82")
    add(texts,2)
    add(texts,"t83")
    options = {"t66","t67","t68"}
    return
 end
 if input == "t63" then
    add(texts,2)
    add(texts,"t87")
    add(texts,2)
    add(texts,"t88")
    add(texts,2)
    add(texts,"t89")
    options = {"t72","t73","t74"}
    return
 end
 if input == "t65" then
    add(texts,2)
    add(texts,"t91")
    add(texts,2)
    add(texts,"t92")
    options = {"t72","t73","t74"}
    return
 end
 if input == "t62" then
    add(texts,3)
    add(texts,"t84")
    add(texts,2)
    add(texts,"t85")
 end
 if input == "t64" then
    add(texts,2)
    add(texts,"t90")
 end
 if input == "t72" or input == "t73" or input == "t74" then
    add(texts,2)
    add(texts,"t93")
    add(texts,3)
    add(texts,"t94")
 end
 if input == "t62" or input == "t64" or input == "t72" or input == "t73" or input == "t74" then
    add(texts,2)
    add(texts,"t86")
    options = {"t69","t70","t71"}
    return
 end 
 if input == "t66" then
    add(texts,2)
    add(texts,"t95")
 end
 if input == "t67" then
    add(texts,2)
    add(texts,"t96")
    add(texts,2)
    add(texts,"t97")
 end
 if input == "t68" then
    add(texts,2)
    add(texts,"t98")
    add(texts,2)
    add(texts,"t99")
 end
 if input == "t71" then
    add(texts,2)
    add(texts,"ta2")
    add(texts,2)
    add(texts,"ta3")
 end
 if input == "t66" or input == "t67" or input == "t68" or input == "t71" then
    add(texts,2)
    add(texts,"ta4")
    options = {"t75","t76","t77"}
    return
 end
 if input == "t69" or input == "t70" then
    add(texts,2)
    add(texts,"ta0")
    add(texts,2)
    add(texts,"t83")
    add(texts,2)
    add(texts,"ta1")
    options = {"t75","t76","t77"}
    return
 end
 if input == "t75" then
    add(texts,2)
    add(texts,"ta5")
 end
 if input == "t76" then
    add(texts,2)
    add(texts,"ta6")
    add(texts,2)
    add(texts,"ta7")
 end
 if input == "t77" then
    add(texts,2)
    add(texts,"ta8")
    add(texts,2)
    add(texts,"ta9")
 end
 if input == "t75" or input == "t76" or input == "t77" then
    if fork == 1 then
       add(texts,2)
       add(texts,"tb0")
       options = {"t78","t79","t80"}
    else
       add(texts,2)
       add(texts,"th7")
       options = {"td4","td5","td6"}
    end
    return
 end
 if input == "t78" then
    add(texts,3)
    add(texts,"tb1")
    options = {"t44","t81","t82"}
    return
 end
 if input == "t80" then
    add(texts,3)
    add(texts,"tb2")
    options = {"t44","t83","t84"}
    return
 end
 -- fork, path #2
 if input == "t44" then
    add(texts,2)
    add(texts,"tb5")
    add(texts,2)
    add(texts,"tb6")
    add(texts,2)
    add(texts,"tb7")
    options = {"t85","t86","t87"}
    if fork == 0 then fork = 2 end
    return
 end
 if input == "t85" or input == "t86" or input == "t87" then
    add(texts,2)
    add(texts,"tb8")
    add(texts,3)
    add(texts,"tb9")
    options = {"t88","t89","t90"}
    return
 end
 if input == "t89" then
    add(texts,2)
    add(texts,"tc2")
    add(texts,2)
    add(texts,"tc3")
    add(texts,2)
    add(texts,"tc4")
    options = {"t91","t92","t93"}
    return
 end 
 if input == "t88" then
    add(texts,2)
    add(texts,"tc0")
    add(texts,2)
    add(texts,"tc1")
 end
 if input == "t90" then
    add(texts,2)
    add(texts,"tc5")
    add(texts,2)
    add(texts,"tc6")
 end
 if input == "t91" then
    add(texts,3)
    add(texts,"tc7")
 end
 if input == "t92" then
    add(texts,3)
    add(texts,"tc8")
 end
 if input == "t93" then
    add(texts,3)
    add(texts,"tc9")
 end
 if input == "t91" or input == "t92" or input == "t93" then
    add(texts,2)
    add(texts,"td0")
 end
 if input == "t88" or input == "t90" or input == "t91" or input == "t92" or input == "t93" then
    add(texts,2)
    add(texts,"td1")
    options = {"t94","t95","t96"}
    return
 end
 if input == "t94" or input == "t95" then
    add(texts,2)
    add(texts,"td2")
    add(texts,2)
    add(texts,"td3")
 end
 if input == "t96" then
    add(texts,2)
    add(texts,"td4")
    add(texts,2)
    add(texts,"td5")
 end
 if input == "t94" or input == "t95" or input == "t96" then
    add(texts,2)
    add(texts,"td6")
    options = {"t97","t98","t99"}
    return
 end
 if input == "t97" then
    add(texts,3)
    add(texts,"td7")
    add(texts,2)
    add(texts,"td8")
    options = {"ta0","ta1","ta2"}
    return
 end
 if input == "t98" or input == "t99" then
    add(texts,2)
    add(texts,"td9")
    add(texts,2)
    add(texts,"te0")
    add(texts,3)
    add(texts,"te1")
    options = {"ta3","ta4","ta5"}
    return
 end
 if input == "ta0" or input == "ta5" then
    add(texts,2)
    add(texts,"te2")
 end
 if input == "ta1" or input == "ta2" then
    add(texts,2)
    add(texts,"te3")
 end
 if input == "ta4" then
    add(texts,2)
    add(texts,"te7")
 end
 if input == "ta0" or input == "ta1" or input == "ta2" or input == "ta4" or input == "ta5" then
    add(texts,2)
    add(texts,"te8")
    add(texts,2)
    add(texts,"te9")
    options = {"ta9","tb0","tb1"}
    return
 end
 if input == "ta3" then
    add(texts,2)
    add(texts,"te4")
    add(texts,2)
    add(texts,"te5")
    add(texts,3)
    add(texts,"te6")
    options = {"ta6","ta7","ta8"}
    return
 end
 if input == "ta9" or input == "tb0" then
    add(texts,3)
    add(texts,"tf8")
    add(texts,2)
    add(texts,"tf9")
    options = {"tc1","tc2","tc3"}
    return
 end
 if input == "tb1" then
    add(texts,2)
    add(texts,"tg0")
    add(texts,3)
    add(texts,"tg1")
    add(texts,2)
    add(texts,"tg2")
    options = {"tc2","tc4","tc5"}
    return
 end
 if input == "ta6" then
    add(texts,2)
    add(texts,"tf0")
    add(texts,2)
    add(texts,"tf1")
    add(texts,2)
    add(texts,"tf2")
    options = {"tb2","tb3","tb4"}
    return
 end
 if input == "ta7" or input == "tc5" then
    add(texts,2)
    add(texts,"tf3")
 end
 if input == "tb2" then
    add(texts,2)
    add(texts,"tg3")
 end
 if input == "ta7" or input == "tb2" or input == "tc3" or input == "tc5" then
    add(texts,2)
    add(texts,"tf4")
    options = {"tb5","tb6","tb7"}
    return
 end
 if input == "ta8" then
    add(texts,2)
    add(texts,"tf5")
    add(texts,2)
    add(texts,"tf6")
    add(texts,2)
    add(texts,"tf7")
    options = {"tb8","tb9","tc0"}
    return
 end
 if input == "tb4" then
    add(texts,2)
    add(texts,"tg5")
    add(texts,2)
    add(texts,"tg6")
    options = {"tc6","tc7","tc8"}
    return
 end
 if input == "tb3" then
    add(texts,2)
    add(texts,"tg4")
 end
 if input == "tb8" or input == "tb9" or input == "tc0" then
    add(texts,2)
    add(texts,"tg3")
 end
 if input == "tc1" then
    add(texts,2)
    add(texts,"tg9")
 end
 if input == "tc2" then
    add(texts,2)
    add(texts,"th0")
 end
 if input == "tc4" then
    add(texts,2)
    add(texts,"th1")
 end
 if input == "tb3" or input == "tb8" or input == "tb9" or input == "tc0" or input == "tc1" or input == "tc2" or input == "tc4" then
    add(texts,2)
    add(texts,"th2")
    add(texts,2)
    add(texts,"th3")
    options = {"tc9","td0","td1"}
    return
 end
 if input == "tb5" or input == "tb6" then
    add(texts,2)
    add(texts,"tg7")
 end
 if input == "tb7" then
    add(texts,2)
    add(texts,"tg8")
 end
 if input == "tc7" then
    add(texts,2)
    add(texts,"th4")
 end
 if input == "tb5" or input == "tb6" or input == "tb7" or input == "tc7" or input == "tc9" or input == "td0" or input == "td1" then
    if fork == 2 then
       add(texts,3)
       add(texts,"tb0")
       options = {"td2","td3","t79"}
    else
       add(texts,2)
       add(texts,"th7")
       options = {"td4","td5","td6"}
    end
    return
 end
 -- very end
 if input == "t81" or input == "t82" or input == "t83" or input == "t84" then
    add(texts,2)
    add(texts,"tb3")
    add(texts,2)
    add(texts,"tb4")
 end
 if input == "t79" or  input == "td4" or input == "td6" then
    add(texts,2)
    add(texts,"tg3")
 end
 if input == "td5" then
    add(texts,2)
    add(texts,"th8")
 end
 if input == "t79" or input == "td4" or input == "td5" or input == "td6" then
    add(texts,2)
    add(texts,"th9")
 end
 if input == "t79" or input == "t81" or input == "t82" or input == "t83" or input == "t84" or input == "td4" or input == "td5" or input == "td6" then
    add(texts,3)
    add(texts,"t56")
    online = 0
    return
 end
end


function _update()
 --if game is over, don't update
 if ending > 0 then return end
 --animate
 a_count = (a_count+1)%30
 --ambience
 snd_wait -= 1
 if snd_wait <= 0 then ambience() end
 --update response queue
 if q_delay <= 0 then
    if q_count > 0 then
       q_count -= 1
       if q_count <= 0 and texts[7] != nil then
   					  --remove oldest past message
          clear_oldest()
          --update variables for new message
          if texts[5] > 2 then s_text = 2 end
          if mode == 0 or mode == 3 then alert = 1 end
          --if another message queued, reset timer
          if texts[7] != nil then q_count = 80+flr(rnd(40)) end
          if mode == 2 or safe < limit  then sfx(0,0) end
       end
    end
 else q_delay -= 1 end
 --if viewing room
 if mode == 0 then
    if safe < limit then
       --if player trying to sleep
    			if btn(5) then
          quit += 1
          if quit > 40 then pick_end() end
   	 		else
   	 		   quit = 0
   	 		   --if player opening phone
   	 		   if btn(4) then
   	 		      alert = 0
   	 		      mode = 1
   	 		   end
   	 		end
   	else
   	   --if at ending 5
   	   e_wait += 1
   	   if e_frame < 0 then
   	   			e_frame = 0
   			    sfx(-1,0)
			       sfx(-1,1)
   	   			music(1)
   	   end
   	   if e_wait >= 25 then
   	      e_wait = 0
   	      e_frame += 1
   	      if e_frame == 4 then music(2) end
   	      if e_frame == 8 then music(3) end
   	      if e_frame == 12 then music(4) end
   	      if e_frame >= 16 then ending = 5 end
   	   end
    end
 --if raising phone
 elseif mode == 1 then
    if phone_y > 56 then phone_y -= 4
    elseif phone_s < 150 then phone_s += 5
    else mode = 2 end
 --if viewing phone
 elseif mode == 2 then
    --update to safe texts
    if s_count > 0 then
       s_count -= 1
       if s_count <= 0 then s_text = 0 end
    end
    if s_text == 2 then
       s_text = 1
       safe += 1
       s_count = 70
       if q_count > 0 then q_count += 70 end
       wait = 70
       snd_wait += 75
       music(0,0,12)
       if safe >= limit then sfx(8,1) end
    end
    if wait <= 0 then
       if online == 1 and q_count <= 0 then
          --change selected response
          if btn(0) or btn(2) then
             select=(select+2)%3
             wait = 5
          end
          if btn(1) or btn(3) then
             select=(select+1)%3
             wait = 5
          end
          --pick the selected respone
          if btn(4) then
             sfx(1,0)
             input = options[select+1]
             add(texts,1)
             add(texts,input)
             clear_oldest()
             respond(input)
          end
       end
       if btn(5) then mode = 3 end
    end
 --if lowering phone
 elseif mode == 3 then
    if phone_s > 0 then phone_s -= 5
    elseif phone_y < 120 then phone_y += 4
    else
       mode = 0
       if safe >= limit then wait = 0 end
    end
 end
 --countdown wait
 if wait > 0 then wait -= 1 end
 --if game over, silence audio
 if ending > 0 then
    music(-1)
    sfx(-1,0)
    sfx(-1,1)
 end
end


function _draw()
 cls()
 color(7)
 if ending == 0 then
    --draw the room
    if safe > 5 then sspr(0,32,32,32, 0,0,128,128)
    else sspr(40,0,32,32, 0,0,128,128)
    end
    if safe >= limit then
       --draw [redacted]
       pal(15,0)
       sspr(64+16*flr(e_frame/4),32,16,16, 32,28-4*(e_frame%2),64,64)
       sspr(64,48,32,16, 0,92-4*(e_frame%2),128,64)
    end
			 --draw the phone
			 if safe < limit or mode > 0 then
			    sspr(8,16,16,16, 56-phone_s,phone_y-phone_s,16+(2*phone_s),16+(2*phone_s))
			 end
    --if viewing the room, draw the ui
    if mode == 0 and safe < limit then
       --draw alert
       if alert == 1 then spr(35+flr(a_count/15),60,112,1,2) end
       --draw sleeping progress
       if quit > 0 then
       			--draw eyelids
       			rectfill(0,0,128,quit*4,0)
       			rectfill(0,128-(quit*4),128,128)
       			--draw meter
          print('falling asleep...', 22,54,7)
          rectfill(23,61,105,66)
          rectfill(24,62,104,65,13)
          rectfill(24,62,24+(2*quit),65,12)
       else
       			if a_count <= 7 or a_count >= 22 then color(7)
          else color(6)
          end
          print('Ž: use phone',2,122)
          print('—: sleep',91,122)
       end
    --if viewing phone, draw the screen
    elseif mode == 2 then
       --draw past messages
       local msg
       local ypos
       for i=1,6,2 do
          if texts[i] != 0 then
             msg = texts[i+1]
             ypos = 5+(11*i)
             if texts[i] == 1 then
                rectfill(6,ypos-1,23,ypos+16,13)
                rectfill(24,ypos+8,121,ypos+16)
                rectfill(7,ypos,22,ypos+15,0)
                spr(1,7,ypos,2,2)
                print(p_texts[msg],25,ypos+10,7)
             else
                rectfill(6,ypos-1,23,ypos+16,5)
                rectfill(24,ypos+8,121,ypos+16)
                rectfill(7,ypos,22,ypos+15,0)
                spr(3,7,ypos,2,2)
                if texts[i] == 2 or s_text == 0 then
                   print(f_texts[msg],25,ypos+10,7)
                else
                   print(e_texts[msg],25,ypos+10,8)
                   --draw distorted icon
                   if safe == 1 and flr(rnd(2)) == 1 then spr(84,7+rnd(2),ypos+7+rnd(2))
                   elseif safe > 1 then spr(84,7+rnd(2),ypos+7+rnd(2)) end
                   if safe == 3 and flr(rnd(2)) == 1 then spr(69,14+rnd(2),ypos+rnd(2))
                   elseif safe > 3 then spr(69,14+rnd(2),ypos+rnd(2)) end
                   if safe == 5 and flr(rnd(2)) == 1 then spr(85,14+rnd(2),ypos+7+rnd(2))
                   elseif safe > 5 then spr(85,14+rnd(2),ypos+7+rnd(2)) end
                   if safe == 7 and flr(rnd(2)) == 1 then spr(68,7+rnd(2),ypos+rnd(2))
                   elseif safe > 7 then spr(68,7+rnd(2),ypos+rnd(2)) end
                end
             end
          end
       end
       --draw pick message box
       line(6,89,121,89,6)
       rectfill(6,91,121,118,13)
       rectfill(7,82,24,104)
       rectfill(8,83,23,98,0)
       spr(1,8,83,2,2)
       print('say something!',26,93,6)
       --draw text options
       if q_count > 0 then
          if q_delay <= 0 then print("<they are typing.>",12,107,6) end
       elseif online == 1 then
          if wait < 5 then
             print('>',7+flr(a_count/15),101+(6*select),7)
             msg = options[1]
             print(p_texts[msg],12,101)
             msg = options[2]
             print(p_texts[msg],12,107)
             msg = options[3]
             print(p_texts[msg],12,113) 
          end
       else print("<they are offline.>",12,107,6)
       end
       --draw ui
       rectfill(47,2,81,10,7)
       rectfill(46,3,82,9)
       print('messages',49,4,13)
       if a_count <= 7 or a_count >= 22 then color(7)
       else color(6)
       end
       if online == 1 then print('Ž: send text',7,121) end
       print('—: put away',74,121)
       --d e b u g
       --print(wait.." "..q_delay.." "..q_count.." "..snd_wait,6,1,7)
    end
 --draw ending screen
 else
    if ending == 1 then
       print('you had a normal night.',2,2)
    elseif ending == 2 then 
       print('you had troubled dreams',2,2)
       print('that night.',2,8)
    elseif ending == 3 then 
       print('nightmares plagued your sleep',2,2)
       print('that night.',2,8)
       print('you woke up screaming twice.',2,14)
    elseif ending == 4 then 
       print('you barely slept that night.',2,2)
       print('you heard sounds from somewhere',2,8)
       print("close that you couldn't explain.",2,14)
       print('it felt like something was',2,20)
       print('hunting you down.',2,26)
    end
    print('<end>', 58,58,8)
 end
end
__gfx__
0000000077777777777777777777777777777777111111111111111d1ddddd1d1ddddddd00000000000000000000000000000000000000000000000000000000
0000000076666666666666677666666666666667d111111111d1d1dddddddd11dddddddd00000000000000000000000000000000000000000000000000000000
007007007600000000000067760000000000006711111d1d1d1ddddddddddd1d1ddddddd00000000000000000000000000000000000000000000000000000000
00077000760000000000006776000aaaaaa00067d1d1d1d1d1dddddddddddd11dddddddd00000000000000000000000000000000000000000000000000000000
0007700076000000000000677600aaaaaaaa0067dd1d1d1ddddddddddddddd1ddddddddd00000000000000000000000000000000000000000000000000000000
007007007600770000770067760a00aaaa00a067d1d1dddddddd66dddddddd1d1ddddddd00000000000000000000000000000000000000000000000000000000
000000007600770000770067760a00aaaa00a067dddddddddd6616dddddddd1ddddddddd00000000000000000000000000000000000000000000000000000000
000000007600000000000067760aaaaaaaaaa067dddddddd667116dddddddd1ddddddddd00000000000000000000000000000000000000000000000000000000
000000007600000000000067760aaaaaaaaaa067dddddd66677116dddddddd1ddddddddd00000000000000000000000000000000000000000000000000000000
000000007600700000070067760a0aaaaaa0a067dddd6677677116dddddddd1ddddddddd00000000000000000000000000000000000000000000000000000000
000000007600700000070067760aa0aaaa0aa067ddd61117671116dddddddd1dddddddd400000000000000000000000000000000000000000000000000000000
0000000076000777777000677600aa0000aa0067ddd61111611666dddddddd1ddddddd4400000000000000000000000000000000000000000000000000000000
00000000760000000000006776000aaaaaa00067ddd61111666116dddddddd1dddd94d4400000000000000000000000000000000000000000000000000000000
0000000076000000000000677600000000000067ddd61166611116dddddddd1dddd44d4400000000000000000000000000000000000000000000000000000000
0000000076666666666666677666666666666667ddd66611611116dddddddd1dddd4446600000000000000000000000000000000000000000000000000000000
0000000077777777777777777777777777777777ddd61111611166dddddddd1ddddcc66600000000000000000000000000000000000000000000000000000000
0000000000007777777700000000000000000000ddd611116166dddddddddd1dcccccdd600000000000000000000000000000000000000000000000000000000
0000000000076666666670000000000000aaaa00ddd6111166ddddddddddddcccccccccd00000000000000000000000000000000000000000000000000000000
000000000007611111167000000000000a0000a0ddd61166dddddd99ddddcccccccccccc00000000000000000000000000000000000000000000000000000000
00000000000761111116700000aaaa00a000000addd666dddddddd94ddcccccccccccccc00000000000000000000000000000000000000000000000000000000
0000000000076111111670000a0000a0000aa000dddddddddddddd44cccccccccc99cccc00000000000000000000000000000000000000000000000000000000
0000000000076111111670000000000000a00a00dddddddddddddd44cccccccccc94cccc00000000000000000000000000000000000000000000000000000000
000000000007611111167000000aa00000000000dddddddddddddd44ddddcccccc44cccd00000000000000000000000000000000000000000000000000000000
0000000000076111111670000000000000000000ddddddddddddd2444444ddddcc44cdd400000000000000000000000000000000000000000000000000000000
0000000000076111111670000000000000000000ddddddddddd2224444444444dd44d44400000000000000000000000000000000000000000000000000000000
0000000000076111111670000000000000000000ddddddddd2222244000444444444444000000000000000000000000000000000000000000000000000000000
000000000007611111167000000000000aaaaaa0ddddddd222222244200000044444400000000000000000000000000000000000000000000000000000000000
000000000007611111167000000000000aaaaaa0ddddd22222222222222000000044000200000000000000000000000000000000000000000000000000000000
000000000007666666667000000000000aaaaaa0ddd2222222222222222222000044022200000000000000000000000000000000000000000000000000000000
0000000000076d6dd6d67000000000000aaaaaa0d222222222222222222222222244222200000000000000000000000000000000000000000000000000000000
000000000007666dd6667000000000000aaaaaa02222222222222222222222222222222200000000000000000000000000000000000000000000000000000000
000000000000777777770000000000000aaaaaa02222222222222222222222222222222200000000000000000000000000000000000000000000000000000000
00000000000000010111110101111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
100000000010101111111100111111110000000000000000000fffffffffff00000fffffffffff00000fffffffffff00000fffffffffff00000fffffffffff00
00000101010111111111110101111111000088888888000000ffffffffffff0000ffffffffffff0000ffffffffffff0000ffffffffffff0000ffffffffffff00
1010101010111111111111001111111100088888888880000ffffffffffffff00ffffffffffffff00ffffffffffffff00ffffffffffffff00ffffffffffffff0
110101011111111111111101111111110082228888222800fffffffffffffff0fffffffffffffff0fffffffffffffff0ff8ffffffffff8f0ff88ffffffff88f0
101011111111551111111101011111110082822882282800fffffffffffffffffffffffffffffffffff8ffffffff8fffff888ffffff888ffff8f8ffffff8f8ff
111111111155051111111101111111110088222882228800fffffffffffffffffffffffffffffffffff888ffff888ffffff888ffff888ffffff888ffff888fff
1111111155d0051111111101111111110088888888888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
111111555dd0051111111101111111110088888888888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8ffffffffff8ff
111155dd5dd0051111111101111111110082888888882800ffffffffffffffffffffffffffffffffffffffffffffffffff8ffffffffff8ffff88ffffffff88ff
1115000d5d000511111111011111111500822822228228000ffffffffffffff00ffffffffffffff00ffffffffffff8f00ff8ffffffff88f00ff88fffff8888f0
1115000050055511111111011111115500882222222288000ffffffffffffff00ffffffffffffff00ff8fffffff88ff00ff88ff88f8888f00fff8f888f88f8f0
1115000055500511111111011115515500088228222880000ffffffffffffff00ffffffffffffff00ff88888ff88fff00ff888888888fff00ff888888888fff0
1115005550000511111111011115515500008888888800000fffffffffffff000fffffffffffff000ffff8f8888fff000fff88f8888fff000fff88f8888fff00
111555005000051111111101111555dd000000000000000000ffffffffffff0000ffffffffffff0000ffffffffffff0000ffffffffffff0000ffffffffffff00
111500005000551111111101111d1ddd0000000000000000000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000000ffffffffff000
111500005055111111111101ddd1155d77777777777777770000000000000000000000000000fffffffff0000000000000000000000000000000000000000000
1115000055111111111111dd111111157666666666666667000000000000000000000000000fffffffff00000000000000000000000000000000000000000000
11150055111111551111dd11111111117600000000000067000000000000000000000000000ffffffff000000000000000000000000000000000000000000000
111555111111115511dd11111111111176000888888000670000000000000000000000000ffffffffffff0000000000000000000000000000000000000000000
1111111111111155dd111111115511117600888888880067000000000000000000000fffffffffffffffff000000000000000000000000000000000000000000
1111111111111155111111111155111176080008800080670000000000000000000fffffffffffffffffffffff00000000000000000000000000000000000000
111111111111115500001111115511107608080880808067000000000000000000ffffffffffffffffffffffffff000000000000000000000000000000000000
111111111111105555550000115510057608800880088067000000000000000000fffffffffffffffffffffffffff00000000000000000000000000000000000
111111111110005555555555005505557608888888888067000000000000000000ffffffffffffffffffffffffffff0000000000000000000000000000000000
111111111000005500055555555555507608008008008067000000000000000000ffffffffffffffffffffffffffff0000000000000000000000000000000000
11111110000000550000000555555000760880000008806700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
11111000000000000000000000550000760088080088006700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
11100000000000000000000000550000760008888880006700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
10000000000000000000000000550000760000000000006700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
00000000000000000000000000000000766666666666666700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
00000000000000000000000000000000777777777777777700000000000000000ffffffffffffffffffffffffffffff000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
000a000024020290502b0402c0003003030020300102e0001f0002e5001200016000190001d00022000260002a000300003200017000000000000000000000000000000000000000000000000000000000000000
0006000031613270153361327015316132701533613270101d500205001b5401b5501e5001f5401f5301f5201f510104001040010400104001040010400104001040010400104001040010400104001040010400
000a00002841028410284202842028430284402845028460284502846028470284602845028460284702846028450284602847028460284502846028470284602845028460284702846010400104001040010400
000a00000561005610056100561005620056200563005630056400564005650056600567005670056700567005670056700567005670056700567005670056700567005670056700567010400104001040010400
000a00001944019440194301943019440194401943019430194401944019430194301944019440194301943019440194401943019430194401944019430194301944019440194301943019440194401943019430
000a00002244022450224602246022460224502244022440224402245022460224602246022450224402244022440224502246022460224602245022440224402244022450224602246022460224502244022440
000a00003347033470334703347033470334603344033470334703347033470334703347033460334403347033470334703347033470334703346033440334703347033470334703347033470334603344033470
000a00000b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b6300b630
000a00200b6110b6110b6110b6110b6110b6110b6110b6110b6210b6210b6210b6210b6210b6210b6210b6210b6210b6210b6110b6110b6110b6010b6010b6010b6010b6010b6010b6010b6010b6010b6010b600
000a00003c5243c54439554395523954239542385002d5003c5143c5343954439542395323953239522395123a5043a5043750437502375023750200603000000000000000000000000000000000000000000000
000800003706439064390643905439004370443904439044390343900437024390243902439014390043700439004370643906439064390543900437044390443904439034390043702439024390243901439004
00130000010100102001020010200101001010010500101001050010101d3001e3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000271408724067340273406744047440575408754047540675407754047540874407744057340673405724057141350217500340041e50415500195041a50434004340040000000000000000000000000
000e00000000001623016000160000000000000000002623000000000000000000000000001623016030000000000000000000000000006030000000623000000000000000000000000000000000000000000000
000600000461103621036310364103651026410261102621026310363104611046210462105611066110662104621046210261000000000000000000000000000000000000000000000000000000000000000000
001000003a2563a2463a236000003a2003a200342003a2063a2063a2063a2063a2060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000014100141003410064200d42016420214302e4303c4303e4403f4503f4703d4603b4403b4503d4703d4503d4503d4503d4503d4403d4303d4203d4100000000000000000000000000000000000000000
000a00000000038633386333863300000000003865338653386530000038673386733867300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000340143401434014345703402434024340243757034014340143401434014355703557034034340343403434034340343a570340443404433570340143401434014340140000000000000000000000000
00100000340043400434004345003400434004340043750034004340043400434004355003550034004340043400434004340043a500340043400433500340043400434004340040000000000000000000000000
00100000340043400434004345003400434004340043750034004340043400434004355003550034004340043400434004340043a500340043400433500340043400434004340040000000000000000000000000
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
04 41 42 02 03
03 04 42 43 07
03 04 05 43 07
03 04 05 06 07
03 06 42 43 07
03 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
