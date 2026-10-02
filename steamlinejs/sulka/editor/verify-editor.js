#!/usr/bin/env node
"use strict";

const assert = require("assert");
const fs = require("fs");
const path = require("path");
const originalData = require("./levels.js");
const Format = require("./format.js");

const expected = Format.cloneLevels(originalData);
const sourcePath = path.resolve(__dirname, "../atari/sulka-vbxe.asm");
const sourceLevels = Format.parseAssembly(fs.readFileSync(sourcePath, "utf8"));

assert.deepStrictEqual(sourceLevels.map((level) => level.rows), expected.map((level) => level.rows), "editor maps differ from Atari source");
assert.deepStrictEqual(sourceLevels.map((level) => level.flies), expected.map((level) => level.flies), "editor fly paths differ from Atari source");
assert.deepStrictEqual(Format.validateLevels(expected).errors, [], "built-in maps are not export-safe");
assert.deepStrictEqual(Format.parseAssembly(Format.exportAssembly(expected)), expected, "MADS assembly did not round-trip");
assert.deepStrictEqual(Format.parseJson(Format.exportJson(expected)), expected, "JSON did not round-trip");
assert.strictEqual(typeof Format.levelsSignature(expected), "string", "map signature was not generated");
assert(Format.exportJavaScript(expected).includes("SULKA_VBXE_LEVELS"), "browser-level module was not generated");
console.log("Sójka editor verified: 24 exact VBXE maps, 8 fly paths, JSON and MADS round-trips.");
