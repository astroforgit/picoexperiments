#!/usr/bin/env node
"use strict";

const fs = require("fs");
const path = require("path");
const Format = require("./format.js");

function fail(message) {
  console.error(`Sójka level import failed: ${message}`);
  process.exit(1);
}

const inputArgument = process.argv[2];
if (!inputArgument) fail("pass the exported sulka-levels.asm file as the first argument.");

const inputPath = path.resolve(process.cwd(), inputArgument);
const targetPath = path.resolve(__dirname, "../atari/sulka-vbxe.asm");
const editorLevelsPath = path.resolve(__dirname, "levels.js");
if (!fs.existsSync(inputPath)) fail(`cannot find ${inputPath}`);
if (!fs.existsSync(targetPath)) fail(`cannot find ${targetPath}`);

const exported = fs.readFileSync(inputPath, "utf8").replace(/\r\n/g, "\n");
const source = fs.readFileSync(targetPath, "utf8").replace(/\r\n/g, "\n");

let levels;
try {
  levels = Format.parseAssembly(exported);
  const validation = Format.validateLevels(levels);
  if (validation.errors.length) fail(validation.errors.join("\n"));
} catch (error) {
  fail(error.message);
}

function markedBlock(text) {
  const start = text.indexOf(Format.BEGIN_MARKER);
  const end = text.indexOf(Format.END_MARKER);
  if (start < 0 || end < start) fail("level-data markers are missing or out of order.");
  return { start, end: end + Format.END_MARKER.length, text: text.slice(start, end + Format.END_MARKER.length) };
}

const incoming = markedBlock(exported);
const existing = markedBlock(source);
const updated = source.slice(0, existing.start) + incoming.text + source.slice(existing.end);

function writeAtomic(destination, contents) {
  const temporaryPath = `${destination}.level-editor.tmp`;
  fs.writeFileSync(temporaryPath, contents, "utf8");
  fs.renameSync(temporaryPath, destination);
}

writeAtomic(targetPath, updated);
writeAtomic(editorLevelsPath, Format.exportJavaScript(levels));
console.log(`Applied 24 validated levels to ${targetPath}`);
console.log(`Synchronized browser defaults in ${editorLevelsPath}`);
console.log("The project launcher will now build this source and start Altirra.");
