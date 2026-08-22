"use strict";

var fs = require("fs");
var path = require("path");
var xex = fs.readFileSync(path.join(__dirname, "grapple-vbxe.xex"));
var labels = fs.readFileSync(path.join(__dirname, "grapple-vbxe.lab"), "utf8");
var assets = fs.readFileSync(path.join(__dirname, "player-assets.bin"));

if (xex.length < 12000 || xex[0] !== 255 || xex[1] !== 255) {
  throw new Error("Invalid or unexpectedly small XEX");
}
if (assets.length !== 16384) {
  throw new Error("Unexpected hero asset size: " + assets.length);
}
["main", "update_player", "start_grapple", "advance_hook",
  "collide_player", "draw_hero", "draw_grapple", "detect_vbxe",
  "upload_assets", "present_back_buffer"].forEach(function (name) {
  if (labels.toLowerCase().indexOf(name.toLowerCase()) < 0) {
    throw new Error("Missing required symbol: " + name);
  }
});
console.log("PASS: grapple-vbxe.xex (" + xex.length + " bytes)");
