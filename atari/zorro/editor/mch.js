/* Graph2Font MCH as written by tebe6502/bmp2mch saveMCHfile:
 * row-major cells (attribute + 8 bitmap bytes), then five 240-byte palettes.
 * Width is not stored; the caller chooses 32, 40 or 48 character columns.
 */
(function (root) {
  'use strict';
  function decode(bytes, columns) {
    if (![32, 40, 48].includes(columns)) throw new Error('Choose 32, 40 or 48 source columns.');
    const size = bytes.length - 1200, rows = size / (columns * 9);
    if (!Number.isInteger(rows) || rows < 1 || rows > 30 || (bytes[0] & 127) !== 5)
      throw new Error('Not a supported MCH image for this width. Use a mode-5 .mch from bmp2mch (up to 240 lines).');
    const width = columns * 4, height = rows * 8, pixels = new Uint8Array(width * height);
    for (let cell = 0; cell < columns * rows; cell++) {
      const attr = bytes[cell * 9];
      if ((attr & 127) !== (cell === 0 ? 5 : 0)) throw new Error('Unsupported MCH cell attributes.');
      for (let y = 0; y < 8; y++) for (let x = 0; x < 4; x++) {
        let c = (bytes[cell * 9 + 1 + y] >> (6 - x * 2)) & 3;
        if (c === 3 && (attr & 128)) c = 4;
        const line = Math.floor(cell / columns) * 8 + y;
        pixels[line * width + (cell % columns) * 4 + x] = bytes[size + c * 240 + line] & 254;
      }
    }
    return { width, height, pixels, background: bytes[size] & 254 };
  }
  function convert(image, x, y, palette, rgb) {
    if (!Number.isInteger(x) || !Number.isInteger(y) || x < 0 || y < 0 || x >= image.width / 4 || y >= image.height / 8)
      throw new Error('Crop origin must be a character position inside the image.');
    // Pad smaller images with the first scanline background colour; never stretch pixels.
    const pixels = new Uint8Array(160 * 176).fill(image.background);
    for (let row = 0; row < 176 && y * 8 + row < image.height; row++)
      for (let col = 0; col < 160 && x * 4 + col < image.width; col++)
        pixels[row * 160 + col] = image.pixels[(y * 8 + row) * image.width + x * 4 + col];
    const counts = new Map();
    pixels.forEach(c => counts.set(c, (counts.get(c) || 0) + 1));
    if (!palette) {
      palette = [...counts.keys()].sort((a, b) => counts.get(b) - counts.get(a) || a - b).slice(0, 4);
      while (palette.length < 4) palette.push(palette[0]);
    }
    const remap = new Map(), colors = palette.map(rgb);
    for (const c of counts.keys()) {
      const source = rgb(c);
      const distances = colors.map(target => target.reduce((sum, value, k) => sum + (value - source[k]) ** 2, 0));
      remap.set(c, distances.indexOf(Math.min(...distances)));
    }
    const tiles = [], cells = [], ids = new Map();
    for (let cy = 0; cy < 22; cy++) for (let cx = 0; cx < 40; cx++) {
      const bytes = [];
      for (let row = 0; row < 8; row++) {
        let b = 0;
        for (let k = 0; k < 4; k++) b = (b << 2) | remap.get(pixels[(cy * 8 + row) * 160 + cx * 4 + k]);
        bytes.push(b);
      }
      const key = bytes.join(',');
      if (!ids.has(key)) { ids.set(key, tiles.length); tiles.push(bytes); }
      cells.push(ids.get(key));
    }
    return { palette, tiles, cells, sourceColors: counts.size };
  }
  const api = { decode, convert };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.MCH = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
