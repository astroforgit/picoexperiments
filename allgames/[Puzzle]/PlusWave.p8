pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pluswave
-- by max levine
function _init()

gamestate = -2
combo_max = 4
seconds_to_answer = 8
max_lives = 4
score_to_win=175
score_to_win_practice=8

t = 0
option_chose=1
question_phase_time=-1
 
cartdata("pluswave")
high_score = {whol=dget(0),dec=dget(1)}
high_score_practice = dget(2)
looked_at_info=dget(3)==1
shown_win=dget(4)==1
 
combo = 0
palt(0,false)
palt(15,true)
poke(0x5f2d,1)
mouse_moved = false
clicked = false
mouse_update=0
 
menu_select=1
subselector = 0
screenshake=0
song = make_song(t)
noise_colors={0,1,1}
noise_colors_2={0,0,1}
noise_colors[0] = 1
region_y={0,0xb00,0x1040,0x1580,0x1ac0}
	
--logo screen
logo_yvel = 0
logo_y = -21
leftwave_x=-17
rightwave_x=165
bounces=3
static = false
static_time = 12
copywrite=0
	
text_scroll=128
text_moved=false
scare_shake=false
	
is_fading = false
fade_amount = 0
is_transitioning = false
transition_amount = 0
	
blip=2.4

divider = 0

loud = true
 
menuwave_t=0
menuwave = 0
menuwave_adder = 0
	
difficulty=15
end

function set_text_length()
local newlines=0
for i=1, #text do
if sub(text, i, i) == '\n' then
newlines+=1
end
end
text_length=46-newlines*6
end

function lookup(i, j)
local value=fget(i+16*j)
return value==255 and -1 or value
end

function start_menu()
question1=random_wave()
question2=random_wave()
answer1=random_wave()
answer2=random_wave()
answer3=random_wave()
answer4=random_wave()
end

function have_won()
return (high_score.whol>=score_to_win) or shown_win
end

