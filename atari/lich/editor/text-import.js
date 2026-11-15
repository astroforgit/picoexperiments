'use strict';
// Import the user's revised Polish text without replacing newer local edits.
const TEXT_IMPORT_PATCH = {"s_backpack": {"before": "^p^l^e^c^a^k", "uploaded": "^w^l^ó^r", "after": "^w^ó^r"}, "s_floor": {"before": "^piętro ", "uploaded": "^pięterko", "after": "^pięterko"}, "s_killedby": {"before": "^zabójca: ", "uploaded": "^zabójczyk: ", "after": "^zabójczyk: "}, "s_onfloor": {"before": "piętro ", "uploaded": "na pięterku", "after": "na pięterku"}, "s_poison": {"before": "trucizna", "uploaded": "trutka", "after": "trutka"}, "s_refill": {"before": "^h^p odnowione!", "uploaded": "^h^p odnowa!", "after": "^h^p odnowa!"}, "s_a_food": {"before": "^potrzebny przeklęty pokarm...", "uploaded": "^potrzebny lewy pokarm...", "after": "^potrzebny lewy pokarm..."}, "s_a_shattererd": {"before": ": rozbita!", "uploaded": ": popsuta!", "after": ": popsuta!"}, "s_a_shattered": {"before": ": rozbita!", "uploaded": ": popsuta!", "after": ": popsuta!"}, "s_a_dip": {"before": "^zanurz przeklętą broń...", "uploaded": "^zanurz lewą broń...", "after": "^zanurz lewą broń..."}, "s_a_nocurse": {"before": ": bez klątwy!", "uploaded": ":nie ma lewizny!", "after": ":nie ma lewizny!"}, "s_a_carry": {"before": "^plecak jest pełny...", "uploaded": "^wór jest pełny...", "after": "^wór jest pełny..."}, "s_a_stuck": {"before": ": nie da się zdjąć!", "uploaded": ": nijak nie da się zdjąć!", "after": ": nijak nie da się zdjąć!"}, "s_stun": {"before": "ogłuszenie", "uploaded": "podduszenie", "after": "podduszenie"}, "s_curse": {"before": "klątwa", "uploaded": "lewizna", "after": "lewizna"}, "s_blind": {"before": "ślepota", "uploaded": "ślepak", "after": "ślepak"}};
if(G.language==='pl'){
 let updated=false;
 for(const [key,p] of Object.entries(TEXT_IMPORT_PATCH)){
  if(G.texts[key]!==p.before&&G.texts[key]!==p.uploaded)continue;
  if(G.texts[key]!==p.after){G.texts[key]=p.after;updated=true;}
 }
 if(updated){save();render();}
}
