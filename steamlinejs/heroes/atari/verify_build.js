"use strict";

var fs = require("fs");
var path = require("path");
var xex = fs.readFileSync(path.join(__dirname, "heroes-vbxe.xex"));
var labels = fs.readFileSync(path.join(__dirname, "heroes-vbxe.lab"), "utf8");
var assets = fs.readFileSync(path.join(__dirname, "assets.bin"));

if (xex.length < 2048 || xex[0] !== 255 || xex[1] !== 255) {
  throw new Error("Invalid or unexpectedly small XEX");
}
if (assets.length !== 14848) {
  throw new Error("Unexpected converted asset size: " + assets.length);
}
["main", "init_battle", "confirm_cell", "enemy_phase", "draw_everything",
  "detect_vbxe", "upload_assets", "present_back_buffer"].forEach(function (name) {
  if (labels.toLowerCase().indexOf(name.toLowerCase()) < 0) {
    throw new Error("Missing required symbol: " + name);
  }
});
console.log("PASS: heroes-vbxe.xex (" + xex.length + " bytes)");