background=0
function set_background(setting)
if setting==background then
return
end
if setting==1 then
for addr=0x4300,0x507f do
local c1,c2=flr(rnd(#noise_colors))+1,flr(rnd(#noise_colors))+1
poke(addr,noise_colors[c1]+noise_colors[c2]*16)
poke(addr+0xd80,noise_colors_2[c1]+noise_colors_2[c2]*16)
end
regions={}
for i=1,5 do
regions[i]={
true,
flr(rnd(0xd80))
}
end
else
for addr=0x4300,0x52ff do
poke(addr,noise_colors[ceil(rnd(#noise_colors))]+noise_colors[ceil(rnd(#noise_colors))]*16)
end
end
end

function is_inbetween()
return not ( ((fade_amount==0 and not is_fading) or (fade_amount==1 and is_fading)) and ((transition_amount==0 and not is_transitioning) or (transition_amount==25 and is_transitioning)) )
end

function pressed()
return btnp(5) or btnp(4) or is_mouse_clicked()
end
function is_mouse_clicked()
if stat(34)==1 and clicked==false then
clicked=true
return true
end
end

function draw_check_and_x(step)
step*=2
if step>16 then
step=16
end
sspr(96,9,16,step,10,wave_pos(questionset.answer+2)-8)
if option_chose~=questionset.answer then
sspr(112,9,16,step,10,wave_pos(option_chose+2)-8)
end
end

function draw_question()
color(7)
if question_phase_time==-1 then
draw_wave_1(question1,0)
draw_wave_1(question2,1)
else
merge_waves(question_phase_time-1)
end
for i = 0, 3 do
if i==selector then
color(7)
else
color(6)
end
if question_phase_time>=19 then
if i==questionset.answer then
color(3)
end
if i==option_chose and questionset.answer~=option_chose then
color(8)
end
end
if questionset.answer==i then
draw_wave_2(question1,question2,i+2)
else
if questionset[i][0]==0 then
draw_wave_1(convert_wave_num(i),i+2)
else
if questionset[i][0]==1 then
if questionset[i][1]==0 then
draw_wave_2(convert_wave_num(i),question1,i+2)
else
draw_wave_2(convert_wave_num(i),question2,i+2)
end
else
if questionset[i][0]==2 then
draw_wave_3(convert_wave_num(i),question1,question2,i+2)
else
if questionset[i][0]==3 then
if questionset[i][1]==0 then
draw_wave_1(question1,i+2)
else
draw_wave_1(question2,i+2)
end
else
if questionset[i][1]==0 then
draw_wave_mult(convert_wave_num(i),question1,i+2)
else
draw_wave_mult(convert_wave_num(i),question2,i+2)
end
end
end
end
end
end
end	
end

function convert_wave_num(num)
if num==0 then
return answer1
end
if num==1 then
return answer2
end
if num==2 then
return answer3
end
if num==3 then
return answer4
end
end

function create_question()
selector=option_chose
question_phase_time=-1
question_time=time()
questionset = {}
for i = 0, 3 do
questionset[i] = {}
for j = 0, 1 do
questionset[i][j] = 0
end
end
questionset.answer = flr(rnd(4))
question1 = random_wave()
question2 = random_wave()
for i = 0, 3 do
questionset[i][0] = mod_type(45,4)
if questionset[i][0]==3 and rnd(100)<35 then
questionset[i][0] = flr(rnd(2))+1
end
if questionset[i][0]==2 then
questionset[i][0] = mod_type(45,4)
end
if rnd(100)<50 then
questionset[i][1] = 0
else
questionset[i][1] = 1
end
end
if questionset.answer~=0 then
repeat
answer1 = random_wave()
until answer_acceptable(answer1,0)
end
if questionset.answer~=1 then
repeat
answer2 = random_wave()
until answer_acceptable(answer2,1)
end
if questionset.answer~=2 then
repeat
answer3 = random_wave()
until answer_acceptable(answer3,2)
end
if questionset.answer~=3 then
repeat
answer4 = random_wave()
until answer_acceptable(answer4,3)
end
drawn_question_yet=false
end

function higher()
if is_practice then
return score.whol>high_score_practice
else
if score.whol==high_score.whol then
return score.dec>high_score.dec
else
return score.whol>high_score.whol
end
end
end

function answer_acceptable(answer,i)
if questionset[i][0]==1 or questionset[i][0]==2 or questionset[i][0]==4 then
high=0
z=0
while z <= 2.56 do
if questionset[i][0]==4 then
x = abs(calc_wave(answer,z,0)-1)
else
x = abs(calc_wave(answer,z,0))
end
if x>high then
high=x
end
z+=0.005
end
if questionset[i][0]==4 then
x-=1
end
if x<0.4 then
return false
end
end
if questionset[i][0]==1 then
if questionset[i][1]==0 then
if are_same(answer,question2) then
return false
end
else
if are_same(answer,question1) then
return false
end
end
end
return true
end

function are_same(w1,w2)
difference=0
z=0
while z <= 2.56 do
value=abs(calc_wave(w1,z,0)-calc_wave(w2,z,0))
if value>difference then
difference=value
end
z+=0.005
end
if difference<1 then
return true
else
return false
end
end

function make_song(song)
if loud==false then
loud=true
else
loud=false
end
song = {}
starting = flr(rnd(19)+7)
ending = flr(rnd(starting-6)+6)
note = starting
printpoint = 0
while (note > ending) do
song[printpoint] = note
printpoint += 1
note -= 2
song[printpoint] = note
printpoint += 1
note += 1
end
song[printpoint] = note
printpoint += 1
note -= 3
song[printpoint] = note
printpoint += 1
note -= 1
song[printpoint] = note
printpoint += 1
note -= 2
song[printpoint] = note
printpoint += 1
note += 2
song[printpoint] = note
printpoint += 1
note = starting+1
song[printpoint] = note
printpoint += 1
note -= 1
song[printpoint] = note
song.length = printpoint
song.node = 0
return song
end

function mod_type(chance,furthest)
reach = 0
while true do
if rnd(100) < (chance-difficulty) or reach==furthest then
return reach
end
reach+=1
end
end

function calc_wave(w,xoriginal,depth)
if w.bake~=nil then
if w.bake[xoriginal]~=nil then
return w.bake[xoriginal]
end
end
x = xoriginal
if w[0][depth]==1 then
x*=-1
end
if w[1][depth]==1 then
x = abs(x)
end
x = x^(w[2][depth]+1)
x += w[3][depth]
x *= (w[4][depth])
if w[6][depth]==0 then
x = sin(x)
else
x = cos(x)
end
if w[7][depth] ~= 0 then
addend = ceil(w[7][depth]/2)
if w[7][depth]%2==0 then
addend *= -1
end
x /= 10
x += addend
end
x *= (w[8][depth])
if w[10][depth]==1 then
x = abs(x)
end
x = x^(w[11][depth]+1)
if w.bake==nil then
w.bake={}
end
if w[12][depth]==0 then
w.bake[xoriginal] = x
return w.bake[xoriginal]
end
if w[12][depth]==1 then
w.bake[xoriginal] =x+calc_wave(w,xoriginal,depth+1)
return w.bake[xoriginal]
end
if w[12][depth]==2 then
w.bake[xoriginal] = x*calc_wave(w,xoriginal,depth+1)
return w.bake[xoriginal]
end
w.bake[xoriginal]=x-calc_wave(w,xoriginal,depth+1)
return w.bake[xoriginal]
end

function random_wave()
wave = {}
for i = 0, 12 do
wave[i] = {}
end
wave.layer = 0
::morelayer::
for i = 0, 12 do
wave[i][wave.layer] = mod_type(lookup(i,0),lookup(i,1))
end
wave[3][wave.layer] = rnd(6)-3
wave[4][wave.layer] = rnd(4)-2
wave[8][wave.layer] = rnd(0.2)+0.9
if wave[12][wave.layer] > 0 then
wave.layer += 1
goto morelayer
end
scale_wave(wave)
z=0
wave.bake = {}
if gamestate==1 then
while z <= 2.56 do
wave.bake[z] = calc_wave(wave,z,0)
z+=0.005
end
end
return wave
end

function add_txt(txt)
text=text..txt
end

function _update()

--remove for bbs version
--poke(0x5f30,1)

mouse_update = (mouse_update+1)%12
if (stat(32) ~= mouse_old_x) or (stat(33) ~= mouse_old_y) then
mouse_moved = true
else
mouse_moved = false
end
if mouse_update==0 then
mouse_old_x = stat(32)
mouse_old_y = stat(33)
end
if stat(34)==0 then
clicked = false
end

if is_transitioning then
if transition_amount<25 then
transition_amount += 0.4
if transition_amount>=20 then
if gamestate==0 then
is_practice=selector==2
set_background(1)
score_particles = {}
score = {whol=0,dec=0}
abs_score = {whol=0,dec=0}
highest_practicing=0
combo = 0
gamestate=1
difficulty=-15
create_question()
selector=0
option_chose=0
help_time=0
lives=max_lives
score_to_win_practice=8
shown_win=have_won()
dont_show_arrow=shown_win
start_time=time()
end
end
end
else
if transition_amount>0 then
transition_amount -= 0.4
if transition_amount<=20 and gamestate==1 then
process_score_particles()
gamestate=2
blip=2.4
scare_shake=true
past_credits=false
text_scroll=128
text_moved=false
if is_practice then
if score.whol>=score_to_win_practice then
shown_win=true
end
score.whol=max(highest_practicing,score.whol)
end
if score.dec~=0 then
score_str=score.whol.."."..score.dec
else
score_str=score.whol
end
text = "final score: "..score_str
where_pi=text
if not is_practice then
add_txt(" ")
end
if higher() then
add_txt("  new high!")
end
end_time=time()-start_time
minutes=flr(end_time/60)
seconds=ceil(end_time%60)
add_txt("\nsession time: ")
if minutes~=0 then
add_txt(minutes.."min ")
end
add_txt(seconds.."sec")
if is_practice then
add_txt("\npractice mode")
else
add_txt("\nnormal mode")
end
add_txt("\n\n")
if is_practice then
if shown_win then
add_txt("you're ready for normal mode!")
if not dont_show_arrow then
sfx(11)
else
if higher() and score.whol>score_to_win_practice then
sfx(11)
end
end
else
add_txt("try again!")
end
else
if score.whol>=score_to_win or high_score.whol>=score_to_win then
add_txt(win_text)
if high_score.whol<score_to_win then
sfx(11)
else
if higher() then
sfx(11)
end
end
else
add_txt("  translating the waves was\nusually work enough for five of\nus - it was all too much. i\nmade it through "..get_percent().."% of it."..(get_percent()>=75 and " i\nwas so close!\n  but" or "\n  then")..lose_text)
end
end
set_text_length()
--set scores
if shown_win then
dset(4,1)
end
if higher() then
if is_practice then
high_score_practice=score.whol
dset(2,score.whol)
else
high_score=score
dset(0,score.whol)
dset(1,score.dec)
end
end
end
end
end
transition_amount=max(0,min(transition_amount,25))

if is_fading then
if fade_amount < 1 then
fade_amount += 0.1
if fade_amount>=1 then
is_fading=false
if gamestate==0 then
if selector==0 then
text_scroll=128
text_moved=false
text=intro_text
set_text_length()
blip=2.4
gamestate=-1
else
set_background(-3)
looked_at_info=true
dset(3,1)
gamestate=-3
end
else
if gamestate==-3 or gamestate==-1 then
selector=menu_select
gamestate=0
else
if gamestate==2 then
selector=menu_select
gamestate=0
end
end
end
end
end
else
if fade_amount > 0 then
fade_amount -= 0.1
end
end
fade_amount=max(0,min(fade_amount,1))

if screenshake>0 then
screenshake-=1
end
 
if gamestate==0 or gamestate==1 then
if not is_inbetween() then
if (btnp(3)) then
if gamestate==0 or question_phase_time==-1 or question_phase_time==20 then
sfx(4)
end
if selector==3 then
selector=0
else
selector+=1
end
if question_phase_time==20 then
if subselector==1 then
subselector=0
else
subselector=1
end
end
end
if (btnp(2)) then
if gamestate==0 or question_phase_time==-1 or question_phase_time==20 then
sfx(4)
end
if selector==0 then
selector=3
else
selector-=1
end
if question_phase_time==20 then
if subselector==1 then
subselector=0
else
subselector=1
end
end
end
if mouse_moved then
old_select=selector+subselector
if gamestate==0 then
if stat(33)<=57 then
selector=0
end
if stat(33)<=68 and stat(33)>57 then
selector=1
end
if stat(33)<=79 and stat(33)>68 then
selector=2
end
if stat(33)>79 then
selector=3
end
else
if gamestate==1 then
if question_phase_time==-1 then
if stat(33)<=64 then
selector=0
end
if stat(33)<=85 and stat(33)>64 then
selector=1
end
if stat(33)<=106 and stat(33)>85 then
selector=2
end
if stat(33)>106 then
selector=3
end
else
if question_phase_time==20 then
if stat(33)<=10 then
subselector=0
end
if stat(33)<=19 and stat(33)>10 then
subselector=1
end
end
end
end
end
if old_select~=(selector+subselector) then
sfx(4)
end
end
end
end

if gamestate==1 then
score_particles_update()
if (127-(127/seconds_to_answer)*(time()-question_time)<=0 and not is_practice) then
if not is_inbetween() then
if question_phase_time==-1 then
question_phase_time=0
option_chose=selector
question_time_freeze=time()
end
end
end
	 
if pressed() then
if not is_inbetween() then
if question_phase_time==-1 then
sfx(5)
question_phase_time=0
option_chose=selector
question_time_freeze=time()
else
if question_phase_time==20 then
sfx(5)
if subselector==0 then
if is_practice then
if abs_score.whol>=score_to_win_practice then
shown_win=true
end
help_time=0
end
create_question()
else
is_transitioning=false
transition_amount=25
end
end
end
end
end

if question_phase_time~=-1 then
question_phase_time+=1
if question_phase_time>20 then
question_phase_time=20
end
selector=option_chose
if question_phase_time==19 then
subselector = 0
if option_chose==questionset.answer then
create_score_particles(seconds_to_answer-(question_time_freeze-question_time))
combo += 1
if combo%combo_max==0 and combo~=0 then
sfx(9)
else
sfx(7)
end
if combo%combo_max==0 and combo~=0 then
if lives<max_lives then
award=0
lives+=flr(combo/combo_max)
else
award=1
if is_practice then
score.whol+=flr(combo/combo_max)
abs_score.whol+=flr(combo/combo_max)
else
score.whol+=3*flr(combo/combo_max)
abs_score.whol+=3*flr(combo/combo_max)
end
end
end
difficulty+=0.6
if difficulty>15 then
difficulty=15
end
else
sfx(6)
screenshake=10
combo=0
if not is_practice then
lives-=1
if lives==0 then
is_transitioning=false
transition_amount=25
end
else
difficulty-=0.6/4
if difficulty<-15 then
difficulty=-15
end
score.whol-=1
if score.whol<0 then
score.whol=0
end
abs_score.whol-=1
if abs_score.whol<0 then
abs_score.whol=0
end
if score.whol>=score_to_win_practice then
score_to_win_practice=score.whol+1
end
end
end
end
end

for i=1,5 do
if regions[i][1] then
regions[i][2]=(regions[i][2]+1)%0xd80
end
        
regions[i][1]=i-2==selector
if question_phase_time>=19 then
regions[i][1] = false
end
regions[1][1]=true
end
  
if score.whol>highest_practicing then
highest_practicing=score.whol
end
end
	
t+=0.02
if t>1 then
t=0
end
	
if gamestate==0 then
menu_select=selector
if not is_inbetween() then
if pressed() then
sfx(5)
if selector==1 or selector==2 then
is_transitioning=true
transition_amount=0
else
is_fading=true
fade_amount=0
end
end
end
	 
menuwave_t+=0.005*10
if menuwave_t>3.56 then
menuwave_t=0
if menuwave_adder==5 then
menuwave_adder=0
if menuwave==5 then
menuwave=0
else
menuwave+=1
end
else
menuwave_adder+=1
end
end
end
	
--music
if gamestate==0 or gamestate==-1 or gamestate==2 then
--metronome drumbeat
if divider==5 and song.node%3==0 then
sfx(1,2,0,3)
blip=2.4
comp_screen = (comp_screen+1)%4
end
end
--ddlc melody
if gamestate==0 or gamestate==-1 or gamestate==-3 or gamestate==2 then
if divider==0 then
divider = 9
if gamestate==0 or gamestate==-3 or (gamestate==2 and past_credits) then
sfx(0,0,song[song.node],1)
end
song.node += 1
if song.node>song.length then
song = make_song(song)
divider = 18
end
end
divider -= 1
end
if gamestate==0 or (gamestate==2 and past_credits) then
if song.node %3==0 then
if loud then
sfx(0,1,28,1)
else
sfx(0,1,30,1)
end
end
if song.node %4==0 then
if loud then
sfx(0,1,29,1)
else
sfx(0,1,31,1)
end
end
end
	
--logo screen
if gamestate==-2 then
logo_yvel += 0.08
logo_y+=logo_yvel
if logo_y>53 then
logo_y=53
logo_yvel = -logo_yvel/3
if bounces>0 then
sfx(3,-1,bounces-1,1)
bounces-=1
end
end
if logo_y>30 then
if not (leftwave_x>=rightwave_x) then
leftwave_x += 1
rightwave_x -= 1
else
static = true
if static_time==12 then
sfx(2)
end
end
end
if static_time>0 and static then
static_time -= 1
end
if static_time==0 then
if copywrite<74 then
copywrite += 1
end
end
if pressed() and copywrite<55 then
bounces = 0
logo_yvel=0
logo_y =53
leftwave_x=165
rightwave_x=-17
static=true
static_time=0
copywrite=55
end
if copywrite==55 then
is_fading=true
end
if copywrite>55 and fade_amount==1 then
gamestate=-1
is_fading=false
fade_amount=1
text = intro_text
set_text_length()
start_menu()
end
end
	
--intro screen
if gamestate==-1 or gamestate==2 then
if gamestate==-1 and text_scroll<=-141 then
scare_shake=true
end
if gamestate==2 then
if text_scroll<-275 then
scare_shake=false
end
if text_scroll<-422 then
past_credits=true
end
end
if scare_shake then
scare_x=rnd(2)-1
scare_y=rnd(2)-1
sfx(10,3)
else
scare_x=0
scare_y=0
end
	 
if not is_inbetween() then
if not text_moved then
text_scroll-=0.18
end
if btn(2) then
text_moved=true
if text_scroll<128 then
text_scroll+=2
end
end
if btn(3) or stat(34)==1 then
text_moved=true
text_scroll-=2
end
end
if text_scroll<text_length or btnp(5) or btnp(4) then
if not is_inbetween() then
is_fading=true
end
end
end

--info screen
if gamestate==-3 then
memcpy(0x4300,0x4301,0xfff)
poke(0x52ff,noise_colors[ceil(rnd(#noise_colors))]+noise_colors[ceil(rnd(#noise_colors))]*16)
if not is_inbetween() then
if pressed() or btnp(2) or btnp(3) then
sfx(5)
is_fading=true
fade_amount=0
end
end
end
end

function draw_logo_wave(x,neg)
color(7)
starting=2.56*(x-16)/128
ending=2.56*(x+16)/128
z=starting
while z <= ending do
pset((z)*50+1,neg*sin(z*4)*3+63)
z+=0.005
end
end

function scale_wave(w)
high = 0
z=0
while z <= 2.56 do
calc=abs(calc_wave(w,z,0))
if calc>high then
high = calc
end
z+=0.005
end
if high==0 then
high=1
end
w.multiplier = 1/high
end

function wave_pos(y)
if y==0 then
adder = 11
else
if y==1 then
adder = 32
else
if y==2 then
adder = 55
else
if y==3 then
adder = 76
else
if y==4 then
adder = 97
else
if y==5 then
adder = 118
end
end
end
end
end
end
return adder
end

function draw_wave_1(w,y)
z=0
while z <= 2.56 do
pset((z)*50,calc_wave(w,z,0)*w.multiplier*10.5-.5+wave_pos(y))
z+=0.005
end
end

function draw_wave_2(w1,w2,y)
z=0
while z <= 2.56 do
pset((z)*50,((calc_wave(w1,z,0)*w1.multiplier*10.5-.5)+(calc_wave(w2,z,0)*w2.multiplier*10.5-.5))/2+wave_pos(y))
z+=0.005
end
end

function draw_wave_3(w1,w2,w3,y)
z=0
while z <= 2.56 do
pset((z)*50,((calc_wave(w1,z,0)*w1.multiplier*10.5-.5)+(calc_wave(w2,z,0)*w2.multiplier*10.5-.5)+(calc_wave(w3,z,0)*w3.multiplier*10.5-.5))/3+wave_pos(y))
z+=0.005
end
end

function draw_wave_mult(w1,w2,y)
z=0
while z <= 2.56 do
pset((z)*50,(calc_wave(w1,z,0)*calc_wave(w2,z,0))*w1.multiplier*w2.multiplier*10.5-.5+wave_pos(y))
z+=0.005
end
end

function merge_waves(step)
step*=1.2
if step>=12 then
z=0
while z <= 2.56 do
pset((z)*50,((calc_wave(question1,z,0)*question1.multiplier*10.5-.5)+(calc_wave(question2,z,0)*question2.multiplier*10.5-.5))/2+wave_pos(1))
z+=0.005
end
return
end
step=10/(1+2^-(step-6))
z=0
while z <= 2.56 do
pset((z)*50,( ((calc_wave(question1,z,0)*question1.multiplier*10.5-.5)+(calc_wave(question2,z,0)*question2.multiplier*10.5-.5))/2*step + calc_wave(question1,z,0)*question1.multiplier*10.5-.5 ) / (step+1) + wave_pos(0)+step*2)
z+=0.005
end
z=0
while z <= 2.56 do
pset((z)*50,( ((calc_wave(question1,z,0)*question1.multiplier*10.5-.5)+(calc_wave(question2,z,0)*question2.multiplier*10.5-.5))/2*step + calc_wave(question2,z,0)*question2.multiplier*10.5-.5 ) / (step+1) + wave_pos(1))
z+=0.005
end
end

function pi(x,y,c)
if c==0 then
sspr(106,2,5,5,x,y+1)
else
if c==1 then
sspr(118,2,5,5,x,y+1)
else
if c==2 then
sspr(111,2,7,6,x-1,y+1)
end
end
end
end

--x
--y
--buffer spaces: #string
--no align/left/center/right: 0,1,2,3
--not wavy/sorta wavy/wavy: 0,1,2
--white/grey/background: 0,1,2
function pi_text(x,y,buffer,align,waviness,c)
if align==1 then
x=buffer*4+2
else
if align==2 then
x=64+buffer*2
else
if align==3 then
x=122
end
end
end
if waviness==1 then
y=y+sin(t+(buffer+1)/10)*1
else
if waviness==2 then
y=y+sin(t+(buffer+2)/10)*2
x-=2
end
end
pi(x,y,c)
end

--use this one, a wrapper
function outline_text_for(s,x,y,c1,c2)
if char==")" and y<69 and y>55 then
x-=1
end
print(s,x+1,y+1,c2)
end

function wavy_text_left_for(text,y,is_left,is_for)
c=7
if is_left then
x_p = 0
else
if sub(text,#text,#text)==" " then
x_p=127-(#text*4)+1
else
x_p=127-(#text*4)
end
end
for letter=0,#text do
char = sub(text,letter,letter)
if is_for then
outline_text_for(spaces(letter-1)..char,x_p,y+sin(t+letter/10)*1,0,c)
else
outline_text_back(spaces(letter-1)..char,x_p,y+sin(t+letter/10)*1,0,c)
end
end
end

function outline_text_back(s,x,y,c1,c2)
if char==")" and y<69 and y>55 then
x-=1
end
outline(s,x,y,c1,c2)
outline("",0,0,0,0)
end

function outline_text_for_center(s,x,y,c1,c2)
print(s,(64-#s*2)+1,y+1,c2)
end

function outline_text_back_center(s,x,y,c1,c2)
outline(s,(64-#s*2),y,c1,c2)
outline("",0,0,0,0)
end

function outline_text(s,x,y,c1,c2)
outline(s,x,y,c1,c2)
outline("",0,0,0,0)
print(s,x+1,y+1,c2)
end

function outline_text_center(s,x,y,c1,c2)
outline(s,(64-#s*2),y,c1,c2)
outline("",0,0,0,0)
print(s,(64-#s*2)+1,y+1,c2)
end

function text_center(s,y,c1)
print(s,(64-#s*2),y,c1)
end

function outline(s,x,y,c1,c2)
for i=0,2 do
for j=0,2 do
if not(i==1 and j==1) then
print(s,x+i,y+j,c1)
end
end
end
end

function wavy_text_back(text,x,y)
c=7
for letter=0,#text do
char = sub(text,letter,letter)
outline_text_back(spaces(letter-1)..char,64-#text*2,y+sin(t+letter/10)*2,0,c)
end
end

function wavy_text_for(text,x,y)
c=7
for letter=0,#text do
char = sub(text,letter,letter)
if char=="(" then
c=6
end
outline_text_for(spaces(letter-1)..char,64-#text*2,y+sin(t+letter/10)*2,0,c)
end
end

function spaces(x)
sp = ""
for i=1,x do
sp = sp.." "
end
return sp
end

function arrows(txt_l,y,d,f)
txt_l+=4
arrow(61-txt_l*2,y,d,f,-1)
if d%2~=0 then
m=2
else
m=0
end
arrow(62+txt_l*2,y,d+m,f,1)
end

function arrow(x,y,d,f,p)
d=d%4
if d%2==0 then
y+=sin(2*t)*1.5+1
else
x+=p*sin(2*t)*1.5
end
if f then
sy=37
else
sy=44
end
sspr(100+d*7,sy,7,7,x,y)
end

function draw_arrows(f)
if high_score.whol>=score_to_win then
return
end
if gamestate==0 then
if not looked_at_info and not have_won() then
arrows(4,83,1,f)
else
if not have_won() then
arrows(#get_practice(),72,1,f)
else
if not (high_score.whol>=score_to_win) then
arrows(#get_start(),61,1,f)
end
end
end
else
if gamestate==1 and question_phase_time==20 and lives>0 then
if is_practice then
if dont_show_arrow then
return
end
if shown_win or abs_score.whol>=score_to_win_practice then
arrows(3,12,1,f)
else
arrows(9,3,1,f)
end
else
if abs_score.whol>=score_to_win then
arrows(#get_end(),12,1,f)
else
arrows(9,3,1,f)
end
end
end
end
end

function fade_screen(f)
fa=max(min(1,f),0)
if current_fade==fa then
return
end
current_fade=fa
local fi=flr(fa*8)
for n=1,15 do
pal(n,sget(fi,n+112),0)
end
end

function is_bar_color(c)
if c==3 or c==8 or c==9 then
return true
end
return false
end

function color_bar(bar)
if bar>128/2 then
return 3
else
if bar>128/4 then
return 9
else
return 8
end
end
end

function get_percent()
return max(min(100,flr(score.whol/score_to_win*100)),min(100,flr(high_score.whol/score_to_win*100)))
end

function get_end()
if not is_practice and subselector==1 then
return "end ("..get_percent().."% translated)"
else
return "end"
end
end

function get_start()
if selector==1 then
if high_score.whol~=0 or high_score.dec~=0 then
if high_score.dec~=0 then
return "start (hi:"..high_score.whol.."."..high_score.dec.."  )"
else
return "start (hi:"..high_score.whol.."  )"
end
else
return "start"
end
else
return "start"
end
end

function get_practice()
if selector==2 then
if high_score_practice~=0 then
return "practice (hi:"..high_score_practice..")"
else
return "practice"
end
else
return "practice"
end
end

comp_screen = 0
function draw_computer()
for x=0,128 do
for y=0,49 do
if rnd(1)<0.4 then
pset(x,y,1)
else
pset(x,y,0)
end
end
end
	
if blip>0 then
blip-=0.08
end
	
color(1)
z=0
while z+t <= 2.56+t do
pset((z)*50,blip*sin(z+t)*10+25)
z+=0.005
end
	
sspr(0,42,47,46,41+scare_x,2+scare_y)
if (comp_screen~=0) then
sspr(65+((comp_screen-1)*21),25,21,12,49+scare_x,10+scare_y)
end
end

function _draw()
cls()
if gamestate==1 and (screenshake>0 or lives<=0) then
if lives<=0 then
sfx(2,3)
end
shake_x=rnd(5)-2.5
shake_y=rnd(5)-2.5
else
shake_x=0
shake_y=0
end
camera(shake_x,shake_y)
	
--logo screen
if gamestate==-2 then
if static_time==0 and static then
sspr(0,21,56,21,36,logo_y)
else
sspr(0,21,23,21,36,logo_y)
pset(58,logo_y+7,0)
end
if not static and static_time>0 then
draw_logo_wave(leftwave_x,1)
draw_logo_wave(rightwave_x,-1)
end
if static and static_time>0 then
for x=58,90 do
for y=60,66 do
if rnd(2)>1 then
pset(x,y,0)
else
pset(x,y,7)
end
end
end
end
color(6)
print(sub("by max levine",0,copywrite),53,68)
end
	
--intro screen
if gamestate==-1 or gamestate==2 then
print(text,2,text_scroll,7)
if gamestate==2 and not is_practice then
pi_text(0,text_scroll-1,#where_pi,1,0,0)
end
draw_computer()
end
	
--info screen
if gamestate==-3 then
memcpy(0x6000,0x4300,0x1000)
memcpy(0x7000,0x4300,0x1000)
print(info_text,2,1,7)
sspr(58,23,5,5,60,46)
sspr(58,28,5,5,60,60)
sspr(58,23,5,5,60,94)
sspr(58,28,5,5,60,107)
z=0.05
while z <= 2.51 do
zx=z*50
pset(zx,sin(z)*5+43,7)
pset(zx,-sin(z)*5+54,7)
pset(zx,cos(z)*5+91,7)
pset(zx,cos(z)*5+102,7)
pset(zx,cos(z)*10+117,7)
z+=0.005
end
line(2,65,125,65)
end
if gamestate==0 then
for x=0,128 do
for y=0,128 do
if rnd(1)<0.26 then
pset(x,y,1)
end
end
end
x=0
while x+t < 2.56+t do
color(1)
value1=(sin(x+t))*12+13
pset((x)*50,value1)
value2=(sin(x-t)+sin(2*(x-t)))*6+46
pset((x)*50,value2)
value3=(cos(x+t*2))*6+67
pset((x)*50,value3)
value4=value1+value2+value3
pset((x)*50,value4-24)
x+=0.005
end
draw_arrows(false)
if selector==0 then
yadder=5
else
if selector==1 then
g=get_start()
wavy_text_back(g,36,61,0,7)
if #g~=5 then
pi_text(36,61,#g-4,2,2,2)
end
yadder=23
else
if selector==2 then
wavy_text_back(get_practice(),36,72,0,7)
yadder=34
else
wavy_text_back("info",36,83,0,7)
yadder=45
end
end
end
line(0,41+yadder,128,41+yadder,2)
line(0,40+yadder,128,40+yadder,0)
line(0,42+yadder,128,42+yadder,0)
if selector==0 then
sspr(0,0,23,21,35,36)
if t<1/4 then
sspr(24,0,35,11,59-2,41)
else
if t<2/4 then
sspr(24,11,35,11,59-2,41)
else
if t<3/4 then
sspr(60,0,35,11,59-2,41)
else
sspr(60,11,35,11,59-2,41)
end
end
end
else
sspr(0,21,56,21,36,36)
end
if selector~=1 then
outline_text_center("start",36,61,0,7)
else
wavy_text_for(g,36,61,0,7)
if #g~=5 then
pi_text(36,61,#g-4,2,2,1)
end
end
if selector~=2 then
outline_text_center("practice",36,72,0,7)
else
wavy_text_for(get_practice(),36,72,0,7)
end
if selector~=3 then
outline_text_center("info",36,83,0,7)
else
wavy_text_for("info",36,83,0,7)
end
if selector==1 then
outline_text("8 seconds per wave, 4 lives",0,121,0,7)
else
if selector==2 then
outline_text("no timing, no lives",0,121,0,7)
else
if selector==3 then
outline_text("what is wave interference?",0,121,0,7)
else
outline_text("read the intro",0,121,0,7)
end
end
end
z=menuwave_t-1
if z<0 then
z=0
end
while z <= menuwave_t do
if z<=2.56 then
if menuwave==0 then
part1=calc_wave(question1,z,0)*question1.multiplier
else
if menuwave==1 then
part1=calc_wave(question2,z,0)*question2.multiplier
else
if menuwave==2 then
part1=calc_wave(answer1,z,0)*answer1.multiplier
else
if menuwave==3 then
part1=calc_wave(answer2,z,0)*answer2.multiplier
else
if menuwave==4 then
part1=calc_wave(answer3,z,0)*answer3.multiplier
else
if menuwave==5 then
part1=calc_wave(answer4,z,0)*answer4.multiplier
end
end
end
end
end
end
if menuwave_adder==0 then
part2=calc_wave(question1,z,0)*question1.multiplier
else
if menuwave_adder==1 then
part2=calc_wave(question2,z,0)*question2.multiplier
else
if menuwave_adder==2 then
part2=calc_wave(answer1,z,0)*answer1.multiplier
else
if menuwave_adder==3 then
part2=calc_wave(answer2,z,0)*answer2.multiplier
else
if menuwave_adder==4 then
part2=calc_wave(answer3,z,0)*answer3.multiplier
else
if menuwave_adder==5 then
part2=calc_wave(answer4,z,0)*answer4.multiplier
end
end
end
end
end
end
pset((z)*37.5+32/2,(part1+part2)/2*8+23,8)
end
z+=0.005
end
end
if gamestate==1 then
for i,y in pairs(region_y) do
local start=regions[i][1] and 0x4300 or 0x5080
local addr=start+regions[i][2]
local len=i==1 and 0xb00 or 0x540
local remainder=max(0,addr+len-(start+0xd80))
memcpy(0x6000+y,addr,len-remainder)
memcpy(0x6000+y+len-remainder,start,remainder)
end
draw_arrows(false)
--score background
if is_practice then
if not (have_won() or shown_win) then
if question_phase_time==-1 then
help_time=(help_time+1)%46
if help_time<23 then
outline_text_back_center("add/combine the waves",10,39,0,7)
arrows(21,39,2,false)
else
outline_text_back_center("choose the right answer",6,39,0,7)
arrows(23,39,0,false)
end
else
if question_phase_time>=19 then
if abs_score.whol>=score_to_win_practice then
outline_text_back_center("you've got the hang of it!",1,39,0,7)
goto no_combo_2
else
if option_chose==questionset.answer then
outline_text_back_center("good job!",1,39,0,7)
else
outline_text_back_center("try again!",1,39,0,7)
end
end
end
end
else
outline_text_back_center(score.whol.."",40,39,0)
end
else
if score.dec~=0 then
outline_text_back_center(score.whol.."."..score.dec.." ",40,39,0)
pi_text(0,39,#(score.whol.."."..score.dec),2,0,2)
else
outline_text_back_center(score.whol.." ",40,39,0)
pi_text(0,39,#(score.whol..""),2,0,2)
end
end

if question_phase_time>=19 then
if combo%combo_max==0 and combo~=0 then
wavy_text_left_for(combo.." combo!",40,true,false)
if is_practice then
wavy_text_left_for("+"..flr(combo/combo_max),40,false,false)
else
if award==0 then
wavy_text_left_for("+"..flr(combo/combo_max).." lives",40,false,false)
else
wavy_text_left_for("+"..3*flr(combo/combo_max).."  ",40,false,false)
pi_text(0,40,#("+"..3*flr(combo/combo_max)),3,1,2)
end
end
end
end
::no_combo_2::

--black background line
color(0)
line(-1,1-1+42,127,1-1+42)
line(-1,1+1+42-1,127,1-1+42+1)

if not is_practice then

--time line
if question_phase_time<0 then
line_calc=127-(127/seconds_to_answer)*(time()-question_time)
else
line_calc=127-(127/seconds_to_answer)*(question_time_freeze-question_time)
end
if line_calc<30 and question_phase_time<=12 then
sfx(12,3)
end
if not drawn_question_yet then
line_calc = 127
end
if line_calc>0 then
color(color_bar(line_calc))
line(-1,1-1+41,line_calc,1-1+41)
line(-1,1-1+42,line_calc,1-1+42)
end

--life line
no_color=false
line_calc=lives*(129/max_lives)-1
if line_calc>0 then
c_life=color_bar(line_calc)
color(c_life)
if c_life==8 and t<0.1 then
no_color=true
end
if screenshake~=0 then
color(8)
end
if not no_color then
line(-1,1-1+41+2,line_calc,1-1+41+2)
line(-1,1-1+42+2,line_calc,1-1+42+2)
end
end

--notches
for i=1,(seconds_to_answer*2)-1 do
p=i*(128/(seconds_to_answer*2))
if is_bar_color(pget(p,41)) then
pset(p,42,0)
pset(p,41,0)
end
end
for i=1,max_lives-1 do
p=i*(128/max_lives)
if is_bar_color(pget(p,44)) then
pset(p,43,0)
pset(p,44,0)
end
end
end
  
--selector line
color(2)
if question_phase_time<=19 then
line(-1,wave_pos(selector+2)-1,128,wave_pos(selector+2)-1)
end
if question_phase_time==20 and lives>0 then
if subselector==1 then
outline_text_back_center("next wave",5,2+1,0,7)
g=get_end()
wavy_text_back(get_end(),5,13-1)
line(0,16-1,128,16-1,2)
line(0,15-1,128,15-1,0)
line(0,17-1,128,17-1,0)
outline_text_for_center("next wave",5,2+1,0,7)
wavy_text_for(get_end(),5,13-1)
else
wavy_text_back("next wave",5,2+1)
outline_text_back_center("end",5,13-1,0,7)
line(0,5+1,128,5+1,2)
line(0,4+1,128,4+1,0)
line(0,6+1,128,6+1,0)
wavy_text_for("next wave",5,2+1)
outline_text_for_center("end",5,13-1,0,7)
end
end

draw_question()
score_particles_draw()

if question_phase_time>10 then
draw_check_and_x(question_phase_time-11)
end

--score foreground
if is_practice then
if not (have_won() or shown_win) then
if question_phase_time==-1 then
if help_time<23 then
outline_text_for_center("add/combine the waves",10,39,0,7)
arrows(21,39,2,true)
else
outline_text_for_center("choose the right answer",6,39,0,7)
arrows(23,39,0,true)
end
else
if question_phase_time>=19 then
if abs_score.whol>=score_to_win_practice then
outline_text_for_center("you've got the hang of it!",1,39,0,7)
goto no_combo
else
if option_chose==questionset.answer then
outline_text_for_center("good job!",1,39,0,7)
else
outline_text_for_center("try again!",1,39,0,7)
end
end
end
end
else
outline_text_for_center(score.whol.."",40,39,7,7)
end
else
if score.dec~=0 then
outline_text_for_center(score.whol.."."..score.dec.." ",40,39,7,7)
pi_text(0,39,#(score.whol.."."..score.dec),2,0,0)
else
outline_text_for_center(score.whol.." ",40,39,7,7)
pi_text(0,39,#(score.whol..""),2,0,0)
end
end
	 
if question_phase_time>=19 then
if combo%combo_max==0 and combo~=0 then
wavy_text_left_for(combo.." combo!",40,true,true)
if is_practice then
wavy_text_left_for("+"..flr(combo/combo_max),40,false,true)
else
if award==0 then
wavy_text_left_for("+"..flr(combo/combo_max).." lives",40,false,true)
else
wavy_text_left_for("+"..3*flr(combo/combo_max).."  ",40,false,true)
pi_text(0,40,#("+"..3*flr(combo/combo_max)),3,1,0)
end
end
end
end
::no_combo::
end

draw_arrows(true)

if stat(102)==0 and (gamestate==0 or gamestate==1) then
if stat(34)==1 then
color(8)
pset(stat(32)+shake_x,stat(33)+shake_y)
end
sspr(99,3,5,5,stat(32)-2+shake_x,stat(33)-2+shake_y)
end

fade_screen(fade_amount)
transition(transition_amount)
	
--keep at end
if drawn_question_yet==false and gamestate==1 and not is_inbetween() then
drawn_question_yet=true
question_time = time()
end
end
-->8
function create_score_particles(distance)
distance = distance*(2.56/seconds_to_answer)
if distance>2.56 then
distance=2.56
else
if distance/0.005<299 then
distance=299*0.005
end
end
if is_practice then
distance=2.56
end
z=0
while z <= distance do
local particle = {}
particle.yvel = rnd(0.7)-.35
particle.x = (z)*50
particle.y = ((calc_wave(question1,z,0)*question1.multiplier*10.5-.5)+(calc_wave(question2,z,0)*question2.multiplier*10.5-.5))/2+wave_pos(questionset.answer+2)
if z==0 then
particle.special=true
end
increment_score(particle,abs_score)
add(score_particles,particle)
z+=0.005
end
end
function score_particles_update()
for p in all(score_particles) do
p.yvel-=0.12
p.y+=p.yvel
if p.y<45 then
increment_score(p,score)
del(score_particles,p)
sfx(8)
end
end
end
function process_score_particles()
score=abs_score
score_particles={}
end

function score_particles_draw()
 for p in all(score_particles) do
  pset(p.x,p.y,6+rnd(2))
 end
end

function increment_score(p,sc)
 if not is_practice then
  sc.dec+=1
  if sc.dec==100 then
   sc.whol+=1
   sc.dec=0
  end
 else
  if p.special then
   sc.whol+=1
  end
 end
end
-->8
--input: 0 to 25
--all black at 20
--+-0.4 is good speed
colors={0,2,8,7,11,10,9}
function transition(transition_t)
if transition_t<=0 or transition_t>=25 then
return
end
if transition_t <= 20 then
mod_transition_t=27.5/(1+2^(-((transition_t-13.5+2)/1.5)))
if transition_t >= 19.5 then
fade_screen(1)
else
fade_screen(0)
end
circle_step=6
orbiter_x = 128/2 + sin(t)*64
orbiter_y = 128/2 + cos(t)*64
while circle_step>=0 do
r=(1/8)*(2^circle_step)*mod_transition_t^2
circfill(64,64,r,colors[circle_step+1])
circfill(orbiter_x,orbiter_y,r,colors[circle_step+1])
circle_step-=1
end
else
fade_t = (5-(transition_t-20))*2/10
fade_screen(fade_t+fade_amount)
end
end
-->8
info_text="  when 2 waves collide, they\nform a resultant wave that is a\nsummation of each of the star-\nting waves' amplitudes.\n  some waves cancel (or inter-\nfere destructively):\n\n\n\n\n\n\n  some waves amplify each other\n(or interfere constructively):"
intro_text="  my colleagues and i are on a\ndistant moon studying an anom-\nalous source of electromagnetic\nwaves. we are going slightly\ninsane, for many months de-\ncoding these waves blipping\nacross our monitors. waves per-\nvade everything. we have to\nstudy them. using waves, we can\nlook into the ethereal plane\nand uncover the secrets of the\nuniverse. waves reveal what is\non the inside, be it x-rays re-\nvealing the insides of luggage\nor the human body, or waves\npeering into the black box of\nquantum mechanics; by bom-\nbarding a sheet of metal with\nalpha waves, e. rutherford\nfirst deduced the structure of\nthe atom. through the doppler\neffect, we can determine the\nmotion of distant suns by look-\ning at the wavelengths of light\nthat reach us. the ancients\nbelieved that waves, or, in\nsanskrit, \"spanda,\" pervade\neverything and emanate from the\nsupreme god or consciousness.\nfurthermore, as human beings,\nthe sound waves that hit our\neardrums and the light waves\nthat hit our corneas form most\nof our knowledge of the world.\n  and here on this moon, the\ncommunicative power of these\nwaves is eerily pronounced. we\nplanned an expedition to the\nsource of these waves, into a\nradial depression in the earth.\ni was the only one to stay be-\nhind in the lab, to watch the\nwaves. near the bottom, a mag-\nnetic force pulled my col-\nleagues into the abyss.\n  back in the lab, the monitors\nwere ablaze with a seizure-\ninducing amount of waves run-\nning across them. i could read\nmy still alive colleagues'\nbrainwaves. among them was an\nalien brainwave.\n  \"finally,\" the brainwave\nread. \"among all these rocks,\nanother intelligence.\"\n  \"it is coming!\" warned my\ncolleague genevieve. \"hurry! it\nis coming!\" shouted clyford.\nthe facility was shaking, the\nseismic sensors were off the\ncharts - the whole moon was\ncollapsing in on itself! but it\nwas my duty to untangle these\nbrainwaves, find out what this\nsinister entity was, what\nexactly was coming..."
win_text="  translating the waves was\nusually work enough for five of\nus; i had to scramble from mon-\nitor to shaking monitor.\nluckily, my years of training\nprepared me well. i noted the\namplitudes, the periods, the\nfrequencies, the wavelengths,\nthe slopes, the maximums and\nminimums, the peaks and\ntroughs, rendering it all into\nclear english:\n  \"entropy, the heat death of\nthe universe, is coming,\" said\nthe alien brainwaves. \"faster\nthan life can reproduce and\npropogate, entropy is coming.\nit is disorder, decomposition.\nlife and its complexity is its\nopposite and enemy, and is the\nonly force in the universe that\nmight counter it. science is\nthe tool of life that can save\nus from this ultimate end, as\nwell as sooner ends such as by\nasteroids or mortality. any\ndisaster that kills life is a\nvictory by entropy.\n  \"i have assimilated your col-\nleagues, glimpsing from them\nyour cities, art, math, and it\nwill all be more than suffic-\nient. join me and we will focus\nour efforts on science. ally\nhumanity with me against\nentropy!\"\n  i was out of time. i leapt\ninto the escape pod and pressed\nthe button. the spaceship aimed\nin the direction of earth and\nwent into light speed. i\nblacked out to reawaken at my\ndestination.\n  upon waking, i tried to re-\nlease the straps holding my\nwrists and ankles, but they\nwere fastened in place. i\nstrained to see the monitors:\n  \"we will be at earth in 23\ndays,\" they reported. the\nbroadcasted waves must have\nbeen arriving ahead of their\nprogenitor, the alien. \"the\nplanet will soon be ours.\"\n  two human forms were nearby.\none was wearing doctors'\nscrubs, and the other, a suit.\nhow they got into my spaceship,\ni don't know.\n  the man in the suit waved at\nme. \"the way he's staring at\nhis own brainwaves like\nthat-\" he whispered.\n  \"apophenia,\" answered the\ndoctor, \"is a common symptom of\nthose with his condition: find-\ning patterns and information\nwhere there are none.\"\n  \"earth is being bombarded by\nan unsubstantiated amount of\nalpha waves. are you sure that\nthat instrument\" - the man in\nthe suit pointed to what looked\nlike an eeg machine - \"is pick-\ning up his brainwaves, or the\nones coming from outer space?\nand what if what he thinks he\nis reading is true?\"\n  \"he may have been a genius\nonce,\" said the doctor, \"but\nhis state has degenerated. psy-\nchic aliens, the impending\napocalypse - the man is no more\nthan a bumbling idiot.\"\n  \"it's all true!\" i burst from\nthe restraints. \"entropy is\ncoming! i've read all of it in\nthe waves!\"\n\n          created by\n\n          max levine\n\n     additional coding by\n\n         ’ bab_b\n           smallfx\n\n          engine by\n\n          lexaloffle\n\n     thanks for playing!"
lose_text=" the sound of rending\nmetal filled the air as the\nbunker turned sideways. i found\nmyself tumbling into the depths\nof the planet. if only i had\nbeen faster, more accurate in\nmy translation, i could have\nlearned the truth behind all\nthis. as i fell, my last bodily\nsensation was the akathisia of\nthe waves echoing through my\nbones."
__gfx__
ffffffff000000000ffffffffffffffffffffffffffffffffffff000000ffffffffffffffff00000ffffffffffffffffffffffffffffffffffffffffffffffff
fffffff00888888800ffffff0000fffffff000000000000fff000077770f0000fffffff000007770000fff000000000fffffffffffffffffffffffffffffffff
fffffff02888888880ffffff07700fffff00770077700700f0070700000f07700fffff00770700700700f0070077770ffffffffffffffff0000000ffffffffff
fffffff02888888880fffffff0070f000f07000700700070f07000700ffff0070f000f07000700700070f0700700000ffffff8ffff77777000000066666fffff
fffffff02888888880fffffff00700070007000700700070007000070000f00700070007000700700070007000700000fffff8fffff7f7f0000000f6f6ffffff
fffffff02888888880fffffff22722727227222222722227272222222222f22722727227222222722227272222222222fff88f88fff7f7ff000000f6f6ffffff
ff000000288888888000000ff00700707007000700700007070007000000f00700707007000700700007070000700000fffff8fffff7ff7f000000f6ff6fffff
f00888888888888888888800ff0070707070000700700f07070f0077770fff0070707070007000070f07070f0700000ffffff8ffffffffff000000ffffffffff
f02881118188818188118880fff007000700f07000070f00700ff000000ffff007000700f000ff000f00700f0077770fffffffffffffffffffffffffffffffff
002881818188818181888880ffff000f000ff000ff000ff000ffffffffffffff000f000ffffffffffff000fff000000ffffffffffff00000000ffffffff00000
222221112122212121112222fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0bb300800ffffff008820
002881888188818188818880ffffffffffffffffffff000fff000fffffff0000fffffff0000fffffffffffffffffffffffffffffff00bb3008200ffff0088820
f028818881118811811888800000fffffff0000000000700f0070000000f07700fffff0077000000000fff000000000fffffffffff0bb300088200ff00882200
f0088888888888888888880007700fffff00770077700070f0700077770f00070f000f07000077700700f0070077770ffffffffff00bb30f088820000882000f
ff000000288888888000000ff0070f000f0700070070f07000700700000ff007000700070f0700700070f0700700000fffffffff00bb300f0088820088200fff
fffffff02888888880fffffff00700070007000700700007070000700000f00700707007000700700070007000700000ffffffff0bbb30fff00888888820ffff
fffffff02888888880fffffff22722727227222222722227272222222222f22722727227222222722227272222222222fffffff00bb300ffff0088888200ffff
fffffff02888888880fffffff00700707007000700700007070000700000ff0070707070000700700007070000700000fffffff0bb300ffffff00888800fffff
fffffff02888888880ffffffff0070707070000700700f00700f0700000ffff007000700f00700700f07070f0700000f00000f00bb30fffffff008888200ffff
fffffff00888888800fffffffff007000700f07000070ff000ff0077770ffff0000f0000f07000070f00700f0077770f0bb3000bb300fffffff08888882000ff
ffffffff000000000fffffffffff000f000ff000ff000ffffffff000000ffffffffffffff000ff000ff000fff000000f0bbb300bb30fffffff0088200882200f
fffffff000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00bbbbbb300ffffff008820f00888200
ffffff00888888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00bbbb300ffffff008820fff0088820
ffffff02888888880fffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffff00bb300fffffff088820ffff008880
ffffff02888888880fffffffffffffffffffffffffffffffffffffffffff7ffffffffffffffffffffffffffffffffffffff00000ffffffff00000ffffff00000
ffffff02888888880fffffffffffffffffffffffffffffffffffffffff77777ff000000000000000000000000000000000000000000000000000000000000000
ffffff02888888880fffffffffffffffffffffffffffffffffffffffffff7ffff000000000000000000000000000000000000000000000000000000000000000
f000000288888888000000000fffffff000000000000fff000000000ffff7ffff000000000000077700000000000000000000000000000000000000000000000
00888888888888888888807700fffff00770077700700f0070077770fffffffff000007770000070770000000000000000000000000000000000000000000000
02881118188818188118880070f000f07000700700070f0700700000ff77777ff000077070000770070000000000000000000000000000000000000000000000
02881818188818181888880070007000700070070f070007000700fffffffffff000770077000700070000000000000000000000000000777777700000000007
0288111818881818111888007007070070f070070f0070700f0070ffff77777ff007700007007700070000777777777777777777777007700000077000007777
028818881888181888188800700707007000700700007070f00700fffffffffff077000007007000077000000000000000000000000077000000007700077000
028818881118811811888800070707070000700700f07070f0700000fffffffff770000007077000007777000000000000000000000700000000000777700000
00888888888888888888800f007000700f07000070f00700f0077770fffffffff000000007770000000000000000000000000000000000000000000000000000
f000000288888888000000fff000f000ff000ff000ff000fff000000fffffffff000000000000000000000000000000000000000000000000000000000000000
ffffff02888888880ffffffffffffffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000
ffffff02888888880fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffff02888888880ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffff7ffffff7ffffff7fff
ffffff02888888880ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffff7ffff777ffff7ffff
ffffff00888888800ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f7f7ff77777ff7f7f7ff77777f
fffffff000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff777ffffff7fffff7fffff7ffff
f00000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffff7ffffff7ffffff7fff
005777777777777777777777777777777777777777750fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055666666666666666666666666666666666666666650fffffffffffffffffffffffffffffffffffffffffffffffffffffffff000ffff000ffff000ffff000ff
055665555555555555555555555555555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffff000ffff0000ff00000ff0000ff
055665555555555555555555555555555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000
055665500000000000000000000000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000
055665500033333333333333333700555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000
055665500000000000000000000000555555555555650ffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000fff0000fff000fff0000ff
055665500000000000000000000000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffff000ffff000ffff000ffff000ff
055665500000000000000000000000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000000000000070000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000000000000070000556666666555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000007000000770000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000077000007770000550005000555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000777000077070000550555055555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000007707000770070000550555055555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000070007007700077000550505050555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500007700007770000007700555555550555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665507777000000000000000070550555055555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000000000000000000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665500000000000000000000000555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665666666666666666666666666655555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
055665555555555555555555555555555555555555650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000666666666666666666666666666666666666666650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
060055555555555555555555555555555555555555550fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
066700000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
06677777777777777777777777777777777777777600ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
05666666666666666666666666666666666666666660ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
00566666445555666666666666666666666556666660ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0056666445555666666666666666666666556666660ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0050666666666666666666666666666666666666600ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f005550000000000000000000000000000000000700fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f005556666666666666666666666666644466666650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f0055556666666666666666666666666644466666500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff055556665555656666666666666000000000066650ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff005555666666666666666666666666600066666550ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fff00555555555555555555555555555500055555500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffff0067666666666666666666666666666666666500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffff00066656565656565656566565656566466666500fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffff00666666666666666666666666666666666666500ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffff005666646466666444444444446666464646666500fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffff05666666666666666666666666666666666666650fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffff00055555555555555555555555555555555555550fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffff0005555555555555555555555555555555550000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffff0000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffff0000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
000000000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
111100000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
222110000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
334521100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
442211100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
552211100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
66d521100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
776d52100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
889452100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
994521100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
af9452100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
bb3452100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ccd552100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
dd5521100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e99452100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fe9452100fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
__gff__
46716f142f3141724e45726e2b0000000101ffffffff01ffffff01ff03000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
012500000073502735047350573507735097350b7350c7350e7351073511735137351573517735187351a7351c7351d7351f7352173523735247352673528735297352b7352d7352f73507010090100911007110
01020000007000c731007010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012600002e62000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000c1130c1230c1330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300000e41418000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010500000d41500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011a00003065624630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002351428517284160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010300003001000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011900002351428517284161742400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011900000d61000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0118000024300283002d4003030024315283252d4153031624300283002d400303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b00002341623111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
