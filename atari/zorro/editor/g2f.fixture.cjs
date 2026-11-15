// Synthetic native project: two character sets, one DLI palette change,
// an inverse character and a visible player. No third-party artwork.
module.exports = function fixture(columns = 40) {
  const fonts = 3 + 30 * columns, table = fonts + 2048;
  const modeOffset = 30 + 33 * 256 + 2 * 240 * 290 + 256 + 240 * 24;
  const bytes = Buffer.alloc(table + modeOffset + 30);
  bytes.set([columns, 0x82, 1]);
  bytes.fill(0x1b, fonts, fonts + 8);
  bytes.fill(0xff, fonts + 1024, fonts + 1032);
  bytes[3 + 1] = 128; // fifth colour in second cell
  bytes[table + 1] = 1; // second character row uses font 1
  for (let c = 0; c < 9; c++) bytes.fill(c * 16, table + 30 + c * 256, table + 30 + (c + 1) * 256);
  bytes[table + 30 + 256 + 1] = 42;
  bytes[table + 30 + 33 * 256 + 2 * 240 * 290 + 1] = 2; // DLI
  bytes.fill(2, table + modeOffset, table + modeOffset + 30);
  // Player 0 at screen x=16 on line 2, foreground over background.
  const player = table + 30 + 9 * 256 + 4;
  bytes[player] = 0x18; // HPOS=$38, normal screen starts at $30
  bytes[table + 30 + 0x1900 + 2] = 0xff;
  return bytes;
};
