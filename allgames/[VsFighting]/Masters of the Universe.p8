pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--mASTERS OF THE uNIVERSE v1.5
--THE rOBOz, FOR dORIAN

bg_cmd={"\"&O¥èº–&NiéÉ&NoérÓ&NsévŒ&NwézÆ&N{é~é&fhéè\0&N}éÃ\0&uñvó&oWg\0'qo}Å'nÄvç&O™è∆&O©è≤ 'g®ö≤&NØé∏ê&M∫ç÷Ω'pƒ~≈P'R√b…`'Xøh≈ñ$NNNN»'y}Çí\0'|uáÖ\0'v¿Ñ¬∂'L´£ƒÂ'M´ö¿≈&N~eí†F&öV£\\$VNçV®&∂ãÕô@&±~»èê#Å°ú°#É£ö£#Ñ•ô•a#Äüùü#ÉùöùB#Q¬_ƒ\0#_∆f¬\0'√æÕ¡f#p≈t¡\0#Ç∆É¡\0#ê¡ñ«\0#ü√ß«\0'FªS¡Ü#ôøûƒ\0#ú¬¢¿\0#≠¬ª¡\0#≥√∑∆\0#}¬ã√\0#…Ω–¿\0#RºV¿\0#TæOø\0#m¿q¿\r#s¡o≈#Ü¡è¡\r#è¡íƒ'Å∞ä≥}&öVú\\",
"&'H5—c'H<—j7'HA—ow'DQÿ{›'D@ÿu«#N~WãG#_~gé#~Åà7'Çjò{'Çhòy'Çgòx	$m[nNÖ&N∫é≈\0F'{Ñ÷óá&Eà‘ª'{Å÷î◊'vÑ—ïQ'7ïö◊'úÑóüP'9ÉóûQ'7çï®s'|ãÕ§É&MîÕß'Eè‘º’'Eç‘∫Ì\"SèŒ∂Ü'sõ§ßﬁ&¬Ø‘æ'≥≥»¬&√∞’ø\0'≤¥»√\0\"eñ≥∞	\"fñ¥∞Z'N≥q√'N¥p≈\0\"pôß™:#â§}¥J#í£∏™Z#é°ΩõY#jñxòI#nîyñ:#zôàü\n#zñïú	'hΩ∂≈±'kæ≥ƒÌ'x¿¶¬å#QéVòG#æç∫ïG#vãxè'H©Rº\0'y¨≥∫¥'ÖØÆπï&∆ñŒ∞&ƒ†»≤'∆ë–∂\0'æ¢≈¶$nNNVœ&àríîŒ&âçë£ &ãrè£ô'dçhè\0",
"!&N_Õu¢&NAÕWe&NíÕ∂ê&NLÕaƒ'ôRÀÉ\r\"òRÀÉP'üS«Å'•U»zb'åÉïí\0'[îe≠\0&W≠Õø\0'Ae÷•±-lphÑ\0&^ç∫≥\0'Åvéë\0'f{kÜ\0&mnáì\0$NNNœ&≤è¥ê&≥è¥ê'¨W…tÌ&¥è¥è	'Æë¥ï#∞í¥ì'SiWn\0'Zm^p\0#UnVo#WlXm&N∂Œ¿F'ïïü≤\0&N¥Œªò'7∫~»\0'gªÊ≈\0'7º~ 'gΩÊ«'N¡–…Ω-ßòûÑ\0'ùÖ®ï\0",
" 'PIü¢'^Pûò-idwNÿ&M¶ç∆&N•ç§	'vWòÖ'vZõÇ	'x`ôÉ\n&rãér\n'Äqêã'Ü^íj&s£{ä\0'wotä	'smoâ&|Ñéô&}èçë\0&Ütéc&aWiç&e`gÑ&qnràâ#O•é•'cìwß\0'_®°≤Q'^én†ê&t†è£&uüêû\r&vùèú%&zôèó]!Åééç&Éäéâ&|ïèñ#}íãë'ÇÄyë\0#}_xe#wgvl-Çá}è!#{]xa	#ufsl	#ÅZ[	#nmoe#r`zU#paÇS#ÖSéU#f`gÖ#af^n#_p^t#`v_{#zhwÇ	#vt}e	'ÉxÉ\0'MkOÜ#RdP{\0#S^Q~\0#RZOg#OnP~&b[aí#OíTù#OäRî#YjVu\0#UvTÑ\0#Z}\\Ñ#`_^d#\\hZs#`±wØô'Ö`í}†'jäoí'däií\0'aèq£'kãnê	&ZPdñ–$_OUW«'eìn°$'fïlû	'gñkúJ'lçmê\n&wÖ{á\0&OOX©ê&N¶ç™0\"m™´≥9\"R¶≥¥4&N´çØ–F'I∏Ÿ∆Ì'X∫∆≈Ω'@ønÀ'b¬{…'@¡oÕ	'b√z 	'†ø€Õ'ü¡⁄œ	#òì¢£#áâÇñ\0'∞d≤Ç$gNë[µ",
"%&OV…d#NeÕe\r#ƒK√K\r'I<—cç'I;—b\r'I9—`å'I7—^'I4—[Ü'I2—Y'N6≈Xá'O.ŒU#VNƒN-NeWN\0#VOƒO\r#OdWM-œj≈N\0-X_Ze\0-__\\e\0-p]le\0-≠]±e\0-ä]ÉV-∑Yº]-yTwN\0-`TeN\0'…R–e\0#WeX^\r#Y^Ze#[e`^\r#`^_e#_O_W#_WfN#ãWãe\r# d≈O\r#ä\\äe- `¡W\0#íVëe\r#í^íe#odq]\0#q]qe\r#o^ke-zW]#o]q]\r#ÇUãU#êUîU-mUpN\0#mNlU#qMmV#wOz]#yOyV#yVÄ]#ôV°V\r#õ]£]#¢W£]\r#òU¢U'®SÆW\r'®S≠V\0#°O§]#Æ]≤d#≠e¨]\r#ÇVâ]#∏Yæ]#¿W»^\r#∆VøV\r-∑Y¥\\R-ÜYÉVB-|Z]B#∑^µ\\#¥\\∑X\r#≤P∂W\r#≥P∑W-sRoX-sTqW\0&NfÃm\"F"}

function pal_from_map(y)
  local p,pl = {},{}
  for y=y,y+1 do
    for m = 0,120,8 do
    for i = 0,7 do p[i*2],p[i*2+1] = mget(i+m,y) >>4, mget(i+m,y) &15 end
    add(pl,p) p={}
    end
  end
  return pl
end

d_i,i_t,ease_in_out,roll_k,roll_x,roll_y,o_y,work_ram,screen_ram,leg_frame,offs_x,offs_y,d_out,gore,musics,ê, title_comm, credits_color_index,c_index,pal_leg, pal_torso, pal_sword, pal_roll = true,split(" _i am adam, prince of eternia_fabulous secret powers were_revealed to me when i raised_my magic sword and said_by the power of grayskull!_i have the power!_i became he-man, the most_powerful man in the universe!_together with my friends_we defend castle greyskull from_the evil forces of skeletor","_"),45, 22.5, 2, 5, -24, 0x4300, 0x6020, {}, 0, 0, false, false, split"0,24,48,48", split, {}, 0,0, pal_from_map(23), pal_from_map(25), pal_from_map(27), pal_from_map(29)

function create_frm_tbl(t)
  local o_t,tbl={},ê(t)
  for i=1,#tbl,2 do
    add(o_t,{tbl[i],tbl[i+1]})
  end
  return o_t
end

torso_frame, back_leg, front_leg,special_leg = create_frm_tbl"16,17,18,19,0,1,2,3,25,26,20,-4,21,99,22,99,23,99,24,99,28,29,28,11,-29,29,-11,11,14,15,27,10,30,-30,28,-28,9,10,25,26,", ê"32,34,37,39,40,42",ê"33,35,41,43", create_frm_tbl"36,0,39,0,60,61,62,63,39,46,39,44,39,35,46,44,44,0,46,0"

function ò(t,default)
  local o_t,tbl={},ê(t)
  for i=1,#tbl,4 do
    o_t[tbl[i]]={}
    for j=1,3 do
    add(o_t[tbl[i]],tbl[i+j])
    end
  end
  o_t[0] = default
  return o_t
end

arms_ofs,plxy_ofs,head_ofs,trso_ofs,swrd_ofs,masters_tbl = ò("701,,4,,702,,4,,-702,,4,,763,,12,,773,,7,,813,,12,,873,,7,,935,,6,360,1240,,6,360,1264,11,31,360",ê"0,0,720"),
 ò("24,1,,,213,,8,,561,-4,,,653,,8,,658,-10,9,,659,-4,6,,-659,-4,8,,763,,8,,873,,8,,702,,-2,,-702,,-2,,935,,-4,,1643,,8,,1093,,8,,1011,4,,,1154,2,,,1264,2,,,1572,,-8,,1644,,-8,,1754,,-6,,5000,4,8,,5001,3,3,,5015,3,3,,5016,4,8,,",ê"0,0,0"),
 ò("10,5,,,43,,2,,223,5,1,,333,5,1,,263,5,1,,463,1,,,483,2,,,545,1,,,546,0,,,561,0,,340,594,0,,350,593,5,,,653,5,,,658,-6,7,327,659,-6,16,112,1011,10,,13,1093,8,2,30,1572,5,1,,1643,,1,45,1644,5,,,1682,5,1,, 1754,5,,,1871,5,,,1880,5,,,2013,1,,,2023,2,,,2091,3,,",ê"4,0,0"),
 ò("24,-1,,,43,,2,,223,3,,,263,3,,,333,4,,,463,2,,,483,3,,,545,2,,,546,1,,,593,4,,,653,5,,,658,-5,5,,659,-4,12,,-659,-4,12,,935,-1,,,1011,2,,,1682,2,,,1754,2,,, 1871,1,,,1880,1,,,1093,2,1,,1240,1,,,2013,2,,,2023,3,,,2091,3,,",ê"0,0,0"),
 ò("24,7,,,43,7,6,331,113,9,,,153,10,7,280,213,9,,317,223,18,0,334,263,16,1,87,333,18,,48,463,11,2,139,483,14,2,137,545,14,3,331,546,13,3,,561,4,7,104,594,4,6,80,593,14,7,87,653,13,6,86,658,-2,14,96,659,10,18,260,-659,4,18,260,701,9,-8,226,702,11,-8,247,-702,11,-8,247,763,14,-6,167,773,7,-5,87,811,1,1,25,813,14,-6,167,873,4,-7,101,1011,9,,4,1093,10,8,112,1154,16,0,319,1264,14,-8,0,1572,4,6,60,1633,0,7,110,1641,3,6,62,1643,3,6,124,1644,2,8,60,1682,6,1,61,1754,6,1,61,1871,13,8,76,1880,13,8,76,1891,12,8,120,2013,17,3,322,2023,16,3,320,2091,13,1,300",ê"8,5,342"),
 ò"1,64,109,HE-MAN,2,64,109,ADAM,3,67,110,MAN AT ARMS,4,73,110,STRATOS,5,115,79,TEELA,6,112,79,SORCERESS,7,86,110,ZODAC,8,102,109,FISTO,9,99,109,SHE-RA,10,80,79,SKELETOR,11,83,109,MER-MAN,12,70,109,TRI-KLOPS,13,89,110,BEASTMAN,14,83,110,STINKOR,15,76,109,JITSU,16,96,79,EVIL-LYN,17,64,109,FAKER,18,92,79,HORDAK,"

anims,dither_p,d_c,stage_y_line = {{1}, ê"12,101,24,1", ê"24,101,12,1", ê"1572,1644,1754,1682,1", ê"43,213,213", ê"43,1,1", ê"2023,463,2013,483", ê"873,873,213,653,653,213", ê"701,701,223,333,333,223", ê"773,773,2091,263,263,2091", ê"811,811,153,593,593,153", ê"702,935,-702,773,2091,263,263,2091", ê"1,113,1011,113,1", ê"545,545,546,545,545,1,1", ê"3,773,773", ê"773,813,813", ê"873,763,763", ê"1633, 594, 101, 12, 1", ê"561,658,213,43", 1, 1, ê"12,1641,1641,1641,1643,1643,1643,1643,1093,-659,-659,-659,-659", ê"1643,1643", ê"1093,1093", ê"658,658", ê"659,659", ê"10,1880,1871,10", ê"1,1891,1154,1264,1264", ê"702,935,-702,-773"},ê"32768, 32736, 24544, 24416, 23392, 23391, 23135, 23131, 6747, 6731, 2635, 2571, 523, 521, 9, 1",ê"rect,oval,line,map,select,rectfill,ovalfill,,,,,,trifill",ê"106,114,114,106"

