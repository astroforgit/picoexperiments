"use strict";

// Shared editor/native-build registry. Paths are relative to grapple/editor.
const GrappleCharacters = [
  {name: "Classic hero", src: "../bin/assets/player.png",
   palette: {16: "#ffffff", 17: "#ffffff", 18: "#ffffff", 20: "#ff0000"}},
  {name: "PixelCharacterV1 · flowing hair", src: "../design/PixelCharacterV1/player-pixelv1.png",
   palette: {16: "#ffb499", 17: "#e2e2e2", 18: "#405230", 20: "#4894ff"}},
  {name: "Orbit Ranger · sci-fi", theme: "scifi", src: "../design/SciFi/player-scifi.png",
   palette: {16: "#39d9d2", 17: "#d5f5ff", 18: "#527da8", 20: "#ffb454"}},
  {name: "Dream Eye · surreal", theme: "surreal", src: "../design/Surreal/player-surreal.png",
   palette: {16: "#ffe89b", 17: "#e9dcff", 18: "#9b70e8", 20: "#ff79bd"}},
  {name: "Nightshade · goth punk", theme: "goth", src: "../design/GothPunk/player-goth.png",
   palette: {16: "#ffccc1", 17: "#646579", 18: "#c3c9d6", 20: "#d65085"}},
  {name: "Elephant Frontman · black metal", theme: "blackmetal", src: "../design/BlackMetal/player-elephant.png",
   palette: {16: "#fff3d9", 17: "#b8bdc9", 18: "#454653", 20: "#f5f6ff"}}
];
if (typeof module !== "undefined") module.exports = GrappleCharacters;
if (typeof window !== "undefined") window.GrappleCharacters = GrappleCharacters;
