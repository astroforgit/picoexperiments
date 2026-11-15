'use strict';
const INTRO_PREVIOUS = ["^dreszcz przebiega ci po plecach.", "^wchodzisz do siedziby licza.", "", "^masz niewiele zapas\u00f3w.", "^szukaj ukrytego jedzenia", "i broni w tych lochach.", "", "^raq'zul czeka na pi\u0119trze 8.", "^zejd\u017a w g\u0142\u0105b jego siedziby", "i pokonaj go!"];
if(G.language==='pl'&&JSON.stringify(G.windows.ml_intro)===JSON.stringify(INTRO_PREVIOUS)){G.windows.ml_intro=clone(DEFAULT_GAME.windows.ml_intro);save();render();}