function do_d_cmds(comm)
  for i=1,#comm do
    local cmd = comm[i]
    if (cmd[6]!=0 and cmd[7] !=4) fillp(-dither_p[cmd[6]] +.5)
    _ENV[d_c[cmd[7]]](unpack(cmd))
    fillp()
  end
end

function add_d_comm(bg_comm,fg_comm,string)
  local cmd_table,dest_table,cmd,c_i = string,bg_comm,{},0
  if (#cmd_table>0) bg_color = ord(cmd_table,1)-32
  for i=2,#cmd_table do
    if c_i==0 and sub(cmd_table,i,i) == "F" then dest_table = fg_comm
    else
      local o = ord(cmd_table,i)
      if c_i==5 then
        add(cmd, o & 15) add(cmd, (o & 240)>>4)
        if (cmd[7] == 4) cmd[5]+=1 cmd[6]+=1
      else
        if c_i==0 then cmd[7]=o-32 else add(cmd, o-32 + ((c_i>0 and c_i<5) and -46 or 0)) end
      end
        c_i+=1
      if (c_i==6) add(dest_table,cmd) cmd={} c_i=0
    end
  end
end

add_d_comm(title_comm,nil,bg_cmd[5])

function copy_from_ram(start_y,end_y,ofs_line)

  if need_copy then
    for y=start_y,end_y do
      for x=0,63 do
        local ody = y<ofs_line and 1 or 0
        pset(126-x,y+ody,pget(x,y))
      end
    end

    for y=start_y,end_y do
      memcpy(work_ram + y*32, screen_ram + y*64, 32)
    end
    need_copy = false
  else
    for y=start_y,end_y do
      memcpy(screen_ram + y*64, work_ram + y*32, 32)
    end
  end
end

function check_copy_bg()
  if need_copy then
    add_d_comm(bg_shapes,fg_shapes,bg_cmd[stage+1])
    d_stage()
  end
end

function ai(IA)
  local distance, a1, dmgH,dmgN,dmgL = calc_distance(),pl1.action, pl2.dmgH,pl2.dmgN,pl2.dmgL

  function adv()
    return any(IA,"4,5,7")
  end

  function is_near()
    return distance <36 and distance >24
  end

  function is_crouching()
    return any(a1,"5,8")
  end

  function attacks(pl)
  local hit_count,a = pl.hit_count, pl.action
  if any(a,"1,5,6,15,16") or(a == 2 and pl.frm == 1) then
  if hit_count == 0 then
    if adv() and is_near() then
      ì(pl,11)
    else
      ì(pl,14)
    end
  elseif hit_count == 1 then
    if distance <= 24 then
      ì(pl,13)
    elseif adv() then
      ì(pl,9)
    else
      auto_idle(pl)
    end
  elseif hit_count == 2 then
    ì(pl,7)
  elseif hit_count == 3 then
    if adv() and is_near() then
      ì(pl,7)
    elseif adv() then
      ì(pl,8)
    else
      auto_idle(pl)
    end
  elseif hit_count == 4 then
    if adv() and is_near() then
      ì(pl,9)
    elseif adv() then
      ì(pl,8)
    else
      ì(pl,5)
    end
  elseif hit_count == 5 then
    if adv() then
      ì(pl,2)
    else
      ì(pl,8)
    end
  elseif hit_count == 6 then
    ì(pl,6)
  elseif hit_count == 7 then
    ì(pl,2)
  end
  pl.hit_count+=1
  if (adv()and pl.hit_count == 6) or pl.hit_count == 8 then pl.hit_count = 0 end
  end
  end

  if (pl2.action==7 and pl2.done) ì(pl2,1)

  if is_not_busy(pl2) then
  if distance >=60 then
    to_roll_fw(pl2)
  else

  if (distance < 60 and a1 == 12) then
    if IA == 3 then
      if (dmgN > 2) to_crouch(pl2) return
      ì(pl2,16) return
    end
    if (IA == 6) ì(pl2,8) return
    if (IA == 7) to_roll_fw(pl2) return
  end

  if distance == 48 and a1 == 1 then ì(pl2,12) else

  if distance > 36 and distance < 60 then
    if a1 == 3 then
      auto_idle(pl2) return
    else
      ì(pl2,2) return
    end
  end

  if distance == 36 then
    if adv() then
      if (a1 == 21) ì(pl2,8) return
      if (IA   <7 and not is_not_busy(pl1)) to_roll_fw(pl2) return
      if (IA == 7 and not is_not_busy(pl1)) ì(pl2,2) return
    else
      if (a1 == 21) ì(pl2,11) return
      if (not is_not_busy(pl1)) ì(pl2,2) return
    end
  end

  if is_near() then
  if     a1 == 20 then ì(pl2,4)
  elseif a1 == 21 then ì(pl2,8)
  elseif a1 ==  3 then ì(pl2,7)
  elseif adv() then
    if (IA == 5 and a1 == 9) ì(pl2,15) return
    if (dmgL > 4 and (is_crouching() or a1 == 7)) ì(pl2,7) return
    if ((dmgL > 2 and (is_crouching() or a1 == 7)) or (dmgN > 2 and IA<7 and a1 == 9)) to_roll_fw(pl2) return
    if (dmgH > 2 and a1 == 10) ì(pl2,8) return
  else
    if IA > 1 then
      if (dmgL > 4 and is_crouching()) ì(pl2,8) return
      if ((dmgL > 2 and any(a1,"5,21")) or (dmgH > 2 and a1 == 9) or (dmgN > 2 and a1 == 10)) to_roll_fw(pl2) return
    end
  end
  attacks(pl2)
  elseif distance <= 24 then
  if a1 == 4 then to_roll_fw(pl2) return
  elseif any(a1,"5,20")
    then ì(pl2,14) return
  elseif adv() then
    if (IA > 4 and a1 == 11) ì(pl2,16) return
    if (IA == 5 and a1 == 8) ì(pl2,4) return
    if (dmgL > 4 and (is_crouching() or a1 == 7)) ì(pl2,7) return
    if (dmgL > 2 and (any(a1,"14,7") or is_crouching())) to_roll_fw(pl2) return
  else
    if (IA == 3 and a1 == 11) ì(pl2,16) return
    if (IA == 2 and a1 == 8)  ì(pl2,4) return
    if IA > 1 then
      if (dmgL > 4 and is_crouching()) ì(pl2,14) return
      if (dmgL > 4 and IA > 2 and a1 == 7) ì(pl2,7) return
      if (dmgL > 2 and (a1 == 14 or is_crouching())) to_roll_fw(pl2) return
    end
    end
    attacks(pl2)
  end
  end
  end
end
end

function animate(pl)
  if (is_rolling(pl)) return false
  local any,anims, _ENV = any,anims, pl
  tik = (tik+1) % frm_len
  if tik == 0 then
    frm += 1
    if frm >= #anims[action] then
      if any(action,"2,3,7")
        then frm = 0
      else frm -= 1 end
      return true
    end
  end
end

function auto_idle(pl)
  if(pl.done) ì(pl,1,1)
end

function change_outline()
  d_out = not d_out
  menuitem(3,"outline "..(d_out and "off" or "on") ,change_outline)
end

function change_gore()
  gore = not gore
  menuitem(2,"gore "..(gore and "off" or "on") ,change_gore)
end

function add_leg_frames(leg_table,i)
  for b=1,#leg_table do
  local l=i*leg_table[b]
  for f=1,#front_leg do add(leg_frame,{l,front_leg[f]}) end
  for f=1,#back_leg  do add(leg_frame,{l,-back_leg[f]}) end
  end
end

function _init()
  music(0)
  mode, selected_menu, p1_s, p2_s, orco_dy, stage,sword,s_t = exp"0, 0, -1, -10, 0, 0,.25,0"
  set_stage()
end

menuitem(1,"back to title",_init)
change_gore()
change_outline()
add_leg_frames(back_leg,1)
add_leg_frames(front_leg,-1)
for b=1,#special_leg do
  add(leg_frame,special_leg[b])
end

function init_player(...)
  player={}
  ì(player,1,1)
  local exp,_ENV = exp,player
  can_decap,x,y,last_step,hit_count,dmgL,dmgN,dmgH,head_X,head_Y,life = true,exp"-16,-24,0,0,0,0,0,0,0,12"
  id,flip,pad = ...
  if (flip) x = 112-x
  return _ENV
end

function pre_init_pl()
  pl1,pl2 = init_player(-p1_s,false,0), init_player(-p2_s, true,1)
end

function init_fight()
  srand(t())
  sword,s_t,orco_x,p2pad = .25, 0, -20, 1
  if mode == 1 then
    p2pad = 9
    stage = starting_p == 9 and diff\2 or (7-diff)\2
  end
  set_stage()
  check_copy_bg()
  pl1,pl2 = init_player(p1_s,false,0), init_player(p2_s, true,p2pad)
  music(musics[stage+1])
end

function check_swap(pl)
  local other = (pl==pl1 and pl2) or pl1
  return (not pl.flip and (pl.x > other.x-8)) or (pl.flip and (pl.x < other.x+8))
end

function check_swap_action()
  local a1,a2 = pl1.action, pl2.action
  return (a1 == 4 and a2 == 20 and pl1.x> 11 and pl1.x<108) or (a1 ==20 and a2 == 4 and pl2.x> 11 and pl2.x<108) or a1 == 29 or a2 == 29
end

function collision(pl)

  if pl1.flip then
    A,B = pl2, pl1
  else
    A,B = pl1, pl2
  end

  if not skip then
    distance = calc_distance()
    if distance<16 then
      if is_moving(pl) then
        plwalk(pl,-pl.last_step) pl.last_step*=-1
      else plwalk(pl,-2) pl.last_step=0
      end
    end
  end

  if (orco_x > -20 or intro) return
  A.x,B.x = mid(0,A.x,128-16), mid(0,B.x,128-16)
end

function calc_distance()
  return abs(pl1.x-pl2.x)
end

function check_damage(A,B)
  local aa,ba,af,bf = A.action, B.action, A.frm,B.frm

  function check_hit(x,y)
    if (ba !=19 and ba !=18 and ba!=22 and A.yAttA == y) and (A.x>B.x and A.xAttA <= x or A.x<B.x and A.xAttA >= x) then
      if (is_rolling(B)) B.y=o_y
      sfx(3) return B
    else
      return nil
    end
  end

  function cling(A,B,frame)
  sfx(8)
  local sx,y = 0,0
  function init_cling(pl)
    local _ENV = pl
    frm,tik=frame,frm_len-1
    sx+=xAttA
    return yAttA
  end
  if A then y = init_cling(A) set_hit_areas(A) end
  if B then y = init_cling(B) set_hit_areas(B) end
  if (A and B and sx>0 and sx!= A.xAttA and sx!= B.xAttA) sx/=2
  if distance<32 then
    if (A) plwalk(A,-4)
    if (B) plwalk(B,-4)
  end
  fx_spark(sx,y)
  end

  if aa == ba and distance < 46 then
    if (is_sword_attack(aa)) and any(af,"3,4") and any(bf,"3,4") then
      cling(A,B,4)
      return true
    elseif aa==12 and any(af,"5,6") and any(bf,"5,6") then
      cling(A,B,6)
      return true
    elseif aa==7 and distance < 34 and (af == 1 or bf == 1) then
      cling(A,B,3)
      return true
    end
  end

  local res = check_hit(B.xHead,B.yHead)

  function blood(y,frm)
    frm = frm or 18
    fx_blood(res.x,y)
    decrease_life(res)
    ì(res,frm)
  end

  if not res then
  res = check_hit(B.xNeck,B.yNeck)
  if not res then
    res = check_hit(B.xBody,B.yBody)
    if not res then
    res = check_hit(B.xLeg,B.yLeg)
    if res then
      if any(aa,"14,20") then
        if(aa == 14) res.dmgL+=1 decrease_life(res)
        ì(res,19)
      elseif aa == 7 then
        blood(res.yLeg,19) res.dmgL+=1
      else
        blood(res.yLeg) res.dmgL+=1
      end
      return true
    end
    else
      if res.action == 16 then cling(A,nil,4)
      else blood(res.yBody)
      end
      return true
    end
  else
    if aa == 13 then
      res.dmgN+=1 decrease_life(res)
      ì(res,19)
    elseif res.action == 16 then
      if aa==12 then blood(B.yNeck) res.dmgN+=1
      else cling(A,nil,4)
      end
    else
      if aa == 12 and gore and res.can_decap and res.life<10 then
        ì(B,22,6) trail_x = B.x + (flip and 4 or 12)
        local _ENV = B
        head_X, head_Y, headDy, headRot = x + 8, yNeck-4, -1.5, 0
      else
        blood(B.yNeck) res.dmgN+=1
      end
    end
    return true
  end
  else
    if res.action == 15 then cling(A,nil,4)
    else blood(B.yHead,19) res.dmgH+=1
    end
    return true
  end
end

function decrease_life(pl)
  if(pl.life>0) pl.life-= 1
  --if(pl==pl2 and pl.life>0) pl.life-= 12 --db cheat
end

function check_death(pl)
  if pl.life==0 then
  srand(t())
  local d = rnd(2)
  if (pl.x>16 and pl.x<111) d = rnd(4)
  ì(pl,flr(d)+23)
  if pl==pl1 then to_win(pl2)
  else to_win(pl1)
  end
  else auto_idle(pl)
  end
end

function d_throne()
  pal(3,1)
  pal(11,5)

  do_d_cmds(bg_shapes)
  copy_from_ram(0,119,0)
  if (not need_copy) do_d_cmds(fg_shapes)

  local p = 1

  function d_lava (bx,c) oval(bx, 120-ct, 2*bx+32, 132, c) end

  d_lava(ct,10)
  d_lava(80-ct, 10)

  poke(0x5f5e, 0xfc)
  for j=0,48,2 do
    fillp(-dither_p[flr(p)]+0.5)
    rectfill(   j, j,        8+j+ct, j+10+ct, 13)
    rectfill(32+j, j-16+ct, 40+j-ct, j+2*ct)
    p=min(p+.65,15)
  end
  out_off()
  fillp()
end

function d_snake()
  do_d_cmds(bg_shapes)
  copy_from_ram(119,119,0)
  sdy+=.15 if(sdy>8)sdy=0
  for i =-8,128,8 do
    spr(207,80,72+i+sdy)
    spr(207,i+sdy,103)
  end
  fillp(dither_p[10]+.5)
  local c,s=cos(sdy/4),sin(sdy/4)
  circfill(80+c,102+s,3,9)
  circfill(88-c,102+s,3)
  fillp()
  if (not need_copy) do_d_cmds(fg_shapes)
end

function d_eternia()
  do_d_cmds(bg_shapes)
  copy_from_ram(0,119,0)
  if (not need_copy) do_d_cmds(fg_shapes)

  fillp(-dither_p[14]+0.5)
  rectfill(60+ct,40,67-ct,75-2*ct,10)
  fillp()
  ovalfill(30,57+ct,38,72+ct,0)
  ovalfill(20,   ct,30,17+ct)
  map(36,14,16,  ct,4,9)

  local cp = (1-ct)/2
  ovalfill(103,cp,118,20+cp)
  map(46,14,96,cp,3,3)
  ovalfill(12,cp+80,18,cp+88)
  map(35,18,12,cp+72,2,2)
  ct/=2
  ct+=64
  ovalfill(82,ct-1,98,24+ct)
  map(43,20,82,ct,2,3)
end

function d_grayskull()
  do_d_cmds(bg_shapes)
  copy_from_ram(8,119,64)

  poke(0x5f5e, 0x76)

  cloud_h = (cloud_h+.05)%6
  for f=0,14 do
   radius = (f-cloud_h)/2.2
    for i=1,rnd(12)do
    srand(f)
    local c_x, c_y = min(-40 + i + 128/radius, 26), min(30-rnd(3.8)*radius, 26)
    fillp(-23390.5)
    circfill(    c_x,c_y,  radius,4)
    circfill(127-c_x,c_y+1,radius)
   end
  end

  out_off()

  if (not need_copy) do_d_cmds(fg_shapes)

  for r = 0,2 do
  fillp(-dither_p[14-r*3]+0.5)
  circfill(63,60,18+ct-r*4,1)
  fillp(-dither_p[15-r*2]+0.5)
  circfill(63,64,15+ct-r*5,2)
  end

  fillp()

end

function d_thunder()
  srand(credits_color_index)
  local rx = rnd(40)-20
  for t=32,96 do
  local x1,x2 = 22+t/1.5 + rx, 40+t/2.5 + -rx/2
  line(t, 24, x1, 56, ê"1,12,7,7,7,7,12,1"[t\8-3])
  line(x1, 56, x2, 92)
  line(x2, 92, 46+t/3.5, 112)
  end
end

function d_legs(pl,flip)
  local f = pl.anim_frm<0 and -pl.anim_frm or pl.anim_frm

  if (pl.id == 5) palt(9,true) palt(10,true)
  if (pl.id != 10) palt(1,true)

  local spr_f = leg_frame[(f-1) % #leg_frame + 1]

  vflip = (f == 659) and true or false

  for i=2,1,-1 do
  local sf, hflip, xsize, ysize, ox, oy = spr_f[i], flip, 1, 2, spr_f[2] == 0 and 4 or (i-1)*8, 8
  if (f == 545 and i == 2) ox-=3 oy-=3
  if (sf<0) sf = - sf hflip = not hflip
  if (sf>43) xsize, ysize = 2, 1
  if (flip) ox = 8*(2-xsize)-ox
  if (sf!= 0 and (i != 2 or spr_f[1]<60)) spr(sf+fem, pl.x + pl.fx + ox, pl.y + pl.fy + stage_y + oy, xsize, ysize, hflip, vflip)
  end
end

function d_torso(pl,flip)
  local f = pl.anim_frm<0 and -pl.anim_frm or pl.anim_frm
  if (pl.id == 5) palt(0b1000000000001100)
  local spr_f = torso_frame[(f-1) \ #leg_frame + 1]
  vflip = (f == 659) and true or false

  local x,y = get_part_coords(trso_ofs,pl,0,flip)

  for i = 1,2 do
  local sf, hflip, oox = spr_f[i], flip, spr_f[2] == 99 and 4 or (i-1)*8
  if (sf<0) sf = - sf hflip = not hflip
  if (i==2 and sf == spr_f[1]) oox-=1
  if (flip) oox = 8-oox
  if (i==1 and is_win_frame(pl)) spr(8+fem, x+oox, y+4, 1, 1, flip,true)
  if (sf!= 99) spr(sf+fem, x+oox, y, 1, 1, hflip,vflip)
  if (pl.anim_frm == 811) oox = hflip and 6 or 2 spr(30+fem, x+oox, y-2, 1, 1, hflip)
  end

end

function d_head(pl,hd,flip)
  mset(127,8,hd)

  local h,f,px,x,y = pl.id, pl.anim_frm, pl.x, get_part_coords(head_ofs,pl,7,flip)

  pal_default()
  palt(0b0000000000010000)

  if (h == 14) pal(ê"1,14,0,4,1,0,7,8,13,0,11,12,13,14,15") pal(0,10)
  if (h == 17) pal(ê"1,2,3,4,5,6,7,8,4,2,11,12,1,13,12")

  if pl.action != 22 then
    if any(f,"935,10") or is_win_frame(pl) then
      local col = 9
      if is_fem(h)>0 then
        col = 1
        if(f == 935 and h != 5) ovalfill(px+2,y,px+12,y+14,pal_leg[h][10])
      end
      if(f == 935) pal_tint(pal_leg[h][col])
      local hh,hx = any(f,"1264,1871") and 2 or 1, flip and 1 or 0
      spr(hd+hh, x+hx, y-8, 1, 1, flip)
    else
      if (f ==659) flip = not flip
      d_rotated_tile(x+4, y, rot, 127, 8, 2,flip)
    end
  else
    local d,_ENV = d_rotated_tile,pl
    d(head_X, head_Y, headRot/360, 127, 7.5, 2,flip)
  end

  palt(0b1000000000000000)
  offs_x, offs_y ,rot = get_ofs_rot(arms_ofs,pl)
  if (f == 1240) flip = not flip
  if (flip) offs_x = (2-rot)*8 - offs_x

  local x, y = px + pl.fx + offs_x, pl.y + pl.fy + stage_y - 8

  if offs_y>0 then
    pal(pal_torso[h])
    spr(offs_y+fem, x, y, rot, 1, flip)
  end

  if f != 935 and f != 1240 and f!=1900 then
    d_sword(pl,flip)
  elseif f != 1240 and f!=1900 then
    offs_x = flip and -7 or 7
    spr(6+fem, x+offs_x, y, rot, 1, not flip)
  end
end

function d_player(pl)
  local sflip,x,h = pl.flip,pl.x,pl.id

  fem = is_fem(h)

  pal_player()

  if not is_rolling(pl) then
    pl.anim_frm = anims[pl.action][pl.frm+1]
    pl.fx,pl.fy = get_ofs_rot(plxy_ofs,pl)
    if (pl.flip) pl.fx*=-1

    if pl.anim_frm<0 then
      sflip = not pl.flip
    end

    local a=pl.anim_frm
    pal(pal_leg[h])
    d_legs(pl,sflip)
    pal_player()
    pal(pal_torso[h])
    d_torso(pl,sflip)
    local head_sp = masters_tbl[h][1]
    d_head(pl,head_sp,sflip)
  else
    local r, py = pl.frm_len , pl.y+stage_y
    pal(pal_roll[h])
    local my = fem>0 and 19.7 or 14.7
    d_rotated_tile(pl.x+8, py,   r/360, 126.4, my, 2)
    d_rotated_tile(pl.x+8, py, 1-r/360, 126.6, my, 2,true,1)
    if(h!=10) palt(1,true)
    if (r < ease_in_out or r > 360 - ease_in_out) pal(pal_leg[h]) spr(60, pl.x, py + plxy_ofs[5000+r\roll_k][2], 2, 1, sflip)
  end
end

function d_rotated_tile(x,y,rot,mx,my,w,flip,scale,o)
  scale = scale or 1
  local halfw, cx = scale*-w/2, mx + .5
  local cs, ss, cy = cos(rot)/scale, -sin(rot)/scale, my-halfw/scale
  local sx, sy, hx, hy = cx + cs*halfw, cy - ss*halfw, w*(flip and -4 or 4)*scale, w*4*scale
  for py = y-hy, y+hy do
    if (not(o and (rot<.25 or rot >.75) and py>y+4)) tline(x-hx, py, x+hx, py, sx + ss*halfw, sy + cs*halfw, cs/8, -ss/8)
    halfw+=1/8
  end
end

function d_stage()
  local df = {d_grayskull,d_eternia,d_snake,d_throne}
  cls(bg_color)
  df[stage+1]()
  if(need_copy) return
  pal_default()
  line(exp"127,0,127,127,0")
  rectfill(exp"0,119,127,127")

  function d_health(pl,x,k,x1)
    local xc = x+k*pl.life*4
    rectfill(x, 120, x+k*48, 126, 4)
    if (pl.life>0) rectfill(x, 120, xc,126,3) rectfill(x,121,xc,124,11)
    ps(masters_tbl[pl.id][3],x1,120,7)
  end

  if intro then
    ps(exp"prepare to fight!,256,121,10")
  elseif pl1 then
    d_health(pl1,0,1,1)
    d_health(pl2,126,-1,510)
  end
end

function d_sword(pl,flip)
  local h,x,y=pl.id, get_part_coords(swrd_ofs,pl,15,flip)
  local ht = masters_tbl[h][2]
  pl.swrd_rot,o = rot,false
  mset(127,0,any(h,"10,18") and 127 or ht)
  mset(127,1,ht+16)
  if any(h,"5,6,10,16,18") then
    mset(127,2,ht+32)
  else
    mset(127,2,0)
    o=true
  end
  pal(pal_sword[h])
  d_rotated_tile(x, y, pl.swrd_rot, 127, 0, 4, flip,1,o)
  pl.sw_y = offs_y
end

function is_fem(id)
  return any(id,"5,6,9,16") and 128 or 0
end

function sword_from(sc)
  local r=(s_t*3)^2.5/20
  if (not sc) sword=mid(.5,sword+.05,2.5) else sword = 2.5
  if (sword%.5>.4 or r >5) pal_tint(7)
  local sw,scale = (2.5-sword)*12, sc or sword/2.5

  function d(r,f)
    d_rotated_tile(63+cos(sword)*sw,71+sin(sword)*sw,r,91.4,0,14,f,scale)
  end

  d(-sword,false) d(sword,true)
  if (sword > 1.5 and sword <1.6) sfx(6)

  if sword== 2.5 and not sc then
    ovalfill(63-r/2,63-r,63+r/2,63+r,7)
  end
end

function exp(c)
  return unpack(ê(c))
end

function d_transition_bg()
  function ll(i,c)
    line(i,0,ln-i,ln,c) line(0,ln-i,ln,i,c)
  end

  cls(0)
  srand(t()\.1)
  ln=127
  for i = 1,ln do
  local r = rnd(64)
  if (r < 4) ll(i,8)
  if r>3 and r < 40 then ll(i,4) elseif r>2 and r < 50 then ll(i,2)
  end
  end
  fillp(-2634.5) rectfill(exp"0,24,127,103,4") fillp()
end

function get_ofs_rot(ofs_table,pl)
  offs = ofs_table[pl.anim_frm]
  local def = ofs_table[0]
  if offs then
    for i=1,3 do
      if(offs[i]=="") offs[i]=def[i]
    end
  else
    offs = def
  end
  return offs[1],offs[2],offs[3]/360
end

function get_part_coords(tbl,pl,k,flip)
  offs_x, offs_y ,rot = get_ofs_rot(tbl,pl)
  if (flip) offs_x = k - offs_x
  return pl.x + pl.fx + offs_x, pl.y + pl.fy + offs_y + stage_y
end

function is_rolling(pl) return any(pl.action,"20,21") end

function is_sword_attack(aa) return aa >7 and aa <12 end

function is_not_busy(pl)
  local a = pl.action
  return not (is_rolling(pl) or (a!=7 and a>3 and pl.frm+1 < #anims[a]))
end

function is_moving(pl)
  local a = pl.action
  return a == 2 or a == 3 or a == 12 or is_rolling(pl)
end

function is_win_frame(pl)
  local f=pl.anim_frm
  return any(f,"1154,1240,1264,1871,1880,1891,1900")
end

function pal_default()
  pal()palt(0b0000000000000010)pal( 4, 136, 1)pal(14, 142, 1)pal(15, 143, 1)
end

function to_fw(pl)
  return (btn(ë,pl.pad) and not pl.flip) or (pl.flip and btn(ã,pl.pad))
end

function to_bk(pl)
  return (btn(ã,pl.pad) and not pl.flip) or (pl.flip and btn(ë,pl.pad))
end

function out_off()
  poke(0x5f5e, 0xff)
end

function pal_player()
  pal()palt(0b1000000000000000)
end

function pal_tint(col)
	for i=0,15 do pal(i,col) end
end

function plinput(pl)
  local pad, a = pl.pad, pl.action
  local attacking, defending = btn(é,pad), btn(ó,pad)

  if is_not_busy(pl) then
  if btn(É,pad) then
    ì(pl,5)
  else
    if a == 5 then
      ì(pl,6)
    elseif ((btn() & (0x003F << pad*8)) == 0) then
      ì(pl,1,1)
    elseif a != 5 and a != 8 then
    if to_fw(pl) then
    if attacking then
      sfx(5)
      ì(pl,10)
    elseif defending then
      ì(pl,13)
    else
      if(a!=2) plwalk(pl,4)
      ì(pl,2)
    end
    elseif to_bk(pl) then
    if attacking then
      ì(pl,7)
    elseif defending then
      ì(pl,14)
    else
      if(a!=3) plwalk(pl,-4)
      ì(pl,3)
    end
    elseif btn(î,pad) then
    if attacking then
      ì(pl,9)
    elseif defending then
      if a == 16 then ì(pl,15,3,2) else ì(pl,15) end
    else
      ì(pl,4)
    end
    elseif attacking and defending then
      ì(pl,12)
    elseif attacking then
      ì(pl,11)
    elseif defending then
      ì(pl,16)
    end
    end
  end
  end
  pl.done = animate(pl)
end

function plstate(pl)
  local a,pad,flip,f = pl.action, pl.pad, pl.flip,pl.frm
  pl.can_decap = true

  function at_frm(fr)
    local _ENV = pl
      return frm == fr-1 and tik == frm_len-1
  end

  function do_roll()
    pl.y-= 8
    if check_swap(pl) then
      to_reverse(pl)
    elseif btn(É,pad) then
      to_crouch(pl)
    else
      ì(pl,6)
    end
  end

  function ccw_roll(step)
    pl.frm_len-=roll_k
    local s = pl.frm_len
    if s < 0 then
      do_roll(pl)
    else
      plwalk(pl,step)
      if (s >= 360 - ease_in_out ) pl.y+=roll_y
      if (s < ease_in_out ) pl.y-=roll_y
    end
  end

  function cw_roll(step)
    pl.frm_len += roll_k
    local s = pl.frm_len
    if s >= 360 + roll_k then
      do_roll(pl)
    else
      plwalk(pl,step)
      if (s <= ease_in_out ) pl.y+=roll_y
      if (s > 360 - ease_in_out ) pl.y-=roll_y
    end
  end

  if a == 20 then
    pl.can_decap = false
    if flip then
      ccw_roll(roll_x)
    else
      cw_roll(roll_x)
    end
  elseif a == 21 then
    pl.can_decap = false
    if flip then
      cw_roll(-roll_x)
    else
      ccw_roll(-roll_x)
    end
  elseif a == 2 then
    if (at_frm(f+1)) plwalk(pl,4)
  elseif a == 3 then
    if (at_frm(f+1)) plwalk(pl,-4)
  elseif a == 4 then
    if (pl.frm <4) pl.can_decap = false
    if is_not_busy(pl) then
      if check_swap(pl) then
        to_reverse(pl)
      else
        auto_idle(pl)
      end
    end
  elseif a == 5 then
    pl.can_decap = false
    if f>1 then
      if btn(É,pad) and (btn(é,pad) or btn(ó,pad)) then
        sfx(4)
        ì(pl,8)
      end
    end
    if f>1 then
      if to_fw(pl) then
        to_roll_fw(pl)
      elseif to_bk(pl) then
        local angle = 0
        if (not flip) angle = 360
        sfx(9)
        pl.y+=8
        ì(pl,21,angle,angle)
      end
    end
  elseif a == 13 or a == 14 then
      if (at_frm(1)) sfx(2)
      auto_idle(pl)
  elseif a >=23 and a<= 26 then
      if (at_frm(1)) pl.frm-=1
  elseif a ==28 then
      if (at_frm(4)) pl.frm-=1
  elseif is_sword_attack(a) then
    if at_frm(1) then
      if (a == 11) sfx(5)
      if (a == 9) sfx(4)
    end
    if a == 8 then
      if(is_not_busy(pl)) to_crouch(pl)
    else
      auto_idle(pl)
    end
  elseif a == 12 then
    pl.can_decap = false
    if f<4 then
      if f>2 then
        plwalk(pl,4)
      elseif f>0 then
        plwalk(pl,2)
      end
      if(at_frm(2)) sfx(4)
    elseif is_not_busy(pl) then
      if pl==pl1 and pl2.action == 22 then
        to_win(pl)
      elseif pl==pl2 and pl1.action == 22 then
        to_win(pl)
      else
        auto_idle(pl)
      end
    end
  elseif a == 7 then
    if (at_frm(1)) sfx(6)
  elseif a == 18 then
    if (at_frm(f+1)) plwalk(pl,-2)
    if (is_not_busy(pl)) check_death(pl)
  elseif a == 19 then
    if (at_frm(1)) sfx(2) plwalk(pl,-8)
    if (at_frm(3) and pl.life >0 and btn(É,pad)) to_crouch(pl)
    if (is_not_busy(pl)) check_death(pl)
  elseif a == 22 then
    update_head(pl)
    if (at_frm(5)) sfx(5)
    if (at_frm(12)) pl.frm-=1
    local fx_blood,stage_y,_ENV = fx_blood,stage_y,pl

    if (anim_frm == 1641) fx_blood(xNeck,yNeck,-4)
    if (anim_frm == 1643) fx_blood(xBody,yBody)
    if (anim_frm == -659 and frm<10) fx_blood(xLeg,stage_y)

  elseif a == 16 or a == 6 then
    pl.can_decap = false
  elseif a == 29 then
    if  at_frm(3,pl) then
      pl.flip = not pl.flip
      ì(pl,1,1)
    else
      plwalk(pl,2)
    end
  end
end

function plwalk(pl,step)
  local _ENV = pl
  last_step = step
  if (flip) step=-step
  x+=step
end

function ps(s,x,y,c)
  if x / 256 ==1 then x -= 192+2*#s elseif x / 256 >= 1 then x -= 384+4*#s end
  ?s,x+1,y,0
  ?s,x+1,y+1
  ?s,x,y+1
  ?s,x,y,c
end

function any(x,s)
  for e in all(ê(s)) do
    if (x == e) return true
  end
end

function set_hit_areas(pl)
  if  is_rolling(pl) then
    local assert,dx,adx,stage_y,D_in_out,_ENV = assert,8,20,stage_y,2.5*ease_in_out,pl
    if(flip) dx = 7

    xAttA = x
    if action == 20 then
      if (not flip) and ( frm_len >= D_in_out and frm_len < 360 - D_in_out) then
        xAttA = x + adx
      elseif (flip) and ( frm_len > D_in_out and frm_len <= 360 - D_in_out) then
        xAttA = x-3
      end
    elseif flip then
        xAttA = x + adx
    end

    yAttA,xHead,yHead = y + stage_y -4, x + dx, y + stage_y
    xNeck, xBody, xLeg = xHead, xHead, xHead
    yNeck, yLeg = yHead - 4, yHead + 8
    yBody = yNeck
  else
    pl.anim_frm = anims[pl.action][pl.frm+1]

    function hit_offs(tbl)
      local aofx,aofy = get_ofs_rot(tbl,pl)
      if(pl.flip) aofx= -aofx+15
      return pl.x + aofx, pl.y -8 + stage_y + aofy
    end

    local ò,ê,hit_offs,_ENV=ò,ê,hit_offs,pl
    xAttA, yAttA = hit_offs(ò("263,32,8,,333,32,4,,463,22,22,,546,24,22,,593,28,14,,653,32,22,,1011,24,8,",ê"0,0,0"))
    xHead, yHead = hit_offs(ò("43,-2,,,113,16,,,1011,16,,,213,-2,,,873,-2,,,653,-2,,,763,-2,,,702,-4,,,-702,-4,,,935,-4,,,",ê"14,4,0"))
    xNeck, yNeck = hit_offs(ò("43,-2,,,113,16,,,1011,16,,,213,-2,,,873,-2,,,653,-2,,,763,-2,,,702,-4,,,-702,-4,,,935,-4,,,1641,8,,,",ê"14,8,0"))
    xBody, yBody = hit_offs(ò("113,16,,,1011,16,,,763,12,,,463,-4,,,483,-4,,,702,-4,,,-702,-4,,,935,-4,,,1643,8,,,1644,-4,,,2013,-4,,,2023,-4,,",ê"14,14,0"))
    xLeg,  yLeg  = hit_offs(ò("113,16,,,1011,16,,,702,-4,,,-702,-4,,,935,-4,,,1572,-4,,,1644,-4,,,1682,-4,,,1754,-4,,",ê"14,22,0"))

    if (action == 12 and frm> 4) xAttA-=4
  end
end

function set_stage()
  stage_y,intro,skip,trail_x,orco_y,sdy, cloud_z, cloud_h, need_copy, bg_shapes, fg_shapes, effects = stage_y_line[stage+1],true,true,200,stage_y_line[stage+1]-18, 0, 0, 0, true, {}, {}, {}
end

function ì(pl,anim,stp,fr)
  local _ENV = pl
  if action != anim then
    fr = fr or 0
    if anim>7 and anim <18 then stp = 3 elseif not stp then stp = 5 end
    action,frm,tik,frm_len = anim, fr, 0, stp
  end
end

function to_crouch(pl)
  ì(pl,5,5,1)
end

function to_reverse(pl)
  ì(pl,29,4)
end

function to_roll_fw(pl)
  if pl.action != 20 then
  local angle = pl.flip and 360 or 0
  sfx(9)
  pl.y+=8
  ì(pl,20,angle,angle)
  end
end

function to_win(pl)
  if (is_rolling(pl)) pl.y=o_y
  ì(pl,28)
  music(-1)
  if mode<3 and pl!=pl1 then
    music(62)
  else
    music(61)
  end
end

function trifill(x1,y1,x2,y2,c)
  local inc=sgn(y2-y1)
  local fy=y2-y1+inc/2
  for i=inc\2,fy,inc do
    line(x1+.5,y1+i,x1+(x2-x1)*i/fy+.5,y1+i,c)
  end
    line(x1,y1,x2,y2)
end

function update_head(pl)
  local abs,min,sfx,stage_y,ox,_ENV = abs,min,sfx,stage_y,orco_x+16,pl

  function step_head(x,r)
    if (ox> -1 and ox+16>=head_X) x=2 head_Y-=.25 r=22.5
    head_X+=x
    if (flip) then headRot-=r else headRot+=r end
  end

  local d = ox >= head_X and 0 or abs(head_X-xNeck)

  if d<=36 then
    if (flip and xHead<127-36) or (not flip and xHead<=36) then
      step_head(1.5,-22.5)
    else
      step_head(-1.5,22.5)
    end
    head_Y+=headDy
    headDy+=.5
    if (head_Y>stage_y-2) headDy=-1 sfx(2)
    head_Y=(min(stage_y-2, head_Y))
  end
end

function boss()
  return any(p1_s,"-9,-18") and 1 or 9
end

function _update()
  pal_default()

  function select_player(p,pl,pad)
    local flip = pl == pl2

    function browse_p()
      sfx(2)
      return init_player(-p,flip,0)
    end

    if btnp(ë,pad) then
      p-=1 if (p<-#masters_tbl) p = -1
      pl = browse_p()
    elseif btnp(ã,pad) then
      p+=1 if (p>-1) p = -#masters_tbl
      pl = browse_p()
    else
      ì(pl,28)
      animate(pl)
    end
    return p,pl
  end

  function is_decapped(pl)
    if (pl.action == 22 and pl.frm > 6) skip = true return pl
    return nil
  end

  if not done_intro then
    done_intro = credits_color_index >20
    credits_color_index+=.25
    return
  end

  function up()
    if(btnp(î,0)) sfx(2) return -1
    if(btnp(É,0)) sfx(2) return 1
    return 0
  end

  if p2_s < 0 then
    if(btnp(ó,0) and mode>0) then
      if (mode==2 and p1_s>0) p1_s = -p1_s pre_init_pl() return
      _init() return
    end

    pl1.x = 16
    if mode == 0 then
      selected_menu+= up()
      selected_menu %= 3
      if btnp(é,0) then
        pre_init_pl()
        if (d_i) d_i,pl1.y = false,-24 return
        sfx(2) mode,orco_x,stage,diff = selected_menu+1,-20,0,0 starting_p=0
      end
    else
      if (mode == 3 or p1_s >0) then
        local pad = p1_s>0 and 0 or 1
        p2_s,pl2 = select_player(p2_s,pl2,pad)
      end

      if(p1_s <0) p1_s,pl1 = select_player(p1_s,pl1,0)

      if mode == 2 and p1_s>0 then
       diff+=up()
       diff %= 8
      elseif mode> 1 then
       stage+=up()
       stage %= 4
      else
        starting_p = (p1_s >-10) and 9 or 0
        p2_s = -starting_p-1
      end

      if btnp(é,0) then
      sfx(2)
      et,enemy_list = ê("2,3,4,5,6,7,8,"..boss()),{}
      for i=1,7 do
        local e = rnd(et)
        add(enemy_list, e+starting_p)
        del(et, e)
      end

      add (enemy_list,10-boss()+starting_p)

      if (mode != 2 or p1_s >0) p2_s = -p2_s orco_x = 200
      if (mode==1) diff = 0 p2_s = enemy_list[1]
      if (p1_s<0) p1_s = -p1_s
      end
    end
    pl1.x = 16
    return
  end

  if orco_x>=128+32 then

    local function ended()
      return mode==1 and diff==7 and pl1.action == 28
    end

    if (ended() and btnp(é,0)) _init()

    if sword == 2.5 then
      if(s_t == 0) sfx(1)
      s_t+=0.5
      if s_t>14 then
        sword,s_t,selected = .25,0,false
        if (mode == 1 and (diff <7 or pl1.action != 28)) or not end_fight() then
          if mode==1 and end_fight() and pl1.life>0 and kp != pl1 then
            diff=diff+1
            p2_s = enemy_list[diff+1]
          end
          init_fight()
        elseif ended() then
          music(0)
        else
          p1_s,p2_s,kp,trail_x = -p1_s, -p2_s, nil, orco_x
          pre_init_pl()
        end
      end
    elseif sword==.5 then
      sfx(6)
      music(63)
    end
  else
  if (not intro) skip = check_swap_action()

  kp = is_decapped(pl1) or is_decapped(pl2)
  check_copy_bg()fx_update(stage_y)
  plstate(pl1)collision(pl1)plstate(pl2)collision(pl2)

  function do_intro(pl)
    if(pl.action!=2) plwalk(pl,4)
    ì(pl,2)
    pl.done = animate(pl)
  end

  if intro then
    if pl1.x<36 then
      do_intro(pl1)do_intro(pl2)
    else
      ì(pl1,1,1)ì(pl2,1,1)
      intro,skip,orco_x = false, false, -20
    end
    return
  end

    if end_fight() then
      orco_x+=2
      orco_dy=sin((orco_x%30)/30)
      if kp and orco_x >= kp.x + ((kp.flip and 4) or 12) then
        kp.x +=2
      end
      animate(pl1)animate(pl2)
      return
    end
    plinput(pl1,0)collision(pl1)
    if mode == 3 then
      plinput(pl2,1)
    else
      ai(diff)
      pl2.done = animate(pl2)
    end
    collision(pl2)
    set_hit_areas(pl1)
    set_hit_areas(pl2)
    if not skip and not check_damage(pl1,pl2) then
      check_damage(pl2,pl1)
    end
  end
end

function end_fight()
  return kp or pl1.life == 0 or pl2.life == 0
end

function tv_bg(n)
  if mode == 0 then
    camera(0,-24)check_copy_bg()d_stage()camera(0,0)
    if d_i then
      pl1 = init_player(c_index<7 and 2 or 1)
      pl1.action,pl1.x,pl1.y,pl1.frm  = 28, 56,-16,ê"1,1,1,1,1,2,3,3,3,2,1,1,1"[c_index+1]
      local a = any(c_index,"6,7")
      if (a) d_thunder()
      d_outline(pl1)
      if(not a or credits_color_index%2==0) d_player(pl1)
      pal_default()
    else
      local menu_y,menu_dy = 74,12
      for y= 1,3 do
        ps(ê"arcade mode,p 1 vs cpu,p 1 vs p 2"[y],256,menu_y+menu_dy*(y-1),7)
      end
      menu_dy *=selected_menu
      ps("è            è  ",256,menu_y+menu_dy,7)
      d_orco(16,menu_y+menu_dy-10)
    end
  else
    d_transition_bg()
  end

  do_d_cmds(title_comm)

  ps("o f     t h e    u n i v e r s e",256,25,7)
  if p2_s<0 then
    rectfill(exp"0,120,127,127,0") credits_color_index+=.25
    ps((d_i and i_t or ê" ,original   idea    ,     john   henderson,music        ,damien hostin   @yourykiki   ,               matt kimball,      geoff   sejai-smith,programming   and gfx    ,    andrea   baldiraghi,       motu tm   by mattel inc.,  barbarian by   palace software, ")[c_index+1],256,121,ê"0,0,0,0,1,5,13,6,7,7,7,7,6,13,5,1,0,0,0,0"[flr(credits_color_index)])

    if credits_color_index >20 then
       credits_color_index,c_index=1,(c_index+1)%12
    if(c_index==0) d_i,pl1.y = false,-24 pre_init_pl()
    end
  end
  if (mode > 0) sword_from(n)
end

function d_shadow(pl)
  if pl.flip then o,o1=1,0 else o,o1=0,1 end
 line(pl.x,   stage_y-o,  pl.x+ 8, stage_y-o,  0)
 line(pl.x+6, stage_y-o1, pl.x+14, stage_y-o1, 0)
end

function d_outline(pl)
  if (not d_out) return
  poke(0x5f5e, 0x0F)
  function d(x,y)
    pl.x+=x pl.head_X+=x pl.y+=y pl.head_Y+=y
    d_player(pl)
  end
  d(-1,0) d(2,0) d(-1,-1) pl.y+=1 pl.head_Y+=1
  out_off()
end

function _draw()
  ct = 3.5*cos(t()/4)
  if (not done_intro) cls() ps("tHErOBOz PRESENTS",256,61,ê"0,0,0,0,1,5,13,6,7,7,7,7,6,13,5,1,0,0,0,0"[flr(credits_color_index)]) return
  if p2_s<0 then
    tv_bg(1)
    if (mode == 0) return
    ps(masters_tbl[pl1.id][3],10,88,7)
    if (mode >1 ) ps("STAGE "..ê"castle,eternia,snake,throne"[stage+1], 2,102,7) ps("î É",(mode == 2 and p1_s>0) and 94 or 2,109,7)
    pl2.x = 96
    ps(masters_tbl[pl2.id][3],502,88,7)
    ps("vs",256,64,10)
    if (mode == 2) ps("LEVEL "..diff+1, 506,102,7)
    stage_y = 84
    if mode==1 then
      local s = ê"2,118,5,108,0,98"
      for t=1,6,2 do
        pl2.id,pl2.x = -p2_s+s[t],s[t+1]
        d_player(pl2)
      end
      pl2.id += 9-boss()
    end
  else
  if orco_x>=128+32 then
    if (mode==1 and diff==7 and pl1.action == 28) then
      cls(0)
      for i = 1,8 do
      pl1 = init_player(i+9-starting_p,false,0)
      pl1.action,pl1.frm, pl1.x = 28, 3 + cos(t())\2, 16 *(i-1) -2
      d_player(pl1)
      end
      local ss = starting_p==0 and "doomed" or "saved"
      ps("eternia is "..ss,256,16,7)
      ps("you have the power",256,32,7)
      return
    end
    tv_bg()
    return
  else
    d_stage()
  end
  end

  if(orco_x>trail_x) ovalfill(trail_x,stage_y,orco_x,stage_y+2,8)

  for pl in all{pl1,pl2} do
  d_shadow(pl)
  d_outline(pl)
  d_player(pl)
  end

  pal_default()

  if kp and orco_x>-20 then
  d_orco()
  end
  fx_draw()
end

function d_orco(ox,oy)
  orco_x,orco_y = ox or orco_x, oy or orco_y
  sp=105+2*(ceil(t()*10)%2)
  if d_out then
  poke(0x5f5e, 0x0F)
  for x=-1,1 do
  local doy = x==0 and 1 or 0
  spr(sp,orco_x+x,orco_y-doy+orco_dy,2,2)
  end
  out_off()
  end
  spr(sp,orco_x,orco_y+orco_dy,2,2)
end

function fx_spark(x,y)
  for i=0, 1 do
    local rw = rnd(2)-1
    fx_add(x+rw, y+rw, 4+rnd(2), rw, rw, 0, 10)
  end
end

function fx_blood(x,y,dy)
  if (not gore) return
  dy = dy or rnd(1)-1
  for i=0, 3 do
    local rw = rnd(2)-1
    fx_add(x+rw, y+rw, 2+rnd(16), rw, dy, .5, 8)
  end
end

function fx_add(...)
  local fx={}
  if(#effects<8) add(effects, fx)
  local _ENV = fx
  t,grow,r,x,y,die,dx,dy,grav,col = 0,-.1,1.2,...
end

function fx_update(stage_y)
  for fx in all(effects) do
    if fx.t>fx.die then
      del(effects,fx)
    else
      local min,_ENV = min,fx
      dy+= grav r += grow x += dx y += dy y = min(y,stage_y) t +=1
    end
  end
end

function fx_draw()
  for fx in all(effects) do
    circfill(fx.x,fx.y,fx.r,fx.col)
  end
end
__gfx__
0000000000014cef0000000000000000000000000ff000000000000000000000000000005d14420000000000d81410000000000000000000000005d5b5000000
000d142144443cef001442144000000000000000ff2000000000000000000000000000005d14141110000000d511000000000000000000000000141bbb500000
00d14444441221000144414124400000000000003c3c0000000cfe000000003eee0000002d2144441413cef0dd20000000000001141c3ef00001441dbdd50000
00d4441222141000d544444412412022000000000c3cc0000043c20000000cc3ef0000001dd221444413cef08d2000000000001441223f300444415d2dd51000
00d2122210000000dd11255144441cef00000000014214000441000000014c2c300000004dd1122000000000dd5000000000014410000c10c312555828511400
00d14155000000000d141d52000033f00000000001141140041200000014100cc000000015dd555000000000d50000000000044410000140cce055dd8dd013cf
00dd1ddd000000000d11d5d00000ee000000055e12141210004110000044100041200000125562600000000062000000000014410000044002ff5d677650000e
0045d440000000000d5ddd00000000000000efe244441410001422000014410041100000112a9a9000000000a9000000000011410000141000f00d6767000000
00004d5dbbb54000000001ddbbd0000005d5b100444441224255214104152214001441d55dd100000000000004445d5b004ddbbbd54403c00fe000000eff0000
00044458dbd84200000042158bd20000014151001441828541dd82140125152101441dd1d144100000ef00004213fe5b014d8dbdd81411c00ee2000000cc0000
0004415dd8dd14000004441ddd8120004441ddd0d115d8d511dddd210dd141dd14412dd5d14444000cfe000041ceff5d0415ddd8dd144140ff32000100130000
0044125d828524000044415dd8214400442d5d80d15dddd05dd555500ddddddd41125522dd2141213c000000445225d204152d8282514400efc1221400410000
00412555d8d41400004111255d8114001441d821055d67605d5266600ddddddd14443cee5d1211443000000000555ddd44125dd8dd5000000324114401440000
00044125fd3c110000004411233c100004425d510d5476700556776005dd1dd50d5213fe05d52140000000000055ddaa410025ddd50000000112241201410000
00004c3efe3c1000000000d2f3ec000001441223005677600d567660005d4d500dddd5e2025d52200000000000da77aa33005267620000000041022024410000
0000093a99a90000000000a9f9a00000001444cc009a99a0009a99a0005a9a5009a99a20009a9a9000000000005a9a90cce09a99a90000000000000014400000
00000ccccddd000000000ccccddd00000dcccddd0000dccc55520000000ddccc00000ee99e0000000000ccccddd000002effe00000000000000000ff20000000
00000dccdddf000000000dcccddf00000dcccdd20000dccc99551000000deeec0000ddcccdd000000000dccddde00000ffffffff0000005000000fffee000000
00000eedcdeff00000000eedcdef00000eeecdee0000eeedaa9df100000effee0000dcccccdd00000002edccdee00000fffff2effe760530002fffe2fff00000
0000efeedbeff00000000feedeeff0000ffedeef0000eff2aa9d14000000fffe00000deedcdef000000efed2effe00002ee2002eee684330ddeffee0efe80000
0000ffff11eeff000000efff11eff0000fffe2ef0000fffea99514000000efff00000eeeddefff00002fff21efff00000000000007684300dcefee000e282035
0000fff0112eff000000efff11efff000efff2ee0000fffe9952440000000fff00000fff22eefff000efff111fff00000000000000003000ccdee20002882330
0000fff01102ef2000000eff110eff0002fff2e00000fff15114410000000fff0000efff1102effe00fffe111fff000000000000000000000000000000083350
0002ff201100eff000000ff2110eff0000effe200000fff1d444120000002ffe0000efff11000eff00fff0111ef2000000000000000000000000000000003500
002ef20000002e2000000f20000e220000ef22f00002f200de4241000000ee200000effe110000ff00ef00000ee0000000000dcdddee20000002e2dd00000000
00eff0000000eef600000eff00eef000000eee00000eff0052882000000ffe0000002ef000000efe0eee00000efe00000000dcccddefff00002efffee2eeff20
00efe0000000776600000efe06ee6000006eff00000efe00d022000006efe00000efeee000000ee60ffe000007e760000000eeecdeeefff0002efffffff22eff
077760000000766000006777047760000466770000777600008200000666600006eee000000066677fe00000067660000000effd112eeeff0000eee22ffe2eef
067600000000048000000640044000000446667000676000000000000448000006660000000004887760000000440000002efffe11006eff000062eeeee22200
04400000000003350000088053300000553388000004400000000000088000004480000000000350684000000048000002efffe011548ee00055864486220000
08800000000005550000534005550000055544000038800000000000535000005350000000000533044000000033500052efff00115448000005380488000000
335000000000000000003550000000000005333000335000000000005330000033300000000000005330000000000000222ee000000006000005300050000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb222bbbbb2bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb0006d000
bbbbbbbbbbbbbbbbbbbbbbbbbbdccdbbbdcccdbbbd9c9dbbbbbbbbbbbbbbbbbbbbbbbbbbbb2484bbb28482bbbb844bbbbb40bbbbbb505bbbbbbbbbbb000d6000
bbb29a9bbb9a9bbbbb999bbbbdc99cdbd99c99db99ddd99bbbb0000bbb000bbbbb333bbbb248488bb84848bbb84848bbbb09efebb2fff2bbbbefebbb000d7000
bb29aaabb9aaa9bbb9dfd9bbbc9dcccb9dcccd9bdc2e2cdbbb333333b33333bbb37c73bbb288cc3b3c383c3b310c013bb055f0fbb0efe0bbb50f05bb000d6000
bb9a9fdbbadedabbbafefabbbcd9ce2bdc2e2cdbdcfffcdbbb31637cb37c73bbb3eef3bbbb48310cb10c01bb3c3e3c3bb00f5e0bb50e05bbb2f5f2bb000d7000
bba9effbbaffeabbbaeeeabbbdcceffbbdfffdbb5deeed5bbb05eeebb0eef0bbb0eee0bbbb288c3bbc3e3cbbb3ffe3bbbb0eeffbbef5febbb50e05bb000d6000
bb9afefbb9fee9bbb9efe9bbbb44fe9bbe9e9ebbbe9e9ebbbbb4effbbbeffbbbb0efe0bbbbbd3efbb3ffe3bbb5efe5bbbbb5fe5bb50e05bbb22022bb000d6000
b52fee2bb5ee25bbb5fe2552b94fe99be99e99ebe99e99ebbbee4e4bb24e42bbb24e42bbbb25dd5bb5d5d5bbb5d5d5bbbb2fe20bbb202bbbbbefebbb000d6000
bbbbbbbbbbbbbbbbbbbbbbbbbb53bbbbb3bbb3bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbddbbbbbbdbbbbbbbbbbbb000d6000
bbb1111bb5111bbbbbbbbbbbb535353b3533353bb53b35bbbdd284bbdbb8bbdbbbb2bbbbbbb444bbbb4e4bbbbb484bbbbb505dbbb50505bbbbbdbbbb000d6000
bb11100b510101bbb51115bbb333539b5393935b5393935bbb55448bb54845bbb84848bbbb42884bb48484bbb24842bbbd0d67db506d605bbd6d6dbb000d6000
b15105ab10a9a0bb510901bbbb5539ab39a9a93b9609069bb5d4884bd84848dbd20d02db2b24824bf24842fbbd1e1dbb05d6567d067d760b5286825b000d6000
b001540b050a05bb15a4a5bbb535960b9609069b59a9a95bb8d5820b520d025b5d555d5bb28f8d1bed1e1de2e8f4f8ebb057d28bd28682db0d776d0b000d6000
b0110eab059494bb059495bb535399ab59aaa95b3992993bb284d55bbd555dbb55ffe55b248e8feb28f4f82428e9e824001d677b5677665bd65256db000d6000
bb1054ebb04e41bbb04541bbb533399b3292923b5235325bbb285efbb5ffe5bbb5efe5bbb228489b28e9e84228848822b051d67b1d525d1b5d1d1d5b000d6000
bb0cd5bbb5cdc5bbb1cdc1bbbb35920bb32023bbb32023bbb52feddbbedddebbbedddebb2424284b428482244248422405051d1bd5d5d5db15d5d515000d6000
bbbbbbbbbbbbbbbbbbbbbbbbbbb9bbbb9bbbbb9bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbeeeeeee84eeeeeeeeeeeeeee84eeeeee00060000000e9000000d6000
bbbdb2bbbd222dbbbbbbbbbbbbb94b4b9b9b9b9b9bb8bb9bbbb242bbbb424bbbbb242bbbeeee8888844eeeeeeeeee8884488eeee0006600000e99a00000dd000
bbb0d00bd20002dbb22022bbbb49498b94a8a49b94efe49bbb24242bb42424bbb2efe2bbeeeeeee48248eeeeeeeeeee484248eee000d60000e99aaa0000d6000
b20200fb20e0e02b2d1f1d2bb9949efb49efe94b9edede9bbb4242ebb2efe2bbbe1e1ebbeee2d2ee4842488eeeeeeeee484248e8000d600000e99a00000dd000
bb0d0d1b2d1e1d2b00fef00b9a49afdb9edede9b49fff94bbb2f2e1bbf1e1fbbb2f4f2bbeeeeed248ccd242eee2d2d248ccd2424000d600000033000000d6000
bbd00ffbd0fff0db20fdf02baa949ffb49fff94b94f8f49bbb4e4febbef4febbb24242bbee2ddddd9b1c2442eeeedddd9b1c2842000d6000006677000005d000
bdb220ebb0ede0bbd2eee2db9aa4ef8ba4f8f4abaa4e4aabbb24f42bb24242bbb12221bbeeee2d2d2d28100eee2d2d2d2d281002000d600000033000000dd000
bbcdfebbbcdedcbbbcdedcbb994efebb9a4e4a9b9aefea9bb52e424bb12421bbb51215bbee84242424d209a0e484242424d209a0000d6000000bb0000005d000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb022222200eeeeeeeeeeeee00e48482948d4d2001888482948d4d20010005d0000003b00000000000
bbb767bbb67776bbb04c40bbbbb449bbbb8a8bbbbba89bbb220222200eeeeeeeeeeee000884849dc88d4dd2ee84849dc88d4dd2e000d6000000b30000043b000
bb7641dc914c419bb4ede4bbbb4889abb8a898bbb8e8e8bb0200200002eeeeeeeeee0000e48424cc224242eee48424cc224242ee0009a0000003b00048422420
bb7694ed64ede46b791e197bb48498eb4aefe94bba1f19bb0002220000eeeeeeeee00001e48842d220000448ee4842d220000448000aa000000bb00084831892
b6769e1b791e197b79fff97bb8849e1b891e198b49fff94b002200201200eeeeee000001ee4484840444422ce44484840444422c00fe7f000066770042412424
b7679ffb79fff97b6defed6bbb489ffb49fff94b89fef98b0002000002100eeeee000131ee4e4e4840eee8cdeeee4e4840eee8cd00f77e000004400082231980
b676dfeb6defed6b76eee67b94b4efeb94efe49b44eee44b2000200002402eeee0000331eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee003bb3000004800048818894
b7676ebb764e467b674e476bb942febb942e249b942e249b00000000112022eee0000331eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000b0000000800000011242
000000000003bbef0000000000000000000000000ff00000000000000000000000000000c65ff20000000000eaefe0000000000000000000000cc565e5d00000
00c5ee8efffb33ef0cefe2efe000000000000000ff200000000000000000000000000000c55ee8ee20000000a52ec00000000000000000000ccdef7efead0000
0c5eff88ff3220000eff8efe2fe00000000000003b3b0000000bfe000000003eee000000c6528fffef2bc2f0562dc000000000002eeb3ef0cddeff27ea650000
0c5ffe2222000000c5ee88ffe2fb202200000000033300000033b20000000bb3ef000000c56522eefeebcef0665dc00000000002fe3b3f30ceffe256a665e000
cd52e25610000000c55522222e43b3ef0000000002e2200002fe00000002f32b30000000c556552000000000552dc000000000efe2000b30b32255666652ef00
cd95565500000000c9655552000033f00000000002efe2000ee20000002ee003b0000000c55665500000000065dddc00000002fe20000eb03bed5556555d23bf
cd98889900000000c956659000000000000003beee2e2e2002fe2000002fe000f2000000cd5998800000000092dddc000000088e000002e0c2fed56565dd000e
cd99889000000000c9988900000000000000efe28fef2fe0002fe200002efe00ee200000cd9998800000000099dddc00000002f200002ee0cdedd99889ddd000
000cefaefea0000000000c6aefa000000cd7ea00f8fffe22f2552efe0fe522ef0c2efe672c77000000000000ce8f567e002ec7efeaf203b00fe000000ef00000
000cff67efae00000000c2e57ea20000cef57e00ee8e5252fe57a2e20e25e52ece8fe567cefe200000ef0000e233fe7e02ef677eaae822300ee0000000b20000
00c88e567eaf0000000c28867ea820002fe57ea0d2257aa5e566562d055e5e55ef825667c2e8e2000bfe0000febbef6708856666662f2e20feb2000e003b0000
00cfe2566a6400000002fe566a6fe20088256660d556656d2555655dc5656565fe255525c658fe203b0000002f2255660fe256656652ef00ef3b22e800e30000
00fe2556656e2000000cfe255555fe002fe56562c555555dc556666dc6666666e4443be2c655efee30000000cd555666efed5556555ddc00033feefe02fe0000
00cfb325553b200000cd44b32e3b2000cef2555ecd55666dc566665dc5665665c552b3fec5652eff00000000cd556688fedd566665dddc0000e22fe20ef20000
00cd3b3efeb3dc0000cddd3bfeb3d000c2fe2893cd59889dc559889dcd66666dc5988522cd59922000000000cd5999883bdd298892ddddc00000020028e00000
00cdd998892ddc0000cddd99889dd000cd2efe3bcd99889dcd99889dcd66566dc99889ddcdd9988000000000cd999990b3dd998899ddddc000000000e8200000
00a99ddcbd299000000a99dcbdd99000a9dccbcd0a99ddcbbbbb30000a9ddccb00a99dbbb2000000a99adccbcd9a9a002efe200000000000000000ef20000000
0a999dccbcd99000000a99ccbcd99000a92dcbd20a99dccb999bb3000a9deedc00a99ddcbd200000a999d2cbcde9aa00ffffffe20000000000002effe2000000
0a999eddbdd29000000a99edbdd29000a92edd2e0a992eed99a9b300a992ffe20a999ddcbcd20000a99a2e2bd2eaa000eeeee2e336700080000effe2f3200000
00a92feedeff20000000a9fedeee2000a9efd22e00a92ff2aa995300a999eff20a999de2dd2e20000a9aefe22ef9a0000000002557688840ddeffe2053760000
000aeff299efe000000002ff2eefe0000aefe2ee000aefeaa99514000a992ff200a99efed2effe000a99ffe99efa00000000000000884400dcefe20005684040
0000ffe9992ff000000000efe92ff20000eff2e20000efe09955140000aa0efe000aaffe002effe000a9ff299efa00000000000000004000ccde200000082480
0000ff20000ef200000000ffe00efe00002ef2e00000ef2055514100000002fe00002efe00002efe0002feaaaee0000000000000000000000000000000008800
0002fe0000025300000000ef2002fe00000efe2000002e00d4e41200000022fe00002ef200000253000efe000530000000000000000000000000000000000400
00035200000033000000005e000e22000002e22000003500de41200000002ee200002ef200000033000532000335000000a99dcdddde2990a992e2dd99900000
0023300000002320000000350053500000025300000533006282000000053520000025e000000067000330000232000000a9dcccddeffe90a92efffee2eeff20
00332000000006700000033000633000005253000003320002200000002630000006532000000076000650000067000000a9d2dcd22eefe0a92efffffff22eff
006700000000066000000670047600000065670000067000008000000067000000677000000000480007600000660000000a2eedaaa22ee3a999eee22ffe2eef
0076000000000480000007600440000004426600000760000000000004480000044800000000008800060000004800000002efe2000065330a99653eeee53200
004000000000008000000440480000004400480000044000000000000880000008800000000004400004000000080000002efe20004485500044865486550000
088000000000004400000480044000000480480000048000000000004800000048000000000000440084000000044000235ee200004848000004880488000000
88400000000000000000484000000000000004800048400000000000048000000480000000000000088800000000000022355000000000000004800080000000
eeeeeeb33bbb32eeeeeeeeee2333b3e3bbbb2533e41eeeeeeeeeec55eeeeed100102022e0000002266d5555dee0d66d6eeeeeee0d67d5edee1eee1ee49898998
eeeee3bbbbbb30eeeeeeeeee3332323bbbbb325540deeeeeeec50020eeeec5020222021e000000026dd5555dee0d66d6eeeeee056dd7d55de01e10e102999888
eeee3bbbbbbb220eeeeeeeee333222bbbbb33125409eeeeeec500050eeecd02e0022022e00000000dd55555dee0d66d6eeeeee0d7d1d625611111010049a9988
ee3bbbb2223222002eeeeeee552e53bbbb332e12000eeeeee5022002eee010ee0104041e02000002dd55555dee0d66d6eeeee0567d2d655631c101101499a998
eeb3b22202222000502eeeeee25ee3bbbbb3eee1e4009eeec02c2002ecd502ee0224022e00000002dd55555dee0d6dd6eeeee0d66d1d625d030001c1502aa998
e332222222550000000eeeee3eeee23bb33eeeeeee4000ee50d2502ed012eeee0222102e00000000d555555dee0d6dd6eeeee067652dd125e0eee030d044a999
e3222222025205003002eeeeb3eeee53b3eeeeeeeee200000d25022e0e0eeeee0122222e00000000d555555dee0d6dd6eeee0567d511d205eeeee00e4504a9a9
32222000255055505302eeee335eeeee3eeeeeeeeeeee200d2022eee21eeeeee0222012e00000000d555555de05d6dd6eeee0d67d100d505eeeeeeee6d089a9a
33202020ee5eeeee00eeeeeeee2333332b303bbbeeeeeee1eeeeec11ee002000bbb0000005765d6d5555555de0d66dd6eeee066700000000dd5dd66ddd04aa9a
20233b33eee255ee200eeeee2bb332333320bbb3eeeeeeedeeecd00d00089992b3000000e0565dd5d555555de0d66dd6eeee0667000000005d5ddd6d6d042a8a
e033bbb3ee55525e502eeee33b3322223322bbbbeeeeeeedeec002200002494210000000ee05d55d5d55555de0d6ddd6eee0566710000001edddd67669504aaa
e3333253e5555e5e200ee323b20202022203bbbbeeeeeecdcd0d0e500000000100000000ee05655505d5555de0d66dd6eee0d667000000015edd576dd565d6a8
e3bb3233ee55eeee002e3223322020002223bbbbeeeeeed1d00000020000022000000101eee0565d005d555de0d6ddd6eee0d66700113311dd5d66d555d9592f
3b333322eeeeee5e0023000220020202e22bbbbbeeeeeed102e505ee0000222200000220eee05d550e05d55de0d6ddddeee0d66711333313d56d5d510155dd46
333b3335eeeee5552020000020000000e22bbbbbeeeeeed10e502eee0000202000002020eee05650ee05d55de0d6ddd6eee0d66713333333dd6d5d5100155966
33333335eeeeee520000000005050002ee3bbbbbeeeeec120002eeee0000000020002241eee05d50eee05d5d05d6ddddee05d667133333b3ddddd6d510015d66
33232eeeeeeeeeeee000000eee005332ee33bb33eeeeed1102420002eeeeeeee10112133eee05d50eeee0dd50d6ddd5dee0d6667e1d5d55555d66ddd51005d6d
b33225eeeeeeeeee03bb3300e2233333e33bbbb3eeeeed1202220002eeeeeeee10112313eee05d50eeee05dd0d6ddd5dee0d6667ee1dd55555ddddddd5105d5d
323335eeeeeeeeee3bb3bbb0e0225335e33bbbbbeeeecd1102220004ee0eeeee30112225eee05d50eeee0ddd0d6dd55dee0d6667dedd55515555d6dddd515d5d
33e335eeeeeeee3bb355533b3200555233bbbbbbeeee1d1102420004ee0eeeee133122e1eee05d50eeee05d50d6dd55dee0d666751edd55015d555663ddd5d55
b33e5eeeeeeeeebbb5000553b3202222333bbbbbeeeedd220422000ee00eeeee33b10224eee05d50eeee0ddd0d6dd55dee0d6667d15555d50155156d5d5ddd55
335eeeeeeeeee3bb200000222330000333bbbbbbeeecdd2114200004e020eeee3b33100eee056550eeee05d50d6d555dee0d66676151555dd5d5555d555dd515
255e5eeeeeee2bb3000000020020002233bbbbb3eeed1d211e200004e012eeeebb33024eee05d550eeee0ddd06dd555dee0d66676515011555d6555555dd5101
eeeeeeeeeeee3b30000000000002252033bbbbbbeeed1111220000020002eeeeb3500222e05d5500eeee05d506d5555dee0d6667d6511001155555605dd5ddd5
5e5eeeeeeeeeee330000000003002300e33bbb33eeed111de002eeee20000000011010eee056550eee00565deeee0ddd11eeeeeee595eeee0155409ddd5d966d
e5555eeeeeeee3b32000000020023000e33bbbb3ee1dd111e0020eee20000000030011eee05d50000055dd5deeee05d5c00deeee595a55ee115d604ad50566d0
e55e55eeeeee33333332000000032000ee3bbb33e11dd111e00220ee0000000051111beee0576555555ddd5deeee05d502200eee5a5665ee512d9d9d4000d606
5e25e5eeeee3333bbbbbbbbb3322323bee2bbbb3c1dd11d1e000020e0000000000103beee0566d55d666dd5deee06d5505e0d0deeada65ee5555d9d900f405df
eee2eeeeeee3b3b3333b3bbbb3323b33eeebbbb3ddd11111e000042e00000000013030eeee05d6666dddd55deee0dddd2000c00de5dda5eed55569d40978404f
25eeeeeee233333322223333b3332333eee2bbb3ddd1d122e00002200000000100133eeeeee05555000005d6eeee0555ee505220ee5d5eeedd555f4008998448
555eeeeee323222222233bbbb3333233eee2bbb3d11d1221e0000221000001000333eeeeeeee0000eeee0d66eeeee05deee20de0ee5ddeee5dd5550099999844
e5eeeeee323233222233bb0223322333eeee3bb311111221e000200411113330330eeeeeeeeeeeeeeeee0555eeeeee00eeee2001eee5deeedddd550799999988
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040400000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004040404040404040404000000040404040404040404040404000000000404040404040404040404040000000004040404040404040404040400000004040404
__map__
00000000c0c1c2000000c0c1c20000000000000000000000000000000000000000000000000000000000000000000000000000000000e7000000000000000000000000000000000000000000000000000000000000000000000000cc00000000000000000000000000000000000000000000000000000000000000670000006f
00000000d0f0d2d3e1000000e0000000d200000000000000000000000000000000000000000000000000000000000000000000000077f6000000000000000000000000000000000000000000000000000000000000000000000000dc00000000000000000000000000000000000000000000000000000000000000670000007f
000000e1e0e1e2e3000000d2e200000000000000000000fc00000000000000000000000000000000000000000000000000000078dde8c8000000000000000000000000000000000000000000000000000000000000000000000000ec000000000000000000000000000000000000000000000000000000000000006700000000
0000e1e3c2f1f2f300c000000000000000000000000000d70000000000000000000000000000000000000000000000000000d7f800e676f60000000000000000000000000000000000000000000000000000000000000000000000ec000000000000000000000000000000000000000000000000000000000000006700000000
00e1d0e0e1e4c3c40000000000d20000000000000000c2f70000000000d50000000000000000000000000000000000000000ce00007700f7f80000e700000000000000000000000000000000000000000000000000000000000000ec000000000000000000000000000000000000000000000000000000000000000067000000
f1d0e3f0c0f4c200000000000000f3f00000000000c5e3e20000000000f50000000000000000000000000000000000d5000000000076f7f8f60000f677e70000000000000000000000000000000000000000000000000000000000cb000000000000000000000000000000000000000000000000000000000000000000676767
d0e07600d0f30000000000000000e3f0d2000000c5c278dd0000000000000000000000d60000000000000000fc0000e500000000dde8d3d8007700c9c8f60000000000000000000000000000000000000000000000000000000000db000000000000000000000000000000000000000000000000000000000000000000006767
f0000000e4c40000000000000000d2e000d00000e1e100000000ed00000000000000d600000000000000000000fc00f500000078d3e6c8c977f6770076c9e700000000000000000000000000000000000000000000000000000000eb000000000000000000000000000000000000000000000000000000000000000000670000
00000000f4000000000000000000d1f00000e1e2f4c2000000d1000000000000fcc60000000000000000000000ced2c8000000c8c8c9e600c9c9c876d700f6000000000000000000000000000000000000000000000000000000ccca000000000000000000000000000000000000000000000000000000000000000000670060
00000000e1c200000000e10000f00000d278f400c2d100000000000000000000e8d2000000000000000000000000ce76000000e676000000f7f800cf0076e6770000000000000000000000000000000000000000000000000000d9da000000000000000000000000000000000000000000000000000000000000000000670000
d10000f0e4c3c200000000000000000000f7f800000000000000000000000000d8f8000000000000000000000000c5c9000000c9f7dddde8d3d800cf00c9c9c80000000000000000000000000000000000000000000000000000e9ea000000000000000000000000000000000000000000000000000000000000000000670000
000000d2c3c0f2f200000000000000cef000000000e0d0c30000000000000000c5ce000000000000000000000000d5d1000078dde8d3d800007600cf0000f6c97700000000000000000000000000000000000000000000000000f9fa000000000000000000000000000000000000000000000000000000000000000000670070
00ce00000000ce00000000000000000000d1e000000000000000000000000000e776c9d1ce00000000000000cef7e57700ced3d3d800c900000000cf0000c900000000000000000000000000000000000000000000000000000000ea000000000000000000000000000000000000000000000000000000000000000000670000
0000000000000000000000000000000000000000000000000000000000000000cdefcf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fb000000000000000000000000000000000000000000000000000000000000000067676767
0000000000000000000000000000000000000000000000000000000000000000efdedf00d1ee000000000000000000decd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067000000
0000000000000000000000000000000000000000000000000000000000000000edeeef00d5de0000000000000000d5edef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067000026
0000000000000000000000000000000000000000000000000000000000000000edfeff0000fd000000000000000000f0ce00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067000036
0000000000000000000000000000000000000000000000000000000000000000d1decf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067000000
0000000000000000000000000000000000000000000000000000000000000000c7fdd10000000000000000000000de000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000067000000
00000000000000000000000000000000000000000000000000000000000000c7000000fd00000000000000000000fd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000d1cf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a6
0000000000000000000000000000000000000000000000000000000000000000000000000000de00000000fdcd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b6
0000000000000000000000000000000000000000000000000000000000000000000000000000fd00000000e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0128222889ae84ef012d1167d9a4d24e0101e0e99da51053011d555dd4a5c35d082f4e67811976ef072f1e67c97776ef012d555dd4aed5ef012d151dd4ae20ef09294499984776ef011c0d0101a110dc011a9953a3a5a9530121000110ae10ef012e884882a8c38e0159eee990a19e100121009a10ae84ef002f0e2d101cd2ef
0112111222ad12dc011506568411105d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e25f5ef89aeddef0627746749ad64ef031e9e53edce995305348c5c54858d5601264e9ae6a711ef011e467cc6cf79dc0e2ef4ef767ef8ef0e55f165d1d6615601244679f9a948ef0d1ccddc1210d1dc05193a53ab33a9ef0e28f553ee9e93ef0822e248ce94888e06540ee9848e89480e28feef9019989a012d4d2ccdcc10ef
0d15ce1c8d6c69dc0510d5604d65105d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0125456685ddcd5d012242ee8244c424012e45aa9994cdef0120353d1111cd0f012345a78aabc9ed0125456785ddcd5d012555d69dddcd5f0121426d81d2cd120125456c85ddcd5d010211d72dadc2ef012e4eaa89a9c9e90120456b85d1cd53012005151111cd0f012335cbcccccd3f0129456789aacdef012141dd8212c212
0128489988eece8e052d456789a6cde000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e25f5ef89aeddef0627746749a664ef033e9e53edce995305148c5c54858d560e24f6a78899c9ef01f6c967c797cdef0e2ef4ef554ef8ef0e53f567d24bcd6f0e24f66789e8cdef0d1ccddc1010d1dc05193a53a333a9ef0e28f553e30e33ef0822e248e484888e06540ee9810e89480e18feef0019989a0e11f2d70020ccef
0d15ce1c824c69dc0153d067d67bd5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000001274012745027001274012745027001274012745007001274012740127450070002700027000f7400f7400f7400f7400f7400f7450030000300001000000000000000000000000000000000000000000
01040000066102a6202f6303564025650166601d670256702d6701a6700c6700e6701c6702b6701d6701e6701f67020670216702267024660286502b64031630396203f6103f6003e60001600016000060001600
010100000b610136301665018670196701767015670126700f6700c67008670026700065000630006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010100001d6701e6701a6601966017650166501565013640036200362003620036200262001170011700117001170011300c05300000000000000000000000000000000000000000000000000000000000000000
0101000002600026000260003600036000460004600056000660007600076000861008620086300a6500c6700f670106701267015670186701c67020670276702e67032670346703665036630356203261032600
010100000000000000000000000007600000000000000000086000860008600006100262008630116401b610266203a6303c6703e67037670326702a670216701067007670056700467003670026500063006620
0102000007610116201b63020660246602666023660206601a66016630116200c6200761004610066100d61011620186301c66020660236602366023660216601d66018660126300f6300a620056200361000610
0001000021370173710d3710917106171031710217101171001710017100171001710017100161001410011100000000000000000000000000000000000000000000000000000000000000000000000000000000
010100003e6143e632373523737037370373703737037370373703f6323a3723a3703f6323f6303f6303f6303f6343e4523e4503f6303e4503d4523c4503c6303b6323c63030430146220b613000000000000000
010400000001005620076600c6600e6600b6600862003630056600a6600f66011660136600e6300961007660016600a6301363000620016100060000600000000000000000000000000000000010000000000000
011800001f5551f5551f5551f5501f5551c5501c5551f555215551f5551d5551f5501f55518550185551f555215551f5551d5551f5501f5551c5501c555185551a5501a5501a5501a5550c5550b5550c5550e555
011800001f5551f5551f5551f5501f5551c5501c5551f555215551f5551d5551f5501f55518550185551f555215551f5551d5551f5501f5551c5501c555185551a5501a5501a5551555518555185551755515555
010c000018550185551855018555185501855518550185551955019550195501955519550195551955019555155561c5562154621546155461c5362153621536155261c5262152621516155161c5162150615506
010c000030625111001110030605111001110011100111013061511100111001110111101111051110011105306151110530615111053062511105306251110530635306053060530605306351f5501f5501f555
010c002021550215502154021540215322153221522215151c5501c5501c5401c5401c5321c5321c5221c5151e5501e5501e5501e5521e5521e5511c5521c551215501f550215502355024550235502455026550
0118000028550285522855521552215552455021550285502655024550235502155021542215351f5521f5552155021542215351c5562155021542215311c5501e5501c5501a5501c5501c5421c5311f5521f545
010c0000215502154021532215252455023550215501f55028550285452155021540215322152528550285452655026545245502454523550235452155021540215402153221532215251f5501f5401f5321f525
010c0000235502355523550245502655028550295502b5502c5502c5551c5001c5001c5001c5001c5001c5002855024540215321c5252855024540215321c5252855024540215321c525285501c555295501d535
01180000295552955528552285352d5062f50630557325373255532555325552d5522d55524550215501c55026550265352d5522d535275502b5502d5502d53526550265352d5502f550285502f5503055032550
010c000034550305502d5402854034540305302d5202851034522305222d51228515000000000000000000003455032550305502d5502b550295502855026550245500000000000000001f557265471f53726527
011800000c2300c3300c4350c2350c3300c4350e230103301143011230113350c4300c2300c3350e4351023511330114301123510330104350c235103350f4350e2351033511435132301333013435072350b335
011800000c2300c3300c4350c2350c3300c4350e230103301143011230113350c4300c2300c3350e4351023511330114301123510330104350c235103350f4350e2300e3300e4350e2300e3300e4351023511335
010c000013230132351333013335134301343513230132351433014330144301442014220142201431014310154361c4362123621236153261c3262142621426152161c216213162131615106151061c10621106
010c00001125011251113511135111441114411124111241113311133111421114211121111215113301133511430114351123011235113301133511430114351123011235000000030013430134301323013235
010c00001a2301a2301a3301a3311a4211a4201a2201a2211a3111a3101a4101a4151523015230153301533115421154201522015221153111531015410154151323013230133301333013430134301323013235
011800001523015330154301523115321154211521115315134301322013315154301522015315134301322515330154301523015331154211522115311154151a2301a3201a4151523015320154151323013325
010c00001523015230153301533015430154311522115220153201532015420154211521115210153101531513430134311322113221133111331515430154311522115221153111531513450134411323113225
010c00001323013235133301333513430134351323013235143301433014430144201422014220143101431015450154401523015225153501534015430154251525015240153301532515450154551125011235
01180000112451134515440152451a3001340513200133051a4451a2451a34515440152451430014400142001a3401a4401a2351a3451b4401b2401b3351b4401c2401c3401c4351c24520340204402023520345
010c0000212402124521340213452144021445212402124521340213451f4401f4451c2401c245183401834515440154351524015235153401533515440154351524015240153301532513440134401323013225
011800201f5551f5551f5551f555205552450024555245552d5572854724537215272d5272851724517215152655226542265352155221542215352b5522b5352d5522d5422d5322d525000002d5553055534555
01180020132451334513445132451434014430142201431515450152401533515445152451534515445152450e3400e4300e22509340094300922507340074250924009335154451524515345154451524515345
0118000032555305552f5552d5502d5502d5552b5552f5552955724557215471d5472953724537215271d5151155511555115551155511550115452b5522b5352d5522d5422d5322d525000002d5053050534505
011800201324013330134251524015330154351324013325054400523505345054450524505345054450524505345054450524505345054400523507340074350924009335154051520515305154051520515305
010c00200c0330000000000000003b615176000c033000000c0330000000000000003b6150000000000000000c0330000000000000003b615000000c033000000c0330000000000000003b615000000000000000
010c00203062500000000000000000000000000000000000000000000000000000000000000000000000000030625000000000000000000000000030625000000000000000000000000030625000000000000000
010c00003062500000306250000030625000003062500000306250000000000000003061500000000000000030605000000000000000000000000000000000000000000000000000000000000000000000000000
011800000c033306153061530615306150000030615000000c0330000030615306150c0333061530615306150c03300000000000c033000000000030615000000c03330605306053060530605000003060500000
011800000c1451014513145151401514513140131451314013145101401014513145101450e145101450e1450c14510145131451514015145131401314515140151451c1401c145181401814018145101450e145
011800000c0630000010063100633c5051006310063000000c063000000c0630c0633c5050c06310063000000c06300000100630c0633c505100630c063000000c063000001006310003100630c0631006300000
011800000010000100001000010000100101401014510140101450c1500c1550e1000e1050c105001000010000100001000010000100001001014010145111401114518140181451514015140151450010000100
011800000c2450c2450c2450c2451f245212451c2421c2450c2450c2450c2450c2451c2451f24521242212450c4450c4450c4450c4451f545215451c5421c5450c4450c4450c4450c4451f545215452854228545
011800000c2451024513245182401824517240172451324013245102421024210242102450c105102450e2450c24510245132451824018245172401724515240152451824018240182401824513245102450e245
01180000000000000000000000000000000000000000000000000181451814518145181451f1401f1401f1401f145211402114021140211451f1401f1401f1401f14524140241402414024145000000000000000
011800000000000000000000000000000000000000000000000000c0630c0630c0630c063000000c0630000010063000000c0630000010063000000c06300000100630000010063000000c0630c0630c06300000
011800000c0630c0630c0630c063000000000018142181450c0630c0630c0630c06300000000001d1421d1450c0630c0630c0630c063000000000018142181450c0630c0630c0630c06300000000002414224145
0118000018245172451324518245172451324518245172451324518242182421824218245152421524215242152451c2421c2421c2421c2451644517445184451744513445184451744513445184451744510445
0118000000000000000000000000000000000000000000001f1001524215242152421524511242112421124211245184421844218442184450000000000000000000000000000000000000000101051510015105
010c00200923409335094340933510234103350c4340c3350923409335094340933505234053350c4340c3350923409335094340933510234103350c4340c3350923409335094340933505234053350c4340c335
010c00000923409335094340933510234103350c4340c3350923409335094340933505234053350c4340c33509234094350000009334093350000010434103350523405335053340533509454094320942209315
01180000102350c4350943504235102350c4350943504235102350c4350943504235102350c43509435042350c4350943505235004350c4350943505235004350c4350943505235004350c435094350523500435
01300020215562454628536215161c5561f546235361c516215562454628536215161f55623546265361f5161d55621546245361d5161c5561f546235361c5161d55621546245361d5161f55623546265361f516
0118002021552245422853221512215422453228522215121c5521f542235321c5121c5421f532235221c51221552245422853221512215422453228522215121f55223542265321f5121f54223532265221f512
011800001d55221542245321d5121d54221532245221d5121c5521f542235321c5121c5421f532235221c5121d55221542245321d5121d54221532245221d5121f55223542265321f5121f54223532265221f512
01180000215522155228532215152454224545285322853521552215522853221515245422454528532285351c5521c552235321c5151f5421f54523532235351c5521c552235321c5151f5421f5452353223535
011800001d5521d552245321d515215422154524532245351d5521d552245321d515215422154524532245351f5521f552265321f515235422354526532265351f5521f552265321f51523542235452653226535
010c0020152501c345154501c245153501c445152501c345154501c24515300154501c24515300154501c24500300004000020000300154501c245153501c445152561c346154361c2250cf730c9053c6230c612
010c00200cf700cf140cf730cf143cb203cb1400000000000cf700cf14000000cf700cf14000003c6230c6120cf700cf140c9030cf733cb203cb1400000000000cf700cf140cf730cf733c6230c6123c6030c602
010c00200cf700cf140cf730cf143cb203cb1400000000000cf700cf14000000cf700cf14000003c6230c6120cf700cf140c9030cf730cf143ca040cf700cf140cf730cf1400000000003c6230c6120000000000
011800200cf700cf140c9030c9043cb203cb1400000000000cf700cf14000000c9003c6230c6123c6030c6020cf700cf140c9030cf733cb203cb1400000000000cf700cf140cf730c9033c6230c6123c6030c602
011600001f5551f5551f5551f5501f5551c5501c5551f555215551f5551d5551f5501f55518550185550000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011500002955724557215471d5472953724537215271f5501f5552155021550215551c5002150021500215011c5001e5001c5001a5001c5001c5001c5011f5001f50000000000000000000000000000000000000
011800000000018100181001810000000000000000000000000000c0030c0630c003100630c0030c0630c003100630c0030c0630c003100630000000000000000000000000000000000000000000000000018100
0118000015245112451024517245132451124513245102450e2451524515245152451524513440134401344013445154401544015440154451344013440134401344518440184401844018445000000000000000
__music__
00 17 0d 43 44
01 18 0e 23 44
00 19 0f 23 44
00 1a 10 23 44
00 14 0a 22 44
00 15 0b 22 44
00 16 0c 24 44
00 18 0e 23 44
00 19 0f 23 44
00 1a 10 23 44
00 14 0a 22 44
00 15 0b 22 44
00 1b 11 24 44
00 1c 12 22 44
00 1d 13 23 44
00 14 0a 22 44
00 15 0b 22 44
00 1e 1f 25 44
02 20 21 25 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 29 2d 43 44
00 26 28 27 44
00 2a 28 27 44
00 29 2d 43 44
00 26 28 27 44
00 2a 28 27 44
00 2e 2f 3e 44
00 2a 28 27 44
00 2e 2f 3e 44
00 26 28 27 44
00 2a 28 27 44
02 3f 2b 2c 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
01 38 42 24 44
00 39 30 43 44
00 3a 31 43 44
00 3b 42 33 44
00 3b 42 34 44
00 3b 42 35 44
00 39 30 33 44
00 39 32 36 44
02 3a 32 37 44
00 41 42 43 44
00 41 42 43 44
00 41 42 43 44
03 41 42 43 44
00 3c 42 43 44
04 00 42 43 44
00 3d 42 43 44
