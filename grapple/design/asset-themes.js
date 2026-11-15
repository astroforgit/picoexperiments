"use strict";

// Source folders relative to the editor; native builds use the same registry.
const GrappleAssetThemes = {
  classic: {name: "Original", dir: "../bin/assets"},
  scifi: {name: "Sci-fi · orbital machinery", dir: "../design/SciFi"},
  surreal: {name: "Surreal · dream eyes", dir: "../design/Surreal"},
  goth: {name: "Goth punk · iron and lanterns", dir: "../design/GothPunk"},
  blackmetal: {name: "Black metal · thorns and ritual iron", dir: "../design/BlackMetal"}
};
if (typeof module !== "undefined") module.exports = GrappleAssetThemes;
if (typeof window !== "undefined") window.GrappleAssetThemes = GrappleAssetThemes;
