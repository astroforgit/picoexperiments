/* Native Graph2Font decoding via the bundled RECOIL 7.0.0 (MIT).
 * Preserve Atari colour codes by giving RECOIL an identity RGB palette.
 * Its 336-pixel visible screen includes 8 border pixels on each side of
 * the normal 320-pixel playfield. Crop column 1 selects that playfield.
 */
(function (root) {
  'use strict';
  const Decoder = typeof module !== 'undefined' && module.exports ? require('./vendor/recoil.js') : root.RECOIL;
  function decode(bytes) {
    if (!bytes.length || bytes.length > 1024 * 1024)
      throw new Error('G2F file is empty or exceeds the 1 MiB project limit.');
    const decoder = new Decoder(), palette = new Uint8Array(768);
    for (let c = 0; c < 256; c++) palette[c * 3 + 2] = c;
    decoder.setPlatformPalette('atari.pal', palette, palette.length);
    let valid = false;
    try { valid = decoder.decode('image.g2f', bytes, bytes.length); } catch (_) { /* malformed project */ }
    if (!valid) throw new Error('Invalid or unsupported G2F project. Some GED raster effects, PGR and VBXE layouts are not supported by the decoder. Export those projects as MCH in Graph2Font.');
    const screenWidth = decoder.getWidth(), height = decoder.getHeight();
    if (screenWidth !== 336 || height !== 240) throw new Error('Unexpected G2F image dimensions.');
    const width = screenWidth / 2, rgb = decoder.getPixels(), pixels = new Uint8Array(width * height);
    // Zorro has double-width pixels. Sample the left half of each pair;
    // native multicolour pixels survive exactly, hires detail is reduced.
    for (let y = 0; y < height; y++) for (let x = 0; x < width; x++)
      pixels[y * width + x] = rgb[y * screenWidth + x * 2] & 254;
    return { width, height, pixels, background: pixels[0] };
  }
  if (typeof module !== 'undefined' && module.exports) module.exports = { decode };
  else root.G2F = { decode };
})(typeof globalThis !== 'undefined' ? globalThis : this);
