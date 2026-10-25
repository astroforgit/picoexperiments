/*
MIT License

Copyright (c) 2009-2026 Piotr Fusik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
(function (root) {
// Generated automatically with "fut". Do not edit.

/**
 * Platform and pixel ratio.
 */
const RECOILResolution = {
	AMIGA1X1 : 0,
	AMIGA2X1 : 1,
	AMIGA4X1 : 2,
	AMIGA8X1 : 3,
	AMIGA1X2 : 4,
	AMIGA1X4 : 5,
	AMIGA_DCTV1X1 : 6,
	AMIGA_DCTV1X2 : 7,
	AMIGA_HAME1X1 : 8,
	AMIGA_HAME2X1 : 9,
	AMSTRAD1X1 : 10,
	AMSTRAD2X1 : 11,
	AMSTRAD1X2 : 12,
	APPLE_I_I1X1 : 13,
	APPLE_I_IE1X2 : 14,
	APPLE_I_I_G_S1X1 : 15,
	APPLE_I_I_G_S1X2 : 16,
	MACINTOSH1X1 : 17,
	XE1X1 : 18,
	XE2X1 : 19,
	XE4X1 : 20,
	XE2X2 : 21,
	XE4X2 : 22,
	XE4X4 : 23,
	XE8X8 : 24,
	VBXE1X1 : 25,
	VBXE2X1 : 26,
	PORTFOLIO1X1 : 27,
	ST1X1 : 28,
	ST1X2 : 29,
	STE1X1 : 30,
	STE1X2 : 31,
	TT1X1 : 32,
	TT2X1 : 33,
	FALCON1X1 : 34,
	FALCON2X1 : 35,
	BBC1X1 : 36,
	BBC2X1 : 37,
	BBC1X2 : 38,
	VIC201X1 : 39,
	VIC202X1 : 40,
	C161X1 : 41,
	C162X1 : 42,
	C641X1 : 43,
	C642X1 : 44,
	C1281X1 : 45,
	BK1X1 : 46,
	BK1X2 : 47,
	MC05151X2 : 48,
	FM_TOWNS1X1 : 49,
	HP481X1 : 50,
	MSX11X1 : 51,
	MSX14X4 : 52,
	MSX21X1 : 53,
	MSX21X2 : 54,
	MSX21X1I : 55,
	MSX22X1I : 56,
	MSX2_PLUS1X1 : 57,
	MSX2_PLUS2X1I : 58,
	MSX_V99901X1 : 59,
	ORIC1X1 : 60,
	PC1X1 : 61,
	PC801X2 : 62,
	PC881X2 : 63,
	PC88_VA1X1 : 64,
	PC981X1 : 65,
	PLAY_STATION1X1 : 66,
	PSION31X1 : 67,
	SAM_COUPE1X1 : 68,
	SAM_COUPE1X2 : 69,
	SAM_COUPE2X1I : 70,
	X68_K1X1 : 71,
	TANDY1X1 : 72,
	VECTOR1X1 : 73,
	ZX811X1 : 74,
	SPECTRUM1X1 : 75,
	SPECTRUM4X4 : 76,
	SPECTRUM_PROFI1X2 : 77,
	SPECTRUM_ULA_PLUS1X1 : 78,
	ZX_EVOLUTION1X1 : 79,
	ZX_UNO2X2 : 80,
	SPECTRUM_NEXT1X1 : 81,
	ELEMENT_ZX1X1 : 82,
	ELEMENT_ZX1X2 : 83,
	TIMEX1X1 : 84,
	TIMEX1X2 : 85,
	TRS1X1 : 86,
	TRS1X2 : 87,
	COCO1X1 : 88,
	COCO2X2 : 89
}

const IffType = {
	ILBM : 0,
	PBM : 1,
	ACBM : 2,
	RGB8 : 3,
	RGBN : 4
}

const IceFrameMode = {
	GR0 : 0,
	GR0_GTIA9 : 1,
	GR0_GTIA10 : 2,
	GR0_GTIA11 : 3,
	GR12 : 4,
	GR12_GTIA9 : 5,
	GR12_GTIA10 : 6,
	GR12_GTIA11 : 7,
	GR13_GTIA9 : 8,
	GR13_GTIA10 : 9,
	GR13_GTIA11 : 10
}

const AnticMode = {
	BLANK : 0,
	FOUR_COLOR : 1,
	FIVE_COLOR : 2,
	HI_RES : 3
}

/**
 * Read-only stream backed by a byte array.
 */
class Stream
{
	content;
	contentOffset;
	contentLength;

	/**
	 * Returns the next byte or -1 on EOF.
	 */
	readByte()
	{
		if (this.contentOffset >= this.contentLength)
			return -1;
		return this.content[this.contentOffset++];
	}

	/**
	 * Advances the stream until after the first byte with the given value.
	 * Returns <code>false</code> on EOF.
	 */
	skipUntilByte(expected)
	{
		for (;;) {
			let b = this.readByte();
			if (b < 0)
				return false;
			if (b == expected)
				return true;
		}
	}

	expect(s)
	{
		for (const c of s)
			if (this.readByte() != c.codePointAt(0))
				return false;
		return true;
	}

	/**
	 * Reads <code>count</code> bytes to <code>dest</code> starting at <code>destOffset</code>.
	 * Returns <code>true</code> on success, <code>false</code> if not enough data.
	 */
	readBytes(dest, destOffset, count)
	{
		let nextOffset = this.contentOffset + count;
		if (nextOffset > this.contentLength)
			return false;
		dest.set(this.content.subarray(this.contentOffset, this.contentOffset + count), destOffset);
		this.contentOffset = nextOffset;
		return true;
	}

	/**
	 * Reads a hexadecimal ASCII digit and returns its value.
	 * If there's no digit at the current stream position,
	 * leaves the position intact and returns -1.
	 */
	#readHexDigit()
	{
		if (this.contentOffset >= this.contentLength)
			return -1;
		let c = this.content[this.contentOffset++];
		if (c >= 48 && c <= 57)
			return c - 48;
		if (c >= 65 && c <= 70)
			return c - 55;
		if (c >= 97 && c <= 102)
			return c - 87;
		this.contentOffset--;
		return -1;
	}

	readHexByte()
	{
		let hi = this.#readHexDigit();
		if (hi < 0)
			return -1;
		let lo = this.#readHexDigit();
		if (lo < 0)
			return -1;
		return hi << 4 | lo;
	}

	/**
	 * Reads an integer in range <code>0</code>..<code>maxValue</code>
	 * in base <code>b</code>.
	 * Returns -1 on error.
	 */
	parseInt(b, maxValue)
	{
		let r = this.#readHexDigit();
		if (r < 0 || r >= b)
			return -1;
		do {
			let d = this.#readHexDigit();
			if (d < 0)
				return r;
			if (d >= b)
				return -1;
			r = r * b + d;
		}
		while (r <= maxValue);
		return -1;
	}

	/**
	 * Reads a decimal integer in range 0-32000
	 * stored as ASCII digits followed by CRLF.
	 * Returns -1 on error.
	 */
	parseDaliInt()
	{
		let r = this.parseInt(10, 32000);
		if (r < 0 || this.readByte() != 13 || this.readByte() != 10)
			return -1;
		return r;
	}
}

class GdosFntStream extends Stream
{
	bigEndian;
	bitmapWidth;
	width;
	leftX;
	rightX;
	nextX;

	/**
	 * Reads a 16-bit unsigned integer.
	 * Returns -1 on EOF.
	 */
	readWord()
	{
		if (this.contentOffset + 1 >= this.contentLength)
			return -1;
		let first = this.content[this.contentOffset];
		let second = this.content[this.contentOffset + 1];
		this.contentOffset += 2;
		return this.bigEndian ? first << 8 | second : first | second << 8;
	}

	/**
	 * Reads a 32-bit integer assuming there's enough data.
	 */
	readInt()
	{
		let value = this.bigEndian ? RECOIL.get32BigEndian(this.content, this.contentOffset) : RECOIL.get32LittleEndian(this.content, this.contentOffset);
		this.contentOffset += 4;
		return value;
	}

	fitRow()
	{
		this.leftX = this.rightX;
		do {
			this.rightX = this.nextX;
			this.nextX = this.readWord();
			if (this.nextX < this.rightX)
				return this.nextX < 0;
			if (this.nextX > this.bitmapWidth) {
				this.nextX = -1;
				return true;
			}
		}
		while (this.nextX - this.leftX <= this.width);
		return true;
	}
}

class DaliStream extends Stream
{

	decode(countLength, recoil, paletteOffset, mode)
	{
		const unpacked = new Uint8Array(32000);
		let valueOffset = this.contentOffset + countLength - 4;
		let count = 1;
		for (let x = 0; x < 160; x += 4) {
			for (let unpackedOffset = x; unpackedOffset < 32000; unpackedOffset += 160) {
				if (--count <= 0) {
					if (valueOffset + 7 >= this.contentLength)
						return false;
					count = this.content[this.contentOffset++];
					if (count == 0)
						return false;
					valueOffset += 4;
				}
				unpacked.set(this.content.subarray(valueOffset, valueOffset + 4), unpackedOffset);
			}
		}
		return recoil.decodeSt(unpacked, 0, this.content, paletteOffset, mode, 0);
	}
}

class ZxpStream extends Stream
{

	readChar()
	{
		let c = this.readByte();
		if (c == 13 && this.contentOffset < this.contentLength && this.content[this.contentOffset] == 10) {
			this.contentOffset++;
			return 10;
		}
		return c;
	}

	isEof()
	{
		return this.contentOffset >= this.contentLength;
	}
}

class AppleSprStream extends Stream
{

	static WIDTH = 320;

	static HEIGHT = 200;

	/**
	 * Reads a decimal, hexadecimal (with <code>$</code> prefix)
	 * or binary (with <code>%</code> prefix) integer.
	 * Skips leading whitespace.
	 * Returns -1 on error.
	 */
	readSprInt()
	{
		while (this.contentOffset < this.contentLength) {
			let c = this.content[this.contentOffset];
			switch (c) {
			case 32:
			case 9:
			case 13:
			case 10:
				this.contentOffset++;
				break;
			case 36:
				this.contentOffset++;
				return this.parseInt(16, 319);
			case 37:
				this.contentOffset++;
				return this.parseInt(2, 319);
			default:
				return this.parseInt(10, 319);
			}
		}
		return -1;
	}
}

class VplStream extends Stream
{
	#palette = new Int32Array(128);

	#skipWhitespace()
	{
		while (this.contentOffset < this.contentLength) {
			let b = this.content[this.contentOffset];
			switch (b) {
			case 32:
			case 9:
			case 13:
				this.contentOffset++;
				break;
			default:
				return b;
			}
		}
		return -1;
	}

	decode()
	{
		let colors = 0;
		for (;;) {
			switch (this.#skipWhitespace()) {
			case -1:
				return colors;
			case 35:
			case 10:
				this.skipUntilByte(10);
				break;
			default:
				if (colors >= 128)
					return -1;
				let r = this.parseInt(16, 255);
				if (r < 0)
					return -1;
				this.#skipWhitespace();
				let g = this.parseInt(16, 255);
				if (g < 0)
					return -1;
				this.#skipWhitespace();
				let b = this.parseInt(16, 255);
				if (b < 0)
					return -1;
				this.#skipWhitespace();
				if (this.parseInt(16, 15) < 0)
					return -1;
				this.#palette[colors++] = r << 16 | g << 8 | b;
				switch (this.#skipWhitespace()) {
				case -1:
					return colors;
				case 10:
					this.contentOffset++;
					break;
				default:
					return -1;
				}
				break;
			}
		}
	}

	copyTo(palette, colors)
	{
		palette.set(this.#palette.subarray(0, colors));
	}
}

/**
 * Readable in-memory stream of bits, most-significant bit first.
 */
class BitStream extends Stream
{
	bits = 0;

	/**
	 * Reads one bit (0 or 1).
	 * Returns -1 on end of stream.
	 */
	readBit()
	{
		if ((this.bits & 127) == 0) {
			if (this.contentOffset >= this.contentLength)
				return -1;
			this.bits = this.content[this.contentOffset++] << 1 | 1;
		}
		else
			this.bits <<= 1;
		return this.bits >> 8 & 1;
	}

	/**
	 * Reads the requested number of bits and returns them
	 * as an unsigned integer with the first bit read as the most significant.
	 * Returns -1 on end of stream.
	 */
	readBits(count)
	{
		let result = 0;
		while (--count >= 0) {
			let bit = this.readBit();
			if (bit < 0)
				return -1;
			result = result << 1 | bit;
		}
		return result;
	}

	readNl3Char(skipSpace)
	{
		let e;
		do
			e = this.readByte();
		while (e == 13 || e == 10 || (skipSpace && e == 32));
		if (e != 239)
			return e;
		if (this.contentOffset + 1 >= this.contentLength)
			return -1;
		switch (this.content[this.contentOffset++]) {
		case 189:
			e = this.content[this.contentOffset++];
			if (e >= 160 && e <= 191)
				return e;
			break;
		case 190:
			e = this.content[this.contentOffset++];
			if (e >= 128 && e <= 159)
				return e + 64;
			break;
		default:
			break;
		}
		return -1;
	}
}

class X68KPicStream extends BitStream
{

	readLength()
	{
		for (let bits = 1; bits < 21; bits++) {
			switch (this.readBit()) {
			case 0:
				let length = this.readBits(bits);
				if (length < 0)
					return -1;
				return length + (1 << bits) - 1;
			case 1:
				break;
			default:
				return -1;
			}
		}
		return -1;
	}
}

class Mx1Stream extends X68KPicStream
{
	constructor()
	{
		super();
		let d = 0;
		for (let e = 0; e < 256; e++) {
			if ((e >= 33 && e <= 126 && e != 34 && e != 39 && e != 44 && e != 64 && e != 92 && e != 96) || (e >= 161 && e <= 200))
				this.#decodeTable[e] = d++;
			else
				this.#decodeTable[e] = 128;
		}
	}
	#decodeTable = new Uint8Array(256);

	findImage()
	{
		for (;;) {
			let lineOffset = this.contentOffset;
			for (;;) {
				let c = this.readByte();
				if (c < 0)
					return false;
				if (c == 13 || c == 10)
					break;
			}
			if (this.contentOffset - lineOffset >= 17 && RECOIL.isStringAt(this.content, lineOffset, "@@@ ") && RECOIL.isStringAt(this.content, this.contentOffset - 11, "lines) @@@")) {
				this.bits = 0;
				return true;
			}
		}
	}

	readBit()
	{
		if ((this.bits & 63) == 0) {
			let e = this.readNl3Char(true);
			if (e < 0)
				return -1;
			let d = this.#decodeTable[e];
			if (d >= 128)
				return -1;
			this.bits = d << 1 | 1;
		}
		else
			this.bits <<= 1;
		return this.bits >> 7 & 1;
	}
}

class MppPaletteStream extends BitStream
{

	read()
	{
		let rgb;
		switch (this.content[4] & 3) {
		case 0:
			rgb = this.readBits(9);
			rgb = (rgb & 448) << 10 | (rgb & 56) << 5 | (rgb & 7);
			return rgb << 5 | rgb << 2 | (rgb >> 1 & 197379);
		case 1:
			rgb = this.readBits(12);
			rgb = (rgb & 1792) << 9 | (rgb & 2160) << 5 | (rgb & 135) << 1 | (rgb & 8) >> 3;
			return rgb << 4 | rgb;
		case 3:
			return RECOIL.getSteInterlacedColor(this.readBits(15));
		default:
			return 0;
		}
	}
}

class MultiPalette extends BitStream
{
}

class ArtPalette extends MultiPalette
{

	setLinePalette(recoil, y)
	{
		if (y == 0)
			recoil.setStPalette(this.content, 32768, 16);
		else if (this.contentOffset < 36864 && this.content[this.contentOffset] == 0 && this.content[this.contentOffset + 1] == y) {
			recoil.setStPalette(this.content, this.contentOffset, 16, 1);
			this.contentOffset += 32;
		}
	}
}

class GfaArtistPalette extends MultiPalette
{

	setLinePalette(recoil, y)
	{
		recoil.setStPalette(this.content, 32036 + (((y + 5) / 3 | 0) << 5), 16);
	}
}

class RastPalette extends MultiPalette
{
	colors;

	setLinePalette(recoil, y)
	{
		let paletteLength = (1 + this.colors) << 1;
		for (let offset = this.contentOffset; offset <= this.contentLength - paletteLength; offset += paletteLength) {
			if (y == (this.content[offset] << 8 | this.content[offset + 1])) {
				recoil.setStPalette(this.content, offset + 2, this.colors);
				break;
			}
		}
	}
}

class HblPalette extends MultiPalette
{

	#hasPalette(row)
	{
		return this.content[row << 1] != 255 || this.content[row << 1 | 1] != 255;
	}

	init()
	{
		if (!this.#hasPalette(0))
			return false;
		this.contentOffset = 896;
		for (let row = 1; row < 50; row++) {
			if (this.#hasPalette(row))
				this.contentOffset += 48;
		}
		return this.contentOffset <= this.contentLength;
	}

	setLinePalette(recoil, y)
	{
		if ((y & 3) == 0 && this.#hasPalette(y >> 2)) {
			this.contentOffset -= 48;
			let bitplanes = recoil.getWidth() == 320 || y == 0 ? 4 : 2;
			for (let c = 0; c < 1 << bitplanes; c++) {
				let offset = this.contentOffset + c * 3;
				let rgb = (this.content[offset] << 16 | this.content[offset + 1] << 8 | this.content[offset + 2]) & 460551;
				recoil.setStVdiColor(c, rgb << 5 | rgb << 2 | (rgb >> 1 & 197379), bitplanes);
			}
		}
	}
}

class CtblPalette extends MultiPalette
{
	colors;

	setLinePalette(recoil, y)
	{
		recoil.setOcsPalette(this.content, this.contentOffset + (y * this.colors << 1), this.colors);
	}
}

class ShamLacePalette extends MultiPalette
{

	setLinePalette(recoil, y)
	{
		recoil.setOcsPalette(this.content, this.contentOffset + (y >> 1 << 5), 16);
	}
}

class PchgPalette extends MultiPalette
{
	#ocs;
	#startLine;
	#lineCount;
	#havePaletteChange;
	#treeOffset;
	#treeLastOffset;
	#compressed;

	#readHuffman()
	{
		let offset = this.#treeLastOffset;
		for (;;) {
			switch (this.readBit()) {
			case 0:
				offset -= 2;
				if (offset < this.#treeOffset)
					return -1;
				if ((this.content[offset] & 129) == 1)
					return this.content[offset + 1];
				break;
			case 1:
				let hi = this.content[offset];
				let lo = this.content[offset + 1];
				if (hi < 128)
					return lo;
				offset += (hi - 256) << 8 | lo;
				if (offset < this.#treeOffset)
					return -1;
				break;
			default:
				return -1;
			}
		}
	}

	init()
	{
		if (this.contentOffset + 20 > this.contentLength || this.content[this.contentOffset] != 0)
			return false;
		switch (this.content[this.contentOffset + 3] & 3) {
		case 1:
			this.#ocs = true;
			break;
		case 2:
			this.#ocs = false;
			break;
		default:
			return false;
		}
		this.#startLine = this.content[this.contentOffset + 4] << 8 | this.content[this.contentOffset + 5];
		this.#lineCount = this.content[this.contentOffset + 6] << 8 | this.content[this.contentOffset + 7];
		let havePaletteChangeLength = (this.#lineCount + 31) >> 5 << 2;
		this.#havePaletteChange = new Uint8Array(havePaletteChangeLength);
		switch (this.content[this.contentOffset + 1]) {
		case 0:
			this.contentOffset += 20;
			if (!this.readBytes(this.#havePaletteChange, 0, havePaletteChangeLength))
				return false;
			this.#compressed = false;
			break;
		case 1:
			this.#treeOffset = this.contentOffset + 28;
			if (this.#treeOffset > this.contentLength)
				return false;
			let treeLength = RECOIL.get32BigEndian(this.content, this.contentOffset + 20);
			if (treeLength < 2 || treeLength > 1022)
				return false;
			this.contentOffset = this.#treeOffset + treeLength;
			this.#treeLastOffset = this.contentOffset - 2;
			for (let i = 0; i < havePaletteChangeLength; i++) {
				let b = this.#readHuffman();
				if (b < 0)
					return false;
				this.#havePaletteChange[i] = b;
			}
			this.#compressed = true;
			break;
		default:
			return false;
		}
		return true;
	}

	#unpackByte()
	{
		return this.#compressed ? this.#readHuffman() : this.readByte();
	}

	#setOcsColors(recoil, paletteOffset, count)
	{
		while (--count >= 0) {
			let rr = this.#unpackByte();
			if (rr < 0)
				return;
			let gb = this.#unpackByte();
			if (gb < 0)
				return;
			recoil.setOcsColor(paletteOffset + (rr >> 4), rr, gb);
		}
	}

	setLinePalette(recoil, y)
	{
		y -= this.#startLine;
		if (y < 0 || y >= this.#lineCount)
			return;
		if ((this.#havePaletteChange[y >> 3] >> (~y & 7) & 1) == 0)
			return;
		let count = this.#unpackByte();
		if (count < 0)
			return;
		let count2 = this.#unpackByte();
		if (count2 < 0)
			return;
		if (this.#ocs) {
			this.#setOcsColors(recoil, 0, count);
			this.#setOcsColors(recoil, 16, count2);
		}
		else {
			count = count << 8 | count2;
			while (--count >= 0) {
				if (this.#unpackByte() != 0)
					return;
				let c = this.#unpackByte();
				if (c < 0 || this.#unpackByte() < 0)
					return;
				let r = this.#unpackByte();
				if (r < 0)
					return;
				let b = this.#unpackByte();
				if (b < 0)
					return;
				let g = this.#unpackByte();
				if (g < 0)
					return;
				recoil.contentPalette[c] = r << 16 | g << 8 | b;
			}
		}
	}
}

/**
 * Readable in-memory Run-Length-Encoded stream.
 * This class contains the compression logic.
 * Subclasses must implement <code>ReadCommand()</code>
 * and are allowed to override <code>ReadValue()</code>.
 */
class RleStream extends BitStream
{
	/**
	 * Block length.
	 */
	repeatCount = 0;
	/**
	 * Value for an RLE block, -1 for a block of literals.
	 */
	repeatValue;

	readValue()
	{
		return this.readByte();
	}

	/**
	 * Returns the next uncompressed byte or -1 on error.
	 */
	readRle()
	{
		while (this.repeatCount == 0) {
			if (!this.readCommand())
				return -1;
		}
		this.repeatCount--;
		if (this.repeatValue >= 0)
			return this.repeatValue;
		return this.readValue();
	}

	/**
	 * Uncompresses bytes to <code>unpacked[unpackedOffset]</code>,
	 * <code>unpacked[unpackedOffset + unpackedStride]</code>,
	 * <code>unpacked[unpackedOffset + 2 * unpackedStride]</code>,
	 * ... as long as indexes are smaller than <code>unpackedEnd</code>.
	 * Returns <code>true</code> on success, <code>false</code> on error.
	 */
	unpack(unpacked, unpackedOffset, unpackedStride, unpackedEnd)
	{
		for (; unpackedOffset < unpackedEnd; unpackedOffset += unpackedStride) {
			let b = this.readRle();
			if (b < 0)
				return false;
			unpacked[unpackedOffset] = b;
		}
		return true;
	}

	/**
	 * Uncompresses laiding out bytes vertically column by column,
	 * <code>unpackedStride</code> being line width.
	 * Returns <code>true</code> on success, <code>false</code> on error.
	 */
	unpackColumns(unpacked, unpackedOffset, unpackedStride, unpackedEnd)
	{
		for (let x = 0; x < unpackedStride; x++) {
			if (!this.unpack(unpacked, unpackedOffset + x, unpackedStride, unpackedEnd))
				return false;
		}
		return true;
	}

	/**
	 * Uncompresses bytes to <code>unpacked[unpackedOffset]</code>, <code>unpacked[unpackedOffset + 1]</code>,
	 * <code>unpacked[unpackedOffset + unpackedStride]</code>, <code>unpacked[unpackedOffset + unpackedStride + 1]</code>,
	 * <code>unpacked[unpackedOffset + 2 * unpackedStride]</code>, <code>unpacked[unpackedOffset + 2 * unpackedStride + 1]</code>,
	 * ... as long as indexes are smaller than <code>unpackedEnd</code>.
	 * Returns <code>true</code> on success, <code>false</code> on error.
	 */
	unpackWords(unpacked, unpackedOffset, unpackedStride, unpackedEnd)
	{
		for (; unpackedOffset < unpackedEnd; unpackedOffset += unpackedStride) {
			let b = this.readRle();
			if (b < 0)
				return false;
			unpacked[unpackedOffset] = b;
			b = this.readRle();
			if (b < 0)
				return false;
			unpacked[unpackedOffset + 1] = b;
		}
		return true;
	}

	/**
	 * Uncompresses writing first byte to <code>unpacked[unpackedEnd]</code>, <code>unpacked[unpackedEnd - 1]</code>, ...
	 * until <code>unpacked[unpackedOffset]</code>.
	 * Returns <code>true</code> on success, <code>false</code> on error.
	 */
	unpackBackwards(unpacked, unpackedOffset, unpackedEnd)
	{
		while (unpackedEnd >= unpackedOffset) {
			let b = this.readRle();
			if (b < 0)
				return false;
			unpacked[unpackedEnd--] = b;
		}
		return true;
	}
}

class BldStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		this.repeatValue = b;
		if (b == 0 || b == 255) {
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = b + 1;
		}
		else
			this.repeatCount = 1;
		return true;
	}
}

class BbgStream extends RleStream
{
	valueBits;
	countBits;

	/**
	 * Reads the requested number of bits and returns them
	 * as an unsigned integer with the first bit read as the least significant.
	 * Returns -1 on end of stream.
	 */
	readBitsReverse(count)
	{
		let result = 0;
		for (let i = 0; i < count; i++) {
			switch (this.readBit()) {
			case 0:
				break;
			case 1:
				result |= 1 << i;
				break;
			default:
				return -1;
			}
		}
		return result;
	}

	readCommand()
	{
		switch (this.readBit()) {
		case 0:
			this.repeatCount = 1;
			break;
		case 1:
			this.repeatCount = this.readBitsReverse(this.countBits);
			if (this.repeatCount <= 0)
				return false;
			break;
		default:
			return false;
		}
		this.repeatValue = this.readBitsReverse(this.valueBits);
		return true;
	}
}

class MspStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b == 0) {
			this.repeatCount = this.readByte();
			this.repeatValue = this.readByte();
			return this.repeatValue >= 0;
		}
		this.repeatCount = b;
		this.repeatValue = -1;
		return true;
	}
}

class C64KoalaStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b == 254) {
			this.repeatValue = this.readByte();
			this.repeatCount = this.readByte();
			return this.repeatCount >= 0;
		}
		this.repeatValue = b;
		this.repeatCount = 1;
		return true;
	}
}

class CmpStream extends RleStream
{
	escape;

	readCommand()
	{
		let b = this.readByte();
		if (b == this.escape) {
			this.repeatCount = this.readByte() + 1;
			b = this.readByte();
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return b >= 0;
	}
}

class DrpStream extends RleStream
{
	escape;

	readCommand()
	{
		let b = this.readByte();
		if (b == this.escape) {
			this.repeatCount = this.readByte();
			b = this.readByte();
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return b >= 0;
	}

	static unpackFile(content, contentLength, signature, unpacked, unpackedLength)
	{
		if (contentLength > 16 && RECOIL.isStringAt(content, 2, signature)) {
			const rle = Object.assign(new DrpStream(), { content: content, contentOffset: 16, contentLength: contentLength, escape: content[15] });
			return rle.unpack(unpacked, 2, 1, unpackedLength) ? unpacked : null;
		}
		if (contentLength != unpackedLength)
			return null;
		return content;
	}
}

class HpmStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b == 0) {
			this.repeatValue = this.readByte();
			b = this.readByte();
		}
		else
			this.repeatValue = -1;
		this.repeatCount = b;
		return b >= 0;
	}
}

class UflStream extends RleStream
{
	escape;

	readCommand()
	{
		let b = this.readValue();
		if (b == this.escape) {
			this.repeatCount = this.readValue();
			if (this.repeatCount == 0)
				this.repeatCount = 256;
			b = this.readValue();
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return b >= 0;
	}
}

class UifStream extends UflStream
{

	readValue()
	{
		if (this.contentOffset <= 2)
			return -1;
		return this.content[--this.contentOffset];
	}

	startSifFrame(contentOffset)
	{
		if (contentOffset + 5 >= this.contentLength)
			return false;
		let packedLength = this.content[contentOffset] + (this.content[contentOffset + 1] << 8) - 37890;
		if (packedLength <= 0 || contentOffset + 2 + packedLength > this.contentLength)
			return false;
		this.contentOffset = contentOffset + 2 + packedLength;
		this.escape = this.content[contentOffset + 2];
		return true;
	}
}

class PgcStream extends RleStream
{

	readCommandByte()
	{
		return this.readByte();
	}

	readCommand()
	{
		let b = this.readCommandByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b;
			this.repeatValue = -1;
		}
		else {
			this.repeatCount = b - 128;
			this.repeatValue = this.readValue();
		}
		return true;
	}
}

class DaVinciStream extends PgcStream
{

	readValue()
	{
		if (this.contentOffset + 3 > this.contentLength)
			return -1;
		this.contentOffset += 3;
		return this.content[this.contentOffset - 2] << 16 | this.content[this.contentOffset - 1] << 8 | this.content[this.contentOffset - 3];
	}
}

class VectorSprStream extends PgcStream
{

	readValue()
	{
		if (this.contentOffset <= 16)
			return -1;
		return this.content[--this.contentOffset];
	}

	readCommandByte()
	{
		return this.readValue();
	}
}

class ScStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b;
			this.repeatValue = this.readByte();
		}
		else {
			this.repeatCount = b - 128;
			this.repeatValue = -1;
		}
		return true;
	}
}

class CciStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b + 1;
			this.repeatValue = -1;
		}
		else {
			this.repeatCount = b - 127;
			this.repeatValue = this.readByte();
		}
		return true;
	}

	unpackGr15(unpacked, unpackedOffset)
	{
		this.contentOffset += 4;
		this.repeatCount = 0;
		for (let x = 0; x < 40; x++) {
			if (!this.unpack(unpacked, unpackedOffset + x, 80, 7680))
				return false;
		}
		return true;
	}
}

class PackBitsStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b + 1;
			this.repeatValue = -1;
		}
		else {
			this.repeatCount = 257 - b;
			this.repeatValue = this.readValue();
		}
		return true;
	}

	unpackBitplaneLines(unpacked, width, height, bitplanes, compressed, hasMask)
	{
		let bytesPerBitplane = (width + 15) >> 4 << 1;
		let bytesPerLine = bitplanes * bytesPerBitplane;
		for (let y = 0; y < height; y++) {
			for (let bitplane = 0; bitplane < bitplanes; bitplane++) {
				for (let w = bitplane << 1; w < bytesPerLine; w += bitplanes << 1) {
					for (let x = 0; x < 2; x++) {
						let b = compressed ? this.readRle() : this.readByte();
						if (b < 0)
							return false;
						unpacked[y * bytesPerLine + w + x] = b;
					}
				}
			}
			if (hasMask) {
				for (let x = 0; x < bytesPerBitplane; x++) {
					let b = compressed ? this.readRle() : this.readByte();
					if (b < 0)
						return false;
				}
			}
		}
		return true;
	}
}

class SpcStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b + 1;
			this.repeatValue = -1;
		}
		else {
			this.repeatCount = 258 - b;
			this.repeatValue = this.readByte();
		}
		return true;
	}
}

class SpsStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			this.repeatCount = b + 3;
			this.repeatValue = this.readByte();
		}
		else {
			this.repeatCount = b - 127;
			this.repeatValue = -1;
		}
		return true;
	}
}

class VhiStream extends RleStream
{

	readCommand()
	{
		let c;
		switch (this.readByte()) {
		case 0:
			c = this.readByte();
			this.repeatValue = -1;
			break;
		case 1:
			c = this.readByte();
			this.repeatValue = this.readByte();
			break;
		default:
			return false;
		}
		this.repeatCount = c == 0 ? 256 : c;
		return true;
	}
}

class PrintfoxStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b == 155) {
			this.repeatCount = this.readByte();
			if (this.content[0] != 80)
				this.repeatCount += this.readByte() << 8;
			else if (this.repeatCount == 0)
				this.repeatCount = 256;
			b = this.readByte();
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return b >= 0;
	}
}

class ArtMaster88Stream extends RleStream
{
	#escape = -1;

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b == this.#escape) {
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = (b - 1) & 255;
			this.#escape = -1;
		}
		else {
			this.repeatCount = 1;
			this.#escape = this.repeatValue = b;
		}
		return true;
	}

	skipChunk()
	{
		if (this.contentOffset + 1 >= this.contentLength)
			return false;
		let length = this.content[this.contentOffset] | this.content[this.contentOffset + 1] << 8;
		if (length < 2)
			return false;
		this.contentOffset += length;
		return true;
	}
	planes = Array.from({ length: 4 }, () => new Uint8Array(32000));

	readPlanes(planes, planeLength)
	{
		for (let plane = 0; plane < planes; plane++) {
			if (!this.unpack(this.planes[plane], 0, 1, planeLength))
				return false;
		}
		return true;
	}
}

class SrStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		switch (b) {
		case -1:
			return false;
		case 0:
			this.repeatCount = this.readByte();
			if (this.repeatCount == 0)
				this.repeatCount = 256;
			this.repeatValue = this.readByte();
			return true;
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
		case 11:
		case 12:
		case 13:
		case 14:
		case 15:
			this.repeatCount = b;
			this.repeatValue = this.readByte();
			return true;
		default:
			this.repeatCount = 1;
			this.repeatValue = b;
			return true;
		}
	}
}

class PacStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b == this.content[4]) {
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = b + 1;
			this.repeatValue = this.content[5];
		}
		else if (b == this.content[6]) {
			this.repeatValue = this.readByte();
			if (this.repeatValue < 0)
				return false;
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = b + 1;
		}
		else {
			this.repeatCount = 1;
			this.repeatValue = b;
		}
		return true;
	}
}

class Bdp4Stream extends RleStream
{

	readCommand()
	{
		switch (this.readByte()) {
		case 255:
			this.repeatCount = this.readByte();
			if (this.repeatCount == 0)
				this.repeatCount = 256;
			this.repeatValue = this.readByte();
			return this.repeatValue >= 0;
		case 254:
			let lo = this.readByte();
			let hi = this.readByte();
			if (hi < 0)
				return false;
			this.repeatCount = lo | hi << 8;
			this.repeatValue = -1;
			return true;
		default:
			return false;
		}
	}
}

class Bdp5Stream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b == this.content[10] || b == this.content[11]) {
			this.repeatCount = this.readByte();
			if (b == this.content[11])
				this.repeatCount |= this.readByte() << 8;
			else if (this.repeatCount == 0)
				this.repeatCount = 256;
			b = this.readByte();
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return b >= 0;
	}
}

class XlpStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		let rle;
		if (b < 128)
			rle = false;
		else {
			b -= 128;
			rle = true;
		}
		this.repeatCount = b;
		if (b >= 64) {
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = (this.repeatCount - 64) << 8 | b;
		}
		this.repeatValue = rle ? this.readByte() : -1;
		return true;
	}
}

class AmstradStream extends RleStream
{
	#blockLength = 0;

	readCommand()
	{
		while (this.#blockLength <= 0) {
			if (this.readByte() != 77 || this.readByte() != 74 || this.readByte() != 72)
				return false;
			let lo = this.readByte();
			if (lo < 0)
				return false;
			let hi = this.readByte();
			if (hi < 0)
				return false;
			this.#blockLength = hi << 8 | lo;
		}
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b == 1) {
			this.repeatCount = this.readByte();
			if (this.repeatCount == 0)
				this.repeatCount = 256;
			this.repeatValue = this.readByte();
		}
		else {
			this.repeatCount = 1;
			this.repeatValue = b;
		}
		this.#blockLength -= this.repeatCount;
		return true;
	}

	static unpackFile(content, contentOffset, contentLength, unpacked, unpackedLength)
	{
		const rle = Object.assign(new AmstradStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
		return rle.unpack(unpacked, 0, 1, unpackedLength);
	}
}

class CpiStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (this.contentOffset + 1 < this.contentLength && this.content[this.contentOffset] == b) {
			this.contentOffset++;
			this.repeatCount = 1 + this.content[this.contentOffset++];
		}
		else
			this.repeatCount = 1;
		this.repeatValue = b;
		return true;
	}
}

class VbmStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b == this.content[9]) {
			this.repeatValue = this.readByte();
			this.repeatCount = this.readByte();
			return this.repeatCount > 0;
		}
		if (b == this.content[10]) {
			this.repeatValue = 0;
			this.repeatCount = this.readByte();
			return this.repeatCount > 0;
		}
		if (b == this.content[11]) {
			this.repeatValue = 255;
			this.repeatCount = this.readByte();
			return this.repeatCount > 0;
		}
		if (b == this.content[12]) {
			this.repeatValue = 0;
			this.repeatCount = 2;
			return true;
		}
		if (b == this.content[13]) {
			this.repeatValue = 255;
			this.repeatCount = 2;
			return true;
		}
		this.repeatValue = b;
		this.repeatCount = 1;
		return true;
	}
}

class XeKoalaStream extends RleStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		let rle;
		if (b < 128)
			rle = true;
		else {
			b -= 128;
			rle = false;
		}
		if (b == 0) {
			let hi = this.readByte();
			if (hi < 0)
				return false;
			b = this.readByte();
			if (b < 0)
				return false;
			b |= hi << 8;
		}
		this.repeatCount = b;
		this.repeatValue = rle ? this.readByte() : -1;
		return true;
	}
	unpacked = new Uint8Array(7680);

	unpackRaw(type, unpackedLength)
	{
		switch (type) {
		case 0:
			if (this.contentLength - this.contentOffset != unpackedLength)
				return false;
			this.unpacked.set(this.content.subarray(this.contentOffset, this.contentOffset + unpackedLength));
			return true;
		case 1:
			for (let x = 0; x < 40; x++) {
				for (let unpackedOffset = x; unpackedOffset < 80; unpackedOffset += 40) {
					if (!this.unpack(this.unpacked, unpackedOffset, 80, unpackedLength))
						return false;
				}
			}
			return true;
		case 2:
			return this.unpack(this.unpacked, 0, 1, unpackedLength);
		default:
			return false;
		}
	}

	unpackWrapped(unpackedLength)
	{
		if (this.readByte() != 255 || this.readByte() != 128 || this.readByte() != 201 || this.readByte() != 199)
			return false;
		let offset = this.readByte();
		offset |= this.readByte() << 8;
		if (offset < 26 || this.readByte() != 1)
			return false;
		let type = this.readByte();
		this.contentOffset++;
		if (this.readByte() != 0 || this.readByte() != 40 || this.readByte() != 0)
			return false;
		this.contentOffset += 9;
		if (this.readByte() != 0)
			return false;
		this.contentOffset += offset - 21;
		return this.unpackRaw(type, unpackedLength);
	}
}

class ImgStream extends RleStream
{
	#patternRepeatCount = 0;

	getLineRepeatCount()
	{
		if (this.repeatCount == 0 && this.contentOffset < this.contentLength - 4 && this.content[this.contentOffset] == 0 && this.content[this.contentOffset + 1] == 0 && this.content[this.contentOffset + 2] == 255) {
			this.contentOffset += 4;
			return this.content[this.contentOffset - 1];
		}
		return 1;
	}

	readCommand()
	{
		if (this.#patternRepeatCount > 1) {
			this.#patternRepeatCount--;
			this.repeatCount = this.content[6] << 8 | this.content[7];
			this.contentOffset -= this.repeatCount;
			return true;
		}
		let b = this.readByte();
		switch (b) {
		case -1:
			return false;
		case 0:
			b = this.readByte();
			if (b < 0)
				return false;
			if (b == 0) {
				b = this.readByte();
				if (b < 0)
					return false;
				this.repeatCount = b + 1;
				this.repeatValue = 256;
				return true;
			}
			this.#patternRepeatCount = b;
			this.repeatCount = this.content[6] << 8 | this.content[7];
			this.repeatValue = -1;
			return true;
		case 128:
			this.repeatCount = this.readByte();
			if (this.repeatCount < 0)
				return false;
			if (this.repeatCount == 0)
				this.repeatCount = 256;
			this.repeatValue = -1;
			return true;
		default:
			this.repeatCount = b & 127;
			this.repeatValue = b >= 128 ? 255 : 0;
			return true;
		}
	}

	unpackLine(unpacked, unpackedLength, y)
	{
		for (let x = 0; x < unpackedLength; x++) {
			let b = this.readRle();
			if (b < 0)
				return false;
			if (b != 256)
				unpacked[x] = b;
			else if (y == 0)
				unpacked[x] = 0;
		}
		return true;
	}
}

class CaStream extends RleStream
{
	#escape;
	#defaultValue;

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b != this.#escape) {
			this.repeatCount = 1;
			this.repeatValue = b;
			return true;
		}
		let c = this.readByte();
		if (c < 0)
			return false;
		if (c == this.#escape) {
			this.repeatCount = 1;
			this.repeatValue = c;
			return true;
		}
		b = this.readByte();
		if (b < 0)
			return false;
		switch (c) {
		case 0:
			this.repeatCount = b + 1;
			this.repeatValue = this.readByte();
			break;
		case 1:
			c = this.readByte();
			if (c < 0)
				return false;
			this.repeatCount = (b << 8) + c + 1;
			this.repeatValue = this.readByte();
			break;
		case 2:
			if (b == 0)
				this.repeatCount = 32000;
			else {
				c = this.readByte();
				if (c < 0)
					return false;
				this.repeatCount = (b << 8) + c + 1;
			}
			this.repeatValue = this.#defaultValue;
			break;
		default:
			this.repeatCount = c + 1;
			this.repeatValue = b;
			break;
		}
		return true;
	}

	unpackCa(unpacked, unpackedOffset)
	{
		if (this.contentOffset > this.contentLength - 4)
			return false;
		this.#escape = this.content[this.contentOffset];
		this.#defaultValue = this.content[this.contentOffset + 1];
		let unpackedStep = this.content[this.contentOffset + 2] << 8 | this.content[this.contentOffset + 3];
		if (unpackedStep >= 32000)
			return false;
		this.repeatCount = 0;
		if (unpackedStep == 0) {
			this.repeatCount = 32000;
			this.repeatValue = this.#defaultValue;
			unpackedStep = 1;
		}
		this.contentOffset += 4;
		return this.unpackColumns(unpacked, unpackedOffset, unpackedStep, unpackedOffset + 32000);
	}

	static unpackDel(content, contentLength, unpacked, blocks)
	{
		const rle = Object.assign(new CaStream(), { content: content, contentOffset: blocks << 2 });
		if (rle.contentOffset >= contentLength)
			return false;
		for (let block = 0; block < blocks; block++) {
			rle.contentLength = rle.contentOffset + RECOIL.get32BigEndian(content, block << 2);
			if (rle.contentLength > contentLength || rle.contentLength < rle.contentOffset || !rle.unpackCa(unpacked, block * 32000))
				return false;
			rle.contentOffset = rle.contentLength;
		}
		if (blocks == 2) {
			rle.contentLength = contentLength;
			return rle.unpackCa(unpacked, 64000);
		}
		return true;
	}
}

class RgbStream extends RleStream
{

	readValue()
	{
		return this.readBits(12);
	}

	readCommand()
	{
		let b = this.readBits(4);
		if (b < 0)
			return false;
		let rle;
		if (b < 8)
			rle = true;
		else {
			b -= 8;
			rle = false;
		}
		if (b == 0) {
			b = this.readBits(4);
			if (b < 0)
				return false;
			b += 7;
		}
		if (rle) {
			this.repeatValue = this.readValue();
			b++;
		}
		else
			this.repeatValue = -1;
		this.repeatCount = b;
		return true;
	}
}

class TnyPcsStream extends RleStream
{

	readTnyCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			if (b == 0 || b == 1) {
				if (this.contentOffset >= this.contentLength - 1)
					return false;
				this.repeatCount = this.content[this.contentOffset] << 8 | this.content[this.contentOffset + 1];
				this.contentOffset += 2;
			}
			else
				this.repeatCount = b;
			this.repeatValue = b == 1 ? -1 : this.readValue();
		}
		else {
			this.repeatCount = 256 - b;
			this.repeatValue = -1;
		}
		return true;
	}
}

class TnyStream extends TnyPcsStream
{
	valueOffset;
	valueLength;

	readCommand()
	{
		return this.readTnyCommand();
	}

	readValue()
	{
		if (this.valueOffset + 1 >= this.valueLength)
			return -1;
		let value = this.content[this.valueOffset] << 8 | this.content[this.valueOffset + 1];
		this.valueOffset += 2;
		return value;
	}
}

class PcsStream extends TnyPcsStream
{
	#commandCount;
	#palette;

	readCommand()
	{
		if (this.#commandCount <= 0)
			return false;
		this.#commandCount--;
		return this.readTnyCommand();
	}

	readValue()
	{
		if (!this.#palette)
			return this.readByte();
		if (this.contentOffset >= this.contentLength - 1)
			return -1;
		let value = this.content[this.contentOffset] << 8 | this.content[this.contentOffset + 1];
		this.contentOffset += 2;
		return value;
	}

	#startBlock()
	{
		if (this.contentOffset >= this.contentLength - 1)
			return false;
		this.#commandCount = this.content[this.contentOffset] << 8 | this.content[this.contentOffset + 1];
		this.contentOffset += 2;
		return true;
	}

	#endBlock()
	{
		while (this.repeatCount > 0 || this.#commandCount > 0) {
			if (this.readRle() < 0)
				return false;
		}
		return true;
	}

	static UNPACKED_LENGTH = 51136;

	unpackPcs(unpacked)
	{
		this.#palette = false;
		if (!this.#startBlock() || !this.unpack(unpacked, 0, 1, 32000) || !this.#endBlock())
			return false;
		this.#palette = true;
		if (!this.#startBlock())
			return false;
		for (let unpackedOffset = 32000; unpackedOffset < 51136; unpackedOffset += 2) {
			let b = this.readRle();
			if (b < 0)
				return false;
			unpacked[unpackedOffset] = b >> 8;
			unpacked[unpackedOffset + 1] = b & 255;
		}
		return this.#endBlock();
	}
}

class VdatStream extends TnyStream
{

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 128) {
			if (b == 0 || b == 1) {
				this.repeatCount = this.readValue();
				if (this.repeatCount < 0)
					return false;
			}
			else
				this.repeatCount = b;
			this.repeatValue = b == 0 ? -1 : this.readValue();
		}
		else {
			this.repeatCount = 256 - b;
			this.repeatValue = -1;
		}
		return true;
	}
}

class HimStream extends RleStream
{

	readValue()
	{
		if (this.contentOffset < 18)
			return -1;
		return this.content[this.contentOffset--];
	}

	readCommand()
	{
		let b = this.readValue();
		switch (b) {
		case -1:
			return false;
		case 0:
			this.repeatCount = this.readValue();
			if (this.repeatCount <= 0)
				return false;
			this.repeatValue = this.readValue();
			return true;
		default:
			this.repeatCount = b - 1;
			this.repeatValue = -1;
			return true;
		}
	}
}

class IcStream extends RleStream
{

	#readCount()
	{
		this.repeatCount = 257;
		while (this.readByte() == 1)
			this.repeatCount += 256;
		let b = this.readByte();
		if (b < 0)
			return false;
		this.repeatCount += b;
		return true;
	}

	readCommand()
	{
		let b = this.readByte();
		let escape = this.content[66];
		if (b != escape) {
			this.repeatCount = 1;
			this.repeatValue = b;
			return true;
		}
		b = this.readByte();
		if (b == escape) {
			this.repeatCount = 1;
			this.repeatValue = b;
			return true;
		}
		switch (b) {
		case -1:
			return false;
		case 0:
			b = this.readByte();
			if (b < 0)
				return false;
			this.repeatCount = b + 1;
			break;
		case 1:
			if (!this.#readCount())
				return false;
			break;
		case 2:
			b = this.readByte();
			switch (b) {
			case -1:
				return false;
			case 0:
				this.repeatCount = 32000;
				break;
			case 1:
				if (!this.#readCount())
					return false;
				break;
			case 2:
				while (this.readByte() > 0) {
				}
				this.repeatCount = 0;
				break;
			default:
				this.repeatCount = b + 1;
				break;
			}
			this.repeatValue = 0;
			return true;
		default:
			this.repeatCount = b + 1;
			break;
		}
		this.repeatValue = this.readByte();
		return true;
	}
}

class DeepStream extends PackBitsStream
{
	components = 0;
	#componentShift = new Int32Array(6);
	#currentByte;
	line = null;

	setDpel(chunkOffset, chunkLength)
	{
		if (chunkLength < 8 || this.content[chunkOffset + 8] != 0 || this.content[chunkOffset + 9] != 0 || this.content[chunkOffset + 10] != 0)
			return false;
		this.components = this.content[chunkOffset + 11];
		if (this.components > 6 || chunkLength != (this.components + 1) << 2)
			return false;
		for (let c = 0; c < this.components; c++) {
			let offset = chunkOffset + 12 + c * 4;
			if (this.content[offset] != 0 || this.content[offset + 2] != 0 || this.content[offset + 3] != 8)
				return false;
			let shift;
			switch (this.content[offset + 1]) {
			case 1:
				shift = 16;
				break;
			case 2:
				shift = 8;
				break;
			case 3:
				shift = 0;
				break;
			case 4:
			case 9:
			case 10:
			case 11:
			case 17:
				shift = -1;
				break;
			default:
				return false;
			}
			this.#componentShift[c] = shift;
		}
		return true;
	}

	readValue()
	{
		let rgb = 0;
		for (let c = 0; c < this.components; c++) {
			let b = this.readByte();
			if (b < 0)
				return -1;
			let shift = this.#componentShift[c];
			if (shift >= 0)
				rgb |= b << shift;
		}
		return rgb;
	}

	#readNibble()
	{
		if (this.#currentByte < 0) {
			this.#currentByte = this.readByte();
			if (this.#currentByte < 0)
				return -1;
			return this.#currentByte >> 4;
		}
		let result = this.#currentByte & 15;
		this.#currentByte = -1;
		return result;
	}

	readDeltaLine(width, tvdcOffset)
	{
		if (this.line == null)
			this.line = new Int32Array(width);
		for (let c = 0; c < this.components; c++) {
			let count = 0;
			let value = 0;
			this.#currentByte = -1;
			for (let x = 0; x < width; x++) {
				if (count == 0) {
					let i = this.#readNibble();
					if (i < 0)
						return false;
					let delta = this.content[tvdcOffset + i * 2 + 1];
					if (delta == 0) {
						if (this.content[tvdcOffset + i * 2] == 0) {
							count = this.#readNibble();
							if (count < 0)
								return false;
						}
					}
					else
						value = (value + delta) & 255;
				}
				else
					count--;
				let rgb = c == 0 ? 0 : this.line[x];
				let shift = this.#componentShift[c];
				if (shift >= 0)
					rgb |= value << shift;
				this.line[x] = rgb;
			}
		}
		return true;
	}
}

class PackBytesStream extends Stream
{
	#count = 1;
	#pattern = 0;

	readUnpacked()
	{
		if (--this.#count == 0) {
			if (this.contentOffset >= this.contentLength)
				return -1;
			let b = this.content[this.contentOffset++];
			this.#count = (b & 63) + 1;
			if (b >= 128)
				this.#count <<= 2;
			this.#pattern = PackBytesStream.#READ_UNPACKED_PATTERNS[b >> 6];
		}
		else if ((this.#count & (this.#pattern - 1)) == 0)
			this.contentOffset -= this.#pattern;
		return this.readByte();
	}

	static #READ_UNPACKED_PATTERNS = new Uint8Array([ 0, 1, 4, 1 ]);
}

class Lz4Stream extends Stream
{
	unpacked;
	unpackedOffset;
	unpackedLength;

	copy(count)
	{
		if (this.unpackedOffset + count > this.unpackedLength || !this.readBytes(this.unpacked, this.unpackedOffset, count))
			return false;
		this.unpackedOffset += count;
		return true;
	}

	readCount(count)
	{
		if (count == 15) {
			let b;
			do {
				b = this.readByte();
				if (b < 0)
					return -1;
				count += b;
			}
			while (b == 255);
		}
		return count;
	}
}

class Tre1Stream extends RleStream
{
	#lastRgb = -1;

	readCommand()
	{
		this.repeatCount = this.readByte();
		if (this.repeatCount <= 0)
			return false;
		if (this.repeatCount == 255) {
			if (this.contentOffset + 1 >= this.contentLength)
				return false;
			this.repeatCount = 255 + (this.content[this.contentOffset] << 8) + this.content[this.contentOffset + 1];
			this.contentOffset += 2;
		}
		this.repeatValue = this.#lastRgb;
		this.#lastRgb = -1;
		return true;
	}

	readValue()
	{
		if (this.contentOffset + 1 >= this.contentLength)
			return -1;
		this.#lastRgb = RECOIL.getFalconTrueColor(this.content, this.contentOffset);
		this.contentOffset += 2;
		return this.#lastRgb;
	}
}

class MciStream extends RleStream
{

	readCommand()
	{
		if (this.contentOffset < 2)
			return false;
		let b = this.content[this.contentOffset--];
		for (let e = 8; e >= 0; e--) {
			if (b == this.content[129 + e]) {
				switch (this.content[120 + e]) {
				case 0:
					this.repeatCount = 2;
					this.repeatValue = this.content[133 + e];
					return true;
				case 7:
					if (this.contentOffset < 2)
						return false;
					this.repeatCount = 2 + this.content[this.contentOffset--];
					this.repeatValue = this.content[79];
					return true;
				case 11:
					this.repeatCount = 3;
					this.repeatValue = this.content[79];
					return true;
				case 17:
					if (this.contentOffset < 3)
						return false;
					this.repeatCount = 2 + this.content[this.contentOffset--];
					this.repeatValue = this.content[this.contentOffset--];
					return true;
				case 23:
					if (this.contentOffset < 2)
						return false;
					this.repeatCount = 3;
					this.repeatValue = this.content[this.contentOffset--];
					return true;
				case 25:
					if (this.contentOffset < 2)
						return false;
					b = this.content[this.contentOffset--];
					break;
				default:
					break;
				}
				break;
			}
		}
		this.repeatCount = 1;
		this.repeatValue = b;
		return true;
	}
}

class Nl3Stream extends RleStream
{

	readValue()
	{
		let e = this.readNl3Char(false);
		if (e < 32)
			return -1;
		if (e < 127)
			return e - 32;
		if (e < 160)
			return -1;
		if (e < 224)
			return e - 65;
		if (e == 253)
			return 159;
		if (e == 254)
			return 160;
		return -1;
	}

	readCommand()
	{
		let b = this.readValue();
		if (b < 0 || b > 127)
			return false;
		this.repeatValue = b & 63;
		if (b < 64)
			this.repeatCount = 1;
		else {
			b = this.readValue();
			if (b < 0)
				return false;
			this.repeatCount = b + 2;
		}
		return true;
	}
}

class SfdnStream extends BitStream
{

	unpack(unpacked, unpackedLength)
	{
		if (this.contentLength < 22 + (unpackedLength >> 1) || !RECOIL.isStringAt(this.content, 0, "S101") || (this.content[4] | this.content[5] << 8) != unpackedLength)
			return false;
		this.contentOffset = 22;
		let current = this.readBits(4);
		let hi = -1;
		for (let unpackedOffset = 0;;) {
			if (hi < 0)
				hi = current;
			else {
				unpacked[unpackedOffset++] = hi << 4 | current;
				if (unpackedOffset >= unpackedLength)
					return true;
				hi = -1;
			}
			let code;
			let bit;
			for (code = 0;; code += 2) {
				bit = this.readBit();
				if (bit == 0)
					break;
				if (bit < 0 || code >= 14)
					return false;
			}
			bit = this.readBit();
			if (bit < 0)
				return false;
			code += bit;
			current = (current - this.content[6 + code]) & 15;
		}
	}
}

class G9bStream extends BitStream
{

	#readLength()
	{
		for (let length = 1; length < 65536;) {
			switch (this.readBit()) {
			case 0:
				return length + 1;
			case 1:
				break;
			default:
				return -1;
			}
			length <<= 1;
			switch (this.readBit()) {
			case 0:
				break;
			case 1:
				length++;
				break;
			default:
				return -1;
			}
		}
		return -2;
	}

	unpack(unpacked, headerLength, unpackedLength)
	{
		this.contentOffset = headerLength + 3;
		for (let unpackedOffset = headerLength; unpackedOffset < unpackedLength;) {
			let b;
			switch (this.readBit()) {
			case 0:
				b = this.readByte();
				if (b < 0)
					return false;
				unpacked[unpackedOffset++] = b;
				break;
			case 1:
				let length = this.#readLength();
				if (length == -2) {
					this.contentOffset += 2;
					this.bits = 0;
					break;
				}
				if (length < 0 || unpackedOffset + length > unpackedLength)
					return false;
				let distance = this.readByte();
				if (distance < 0)
					return false;
				if (distance >= 128) {
					b = this.readBits(4);
					if (b < 0)
						return false;
					distance += (b - 1) << 7;
				}
				distance++;
				if (unpackedOffset - distance < headerLength)
					return false;
				do {
					unpacked[unpackedOffset] = unpacked[unpackedOffset - distance];
					unpackedOffset++;
				}
				while (--length > 0);
				break;
			default:
				return false;
			}
		}
		return true;
	}
}

class MigStream extends BitStream
{

	static MAX_UNPACKED_LENGTH = 108800;

	unpack(unpacked)
	{
		this.contentOffset = 15;
		for (let unpackedOffset = 0; unpackedOffset < 108800;) {
			let c = this.readBit();
			if (c < 0)
				return -1;
			let b = this.readByte();
			if (b < 0)
				return -1;
			if (c == 0)
				unpacked[unpackedOffset++] = b;
			else {
				if (b >= 128) {
					c = this.readBits(4);
					if (c < 0)
						return -1;
					b += (c - 1) << 7;
				}
				let distance = b + 1;
				if (unpackedOffset - distance < 0)
					return -1;
				c = -1;
				do {
					b = this.readBit();
					if (b < 0)
						return -1;
					c++;
				}
				while (b != 0);
				let length = this.readBits(c);
				if (length < 0)
					return -1;
				if (c >= 16) {
					this.contentOffset += 4;
					if (this.contentOffset >= this.contentLength)
						return unpackedOffset;
					this.bits = 0;
				}
				else {
					length += (1 << c) + 1;
					if (unpackedOffset + length > 108800)
						return -1;
					do {
						unpacked[unpackedOffset] = unpacked[unpackedOffset - distance];
						unpackedOffset++;
					}
					while (--length > 0);
				}
			}
		}
		return -1;
	}
}

class Ice21Stream
{
	content;
	contentOffset;
	contentStart;
	bits;

	getUnpackedLength()
	{
		if (this.contentStart + 16 > this.contentOffset || !RECOIL.isStringAt(this.content, this.contentStart, "Ice!") || RECOIL.get32BigEndian(this.content, this.contentStart + 4) != this.contentOffset - this.contentStart)
			return -1;
		return RECOIL.get32BigEndian(this.content, this.contentStart + 8);
	}

	readBit()
	{
		let b = this.bits;
		let next = b & 2147483647;
		if (next == 0) {
			this.contentOffset -= 4;
			if (this.contentOffset < this.contentStart)
				return -1;
			b = RECOIL.get32BigEndian(this.content, this.contentOffset);
			this.bits = (b & 2147483647) << 1 | 1;
		}
		else
			this.bits = next << 1;
		return b >> 31 & 1;
	}

	readBits(count)
	{
		let result = 0;
		while (--count >= 0) {
			let bit = this.readBit();
			if (bit < 0)
				return -1;
			result = result << 1 | bit;
		}
		return result;
	}

	#countOnes(max)
	{
		for (let result = 0; result < max; result++) {
			switch (this.readBit()) {
			case -1:
				return -1;
			case 0:
				return result;
			default:
				break;
			}
		}
		return max;
	}

	#readLiteralLength()
	{
		let o = 1;
		for (let n = 0;; n++) {
			let c = Ice21Stream.#READ_LITERAL_LENGTH_BITS[n];
			let b = this.readBits(c);
			if (b < 0)
				return -1;
			c = (1 << c) - 1;
			if (b < c || n == 5)
				return o + b;
			o += c;
		}
	}

	#readEncoded(maxCount, extraBits, offsets)
	{
		let n = this.#countOnes(maxCount);
		if (n < 0)
			return -1;
		let b = this.readBits(extraBits[n]);
		if (b < 0)
			return -1;
		return offsets[n] + b;
	}

	unpack(unpacked, unpackedStart, unpackedEnd)
	{
		this.contentStart += 12;
		this.contentOffset -= 4;
		this.bits = RECOIL.get32BigEndian(this.content, this.contentOffset);
		for (let unpackedOffset = unpackedEnd; unpackedOffset > unpackedStart;) {
			let length;
			switch (this.readBit()) {
			case -1:
				return false;
			case 1:
				length = this.#readLiteralLength();
				if (length < 0)
					return false;
				if (length > unpackedOffset - unpackedStart)
					length = unpackedOffset - unpackedStart;
				this.contentOffset -= length;
				if (this.contentOffset < this.contentStart)
					return false;
				unpackedOffset -= length;
				unpacked.set(this.content.subarray(this.contentOffset, this.contentOffset + length), unpackedOffset);
				if (unpackedOffset == unpackedStart)
					return true;
				break;
			default:
				break;
			}
			length = this.#readEncoded(4, Ice21Stream.#UNPACK_LENGTH_EXTRA_BITS, Ice21Stream.#UNPACK_LENGTH_OFFSETS);
			let offset;
			switch (length) {
			case -1:
				return false;
			case 0:
				switch (this.readBit()) {
				case -1:
					return false;
				case 0:
					offset = this.readBits(6);
					if (offset < 0)
						return false;
					break;
				default:
					offset = this.readBits(9);
					if (offset < 0)
						return false;
					offset += 64;
					break;
				}
				break;
			default:
				offset = this.#readEncoded(2, Ice21Stream.#UNPACK_OFFSET_EXTRA_BITS, Ice21Stream.#UNPACK_OFFSET_OFFSETS);
				if (offset < 0)
					return false;
				break;
			}
			length += 2;
			offset += length;
			if (unpackedOffset + offset > unpackedEnd)
				return false;
			if (length > unpackedOffset - unpackedStart)
				length = unpackedOffset - unpackedStart;
			unpackedOffset -= length;
			unpacked.set(unpacked.subarray(unpackedOffset + offset, unpackedOffset + offset + length), unpackedOffset);
		}
		return true;
	}

	static #READ_LITERAL_LENGTH_BITS = new Uint8Array([ 1, 2, 2, 3, 8, 15 ]);

	static #UNPACK_LENGTH_EXTRA_BITS = new Uint8Array([ 0, 0, 1, 2, 10 ]);

	static #UNPACK_LENGTH_OFFSETS = new Int32Array([ 0, 1, 2, 4, 8 ]);

	static #UNPACK_OFFSET_EXTRA_BITS = new Uint8Array([ 8, 5, 12 ]);

	static #UNPACK_OFFSET_OFFSETS = new Int32Array([ 32, 0, 288 ]);
}

class SpxStream extends Ice21Stream
{

	#readCount()
	{
		let b = this.readBits(2);
		if (b < 0)
			return -1;
		return this.readBits((b + 1) << 2);
	}

	unpackV2(unpacked, unpackedLength)
	{
		this.bits = 0;
		for (let unpackedOffset = unpackedLength; unpackedOffset > 0;) {
			let count;
			switch (this.readBit()) {
			case -1:
				return false;
			case 0:
				count = this.#readCount();
				if (count <= 0)
					return false;
				if (count > unpackedOffset)
					count = unpackedOffset;
				for (let i = 0; i < count; i++) {
					let b = this.readBits(8);
					if (b < 0)
						return false;
					unpacked[--unpackedOffset] = b;
				}
				if (unpackedOffset == 0)
					return true;
				if (count == 65535)
					continue;
				break;
			default:
				break;
			}
			let distance = this.#readCount();
			if (distance <= 0 || unpackedOffset + distance > unpackedLength)
				return false;
			count = this.#readCount();
			if (count < 0)
				return false;
			count = Math.min(count + 3, unpackedOffset);
			do {
				unpackedOffset--;
				unpacked[unpackedOffset] = unpacked[unpackedOffset + distance];
			}
			while (--count > 0);
		}
		return true;
	}
}

class Q4Stream extends RleStream
{

	startChunk()
	{
		if (this.contentOffset + 6 > this.contentLength)
			return -1;
		let chunkLength = this.content[this.contentOffset] | this.content[this.contentOffset + 1] << 8;
		this.contentOffset += 6;
		this.contentLength = this.contentOffset + chunkLength;
		return this.contentLength;
	}
	#codeBits;

	#readCode()
	{
		do {
			let value = this.readBits(this.#codeBits);
			switch (value) {
			case -1:
			case 0:
				return -1;
			case 1:
				break;
			default:
				return value - 2;
			}
		}
		while (++this.#codeBits <= 15);
		return -1;
	}
	#unpacked = new Uint8Array(65536);

	unpackQ4()
	{
		this.bits = 0;
		this.#codeBits = 3;
		let unpackedLength = 0;
		const offsets = new Uint16Array(16384);
		for (let codes = 17; codes < 16384; codes++) {
			let code = this.#readCode();
			if (code < 0 || code >= codes) {
				this.content = this.#unpacked;
				this.contentOffset = 0;
				this.contentLength = unpackedLength;
				this.#lastRepeatValue = 0;
				return true;
			}
			if (unpackedLength >= 65536)
				return false;
			offsets[codes] = unpackedLength;
			if (code <= 16) {
				this.#unpacked[unpackedLength++] = code;
			}
			else {
				let sourceOffset = offsets[code];
				let endOffset = offsets[code + 1];
				if (unpackedLength + endOffset - sourceOffset >= 65536)
					return false;
				do
					this.#unpacked[unpackedLength++] = this.#unpacked[sourceOffset++];
				while (sourceOffset <= endOffset);
			}
		}
		return false;
	}
	#lastRepeatValue;

	readCommand()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		if (b < 16) {
			this.repeatCount = 1;
			this.repeatValue = b;
			return true;
		}
		b = this.readByte();
		if (b == 0) {
			this.#lastRepeatValue = this.readByte();
			if (this.#lastRepeatValue < 0 || this.#lastRepeatValue >= 16)
				return false;
			b = this.readByte();
		}
		if (b < 0)
			return false;
		this.repeatCount = b * 17;
		b = this.readByte();
		if (b < 0)
			return false;
		this.repeatCount += b;
		this.repeatValue = this.#lastRepeatValue;
		return true;
	}
}

class PiStream extends BitStream
{
	indexes;
	#recentColors = new Uint8Array(65536);

	#readInt(bits, maxBits)
	{
		for (; bits < maxBits; bits++) {
			let b = this.readBit();
			if (b == 0)
				break;
			if (b < 0)
				return -1;
		}
		return 1 << bits | this.readBits(bits);
	}

	#unpackLiteral(indexesOffset, depth)
	{
		let offset;
		switch (this.readBit()) {
		case 1:
			offset = this.readBit();
			break;
		case 0:
			offset = this.#readInt(1, depth - 1);
			break;
		default:
			return false;
		}
		if (offset < 0)
			return false;
		let recentOffset = indexesOffset == 0 ? 0 : this.indexes[indexesOffset - 1] << 8;
		offset += recentOffset;
		let c = this.#recentColors[offset];
		for (; offset > recentOffset; offset--)
			this.#recentColors[offset] = this.#recentColors[offset - 1];
		this.#recentColors[offset] = c;
		this.indexes[indexesOffset] = c;
		return true;
	}

	#unpackTwoLiterals(indexesOffset, indexesLength, depth)
	{
		if (!this.#unpackLiteral(indexesOffset, depth))
			return false;
		return indexesOffset + 1 >= indexesLength || this.#unpackLiteral(indexesOffset + 1, depth);
	}

	#readPosition()
	{
		let position = this.readBits(2);
		if (position != 3)
			return position;
		position = this.readBit();
		if (position < 0)
			return -1;
		return 3 + position;
	}

	unpack(width, height, depth)
	{
		let colors = 1 << depth;
		for (let i = 0; i < colors; i++)
			for (let j = 0; j < colors; j++)
				this.#recentColors[i << 8 | j] = (i - j) & (colors - 1);
		let indexesLength = width * height;
		this.indexes = new Uint8Array(indexesLength);
		if (!this.#unpackTwoLiterals(0, indexesLength, depth))
			return false;
		let lastPosition = -1;
		for (let indexesOffset = 0; indexesOffset < indexesLength;) {
			let position = this.#readPosition();
			if (position < 0)
				return false;
			if (position == lastPosition) {
				do {
					if (!this.#unpackTwoLiterals(indexesOffset, indexesLength, depth))
						return false;
					indexesOffset += 2;
				}
				while (indexesOffset < indexesLength && this.readBit() == 1);
				lastPosition = -1;
			}
			else {
				let length = this.#readInt(0, 23);
				if (length < 0)
					return false;
				lastPosition = position;
				switch (position) {
				case 0:
					position = indexesOffset == 0 ? 0 : indexesOffset - 2;
					position = this.indexes[position] == this.indexes[position + 1] ? 2 : 4;
					break;
				case 1:
					position = width;
					break;
				case 2:
					position = width << 1;
					break;
				case 3:
					position = width - 1;
					break;
				case 4:
					position = width + 1;
					break;
				default:
					throw new Error();
				}
				let copyEnd = Math.min(indexesOffset + (length << 1), indexesLength);
				for (; indexesOffset < copyEnd; indexesOffset++) {
					let sourceOffset = indexesOffset - position;
					if (sourceOffset < 0)
						sourceOffset &= 1;
					this.indexes[indexesOffset] = this.indexes[sourceOffset];
				}
			}
		}
		return true;
	}
}

class A4rStream extends Stream
{
	#outerFlags = 0;
	#innerFlags = 0;

	#readFlag()
	{
		if ((this.#innerFlags & 127) == 0) {
			if ((this.#outerFlags & 127) == 0) {
				if (this.contentOffset >= this.contentLength)
					return -1;
				this.#outerFlags = this.content[this.contentOffset++] << 1 | 1;
			}
			else
				this.#outerFlags <<= 1;
			if ((this.#outerFlags & 256) == 0)
				this.#innerFlags = 1;
			else {
				if (this.contentOffset >= this.contentLength)
					return -1;
				this.#innerFlags = this.content[this.contentOffset++] << 1 | 1;
			}
		}
		else
			this.#innerFlags <<= 1;
		return this.#innerFlags >> 8 & 1;
	}

	static MIN_ADDRESS = 19984;
	unpacked = new Uint8Array(11248);
	#unpackedOffset;

	#copyByte()
	{
		let b = this.readByte();
		if (b < 0 || this.#unpackedOffset < 0 || this.#unpackedOffset >= 11248)
			return false;
		this.unpacked[this.#unpackedOffset++] = b;
		return true;
	}

	#copyBlock(distance, count)
	{
		if (this.#unpackedOffset < 0)
			return false;
		let nextOffset = this.#unpackedOffset + count;
		if (nextOffset > 11248 || !RECOIL.copyPrevious(this.unpacked, this.#unpackedOffset, distance, count))
			return false;
		this.#unpackedOffset = nextOffset;
		return true;
	}

	unpackA4r()
	{
		this.unpacked.fill(0);
		this.#unpackedOffset = -1;
		for (;;) {
			switch (this.#readFlag()) {
			case 0:
				if (!this.#copyByte())
					return false;
				break;
			case 1:
				let b = this.readByte();
				switch (b) {
				case -1:
					return false;
				case 0:
					if (this.contentOffset >= this.contentLength - 2)
						return false;
					b = this.readByte();
					this.#unpackedOffset = b + (this.readByte() << 8) + 128 - 19984;
					if (!this.#copyByte())
						return false;
					break;
				case 1:
					b = this.readByte();
					switch (b) {
					case -1:
						return false;
					case 0:
						return true;
					default:
						if (!this.#copyBlock(1, b + 2))
							return false;
						break;
					}
					break;
				default:
					if (!this.#copyBlock(128 - (b >> 1), 2 + (b & 1)))
						return false;
					break;
				}
				break;
			default:
				return false;
			}
		}
	}
}

class ZimStream extends Stream
{
	#flags1 = new Uint8Array(1);
	flags2 = new Uint8Array(8);

	readWord()
	{
		if (this.contentOffset + 1 >= this.contentLength)
			return -1;
		let result = this.content[this.contentOffset] | this.content[this.contentOffset + 1] << 8;
		this.contentOffset += 2;
		return result;
	}

	readUnpacked(flags, unpackedOffset)
	{
		return (flags[unpackedOffset >> 3] >> (~unpackedOffset & 7) & 1) != 0 ? this.readByte() : 0;
	}

	unpack(flags, unpacked, unpackedLength)
	{
		let enough = true;
		for (let unpackedOffset = 0; unpackedOffset < unpackedLength; unpackedOffset++) {
			let b = this.readUnpacked(flags, unpackedOffset);
			if (b < 0) {
				enough = false;
				b = 0;
			}
			unpacked[unpackedOffset] = b;
		}
		return enough;
	}

	unpackFlags2()
	{
		let b = this.readByte();
		if (b < 0)
			return false;
		this.#flags1[0] = b;
		return this.unpack(this.#flags1, this.flags2, 8);
	}
}

class FanoTree
{
	/**
	 * Count[n] == number of codes of bit length n.
	 */
	#count = new Int32Array(16);
	/**
	 * Values sorted by code length.
	 */
	#values = new Uint8Array(256);

	create(content, contentOffset, codeCount)
	{
		this.#count.fill(0);
		for (let code = 0; code < codeCount; code++)
			this.#count[RECOIL.getNibble(content, contentOffset, code)]++;
		const positions = new Int32Array(16);
		let position = 0;
		for (let bits = 0; bits < 16; bits++) {
			positions[bits] = position;
			position += this.#count[bits];
		}
		for (let code = 0; code < codeCount; code++)
			this.#values[positions[RECOIL.getNibble(content, contentOffset, code)]++] = code;
	}

	readCode(bitStream)
	{
		let code = 0;
		let valuesOffset = this.#count[0];
		for (let bits = 1; bits < 16; bits++) {
			let bit = bitStream.readBit();
			if (bit < 0)
				return -1;
			code = code << 1 | bit;
			let count = this.#count[bits];
			if (code < count)
				return this.#values[valuesOffset + code];
			code -= count;
			valuesOffset += count;
		}
		return -1;
	}
}

/**
 * Dictionary of <code>Count</code> key-value pairs.
 * A key is an integer between zero and <code>Count-1</code>. A value is an int.
 * The dictionary always contains exactly <code>Count</code> mappings. The values are initially all zeros.
 * The pairs are ordered by their last usage, from Most Recently Used (MRU) to Least Recently Used (LRU).
 * When you add or retrieve a value, it becomes the Most Recently Used.
 * When you add a value, the Least Recently Used is discarded.
 */
class RecentInts
{
	constructor()
	{
		for (let i = 0; i < 128; i++) {
			this.#prev[i] = (i + 1) & 127;
			this.#next[i] = (i - 1) & 127;
		}
	}
	#value = new Int32Array(128);
	#prev = new Uint8Array(128);
	#next = new Uint8Array(128);
	#head = 0;

	/**
	 * Store the value.
	 * Will use the Least Recently Used key.
	 * Its previous value is discarded and now it maps to <code>value</code>
	 * and becomes the Most Recently Used.
	 */
	add(value)
	{
		this.#head = this.#prev[this.#head];
		this.#value[this.#head] = value;
	}

	/**
	 * Retrieve a value by key.
	 */
	get(key)
	{
		if (key != this.#head) {
			let prev = this.#prev[key];
			let next = this.#next[key];
			this.#next[prev] = next;
			this.#prev[next] = prev;
			let tail = this.#prev[this.#head];
			this.#next[tail] = key;
			this.#prev[key] = tail;
			this.#prev[this.#head] = key;
			this.#next[key] = this.#head;
			this.#head = key;
		}
		return this.#value[key];
	}
}

class BlazingPaddlesBoundingBox
{
	left;
	top;
	right;
	bottom;

	calculate(content, contentLength, index, startAddress)
	{
		index <<= 1;
		if (index + 1 >= contentLength)
			return false;
		let contentOffset = content[index] + (content[index + 1] << 8) - startAddress;
		if (contentOffset < 0)
			return false;
		this.left = this.top = this.right = this.bottom = 0;
		let x = 0;
		let y = 0;
		while (contentOffset < contentLength) {
			let control = content[contentOffset++];
			if (control == 8)
				return true;
			let len = (control >> 4) + 1;
			switch (control & 3) {
			case 0:
				x += len;
				if (this.right < x)
					this.right = x;
				break;
			case 1:
				x -= len;
				if (this.left > x)
					this.left = x;
				break;
			case 2:
				y -= len;
				if (this.top > y)
					this.top = y;
				break;
			case 3:
				y += len;
				if (this.bottom < y)
					this.bottom = y;
				break;
			default:
				throw new Error();
			}
		}
		return false;
	}
}

class IcnParser extends Stream
{

	#skipWhitespaceAndComments()
	{
		let got = false;
		while (this.contentOffset < this.contentLength) {
			switch (this.content[this.contentOffset]) {
			case 32:
			case 9:
			case 13:
			case 10:
				this.contentOffset++;
				got = true;
				break;
			case 47:
				if (this.contentOffset >= this.contentLength - 3 || this.content[this.contentOffset + 1] != 42)
					return false;
				this.contentOffset += 3;
				do {
					if (++this.contentOffset > this.contentLength)
						return false;
				}
				while (this.content[this.contentOffset - 2] != 42 || this.content[this.contentOffset - 1] != 47);
				got = true;
				break;
			default:
				return got;
			}
		}
		return true;
	}

	expectAfterWhitespace(s)
	{
		return this.#skipWhitespaceAndComments() && this.expect(s);
	}

	parseHex()
	{
		if (!this.expectAfterWhitespace("0x"))
			return -1;
		return this.parseInt(16, 65535);
	}

	parseDefine(s)
	{
		if (!this.expectAfterWhitespace("#define") || !this.expectAfterWhitespace(s))
			return -1;
		return this.parseHex();
	}
}

class PInterpreter extends Stream
{
	screen = new Uint8Array(768);
	#screenOffset;
	#newLineWorks;
	#bottomOffset;
	#bottomCode;

	#readNumber()
	{
		for (;;) {
			switch (this.readByte()) {
			case 21:
			case 22:
			case 27:
			case 28:
			case 29:
			case 30:
			case 31:
			case 32:
			case 33:
			case 34:
			case 35:
			case 36:
			case 37:
			case 42:
				break;
			case 126:
				if (this.contentOffset > this.contentLength - 5)
					return -1;
				let exp = this.readByte();
				let m0 = this.readByte();
				let m1 = this.readByte();
				this.contentOffset += 2;
				if (exp > 144 || m0 >= 128)
					return -1;
				if (exp <= 128)
					return 0;
				return ((m0 | 128) << 8 | m1) >> (144 - exp);
			default:
				return -1;
			}
		}
	}

	#printString(offset)
	{
		for (;;) {
			if (offset >= this.contentLength)
				return -1;
			let c = this.content[offset++];
			if (c == 11)
				break;
			if (this.#screenOffset >= 768)
				return -1;
			if (c == 192)
				c = 11;
			else if ((c & 127) >= 64)
				return -1;
			this.screen[this.#screenOffset++] = c;
			this.#newLineWorks = (this.#screenOffset & 31) != 0;
		}
		return offset;
	}

	#print()
	{
		for (;;) {
			switch (this.readByte()) {
			case 11:
				this.contentOffset = this.#printString(this.contentOffset);
				if (this.contentOffset < 0)
					return false;
				break;
			case 193:
				let row = this.#readNumber();
				if (row < 0 || row > 21 || this.readByte() != 26)
					return false;
				let column = this.#readNumber();
				if (column < 0 || column > 31)
					return false;
				this.#screenOffset = row << 5 | column;
				this.#newLineWorks = true;
				break;
			case 0:
			case 25:
				break;
			case 118:
				this.contentOffset--;
				if (this.content[this.contentOffset - 1] != 25) {
					if (this.#newLineWorks)
						this.#screenOffset = (this.#screenOffset & ~31) + 32;
					this.#newLineWorks = true;
				}
				return true;
			default:
				return false;
			}
		}
	}

	#dPeek(expectedX, expectedAddress)
	{
		return this.readByte() == 20 && this.#readNumber() == expectedX && this.readByte() == 21 && this.readByte() == 211 && this.#readNumber() == expectedAddress && this.readByte() == 21 && this.#readNumber() == 256 && this.readByte() == 23 && this.readByte() == 211 && this.#readNumber() == expectedAddress + 1;
	}

	#let()
	{
		switch (this.readByte()) {
		case 38:
			if (this.readByte() != 13 || this.readByte() != 20 || this.readByte() != 11)
				return false;
			this.#bottomOffset = this.contentOffset;
			for (;;) {
				switch (this.readByte()) {
				case -1:
					return false;
				case 11:
					return true;
				default:
					break;
				}
			}
		case 56:
			this.#bottomCode |= 1;
			return this.#dPeek(3, 16400);
		case 41:
			this.#bottomCode |= 2;
			return this.#dPeek(727, 16396);
		default:
			return false;
		}
	}

	#doIf()
	{
		return this.readByte() == 198 && this.readByte() == 38 && this.readByte() == 13 && this.readByte() == 221 && this.#readNumber() == 64 && this.readByte() == 222 && this.readByte() == 227;
	}

	#doFor()
	{
		this.#bottomCode |= 4;
		return this.readByte() == 43 && this.readByte() == 20 && this.#readNumber() == 0 && this.readByte() == 223 && this.#readNumber() == 63;
	}

	#poke()
	{
		this.#bottomCode |= 8;
		return this.readByte() == 41 && this.readByte() == 21 && this.readByte() == 43 && this.readByte() == 21 && this.readByte() == 16 && this.readByte() == 43 && this.readByte() == 18 && this.#readNumber() == 31 && this.readByte() == 17 && this.readByte() == 26 && this.readByte() == 211 && this.readByte() == 16 && this.readByte() == 56 && this.readByte() == 21 && this.readByte() == 43 && this.readByte() == 17;
	}

	#next()
	{
		if (this.readByte() == 43 && this.#bottomOffset > 0 && this.#bottomCode == 15) {
			this.#screenOffset = 704;
			return this.#printString(this.#bottomOffset) >= 0;
		}
		return false;
	}

	run()
	{
		this.contentOffset = 116;
		this.screen.fill(0);
		this.#screenOffset = 0;
		this.#newLineWorks = true;
		this.#bottomOffset = -1;
		this.#bottomCode = 0;
		for (;;) {
			if (this.contentOffset > this.contentLength - 8)
				return false;
			if (this.readByte() == 118)
				return true;
			this.contentOffset += 3;
			switch (this.readByte()) {
			case 228:
			case 229:
			case 251:
			case 253:
				break;
			case 227:
			case 236:
			case 242:
				return true;
			case 245:
				if (!this.#print())
					return false;
				break;
			case 241:
				if (!this.#let())
					return false;
				break;
			case 250:
				if (!this.#doIf())
					return false;
				break;
			case 235:
				if (!this.#doFor())
					return false;
				break;
			case 244:
				if (!this.#poke())
					return false;
				break;
			case 243:
				if (!this.#next())
					return false;
				break;
			default:
				return false;
			}
			if (this.readByte() != 118)
				return false;
		}
	}
}

class GtiaRenderer
{
	playerHpos = new Uint8Array(4);
	missileHpos = new Uint8Array(4);
	playerSize = new Uint8Array(4);
	missileSize = new Uint8Array(4);
	#playerSizeCounter = new Uint8Array(4);
	#missileSizeCounter = new Uint8Array(4);
	playerGraphics = new Uint8Array(4);
	missileGraphics;
	#playerShiftRegister = new Uint8Array(4);
	#missileShiftRegister;
	colors = new Uint8Array(9);
	prior;

	setPlayerSize(i, size)
	{
		size &= 3;
		this.playerSize[i] = size == 2 ? 1 : size + 1;
	}

	static setSpriteSizes(sizes, value)
	{
		for (let i = 0; i < 4; i++) {
			let size = value >> (i << 1) & 3;
			sizes[i] = size == 2 ? 1 : size + 1;
		}
	}

	poke(addr, value)
	{
		switch (addr) {
		case 0:
		case 1:
		case 2:
		case 3:
			this.playerHpos[addr] = value;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			this.missileHpos[addr - 4] = value;
			break;
		case 8:
		case 9:
		case 10:
		case 11:
			this.setPlayerSize(addr - 8, value);
			break;
		case 12:
			GtiaRenderer.setSpriteSizes(this.missileSize, value);
			break;
		case 13:
		case 14:
		case 15:
		case 16:
			this.playerGraphics[addr - 13] = value;
			break;
		case 17:
			this.missileGraphics = value;
			break;
		case 18:
		case 19:
		case 20:
		case 21:
		case 22:
		case 23:
		case 24:
		case 25:
		case 26:
			this.colors[addr - 18] = value & 254;
			break;
		case 27:
			this.prior = value;
			break;
		default:
			break;
		}
	}

	processPlayerDma(content, playersOffset)
	{
		for (let i = 0; i < 4; i++)
			this.playerGraphics[i] = content[playersOffset + (i << 8)];
	}

	processSpriteDma(content, missileOffset)
	{
		this.missileGraphics = content[missileOffset];
		this.processPlayerDma(content, missileOffset + 256);
	}

	#getPmg(hpos, objects)
	{
		for (let i = 0; i < 4; i++) {
			if (this.playerHpos[i] == hpos) {
				this.#playerShiftRegister[i] |= this.playerGraphics[i];
				this.#playerSizeCounter[i] = this.playerSize[i];
			}
			if (this.missileHpos[i] == hpos) {
				this.#missileShiftRegister |= this.missileGraphics & 3 << (i << 1);
				this.#missileSizeCounter[i] = this.missileSize[i];
			}
		}
		if ((this.prior & 16) != 0 && (this.#missileShiftRegister & 170) != 0)
			objects |= 128;
		for (let i = 0; i < 4; i++) {
			if ((this.#playerShiftRegister[i] & 128) != 0 || ((this.prior & 16) == 0 && (this.#missileShiftRegister & 2 << (i << 1)) != 0))
				objects |= 1 << i;
			if (--this.#playerSizeCounter[i] == 0) {
				this.#playerShiftRegister[i] = this.#playerShiftRegister[i] << 1 & 255;
				this.#playerSizeCounter[i] = this.playerSize[i];
			}
			if (--this.#missileSizeCounter[i] == 0) {
				let mask = 1 << (i << 1);
				this.#missileShiftRegister = (this.#missileShiftRegister & ~(mask * 3)) | (this.#missileShiftRegister & mask) << 1;
				this.#missileSizeCounter[i] = this.missileSize[i];
			}
		}
		return objects;
	}

	#getColor(objects)
	{
		if (objects == 0)
			return this.colors[8];
		let prior = this.prior;
		let color = 0;
		if ((objects & 3) != 0) {
			if (((objects & 48) == 0 || (prior & 12) == 0) && ((objects & 192) == 0 || (prior & 4) == 0)) {
				if ((objects & 1) != 0) {
					color = this.colors[0];
					if ((objects & 2) != 0 && (prior & 32) != 0)
						color |= this.colors[1];
				}
				else
					color = this.colors[1];
			}
		}
		else if ((objects & 12) != 0) {
			if (((objects & 192) == 0 || (prior & 6) == 0) && ((objects & 48) == 0 || (prior & 1) != 0)) {
				if ((objects & 4) != 0) {
					color = this.colors[2];
					if ((objects & 8) != 0 && (prior & 32) != 0)
						color |= this.colors[3];
				}
				else
					color = this.colors[3];
			}
		}
		if ((objects & 192) != 0 && ((objects & 12) == 0 || (prior & 9) == 0) && ((objects & 3) == 0 || (prior & 4) != 0)) {
			return color | this.colors[(objects & 128) != 0 ? 7 : 6];
		}
		if ((objects & 48) != 0 && ((objects & 12) == 0 || (prior & 1) == 0) && ((objects & 3) == 0 || (prior & 3) == 0)) {
			return color | this.colors[(objects & 16) != 0 ? 4 : 5];
		}
		return color;
	}

	startLine(startHpos)
	{
		this.#playerShiftRegister.fill(0);
		this.#missileShiftRegister = 0;
		for (let hpos = startHpos - 31; hpos < startHpos; hpos++)
			this.#getPmg(hpos, 0);
	}
	content;
	playfieldColumns;

	getHiresColor(c)
	{
		return (c & 240) + (this.colors[5] & 14);
	}

	drawSpan(y, hpos, untilHpos, anticMode, frame, width, yOffset = 0)
	{
		let gtiaMode = this.prior >> 6;
		for (; hpos < untilHpos; hpos++) {
			let x = hpos;
			let objects = 0;
			let playfield = 0;
			if (gtiaMode == 2) {
				x--;
				objects = 1;
			}
			if (anticMode != AnticMode.BLANK) {
				let column = (x >> 2) + (this.playfieldColumns >> 1) - 32;
				if (column >= 0 && column < this.playfieldColumns) {
					playfield = this.getPlayfieldByte(y, column);
					let inverseChar = playfield >= 256;
					if (inverseChar && anticMode == AnticMode.HI_RES)
						playfield = 511 - playfield;
					if (gtiaMode == 0) {
						playfield = playfield >> ((~x & 3) << 1) & 3;
						objects = anticMode == AnticMode.HI_RES ? 64 : anticMode == AnticMode.FIVE_COLOR && playfield == 3 && inverseChar ? 128 : 8 << playfield & 112;
					}
					else {
						if ((x & 2) == 0)
							playfield >>= 4;
						playfield &= 15;
						if (gtiaMode == 2) {
							objects = GtiaRenderer.#DRAW_SPAN_GTIA10_OBJECTS[playfield];
						}
					}
				}
			}
			objects = this.#getPmg(hpos, objects);
			let c = this.#getColor(objects);
			let frameOffset = (yOffset + y) * width + ((hpos + (width >> 2) - 128) << 1);
			switch (gtiaMode) {
			case 0:
				if (anticMode != AnticMode.HI_RES)
					break;
				frame[frameOffset] = (playfield & 2) == 0 ? c : this.getHiresColor(c);
				frame[frameOffset + 1] = (playfield & 1) == 0 ? c : this.getHiresColor(c);
				continue;
			case 2:
				break;
			default:
				if ((objects & 15) != 0)
					break;
				console.assert(objects == 0 || objects == 128);
				if (gtiaMode == 1)
					c |= playfield;
				else if (playfield == 0)
					c &= 240;
				else
					c |= playfield << 4;
				break;
			}
			frame[frameOffset + 1] = frame[frameOffset] = c;
		}
		return hpos;
	}

	setG2fColors(contentOffset, contentStride, count, gtiaMode)
	{
		for (let i = 0; i < count; i++)
			this.colors[(gtiaMode & 192) == 128 ? i : GtiaRenderer.#SET_G2F_COLORS_NORMAL_REGISTERS[i]] = this.content[contentOffset + i * contentStride] & 254;
	}

	advanceCpuCycles(hpos, cpuCycles, nonBlank)
	{
		for (;;) {
			hpos += 2;
			let x = (hpos - 118) >> 1;
			if ((x & 1) != 0 ? nonBlank && x >= -this.playfieldColumns && x < this.playfieldColumns : x >= -36 && x < 0 && (x & 2) != 0) {
			}
			else if (--cpuCycles == 0)
				return hpos;
		}
	}

	static #DRAW_SPAN_GTIA10_OBJECTS = new Uint8Array([ 1, 2, 4, 8, 16, 32, 64, 128, 0, 0, 0, 0, 16, 32, 64, 128 ]);

	static #SET_G2F_COLORS_NORMAL_REGISTERS = new Uint8Array([ 8, 4, 5, 6, 7, 0, 1, 2, 3 ]);
}

class HcmRenderer extends GtiaRenderer
{

	getPlayfieldByte(y, column)
	{
		return this.content[2064 + (y << 5) + column];
	}
}

class GedRenderer extends GtiaRenderer
{

	getPlayfieldByte(y, column)
	{
		return this.content[3302 + y * 40 + column];
	}
}

class PgrRenderer extends GtiaRenderer
{
	screenOffset;

	getPlayfieldByte(y, column)
	{
		return this.content[this.screenOffset + column];
	}
}

class MchRenderer extends GtiaRenderer
{
	dliPlus;

	getPlayfieldByte(y, column)
	{
		let offset = ((y >> 3) * this.playfieldColumns + column) * 9;
		let shift = this.dliPlus && (y & 4) != 0 ? 2 : 1;
		return (this.content[offset] << shift & 256) | this.content[offset + 1 + (y & 7)];
	}
}

class G2fRenderer extends GtiaRenderer
{
	fontOffset;
	inverse2Offset;
	vbxeOffset;

	getHiresColor(c)
	{
		return this.vbxeOffset >= 0 ? this.colors[5] : (c & 240) + (this.colors[5] & 14);
	}

	getPlayfieldByte(y, column)
	{
		if (this.vbxeOffset >= 0) {
			let colorOffset = this.vbxeOffset + 3 + ((24 - (this.playfieldColumns >> 1) + column) * 240 + (y / this.content[this.vbxeOffset + 2] | 0)) * 12 + 2;
			this.colors[4] = this.content[colorOffset];
			this.colors[5] = this.content[colorOffset + 2];
			this.colors[6] = this.content[colorOffset + 4];
		}
		let charOffset = (y >> 3) * this.playfieldColumns + column;
		let ch = this.content[3 + charOffset];
		let inverse = this.inverse2Offset >= 0 && (y & 4) != 0 ? this.content[this.inverse2Offset + charOffset] : ch;
		return (inverse & 128) << 1 | this.content[this.fontOffset + ((ch & 127) << 3) + (y & 7)];
	}

	static setSprite(hpos, sizes, i, content, spriteOffset)
	{
		spriteOffset += i << 10;
		let value = content[spriteOffset + 1];
		if (value >= 128) {
			hpos[i] = 0;
			return true;
		}
		value &= 15;
		switch (value) {
		case 0:
			value = 1;
			break;
		case 1:
		case 2:
		case 4:
			break;
		default:
			return false;
		}
		sizes[i] = value;
		hpos[i] = (32 + content[spriteOffset]) & 255;
		return true;
	}
}

class RastaRenderer extends GtiaRenderer
{

	getPlayfieldByte(y, column)
	{
		return this.content[y * 40 + column];
	}
}

class RastaStream extends Stream
{
	#gtia = new RastaRenderer();
	#cpuRegisters = new Uint8Array(3);

	#endLine()
	{
		for (;;) {
			switch (this.readByte()) {
			case 32:
			case 9:
			case 13:
				break;
			case 10:
				return true;
			case 59:
				return this.skipUntilByte(10);
			default:
				return false;
			}
		}
	}

	#readCpuRegister()
	{
		switch (this.readByte()) {
		case 97:
			return 0;
		case 120:
			return 1;
		case 121:
			return 2;
		default:
			return -1;
		}
	}

	#parseHexByte()
	{
		return this.parseInt(16, 255);
	}

	#readDigit(offset, maxValue)
	{
		let digit = this.readByte() - 48;
		return digit >= 0 && digit <= maxValue ? offset + digit : -1;
	}

	#readGtiaRegister()
	{
		switch (this.readByte()) {
		case 67:
			if (this.readByte() != 79 || this.readByte() != 76)
				return -1;
			switch (this.readByte()) {
			case 66:
				return this.readByte() == 65 && this.readByte() == 75 ? 26 : -1;
			case 79:
				return this.readByte() == 82 ? this.#readDigit(22, 2) : -1;
			case 80:
				return this.readByte() == 77 ? this.#readDigit(18, 3) : -1;
			default:
				return -1;
			}
		case 72:
			return this.expect("POSP") ? this.#readDigit(0, 3) : -1;
		default:
			return -1;
		}
	}

	static #isLetter(b)
	{
		if (b == 95)
			return true;
		b &= ~32;
		return b >= 65 && b <= 90;
	}

	#skipUntilMnemonic()
	{
		for (;;) {
			let b = this.readByte();
			switch (b) {
			case -1:
				return false;
			case 59:
				if (!this.skipUntilByte(10))
					return false;
				break;
			case 13:
			case 10:
				break;
			case 9:
				return true;
			default:
				if (RastaStream.#isLetter(b)) {
					do
						b = this.readByte();
					while (RastaStream.#isLetter(b) || (b >= 48 && b <= 57));
					if (this.#endLine())
						break;
				}
				return false;
			}
		}
	}
	#cpuRegisterIndex;
	#gtiaRegisterIndex;

	#executeUntilPoke()
	{
		let cpuCycles = 4;
		while (this.#skipUntilMnemonic()) {
			switch (this.readByte()) {
			case 108:
				if (this.readByte() != 100)
					return -1;
				let reg = this.#readCpuRegister();
				if (reg < 0 || !this.expect(" #$"))
					return -1;
				let value = this.#parseHexByte();
				if (value < 0 || !this.#endLine())
					return -1;
				this.#cpuRegisters[reg] = value;
				break;
			case 115:
				if (this.readByte() != 116)
					return -1;
				this.#cpuRegisterIndex = this.#readCpuRegister();
				if (this.#cpuRegisterIndex < 0 || this.readByte() != 32)
					return -1;
				this.#gtiaRegisterIndex = this.#readGtiaRegister();
				if (this.#gtiaRegisterIndex < 0 || !this.#endLine())
					return -1;
				return cpuCycles;
			case 110:
				if (this.readByte() != 111 || this.readByte() != 112 || !this.#endLine())
					return -1;
				break;
			default:
				this.contentOffset--;
				return 0;
			}
			cpuCycles += 2;
		}
		return -1;
	}

	#poke()
	{
		this.#gtia.poke(this.#gtiaRegisterIndex, this.#cpuRegisters[this.#cpuRegisterIndex]);
	}

	readIni()
	{
		this.#gtia.playerHpos.fill(0);
		this.#gtia.colors.fill(0);
		this.contentOffset = 0;
		for (;;) {
			switch (this.#executeUntilPoke()) {
			case -1:
				return false;
			case 0:
				return this.expect(":2 sta wsync") && this.#endLine();
			default:
				this.#poke();
				break;
			}
		}
	}
	#players = new Uint8Array(1024);

	readPmg()
	{
		this.contentOffset = 0;
		if (!this.#skipUntilMnemonic() || !this.expect(".ds $100") || !this.#endLine())
			return false;
		let beginLine = true;
		for (let i = 0; i < 1024; i++) {
			if (beginLine) {
				if (!this.#skipUntilMnemonic() || !this.expect(".he "))
					return false;
				beginLine = false;
			}
			let b = this.#parseHexByte();
			if (b < 0)
				return false;
			this.#players[i] = b;
			if (this.readByte() != 32) {
				this.contentOffset--;
				if (!this.#endLine())
					return false;
				beginLine = true;
			}
		}
		return true;
	}

	#expectCmpZp()
	{
		return this.expect("cmp byt2") && this.#endLine();
	}

	readRp(bitmap, height, frame)
	{
		this.contentOffset = 0;
		for (let i = 0; i < 4; i++) {
			if (!this.#skipUntilMnemonic() || !this.expect("nop") || !this.#endLine())
				return false;
		}
		if (!this.#skipUntilMnemonic() || !this.#expectCmpZp())
			return false;
		this.#gtia.missileHpos.fill(0);
		GtiaRenderer.setSpriteSizes(this.#gtia.playerSize, 255);
		GtiaRenderer.setSpriteSizes(this.#gtia.missileSize, 0);
		this.#gtia.missileGraphics = 0;
		this.#gtia.prior = 20;
		this.#gtia.content = bitmap;
		this.#gtia.playfieldColumns = 40;
		for (let y = 0; y < height; y++) {
			this.#gtia.processPlayerDma(this.#players, 8 + y);
			this.#gtia.startLine(48);
			for (let hpos = 7;;) {
				let cpuCycles = this.#executeUntilPoke();
				if (cpuCycles > 0) {
					let untilHpos = this.#gtia.advanceCpuCycles(hpos, cpuCycles, true);
					this.#gtia.drawSpan(y, hpos >= 48 ? hpos : 48, untilHpos < 208 ? untilHpos : 208, AnticMode.FOUR_COLOR, frame, 320);
					hpos = untilHpos;
					this.#poke();
					continue;
				}
				if (cpuCycles == 0 && this.#expectCmpZp()) {
					this.#gtia.drawSpan(y, hpos >= 48 ? hpos : 48, 208, AnticMode.FOUR_COLOR, frame, 320);
					break;
				}
				return false;
			}
		}
		return true;
	}
}

class InflateStream extends Stream
{
	#bits;

	#readBit()
	{
		if (this.#bits <= 1) {
			if (this.contentOffset >= this.contentLength)
				return -1;
			this.#bits = this.content[this.contentOffset++] | 256;
		}
		let result = this.#bits & 1;
		this.#bits >>= 1;
		return result;
	}

	#readBits(count)
	{
		let result = 0;
		for (let rank = 0; rank < count; rank++) {
			switch (this.#readBit()) {
			case -1:
				return -1;
			case 1:
				result |= 1 << rank;
				break;
			default:
				break;
			}
		}
		return result;
	}
	#symbolCodeLength = new Uint8Array(318);
	#nBitCodeCount = new Int32Array(32);
	#nBitCodeOffset = new Int32Array(32);
	#codeToSymbol = new Int16Array(318);

	#buildHuffmanTrees()
	{
		this.#nBitCodeCount.fill(0);
		for (let i = 0; i < 318; i++)
			this.#nBitCodeCount[this.#symbolCodeLength[i]]++;
		let offset = 0;
		for (let i = 0; i < 32; i++) {
			this.#nBitCodeOffset[i] = offset;
			offset += this.#nBitCodeCount[i];
		}
		for (let i = 0; i < 318; i++)
			this.#codeToSymbol[this.#nBitCodeOffset[this.#symbolCodeLength[i]]++] = i;
	}

	#fetchCode(tree)
	{
		let code = 0;
		do {
			let bit = this.#readBit();
			if (bit < 0)
				return -1;
			code = (code << 1) + bit - this.#nBitCodeCount[++tree];
			if (code < 0)
				return this.#codeToSymbol[this.#nBitCodeOffset[tree] + code];
		}
		while ((tree & 15) != 15);
		return -1;
	}

	#inflate(unpacked, unpackedLength)
	{
		let unpackedOffset = 0;
		this.#bits = 0;
		let lastBlock;
		do {
			lastBlock = this.#readBit();
			let count;
			switch (this.#readBits(2)) {
			case 0:
				this.#bits = 0;
				count = this.#readBits(16);
				if (this.#readBits(16) != (count ^ 65535))
					return -1;
				if (count > unpackedLength - unpackedOffset)
					count = unpackedLength - unpackedOffset;
				if (!this.readBytes(unpacked, unpackedOffset, count))
					return -1;
				unpackedOffset += count;
				if (unpackedOffset == unpackedLength)
					return unpackedOffset;
				continue;
			case 1:
				for (let i = 0; i < 144; i++)
					this.#symbolCodeLength[i] = 8;
				for (let i = 144; i < 256; i++)
					this.#symbolCodeLength[i] = 9;
				for (let i = 256; i < 280; i++)
					this.#symbolCodeLength[i] = 7;
				for (let i = 280; i < 288; i++)
					this.#symbolCodeLength[i] = 8;
				for (let i = 288; i < 318; i++)
					this.#symbolCodeLength[i] = 21;
				break;
			case 2:
				let primaryCodes = 257 + this.#readBits(5);
				let codes = 289 + this.#readBits(5);
				if (codes > 318)
					return -1;
				let temporaryCodes = this.#readBits(4);
				if (temporaryCodes < 0)
					return -1;
				temporaryCodes += 4;
				this.#symbolCodeLength.fill(0);
				for (let i = 0; i < temporaryCodes; i++) {
					let bits = this.#readBits(3);
					if (bits < 0)
						return -1;
					this.#symbolCodeLength[InflateStream.#INFLATE_TEMP_SYMBOLS[i]] = bits;
				}
				this.#buildHuffmanTrees();
				let length = 0;
				count = 1;
				for (let i = 0; i < codes; i++) {
					if (--count == 0) {
						let symbol = this.#fetchCode(0);
						switch (symbol) {
						case -1:
							return -1;
						case 16:
							count = this.#readBits(2);
							if (count < 0)
								return -1;
							count += 3;
							break;
						case 17:
							length = 0;
							count = this.#readBits(3);
							if (count < 0)
								return -1;
							count += 3;
							break;
						case 18:
							length = 0;
							count = this.#readBits(7);
							if (count < 0)
								return -1;
							count += 11;
							break;
						default:
							length = symbol;
							count = 1;
							break;
						}
					}
					if (i == primaryCodes)
						i = 288;
					this.#symbolCodeLength[i] = i < 288 ? length : 16 + length;
				}
				break;
			default:
				return -1;
			}
			this.#buildHuffmanTrees();
			for (;;) {
				let symbol = this.#fetchCode(0);
				if (symbol < 0)
					return -1;
				else if (symbol < 256)
					unpacked[unpackedOffset++] = symbol;
				else if (symbol == 256)
					break;
				else {
					switch (symbol) {
					case 257:
					case 258:
					case 259:
					case 260:
					case 261:
					case 262:
					case 263:
					case 264:
						count = symbol - 254;
						break;
					case 285:
						count = 258;
						break;
					case 286:
					case 287:
						return -1;
					default:
						symbol -= 261;
						count = this.#readBits(symbol >> 2);
						if (count < 0)
							return -1;
						count += ((4 + (symbol & 3)) << (symbol >> 2)) + 3;
						break;
					}
					symbol = this.#fetchCode(16);
					let distance;
					switch (symbol) {
					case -1:
						return -1;
					case 288:
					case 289:
					case 290:
					case 291:
						distance = symbol - 287;
						break;
					default:
						symbol -= 290;
						distance = this.#readBits(symbol >> 1);
						if (distance < 0)
							return -1;
						distance += ((2 + (symbol & 1)) << (symbol >> 1)) + 1;
						break;
					}
					if (count > unpackedLength - unpackedOffset)
						count = unpackedLength - unpackedOffset;
					if (!RECOIL.copyPrevious(unpacked, unpackedOffset, distance, count))
						return -1;
					unpackedOffset += count;
				}
				if (unpackedOffset == unpackedLength)
					return unpackedOffset;
			}
		}
		while (lastBlock == 0);
		return unpackedOffset;
	}

	uncompress(unpacked, unpackedLength)
	{
		let b0 = this.readByte();
		if ((b0 & 143) != 8)
			return -1;
		let b1 = this.readByte();
		if ((b1 & 32) != 0 || (b0 << 8 | b1) % 31 != 0)
			return -1;
		return this.#inflate(unpacked, unpackedLength);
	}

	static #INFLATE_TEMP_SYMBOLS = new Uint8Array([ 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2,
		14, 1, 15 ]);
}

/**
 * Decoder of images in formats native to vintage computers.
 * Decodes file contents passed as a byte array
 * into a 24-bit RGB bitmap.
 */
class RECOIL
{
	/**
	 * Constructs a decoder of images.
	 * The decoder can be used for several images, one after another.
	 */
	constructor()
	{
		this.setNtsc(false);
	}

	/**
	 * RECOIL version - major part.
	 */
	static VERSION_MAJOR = 7;

	/**
	 * RECOIL version - minor part.
	 */
	static VERSION_MINOR = 0;

	/**
	 * RECOIL version - micro part.
	 */
	static VERSION_MICRO = 0;

	/**
	 * RECOIL version as a string.
	 */
	static VERSION = "7.0.0";

	/**
	 * Years RECOIL was created in.
	 */
	static YEARS = "2009-2026";

	/**
	 * Short credits for RECOIL.
	 */
	static CREDITS = "Retro Computer Image Library (C) 2009-2026 Piotr Fusik\n";

	/**
	 * Short license notice.
	 * Display after the credits.
	 */
	static LICENSE = "This program is licensed under the MIT License.";

	/**
	 * Maximum length of a supported platform palette file.
	 */
	static MAX_PLATFORM_PALETTE_CONTENT_LENGTH = 32768;
	/**
	 * Decoded image width.
	 */
	#width;
	/**
	 * Decoded image height.
	 */
	#height;
	/**
	 * Decoded image pixels as 0xRRGGBB.
	 */
	#pixels;
	/**
	 * Length of the currently allocated <code>Pixels</code>.
	 */
	#pixelsLength = 0;
	/**
	 * Platform and pixel ratio.
	 */
	#resolution;
	/**
	 * Number of frames (normally 1; 2 or 3 for flickering pictures).
	 */
	#frames;
	/**
	 * <code>true</code> if NTSC is preferred over PAL.
	 */
	#ntsc;
	#c64Palette = new Int32Array(16);
	#c16Palette = new Int32Array(128);
	#atari8Palette = new Int32Array(256);
	#leftSkip;

	/**
	 * Maximum length of a string returned by <code>GetPlatform()</code>.
	 */
	static MAX_PLATFORM_LENGTH = 22;

	/**
	 * Selects the PAL/NTSC video standard for applicable platforms.
	 * Resets all platform palettes loaded with <code>SetPlatformPalette</code> to default.
	 * @param ntsc <code>true</code> for NTSC, <code>false</code> for PAL
	 */
	setNtsc(ntsc)
	{
		this.#ntsc = ntsc;
		this.#c64Palette[0] = 0;
		this.#c64Palette[1] = 16777215;
		this.#c64Palette[2] = 6829867;
		this.#c64Palette[3] = 7382194;
		this.#c64Palette[4] = 7290246;
		this.#c64Palette[5] = 5803331;
		this.#c64Palette[6] = 3483769;
		this.#c64Palette[7] = 12109679;
		this.#c64Palette[8] = 7294757;
		this.#c64Palette[9] = 4405504;
		this.#c64Palette[10] = 10119001;
		this.#c64Palette[11] = 4473924;
		this.#c64Palette[12] = 7105644;
		this.#c64Palette[13] = 10146436;
		this.#c64Palette[14] = 7102133;
		this.#c64Palette[15] = 9803157;
		RECOIL.#decodeR8G8B8Colors(Fu.c16_pal, 0, 128, this.#c16Palette, 0);
		RECOIL.#decodeR8G8B8Colors(this.#ntsc ? Fu.altirrantsc_pal : Fu.altirrapal_pal, 0, 256, this.#atari8Palette, 0);
	}

	/**
	 * Returns <code>true</code> if NTSC video standard is selected.
	 */
	isNtsc()
	{
		return this.#ntsc;
	}

	static #packExt(ext)
	{
		return ext.length == 0 || ext.length > 4 ? 0 : (ext.charCodeAt(0) + (ext.length >= 2 ? ext.charCodeAt(1) << 8 : 0) + (ext.length >= 3 ? ext.charCodeAt(2) << 16 : 0) + (ext.length >= 4 ? ext.charCodeAt(3) << 24 : 0)) | 538976288;
	}

	static #getPackedExt(filename)
	{
		let ext = 0;
		for (let i = filename.length; --i >= 0;) {
			let c = filename.charCodeAt(i);
			if (c == 46)
				return ext | 538976288;
			if (c <= 32 || c > 122 || ext >= 16777216)
				return 0;
			ext = (ext << 8) + c;
		}
		return 0;
	}

	/**
	 * Sets a custom platform palette.
	 * 
	 * <ul>
	 * <li>768-byte <code>ACT</code>/<code>PAL</code> file with an Atari 8-bit palette</li>
	 * <li><code>VPL</code> VICE Palette file with a C64 or C16 palette</li>
	 * </ul>
	 * <p>Returns <code>true</code> on success.
	 * @param filename Name of the file to decode. Only the extension is processed, for format recognition.
	 * @param content File contents.
	 * @param contentLength File length.
	 */
	setPlatformPalette(filename, content, contentLength)
	{
		switch (RECOIL.#getPackedExt(filename)) {
		case 544498529:
		case 543973744:
			if (contentLength != 768)
				return false;
			RECOIL.#decodeR8G8B8Colors(content, 0, 256, this.#atari8Palette, 0);
			return true;
		case 543977590:
			const vpl = Object.assign(new VplStream(), { content: content, contentOffset: 0, contentLength: contentLength });
			switch (vpl.decode()) {
			case 16:
				vpl.copyTo(this.#c64Palette, 16);
				return true;
			case 128:
				vpl.copyTo(this.#c16Palette, 128);
				return true;
			default:
				return false;
			}
		default:
			return false;
		}
	}

	/**
	 * Initializes decoded image size and resolution.
	 */
	#setSize(width, height, resolution, frames = 1)
	{
		if (width <= 0 || height <= 0 || height > ((134217728 / width | 0) / frames | 0))
			return false;
		this.#width = width;
		this.#height = height;
		this.#resolution = resolution;
		this.#frames = frames;
		this.#colors = -1;
		this.#leftSkip = 0;
		let pixelsLength = width * height * frames;
		if (this.#pixelsLength < pixelsLength) {
			this.#pixels = new Int32Array(pixelsLength);
			this.#pixelsLength = pixelsLength;
		}
		return true;
	}

	#setSizeStOrFalcon(width, height, bitplanes, squarePixels)
	{
		let resolution = RECOILResolution.FALCON1X1;
		switch (bitplanes) {
		case 1:
			if (width <= 640 && height <= 400)
				resolution = RECOILResolution.ST1X1;
			break;
		case 2:
			if (!squarePixels && width == 640 && height == 200) {
				height <<= 1;
				resolution = RECOILResolution.STE1X2;
			}
			break;
		case 4:
			if (width <= 320 && height <= 200)
				resolution = RECOILResolution.STE1X1;
			break;
		case 8:
			if (!squarePixels && width == 320 && height == 480) {
				width <<= 1;
				resolution = RECOILResolution.TT2X1;
			}
			break;
		default:
			break;
		}
		return this.#setSize(width, height, resolution);
	}

	#setScaledSize(width, height, resolution)
	{
		switch (resolution) {
		case RECOILResolution.AMIGA2X1:
		case RECOILResolution.FALCON2X1:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS2X1I:
			width <<= 1;
			break;
		case RECOILResolution.AMIGA4X1:
			width <<= 2;
			break;
		case RECOILResolution.AMIGA8X1:
			width <<= 3;
			break;
		case RECOILResolution.AMIGA1X2:
		case RECOILResolution.AMIGA_DCTV1X2:
		case RECOILResolution.ST1X2:
		case RECOILResolution.STE1X2:
		case RECOILResolution.MSX21X2:
		case RECOILResolution.PC801X2:
		case RECOILResolution.PC881X2:
		case RECOILResolution.ELEMENT_ZX1X2:
			height <<= 1;
			break;
		case RECOILResolution.AMIGA1X4:
			height <<= 2;
			break;
		default:
			break;
		}
		return this.#setSize(width, height, resolution);
	}

	#setScaledPixel(x, y, rgb)
	{
		let offset = y * this.#width;
		switch (this.#resolution) {
		case RECOILResolution.AMIGA2X1:
		case RECOILResolution.AMIGA_HAME2X1:
		case RECOILResolution.AMSTRAD2X1:
		case RECOILResolution.TT2X1:
		case RECOILResolution.FALCON2X1:
		case RECOILResolution.BBC2X1:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS2X1I:
		case RECOILResolution.SAM_COUPE2X1I:
			offset += x << 1;
			this.#pixels[offset + 1] = this.#pixels[offset] = rgb;
			break;
		case RECOILResolution.AMIGA4X1:
			offset += x << 2;
			this.#pixels[offset + 3] = this.#pixels[offset + 2] = this.#pixels[offset + 1] = this.#pixels[offset] = rgb;
			break;
		case RECOILResolution.AMIGA8X1:
			offset += x << 3;
			for (x = 0; x < 8; x++)
				this.#pixels[offset + x] = rgb;
			break;
		case RECOILResolution.AMIGA1X2:
		case RECOILResolution.AMIGA_DCTV1X2:
		case RECOILResolution.APPLE_I_I_G_S1X2:
		case RECOILResolution.ST1X2:
		case RECOILResolution.STE1X2:
		case RECOILResolution.MC05151X2:
		case RECOILResolution.PC801X2:
		case RECOILResolution.PC881X2:
		case RECOILResolution.MSX21X2:
		case RECOILResolution.SAM_COUPE1X2:
		case RECOILResolution.ELEMENT_ZX1X2:
		case RECOILResolution.TRS1X2:
			offset = (offset << 1) + x;
			this.#pixels[offset + this.#width] = this.#pixels[offset] = rgb;
			break;
		case RECOILResolution.AMIGA1X4:
			offset = (offset << 2) + x;
			this.#pixels[offset + this.#width * 3] = this.#pixels[offset + this.#width * 2] = this.#pixels[offset + this.#width] = this.#pixels[offset] = rgb;
			break;
		default:
			this.#pixels[offset + x] = rgb;
			break;
		}
	}

	/**
	 * Reads a 32-bit big endian integer from a byte array.
	 */
	static get32BigEndian(content, contentOffset)
	{
		return content[contentOffset] << 24 | content[contentOffset + 1] << 16 | content[contentOffset + 2] << 8 | content[contentOffset + 3];
	}

	/**
	 * Reads a 32-bit little endian integer from a byte array.
	 */
	static get32LittleEndian(content, contentOffset)
	{
		return content[contentOffset] | content[contentOffset + 1] << 8 | content[contentOffset + 2] << 16 | content[contentOffset + 3] << 24;
	}

	static getNibble(content, contentOffset, index)
	{
		let b = content[contentOffset + (index >> 1)];
		return (index & 1) == 0 ? b >> 4 : b & 15;
	}

	static isStringAt(content, contentOffset, s)
	{
		for (const c of s)
			if (content[contentOffset++] != c.codePointAt(0))
				return false;
		return true;
	}

	static copyPrevious(unpacked, unpackedOffset, distance, count)
	{
		if (distance > unpackedOffset)
			return false;
		do {
			unpacked[unpackedOffset] = unpacked[unpackedOffset - distance];
			unpackedOffset++;
		}
		while (--count > 0);
		return true;
	}

	#applyBlend()
	{
		let pixelsLength = this.#width * this.#height;
		for (let i = 0; i < pixelsLength; i++) {
			let rgb1 = this.#pixels[i];
			let rgb2 = this.#pixels[pixelsLength + i];
			this.#pixels[i] = (rgb1 & rgb2) + ((rgb1 ^ rgb2) >> 1 & 8355711);
		}
		return true;
	}

	/**
	 * Reads a companion file to the specified byte array.
	 * Implement this method in a subclass to enable support for multi-file images.
	 * Returns the number of bytes read (up to <code>contentLength</code>) or -1 on error.
	 * @param filename Name of the file to read.
	 * @param content Out: target for the file contents.
	 * @param contentLength Maximum number of bytes to read.
	 */
	readFile(filename, content, contentLength)
	{
		return -1;
	}

	#readCompanionFile(baseFilename, upperExt, lowerExt, content, contentLength)
	{
		let i = baseFilename.length;
		let lower = false;
		for (;;) {
			let c = baseFilename.charCodeAt(--i);
			if (c >= 97)
				lower = true;
			else if (c == 46)
				break;
		}
		let filename = baseFilename.substring(0, i + 1);
		filename += lower ? lowerExt : upperExt;
		return this.readFile(filename, content, contentLength);
	}

	#readSiblingFile(baseFilename, newFilename, content, contentLength)
	{
		let i = baseFilename.length;
		while (i > 0 && baseFilename.charCodeAt(i - 1) != 47 && baseFilename.charCodeAt(i - 1) != 92)
			i--;
		let filename = baseFilename.substring(0, i);
		filename += newFilename;
		return this.readFile(filename, content, contentLength);
	}

	#decodeBru(content, contentLength)
	{
		if (contentLength != 64)
			return false;
		this.#setSize(8, 8, RECOILResolution.ST1X1);
		for (let i = 0; i < 64; i++) {
			switch (content[i]) {
			case 0:
				this.#pixels[i] = 0;
				break;
			case 1:
				this.#pixels[i] = 16777215;
				break;
			default:
				return false;
			}
		}
		return true;
	}
	/**
	 * RGB palette decoded from the image file.
	 */
	contentPalette = new Int32Array(256);

	#setGrayscalePalette(inverse)
	{
		for (let c = 0; c < 256; c++)
			this.contentPalette[c] = (c ^ inverse) * 65793;
	}

	#decodeBytes(content, contentOffset)
	{
		let width = this.getOriginalWidth();
		let height = this.getOriginalHeight();
		for (let y = 0; y < height; y++)
			for (let x = 0; x < width; x++)
				this.#setScaledPixel(x, y, this.contentPalette[content[contentOffset + y * width + x]]);
	}

	#decodeNibbles(content, contentOffset, contentStride)
	{
		let width = this.getOriginalWidth();
		let height = this.getOriginalHeight();
		for (let y = 0; y < height; y++)
			for (let x = 0; x < width; x++)
				this.#setScaledPixel(x, y, this.contentPalette[RECOIL.getNibble(content, contentOffset + y * contentStride, x)]);
	}

	static #getR8G8B8Color(content, contentOffset)
	{
		return content[contentOffset] << 16 | content[contentOffset + 1] << 8 | content[contentOffset + 2];
	}

	static #getB8G8R8Color(content, contentOffset)
	{
		return content[contentOffset + 2] << 16 | content[contentOffset + 1] << 8 | content[contentOffset];
	}

	static #decodeR8G8B8Colors(content, contentOffset, count, destination, destinationOffset)
	{
		for (let i = 0; i < count; i++)
			destination[destinationOffset + i] = RECOIL.#getR8G8B8Color(content, contentOffset + i * 3);
	}

	static #getB5G5R5Color(c)
	{
		c = (c & 31) << 19 | (c & 992) << 6 | (c >> 7 & 248);
		return c | (c >> 5 & 460551);
	}

	static #getR5G5B5Color(c)
	{
		c = (c & 31744) << 9 | (c & 992) << 6 | (c & 31) << 3;
		return c | (c >> 5 & 460551);
	}

	static #getG6R5B5Color(c)
	{
		c = (c & 992) << 14 | (c & 64512) | (c & 31) << 3;
		return c | (c >> 5 & 458759) | (c >> 6 & 768);
	}

	static #get729Color(c)
	{
		let r = c / 81 | 0;
		let g = (c / 9 | 0) % 9;
		let b = c % 9;
		return r * 255 >> 3 << 16 | g * 255 >> 3 << 8 | b * 255 >> 3;
	}

	static getFalconTrueColor(content, contentOffset)
	{
		let rg = content[contentOffset];
		let gb = content[contentOffset + 1];
		let rgb = (rg & 248) << 16 | (rg & 7) << 13 | (gb & 224) << 5 | (gb & 31) << 3;
		rgb |= (rgb >> 5 & 458759) | (rgb >> 6 & 768);
		return rgb;
	}

	static #getBitplanePixel(content, contentOffset, x, bitplanes, bytesPerBitplane)
	{
		let bit = ~x & 7;
		let c = 0;
		for (let bitplane = bitplanes; --bitplane >= 0;)
			c = c << 1 | (content[contentOffset + bitplane * bytesPerBitplane] >> bit & 1);
		return c;
	}

	#decodeAmigaPlanar(content, contentOffset, width, height, resolution, bitplanes, palette)
	{
		if (!this.#setScaledSize(width, height, resolution))
			return false;
		let bytesPerLine = (width + 15) >> 4 << 1;
		let bitplaneLength = height * bytesPerLine;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let c = RECOIL.#getBitplanePixel(content, contentOffset + y * bytesPerLine + (x >> 3), x, bitplanes, bitplaneLength);
				this.#setScaledPixel(x, y, palette[c]);
			}
		}
		return true;
	}

	static #getBitplaneWordsPixel(content, contentOffset, x, bitplanes)
	{
		return RECOIL.#getBitplanePixel(content, contentOffset + (x >> 3 & ~1) * bitplanes + (x >> 3 & 1), x, bitplanes, 2);
	}

	/**
	 * Decodes Atari ST/Falcon interleaved bitplanes.
	 * Each 16 pixels are encoded in N consecutive 16-bit words.
	 */
	#decodeBitplanes(content, contentOffset, contentStride, bitplanes, pixelsOffset, width, height)
	{
		while (--height >= 0) {
			for (let x = 0; x < width; x++) {
				let c = RECOIL.#getBitplaneWordsPixel(content, contentOffset, x, bitplanes);
				this.#pixels[pixelsOffset + x] = this.contentPalette[c];
			}
			contentOffset += contentStride;
			pixelsOffset += this.#width;
		}
	}

	#decodeScaledBitplanes(content, contentOffset, width, height, bitplanes, ehb, multiPalette)
	{
		let contentStride = ((width + 15) >> 4 << 1) * bitplanes;
		for (let y = 0; y < height; y++) {
			if (multiPalette != null)
				multiPalette.setLinePalette(this, y);
			if (ehb) {
				for (let c = 0; c < 32; c++)
					this.contentPalette[32 + c] = this.contentPalette[c] >> 1 & 8355711;
			}
			for (let x = 0; x < width; x++) {
				let c = RECOIL.#getBitplaneWordsPixel(content, contentOffset, x, bitplanes);
				this.#setScaledPixel(x, y, this.contentPalette[c]);
			}
			contentOffset += contentStride;
		}
	}

	#decodeMono(content, contentOffset, contentLength, wordAlign)
	{
		let contentStride = (this.#width + 7) >> 3;
		if (wordAlign)
			contentStride += contentStride & 1;
		if (contentLength != contentOffset + contentStride * this.#height)
			return false;
		this.#decodeBitplanes(content, contentOffset, contentStride, 1, 0, this.#width, this.#height);
		return true;
	}

	#decodeBlackAndWhite(content, contentOffset, contentLength, wordAlign, backgroundColor)
	{
		this.contentPalette[0] = backgroundColor;
		this.contentPalette[1] = backgroundColor ^ 16777215;
		return this.#decodeMono(content, contentOffset, contentLength, wordAlign);
	}

	#decodeRleMono(rle, color0, color1)
	{
		let width = this.getOriginalWidth();
		let height = this.getOriginalHeight();
		for (let y = 0; y < height; y++) {
			let b = 0;
			for (let x = 0; x < width; x++) {
				if ((x & 7) == 0) {
					b = rle.readRle();
					if (b < 0)
						return false;
				}
				this.#setScaledPixel(x, y, (b >> (~x & 7) & 1) == 0 ? color0 : color1);
			}
		}
		return true;
	}

	#decodeRleBlackAndWhite(rle, backgroundColor)
	{
		return this.#decodeRleMono(rle, backgroundColor, backgroundColor ^ 16777215);
	}

	#decodeBlackAndWhiteFont(content, contentOffset, contentLength, fontHeight)
	{
		for (let y = 0; y < this.#height; y++) {
			for (let x = 0; x < 256; x++) {
				let row = y % fontHeight;
				let offset = contentOffset + ((y - row) << 5) + (x >> 3) * fontHeight + row;
				let c;
				if (offset < contentLength) {
					c = content[offset] >> (~x & 7) & 1;
					if (c != 0)
						c = 16777215;
				}
				else
					c = 0;
				this.#pixels[(y << 8) + x] = c;
			}
		}
	}

	#decodePgf(content, contentLength)
	{
		this.#setSize(240, 64, RECOILResolution.PORTFOLIO1X1);
		this.contentPalette[0] = 9355692;
		this.contentPalette[1] = 4409239;
		return this.#decodeMono(content, 0, contentLength, false);
	}

	#decodePgc(content, contentLength)
	{
		if (contentLength < 33 || content[0] != 80 || content[1] != 71 || content[2] != 1)
			return false;
		this.#setSize(240, 64, RECOILResolution.PORTFOLIO1X1);
		const rle = Object.assign(new PgcStream(), { content: content, contentOffset: 3, contentLength: contentLength });
		return this.#decodeRleMono(rle, 9355692, 4409239);
	}

	#decodePsion3Pic(content, contentLength)
	{
		if (contentLength < 22 || content[0] != 80 || content[1] != 73 || content[2] != 67 || content[3] != 220 || content[4] != 48 || content[5] != 48 || (content[6] == 0 && content[7] == 0))
			return false;
		let width = content[10] | content[11] << 8;
		let height = content[12] | content[13] << 8;
		let bitmapLength = content[14] | content[15] << 8;
		let stride = (width + 15) >> 4 << 1;
		if (bitmapLength != height * stride)
			return false;
		let bitmapOffset = 20 + RECOIL.get32LittleEndian(content, 16);
		if (bitmapOffset < 20 || contentLength < bitmapOffset + bitmapLength)
			return false;
		if (!this.#setSize(width, height, RECOILResolution.PSION31X1))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				this.#pixels[y * width + x] = (content[bitmapOffset + (x >> 3)] >> (x & 7) & 1) == 0 ? 16777215 : 0;
			}
			bitmapOffset += stride;
		}
		return true;
	}

	#decodeGrb(content, contentLength)
	{
		if (contentLength < 19)
			return false;
		if (RECOIL.isStringAt(content, 0, "HPHP48-") && content[8] == 30 && content[9] == 43 && (content[10] & 15) == 0) {
			let nibbles = content[10] >> 4 | content[11] << 4 | content[12] << 12;
			let height = content[13] | content[14] << 8 | (content[15] & 15) << 16;
			let width = content[15] >> 4 | content[16] << 4 | content[17] << 12;
			let bytesPerLine = (width + 7) >> 3;
			if (nibbles != (contentLength << 1) - 21 || contentLength != 18 + height * bytesPerLine || !this.#setSize(width, height, RECOILResolution.HP481X1))
				return false;
			for (let y = 0; y < height; y++) {
				for (let x = 0; x < width; x++)
					this.#pixels[y * width + x] = (content[18 + y * bytesPerLine + (x >> 3)] >> (x & 7) & 1) == 0 ? 16777215 : 0;
			}
			return true;
		}
		if (contentLength >= 31 && RECOIL.isStringAt(content, 0, "%%HP: T(0)A(D)F(.);\rGROB ")) {
			const s = Object.assign(new Stream(), { content: content, contentOffset: 25, contentLength: contentLength });
			let width = s.parseInt(10, 65535);
			if (width <= 0 || s.readByte() != 32)
				return false;
			let height = s.parseInt(10, 65535);
			if (height <= 0 || s.readByte() != 13 || !this.#setSize(width, height, RECOILResolution.HP481X1))
				return false;
			let b = 0;
			for (let y = 0; y < height; y++) {
				for (let x = 0; x < width; x++) {
					let bit = x & 7;
					if (bit == 0) {
						b = s.readHexByte();
						if (b < 0)
							return false;
					}
					this.#pixels[y * width + x] = (b >> (bit ^ 4) & 1) == 0 ? 16777215 : 0;
				}
			}
			return true;
		}
		return false;
	}

	#decodeTrsHr(content, contentLength)
	{
		switch (contentLength) {
		case 19200:
		case 19328:
		case 19456:
			break;
		default:
			return false;
		}
		this.#setSize(640, 480, RECOILResolution.TRS1X2);
		for (let y = 0; y < 240; y++) {
			for (let x = 0; x < 640; x++) {
				let c = content[y * 80 + (x >> 3)] >> (~x & 7) & 1;
				if (c != 0)
					c = 16777215;
				let pixelsOffset = y * 1280 + x;
				this.#pixels[pixelsOffset + 640] = this.#pixels[pixelsOffset] = c;
			}
		}
		return true;
	}

	#decodeTrsShr(content, contentLength)
	{
		this.#setSize(640, 480, RECOILResolution.TRS1X2);
		const rle = Object.assign(new PgcStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		return this.#decodeRleBlackAndWhite(rle, 0);
	}

	#decodeRle(content, contentLength)
	{
		if (contentLength < 520 || content[0] != 27 || content[1] != 71 || content[2] != 72)
			return false;
		this.#setSize(256, 192, RECOILResolution.TRS1X1);
		let count = 0;
		let contentOffset = 3;
		let c = 16777215;
		for (let pixelsOffset = 0; pixelsOffset < 49152; pixelsOffset++) {
			while (count == 0) {
				if (contentOffset >= contentLength)
					return false;
				count = content[contentOffset++];
				if (count < 32 || count > 127) {
					if (pixelsOffset == 49151) {
						this.#pixels[pixelsOffset] = c;
						return true;
					}
					return false;
				}
				c ^= 16777215;
				count -= 32;
			}
			this.#pixels[pixelsOffset] = c;
			count--;
		}
		return true;
	}

	#decodeCocoClp(content, contentLength)
	{
		if (contentLength != 306 || content[305] != 100)
			return false;
		for (let i = 0; i < 25; i++) {
			if (content[i] != RECOIL.#DECODE_COCO_CLP_HEADER[i])
				return false;
		}
		this.#setSize(40, 56, RECOILResolution.COCO1X1);
		return this.#decodeBlackAndWhite(content, 25, 305, false, 16777215);
	}

	#decodeCocoMax(content, contentLength)
	{
		switch (contentLength) {
		case 6154:
		case 6155:
		case 6272:
		case 7168:
			break;
		default:
			return false;
		}
		if (content[0] != 0 || content[1] != 24 || content[2] > 1 || content[3] != 14 || content[4] != 0)
			return false;
		this.#setSize(256, 192, RECOILResolution.COCO1X1);
		return this.#decodeBlackAndWhite(content, 5, 6149, false, 0);
	}

	#decodeP11(content, contentLength)
	{
		if ((contentLength != 3083 && contentLength != 3243) || content[0] != 0 || content[1] != 12 || content[3] != 14 || content[4] != 0)
			return false;
		this.#setSize(256, 192, RECOILResolution.COCO2X2);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let c = content[5 + ((y & ~1) << 4) + (x >> 3)] >> (~x & 6) & 3;
				this.#pixels[(y << 8) + x] = RECOIL.#DECODE_P11_PALETTE[c];
			}
		}
		return true;
	}

	#decodeMac(content, contentLength)
	{
		if (contentLength < 512)
			return false;
		let contentOffset = RECOIL.isStringAt(content, 65, "PNTG") ? 128 : 0;
		if (content[contentOffset] != 0 || content[contentOffset + 1] != 0 || content[contentOffset + 2] != 0 || content[contentOffset + 3] > 3)
			return false;
		this.#setSize(576, 720, RECOILResolution.MACINTOSH1X1);
		const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: contentOffset + 512, contentLength: contentLength });
		return this.#decodeRleBlackAndWhite(rle, 16777215);
	}

	static #decodePlayStation(content, contentOffset, pixels, pixelsLength)
	{
		for (let i = 0; i < pixelsLength; i++)
			pixels[i] = RECOIL.#getB5G5R5Color(content[contentOffset + (i << 1)] | content[contentOffset + (i << 1) + 1] << 8);
	}

	#decodeTimPalette(content, contentLength, colors)
	{
		if ((content[16] | content[17] << 8) != colors)
			return -1;
		let paletteCount = content[18] | content[19] << 8;
		if (paletteCount == 0)
			return -1;
		let bitmapOffset = 20 + (paletteCount * colors << 1);
		if (RECOIL.get32LittleEndian(content, 8) != bitmapOffset - 8 || contentLength < bitmapOffset + 12)
			return -1;
		let width = (content[bitmapOffset + 8] | content[bitmapOffset + 9] << 8) << 1;
		let height = content[bitmapOffset + 10] | content[bitmapOffset + 11] << 8;
		if (contentLength < bitmapOffset + 12 + width * height)
			return -1;
		if (colors == 16)
			width <<= 1;
		if (!this.#setSize(width, height, RECOILResolution.PLAY_STATION1X1))
			return -1;
		RECOIL.#decodePlayStation(content, 20, this.contentPalette, colors);
		return bitmapOffset + 12;
	}

	#decodeTim(content, contentLength)
	{
		if (contentLength < 20 || RECOIL.get32LittleEndian(content, 0) != 16)
			return false;
		let width;
		let height;
		let pixelsLength;
		let bitmapOffset;
		switch (content[4] & 15) {
		case 2:
			width = content[16] | content[17] << 8;
			height = content[18] | content[19] << 8;
			pixelsLength = width * height;
			if (contentLength < 20 + (pixelsLength << 1) || !this.#setSize(width, height, RECOILResolution.PLAY_STATION1X1))
				return false;
			RECOIL.#decodePlayStation(content, 20, this.#pixels, pixelsLength);
			return true;
		case 3:
			width = (content[16] | content[17] << 8) * 2 / 3 | 0;
			height = content[18] | content[19] << 8;
			pixelsLength = width * height;
			if (contentLength != 20 + pixelsLength * 3 || !this.#setSize(width, height, RECOILResolution.PLAY_STATION1X1))
				return false;
			RECOIL.#decodeR8G8B8Colors(content, 20, pixelsLength, this.#pixels, 0);
			return true;
		case 8:
			bitmapOffset = this.#decodeTimPalette(content, contentLength, 16);
			if (bitmapOffset < 0)
				return false;
			pixelsLength = this.#width * this.#height;
			for (let i = 0; i < pixelsLength; i++) {
				let b = content[bitmapOffset + (i >> 1)];
				this.#pixels[i] = this.contentPalette[(i & 1) == 0 ? b & 15 : b >> 4];
			}
			return true;
		case 9:
			bitmapOffset = this.#decodeTimPalette(content, contentLength, 256);
			if (bitmapOffset < 0)
				return false;
			this.#decodeBytes(content, bitmapOffset);
			return true;
		default:
			return false;
		}
	}

	static #BBC_PALETTE = new Int32Array([ 0, 16711680, 65280, 16776960, 255, 16711935, 65535, 16777215, 0, 16711680, 65280, 16776960, 255, 16711935, 65535, 16777215 ]);

	static #BBC_PALETTE2_BIT = new Int32Array([ 0, 16711680, 16776960, 16777215 ]);

	static #BBC_PALETTE1_BIT = new Int32Array([ 0, 16777215 ]);

	#decodeBb0(content, contentLength, palette)
	{
		if (contentLength != 20480)
			return false;
		this.#setSize(640, 512, RECOILResolution.BBC1X2);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 640; x++) {
				let c = content[(y & ~7) * 80 + (x & ~7) + (y & 7)] >> (~x & 7) & 1;
				let pixelsOffset = y * 1280 + x;
				this.#pixels[pixelsOffset + 640] = this.#pixels[pixelsOffset] = palette[c];
			}
		}
		return true;
	}

	#decodeBb1(content, contentLength, palette)
	{
		if (contentLength != 20480)
			return false;
		this.#setSize(320, 256, RECOILResolution.BBC1X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 320; x++) {
				let c = content[(y & ~7) * 80 + ((x & ~3) << 1) + (y & 7)] >> (~x & 3);
				this.#pixels[y * 320 + x] = palette[(c >> 3 & 2) + (c & 1)];
			}
		}
		return true;
	}

	#decodeBb2(content, contentLength, palette)
	{
		if (contentLength != 20480)
			return false;
		this.#setSize(320, 256, RECOILResolution.BBC2X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 160; x++) {
				let c = content[(y & ~7) * 80 + ((x & ~1) << 2) + (y & 7)] >> (~x & 1);
				let pixelsOffset = (y * 160 + x) << 1;
				this.#pixels[pixelsOffset + 1] = this.#pixels[pixelsOffset] = palette[(c >> 3 & 8) + (c >> 2 & 4) + (c >> 1 & 2) + (c & 1)];
			}
		}
		return true;
	}

	#decodeBb4(content, contentLength, palette)
	{
		if (contentLength != 10240)
			return false;
		this.#setSize(320, 256, RECOILResolution.BBC1X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 320; x++) {
				let c = content[(y & ~7) * 40 + (x & ~7) + (y & 7)] >> (~x & 7) & 1;
				this.#pixels[y * 320 + x] = palette[c];
			}
		}
		return true;
	}

	#decodeBb5(content, contentLength, palette)
	{
		if (contentLength != 10240)
			return false;
		this.#setSize(320, 256, RECOILResolution.BBC2X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 160; x++) {
				let c = content[(y & ~7) * 40 + ((x & ~3) << 1) + (y & 7)] >> (~x & 3);
				let pixelsOffset = (y * 160 + x) << 1;
				this.#pixels[pixelsOffset + 1] = this.#pixels[pixelsOffset] = palette[(c >> 3 & 2) + (c & 1)];
			}
		}
		return true;
	}

	#decodeBbg(content, contentLength)
	{
		const rle = Object.assign(new BbgStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		rle.valueBits = rle.readBitsReverse(8);
		if (rle.valueBits < 1 || rle.valueBits > 8)
			return false;
		let mode = rle.readBitsReverse(8);
		let unpackedLength;
		switch (mode) {
		case 0:
		case 1:
		case 2:
			unpackedLength = 20480;
			break;
		case 4:
		case 5:
			unpackedLength = 10240;
			break;
		default:
			return false;
		}
		for (let i = 15; i >= 0; i--) {
			let c = rle.readBitsReverse(4);
			if (c < 0)
				return false;
			this.contentPalette[i] = RECOIL.#BBC_PALETTE[c];
		}
		let unpackedStep = rle.readBitsReverse(8);
		if (unpackedStep <= 0)
			return false;
		rle.countBits = rle.readBitsReverse(8);
		if (rle.countBits < 1 || rle.countBits > 8)
			return false;
		const unpacked = new Uint8Array(20480);
		for (let x = unpackedStep - 1; x >= 0; x--) {
			if (!rle.unpack(unpacked, x, unpackedStep, unpackedLength))
				return false;
		}
		switch (mode) {
		case 0:
			return this.#decodeBb0(unpacked, unpackedLength, this.contentPalette);
		case 1:
			return this.#decodeBb1(unpacked, unpackedLength, this.contentPalette);
		case 2:
			return this.#decodeBb2(unpacked, unpackedLength, this.contentPalette);
		case 4:
			return this.#decodeBb4(unpacked, unpackedLength, this.contentPalette);
		case 5:
			return this.#decodeBb5(unpacked, unpackedLength, this.contentPalette);
		default:
			return false;
		}
	}

	static #getOricHeader(content, contentLength)
	{
		if (contentLength < 26 || content[0] != 22 || content[1] != 22 || content[2] != 22 || content[3] != 36 || content[4] != 0 || content[5] != 0 || content[6] != 128 || content[7] != 0 || content[12] != 0)
			return 0;
		let contentOffset = 13;
		while (content[contentOffset++] != 0) {
			if (contentOffset >= 26)
				return 0;
		}
		return contentOffset;
	}

	#decodeChs(content, contentLength)
	{
		let contentOffset = RECOIL.#getOricHeader(content, contentLength);
		switch (contentLength - contentOffset) {
		case 768:
		case 769:
			break;
		default:
			return false;
		}
		this.#setSize(256, 24, RECOILResolution.ORIC1X1);
		this.#decodeBlackAndWhiteFont(content, contentOffset, contentLength, 8);
		return true;
	}

	#decodeHrs(content, contentLength)
	{
		let contentOffset = RECOIL.#getOricHeader(content, contentLength);
		if (contentOffset + 8000 != contentLength)
			return false;
		this.#setSize(240, 200, RECOILResolution.ORIC1X1);
		for (let y = 0; y < 200; y++) {
			let paper = 0;
			let ink = 7;
			for (let col = 0; col < 40; col++) {
				let offset = y * 40 + col;
				let b = content[contentOffset + offset];
				let inverse = b >= 128 ? 7 : 0;
				switch (b & 120) {
				case 0:
					ink = b & 7;
					b = 0;
					break;
				case 8:
				case 24:
					b = 0;
					break;
				case 16:
					paper = b & 7;
					b = 0;
					break;
				default:
					break;
				}
				for (let x = 0; x < 6; x++)
					this.#pixels[offset * 6 + x] = RECOIL.#BBC_PALETTE[((b >> (5 - x) & 1) == 0 ? paper : ink) ^ inverse];
			}
		}
		return true;
	}

	static #getAmstradHeader(content, contentLength)
	{
		if (contentLength < 128 || (content[24] | content[25] << 8) != contentLength - 128 || content[64] != content[24] || content[65] != content[25] || content[66] != 0)
			return 0;
		let sum = 0;
		for (let i = 0; i < 67; i++)
			sum += content[i];
		if ((content[67] | content[68] << 8) != sum)
			return 0;
		return 128;
	}

	#decodeAmstradFnt(content, contentLength)
	{
		let contentOffset = RECOIL.#getAmstradHeader(content, contentLength);
		if (contentLength != contentOffset + 768 && (contentLength != 896 || contentOffset != 0))
			return false;
		this.#setSize(256, 24, RECOILResolution.AMSTRAD1X1);
		this.#decodeBlackAndWhiteFont(content, contentOffset, contentLength, 8);
		return true;
	}

	static #getAmstradLineOffset(y, bytesPerLine, overscan)
	{
		return ((y & 7) << 11) + (y >> 3) * bytesPerLine + (overscan && y >= 128 ? 14336 : 0);
	}

	#decodeAmstradMode2Line(content, lineOffset, y)
	{
		for (let x = 0; x < this.#width; x++) {
			let offset = (y * this.#width << 1) + x;
			let c = content[lineOffset + (x >> 3)] >> (~x & 7) & 1;
			this.#pixels[offset + this.#width] = this.#pixels[offset] = this.contentPalette[c];
		}
	}

	#decodeAmstradMode2(content, contentOffset, width, height, overscan)
	{
		this.#setSize(width, height << 1, RECOILResolution.AMSTRAD1X2);
		for (let y = 0; y < height; y++)
			this.#decodeAmstradMode2Line(content, contentOffset + RECOIL.#getAmstradLineOffset(y, width >> 3, overscan), y);
		return true;
	}

	#decodeHgb(content, contentLength)
	{
		let contentOffset = RECOIL.#getAmstradHeader(content, contentLength);
		if (contentLength != contentOffset + 16384)
			return false;
		this.contentPalette[0] = 0;
		this.contentPalette[1] = 16777215;
		return this.#decodeAmstradMode2(content, contentOffset, 512, 256, false);
	}

	static #AMSTRAD_PALETTE = new Int32Array([ 8421504, 8421504, 65408, 16777088, 128, 16711808, 32896, 16744576, 16711808, 16777088, 16776960, 16777215, 16711680, 16711935, 16744448, 16744703,
		128, 65408, 65280, 65535, 0, 255, 32768, 33023, 8388736, 8454016, 8453888, 8454143, 8388608, 8388863, 8421376, 8421631 ]);

	#setAmstradPalette(filename)
	{
		const pal = new Uint8Array(368);
		let palLength = this.#readCompanionFile(filename, "PAL", "pal", pal, 368);
		let palOffset = RECOIL.#getAmstradHeader(pal, palLength);
		if (palLength != palOffset + 239)
			return -1;
		for (let i = 0; i < 16; i++) {
			let c = pal[palOffset + 3 + i * 12];
			if (c < 64 || c > 95)
				return -1;
			this.contentPalette[i] = RECOIL.#AMSTRAD_PALETTE[c - 64];
		}
		return pal[palOffset];
	}

	static #unpackConvImgCpc(content, contentOffset, contentLength, unpacked)
	{
		let unpackedOffset = 0;
		let bits = 0;
		while (contentOffset < contentLength) {
			if (bits <= 1) {
				bits = content[contentOffset++] | 256;
				if (contentOffset >= contentLength)
					return false;
			}
			let compressed = bits & 1;
			bits >>= 1;
			if (compressed == 0) {
				if (unpackedOffset >= 16000)
					return false;
				unpacked[unpackedOffset++] = content[contentOffset++];
			}
			else {
				let b = content[contentOffset++];
				let distance;
				let count;
				if (b >= 128) {
					if (contentOffset >= contentLength)
						return false;
					count = (b >> 4) - 5;
					distance = ((b & 15) << 8) + content[contentOffset++] + 1;
				}
				else if (b >= 64) {
					distance = b - 63;
					count = 2;
				}
				else if (b >= 32) {
					if (contentOffset >= contentLength)
						return false;
					count = b - 30;
					distance = content[contentOffset++] + 1;
				}
				else if (b >= 16) {
					if (contentOffset + 1 >= contentLength)
						return false;
					distance = ((b - 16) << 8) + content[contentOffset++] + 1;
					count = content[contentOffset++] + 1;
				}
				else if (b == 15) {
					if (contentOffset >= contentLength)
						return false;
					count = distance = content[contentOffset++] + 1;
				}
				else if (b >= 2)
					count = distance = b;
				else if (b == 1)
					count = distance = 256;
				else
					return contentOffset == contentLength && unpackedOffset == 16000;
				if (unpackedOffset + count > 16000)
					count = 16000 - unpackedOffset;
				if (!RECOIL.copyPrevious(unpacked, unpackedOffset, distance, count))
					return false;
				unpackedOffset += count;
			}
		}
		return false;
	}

	#setAmstradFirmwarePalette(content, contentOffset, count)
	{
		for (let i = 0; i < count; i++) {
			let c = content[contentOffset + i];
			if (c > 26) {
				this.contentPalette.fill(0, i, i + count - i);
				for (; i < count; i++) {
					if (content[contentOffset + i] != 255)
						return false;
				}
				break;
			}
			this.contentPalette[i] = RECOIL.#SET_AMSTRAD_FIRMWARE_PALETTE_TRI_LEVEL[(c / 3 | 0) % 3] << 16 | RECOIL.#SET_AMSTRAD_FIRMWARE_PALETTE_TRI_LEVEL[c / 9 | 0] << 8 | RECOIL.#SET_AMSTRAD_FIRMWARE_PALETTE_TRI_LEVEL[c % 3];
		}
		return true;
	}

	static #getAmstradMode0Index(x, b)
	{
		if ((x & 2) == 0)
			b >>= 1;
		return ((b & 1) << 3) + (b >> 2 & 4) + (b >> 1 & 2) + (b >> 6 & 1);
	}

	#decodeAmstradMode0Line(content, lineOffset, y, skip = 0)
	{
		for (let x = 0; x < this.#width; x++) {
			let i = x + skip;
			let b = i >= this.#width ? 0 : content[lineOffset + (i >> 2)];
			this.#pixels[y * this.#width + x] = this.contentPalette[RECOIL.#getAmstradMode0Index(i, b)];
		}
	}

	static #getAmstradMode1Index(x, b)
	{
		b >>= ~x & 3;
		return ((b & 1) << 1) + (b >> 4 & 1);
	}

	#decodeAmstradMode1Line(content, lineOffset, y)
	{
		for (let x = 0; x < this.#width; x++)
			this.#pixels[y * this.#width + x] = this.contentPalette[RECOIL.#getAmstradMode1Index(x, content[lineOffset + (x >> 2)])];
	}

	#decodeAmstradScr(filename, content, contentLength)
	{
		const unpacked = new Uint8Array(16384);
		let contentOffset = RECOIL.#getAmstradHeader(content, contentLength);
		let width = 320;
		let height = 200;
		let overscan = false;
		let mode;
		switch (contentLength - contentOffset) {
		case 15872:
			width = 256;
			height = 192;
			break;
		case 16336:
		case 16384:
			break;
		case 31936:
			width = 384;
			height = 272;
			overscan = true;
			break;
		default:
			if (RECOIL.isStringAt(content, contentOffset, "PKSL") && RECOIL.#unpackConvImgCpc(content, contentOffset + 21, contentLength, unpacked)) {
				mode = content[contentOffset + 4];
				if (mode > 1 || !this.#setAmstradFirmwarePalette(content, contentOffset + 5, mode == 0 ? 16 : 4))
					return false;
				this.#setSize(320, 200, mode == 0 ? RECOILResolution.AMSTRAD2X1 : RECOILResolution.AMSTRAD1X1);
				for (let y = 0; y < 200; y++) {
					for (let x = 0; x < 320; x++) {
						let b = unpacked[(x >> 2) * 200 + y];
						this.#pixels[y * 320 + x] = this.contentPalette[mode == 0 ? RECOIL.#getAmstradMode0Index(x, b) : RECOIL.#getAmstradMode1Index(x, b)];
					}
				}
				return true;
			}
			if (!AmstradStream.unpackFile(content, contentOffset, contentLength, unpacked, 16384))
				return false;
			content = unpacked;
			contentOffset = 0;
			break;
		}
		mode = this.#setAmstradPalette(filename);
		if (mode < 0) {
			let paletteOffset = contentOffset + (width == 384 ? 1536 : 6096);
			mode = content[paletteOffset];
			if (mode > 4 || !this.#setAmstradFirmwarePalette(content, paletteOffset + 1, 1 << (4 >> mode % 3)))
				return false;
		}
		switch (mode) {
		case 0:
			this.#setSize(width, height, RECOILResolution.AMSTRAD2X1);
			for (let y = 0; y < height; y++)
				this.#decodeAmstradMode0Line(content, contentOffset + RECOIL.#getAmstradLineOffset(y, width >> 2, overscan), y);
			return true;
		case 1:
			this.#setSize(width, height, RECOILResolution.AMSTRAD1X1);
			for (let y = 0; y < height; y++)
				this.#decodeAmstradMode1Line(content, contentOffset + RECOIL.#getAmstradLineOffset(y, width >> 2, overscan), y);
			return true;
		case 2:
			return this.#decodeAmstradMode2(content, contentOffset, width << 1, height, overscan);
		case 3:
			this.#setSize(width, height, RECOILResolution.AMSTRAD1X1);
			for (let y = 0; y < height; y += 2) {
				let lineOffset = contentOffset + RECOIL.#getAmstradLineOffset(y, width >> 2, overscan);
				this.#decodeAmstradMode1Line(content, lineOffset, y);
				this.#decodeAmstradMode0Line(content, lineOffset + 2048, y + 1);
			}
			return true;
		case 4:
			if (width != 320)
				return false;
			let yEgx = content[contentOffset + 14309] - 141;
			if (yEgx >> 1 != 0)
				return false;
			this.#setSize(640, 400, RECOILResolution.AMSTRAD1X2);
			for (let y = 0; y < 200; y++) {
				let lineOffset = contentOffset + RECOIL.#getAmstradLineOffset(y, 80, false);
				if (((y ^ yEgx) & 1) == 0)
					this.#decodeAmstradMode2Line(content, lineOffset, y);
				else {
					for (let x = 0; x < 320; x++) {
						let offset = y * 1280 + (x << 1);
						let b = content[lineOffset + (x >> 2)];
						this.#pixels[offset + 641] = this.#pixels[offset + 640] = this.#pixels[offset + 1] = this.#pixels[offset] = this.contentPalette[RECOIL.#getAmstradMode1Index(x, b)];
					}
				}
			}
			return true;
		default:
			return false;
		}
	}

	#decodeWin(filename, content, contentLength)
	{
		if (contentLength < 6)
			return false;
		let width = content[contentLength - 4] | content[contentLength - 3] << 8;
		if (width == 0 || width > 640)
			return false;
		let height = content[contentLength - 2];
		if (height == 0 || height > 200)
			return false;
		let bytesPerLine = (width + 7) >> 3;
		const unpacked = new Uint8Array(16000);
		let contentOffset = RECOIL.#getAmstradHeader(content, contentLength);
		if (contentLength != contentOffset + bytesPerLine * height + 5) {
			if (!AmstradStream.unpackFile(content, contentOffset, contentLength, unpacked, bytesPerLine * height))
				return false;
			content = unpacked;
			contentOffset = 0;
		}
		if (this.#setAmstradPalette(filename) != 0)
			return false;
		width >>= 1;
		this.#setSize(width, height, RECOILResolution.AMSTRAD2X1);
		for (let y = 0; y < height; y++)
			this.#decodeAmstradMode0Line(content, contentOffset + y * bytesPerLine, y);
		return true;
	}

	#decodeCm5(filename, content, contentLength)
	{
		if (contentLength != 2049)
			return false;
		const gfx = new Uint8Array(18433);
		if (this.#readCompanionFile(filename, "GFX", "gfx", gfx, 18433) != 18432)
			return false;
		this.#setSize(288, 256, RECOILResolution.AMSTRAD1X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 288; x++) {
				let c;
				switch (gfx[y * 72 + (x >> 2)] >> (~x & 3) & 17) {
				case 0:
					c = 3 + (y << 3) + (x / 48 | 0);
					break;
				case 1:
					c = 1 + (y << 3);
					break;
				case 16:
					c = 2 + (y << 3);
					break;
				default:
					c = 0;
					break;
				}
				c = content[c];
				if (c < 64 || c > 95)
					return false;
				this.#pixels[y * 288 + x] = RECOIL.#AMSTRAD_PALETTE[c - 64];
			}
		}
		return true;
	}

	#decodeSgx(content, contentLength)
	{
		let width = 0;
		let height = 0;
		let chunkLeft = 0;
		let rowHeight = 0;
		for (let contentOffset = 0; contentOffset + 3 < contentLength;) {
			let chunkStride = content[contentOffset];
			if (chunkStride == 0)
				break;
			if (chunkStride == 255) {
				if (width == 0)
					width = chunkLeft;
				else if (chunkLeft != width)
					return false;
				chunkLeft = 0;
				contentOffset += 3;
			}
			else {
				let chunkWidth;
				let chunkHeight;
				if (chunkStride <= 63) {
					chunkWidth = content[contentOffset + 1];
					if ((chunkWidth + 3) >> 2 != chunkStride)
						return false;
					chunkHeight = content[contentOffset + 2];
					contentOffset += 3;
				}
				else if (chunkStride == 64) {
					if (contentOffset + 8 >= contentLength || content[contentOffset + 1] != 5)
						return false;
					chunkStride = content[contentOffset + 2] | content[contentOffset + 3] << 8;
					chunkWidth = content[contentOffset + 4] | content[contentOffset + 5] << 8;
					if ((chunkWidth + 1) >> 1 != chunkStride)
						return false;
					chunkHeight = content[contentOffset + 6] | content[contentOffset + 7] << 8;
					contentOffset += 8;
				}
				else
					return false;
				if (chunkLeft == 0)
					height += rowHeight = chunkHeight;
				else if (chunkHeight != rowHeight)
					return false;
				chunkLeft += chunkWidth;
				contentOffset += chunkHeight * chunkStride;
				if (contentOffset > contentLength)
					return false;
			}
		}
		if (width == 0)
			width = chunkLeft;
		else if (chunkLeft != width)
			return false;
		if (!this.#setSize(width, height, RECOILResolution.AMSTRAD1X1))
			return false;
		chunkLeft = 0;
		let chunkTop = 0;
		rowHeight = 0;
		for (let contentOffset = 0; contentOffset + 3 < contentLength;) {
			let chunkStride = content[contentOffset];
			if (chunkStride == 0)
				break;
			if (chunkStride == 255) {
				chunkLeft = 0;
				chunkTop += rowHeight;
				contentOffset += 3;
			}
			else {
				let chunkWidth;
				if (chunkStride <= 63) {
					chunkWidth = content[contentOffset + 1];
					rowHeight = content[contentOffset + 2];
					contentOffset += 3;
					for (let y = 0; y < rowHeight; y++) {
						for (let x = 0; x < chunkWidth; x++) {
							let b = content[contentOffset + (x >> 2)] >> (~x & 3);
							this.#pixels[(chunkTop + y) * width + chunkLeft + x] = RECOIL.#DECODE_SGX_PALETTE4[(b >> 3 & 2) + (b & 1)];
						}
						contentOffset += chunkStride;
					}
				}
				else {
					chunkStride = content[contentOffset + 2] | content[contentOffset + 3] << 8;
					chunkWidth = content[contentOffset + 4] | content[contentOffset + 5] << 8;
					rowHeight = content[contentOffset + 6] | content[contentOffset + 7] << 8;
					contentOffset += 8;
					for (let y = 0; y < rowHeight; y++) {
						for (let x = 0; x < chunkWidth; x++) {
							let c = RECOIL.getNibble(content, contentOffset, x);
							this.#pixels[(chunkTop + y) * width + chunkLeft + x] = RECOIL.#DECODE_SGX_PALETTE16[c];
						}
						contentOffset += chunkStride;
					}
				}
				chunkLeft += chunkWidth;
			}
		}
		return true;
	}

	#setAmstradFirmwarePalette16(content)
	{
		return content[5] == 1 && this.#setAmstradFirmwarePalette(content, 6, 16);
	}

	#decodePphFrame(filename, upperExt, lowerExt, bitmap, pph, frame)
	{
		let bitmapStride = this.#width >> 2;
		let bitmapLength = this.#height * bitmapStride;
		if (this.#readCompanionFile(filename, upperExt, lowerExt, bitmap, bitmapLength + 1) != bitmapLength)
			return false;
		let yOffset = frame * this.#height;
		switch (pph[0]) {
		case 3:
			for (let y = 0; y < this.#height; y++)
				this.#decodeAmstradMode0Line(bitmap, y * bitmapStride, yOffset + y, (y ^ frame) & 1);
			break;
		case 4:
			for (let y = 0; y < this.#height; y++)
				this.#decodeAmstradMode0Line(bitmap, y * bitmapStride, yOffset + y);
			break;
		case 5:
			let paletteOffset = 6;
			let paletteLines = 0;
			for (let y = 0; y < this.#height; y++) {
				if (paletteLines == 0) {
					if (!this.#setAmstradFirmwarePalette(pph, paletteOffset, 4))
						return false;
					paletteOffset += 4;
					if (paletteOffset < (1 + pph[5]) * 5) {
						paletteLines = pph[paletteOffset++];
						if (paletteLines == 0)
							return false;
					}
					else
						paletteLines = 272;
				}
				this.#decodeAmstradMode1Line(bitmap, y * bitmapStride, yOffset + y);
				paletteLines--;
			}
			break;
		default:
			throw new Error();
		}
		return true;
	}

	#decodePph(filename, content, contentLength)
	{
		if (contentLength < 10)
			return false;
		let resolution;
		switch (content[0]) {
		case 3:
			if (contentLength != 22 || !this.#setAmstradFirmwarePalette16(content))
				return false;
			resolution = RECOILResolution.AMSTRAD1X1;
			break;
		case 4:
			if (contentLength != 22 || !this.#setAmstradFirmwarePalette16(content))
				return false;
			resolution = RECOILResolution.AMSTRAD2X1;
			break;
		case 5:
			if (contentLength != (1 + content[5]) * 5)
				return false;
			resolution = RECOILResolution.AMSTRAD1X1;
			break;
		default:
			return false;
		}
		let width = content[1] | content[2] << 8;
		if (width == 0 || width > 384 || (width & 3) != 0)
			return false;
		let height = content[3] | content[4] << 8;
		if (height == 0 || height > 272)
			return false;
		this.#setSize(width, height, resolution, 2);
		const bitmap = new Uint8Array(26113);
		return this.#decodePphFrame(filename, "ODD", "odd", bitmap, content, 0) && this.#decodePphFrame(filename, "EVE", "eve", bitmap, content, 1) && this.#applyBlend();
	}

	#decodeZx81(screen)
	{
		this.#setSize(256, 192, RECOILResolution.ZX811X1);
		let font = Fu.zx81_fnt;
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let c = screen[y >> 3 << 5 | x >> 3];
				let b = font[(c & 63) << 3 | (y & 7)] >> (~x & 7) & 1;
				this.#pixels[(y << 8) + x] = b == c >> 7 ? 16777215 : 0;
			}
		}
		return true;
	}

	#decodeZx81Raw(content, contentLength)
	{
		if (contentLength != 792)
			return false;
		const screen = new Uint8Array(768);
		for (let y = 0; y < 24; y++) {
			if (content[y * 33 + 32] != 118)
				return false;
			screen.set(content.subarray(y * 33, y * 33 + 32), y * 32);
		}
		return this.#decodeZx81(screen);
	}

	#decodeZp1(content, contentLength)
	{
		const screen = new Uint8Array(768);
		const s = Object.assign(new Stream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (let i = 0; i < 768; i++) {
			let b = s.readHexByte();
			if (b < 0)
				return false;
			screen[i] = b;
		}
		return this.#decodeZx81(screen);
	}

	#decodeP(content, contentLength)
	{
		const interp = Object.assign(new PInterpreter(), { content: content, contentLength: contentLength });
		return interp.run() && this.#decodeZx81(interp.screen);
	}

	static #getZxPaletteColor(c)
	{
		return (c >> 1 & 1) * 16711680 | (c >> 2 & 1) * 65280 | (c & 1) * 255;
	}

	#setZxPalette()
	{
		for (let i = 0; i < 64; i++) {
			let rgb = RECOIL.#getZxPaletteColor(i);
			if ((i & 16) == 0)
				rgb &= 13487565;
			this.contentPalette[i] = rgb;
		}
	}

	#setZxSize(width, height, resolution, frames = 1)
	{
		if (!this.#setSize(width, height, resolution, frames))
			return false;
		this.#setZxPalette();
		return true;
	}

	#setZx(resolution, frames = 1)
	{
		this.#setZxSize(256, 192, resolution, frames);
	}

	static #getG3R3B2Color(c)
	{
		return (c & 28) * 73 >> 3 << 16 | (c >> 5) * 73 >> 1 << 8 | (c & 3) * 85;
	}

	#setUlaPlus(resolution, content, paletteOffset, colors)
	{
		this.#setSize(256, 192, resolution);
		for (let i = 0; i < colors; i++)
			this.contentPalette[i] = RECOIL.#getG3R3B2Color(content[paletteOffset + i]);
	}

	static #getZxIndex(c, a)
	{
		return (a >> 2 & 48) | ((c & 1) == 0 ? 8 | (a >> 3 & 7) : a & 7);
	}

	static #getZxLineOffset(y)
	{
		return ((y & 192) << 5) + ((y & 7) << 8) + ((y & 56) << 2);
	}

	#decodeZx(content, bitmapOffset, attributesOffset, attributesMode, pixelsOffset)
	{
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let col = x >> 3;
				let c;
				switch (bitmapOffset) {
				case -3:
					c = x ^ y;
					break;
				case -2:
					c = content[84 + (y & 7)] >> (~x & 7);
					break;
				case -1:
					c = content[y << 5 | col] >> (~x & 7);
					break;
				default:
					c = content[bitmapOffset + RECOIL.#getZxLineOffset(y) + col] >> (~x & 7);
					break;
				}
				if (attributesMode == -3) {
					c &= 1;
					if (c != 0)
						c = 16777215;
				}
				else {
					let a;
					switch (attributesMode) {
					case -2:
						if (col < 8)
							a = attributesOffset + (y >> 3 << 4);
						else if (col < 24)
							a = (attributesOffset == 18688 ? 12536 : 15608) + (y << 4);
						else
							a = attributesOffset + (y >> 3 << 4) - 16;
						break;
					case -1:
						a = attributesOffset + RECOIL.#getZxLineOffset(y);
						break;
					default:
						a = attributesOffset + (y >> attributesMode << 5);
						break;
					}
					a = content[a + col];
					c = this.contentPalette[RECOIL.#getZxIndex(c, a)];
				}
				this.#pixels[pixelsOffset + (y << 8) + x] = c;
			}
		}
	}

	#decodeTimexHires(content, contentOffset, pixelsOffset)
	{
		let inkColor = RECOIL.#getZxPaletteColor(content[contentOffset + 12288] >> 3);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 512; x++) {
				let c = content[contentOffset + (x & 8) * 768 + RECOIL.#getZxLineOffset(y) + (x >> 4)] >> (~x & 7) & 1;
				let offset = pixelsOffset + (y << 10) + x;
				this.#pixels[offset + 512] = this.#pixels[offset] = c == 0 ? inkColor ^ 16777215 : inkColor;
			}
		}
	}

	#decodeHrg(content, contentLength)
	{
		if (contentLength != 24578)
			return false;
		this.#setSize(512, 384, RECOILResolution.TIMEX1X2, 2);
		this.#decodeTimexHires(content, 0, 0);
		this.#decodeTimexHires(content, 12289, 196608);
		return this.#applyBlend();
	}

	#decodeZxIfl(content, contentLength)
	{
		if (contentLength != 9216)
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1);
		this.#decodeZx(content, 0, 6144, 1, 0);
		return true;
	}

	#decodeMcMlt(content, contentLength, bitmapOffset)
	{
		if (contentLength != 12288)
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1);
		this.#decodeZx(content, bitmapOffset, 6144, 0, 0);
		return true;
	}

	#decodeThc(content, contentLength)
	{
		if (contentLength != 12288)
			return false;
		this.#setZx(RECOILResolution.TIMEX1X1);
		this.#decodeZx(content, 0, 6144, -1, 0);
		return true;
	}

	#decodeThr(content, contentLength)
	{
		if (contentLength != 12289)
			return false;
		this.#setSize(512, 384, RECOILResolution.TIMEX1X2);
		this.#decodeTimexHires(content, 0, 0);
		return true;
	}

	#decodeTcu(content, contentLength)
	{
		if (contentLength != 12352)
			return false;
		this.#setUlaPlus(RECOILResolution.SPECTRUM_ULA_PLUS1X1, content, 12288, 64);
		this.#decodeZx(content, 0, 6144, -1, 0);
		return true;
	}

	#decodeGsc(content, contentLength)
	{
		let contentOffset;
		switch (contentLength) {
		case 13824:
			contentOffset = 0;
			break;
		case 13952:
			contentOffset = 128;
			break;
		default:
			return false;
		}
		this.#setZx(RECOILResolution.SPECTRUM1X1, 2);
		this.#decodeZx(content, contentOffset, contentOffset + 6144, 3, 0);
		this.#decodeZx(content, contentOffset + 6912, contentOffset + 13056, 3, 49152);
		return this.#applyBlend();
	}

	#decodeMg(content, contentLength)
	{
		if (contentLength < 14080 || content[0] != 77 || content[1] != 71 || content[2] != 72 || content[3] != 1)
			return false;
		let attributesMode;
		switch (content[4]) {
		case 1:
			if (contentLength != 19456)
				return false;
			this.#setZx(RECOILResolution.SPECTRUM1X1, 2);
			this.#decodeZx(content, 256, 18688, -2, 0);
			this.#decodeZx(content, 6400, 19072, -2, 49152);
			return this.#applyBlend();
		case 2:
			attributesMode = 1;
			break;
		case 4:
			attributesMode = 2;
			break;
		case 8:
			attributesMode = 3;
			break;
		default:
			return false;
		}
		if (contentLength != 12544 + (12288 >> attributesMode))
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1, 2);
		this.#decodeZx(content, 256, 12544, attributesMode, 0);
		this.#decodeZx(content, 6400, 12544 + (6144 >> attributesMode), attributesMode, 49152);
		return this.#applyBlend();
	}

	#decodeAtr(content, contentLength)
	{
		if (contentLength != 768)
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1);
		this.#decodeZx(content, -3, 0, 3, 0);
		return true;
	}

	#decodeHlr(content, contentLength)
	{
		if (contentLength != 1628 || content[0] != 118 || content[1] != 175 || content[2] != 211 || content[3] != 254 || content[4] != 33 || content[5] != 0 || content[6] != 88)
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1, 2);
		this.#decodeZx(content, -2, 92, 3, 0);
		this.#decodeZx(content, -2, 860, 3, 49152);
		return this.#applyBlend();
	}

	#decodeStl(content, contentLength)
	{
		if (contentLength != 3072)
			return false;
		this.#setSize(256, 192, RECOILResolution.SPECTRUM4X4, 2);
		for (let f = 0; f < 2; f++) {
			for (let y = 0; y < 192; y++) {
				for (let x = 0; x < 256; x++) {
					let b = content[(y & ~3) << 4 | (x >> 2 & ~3) | f << 1 | (x >> 3 & 1)];
					let rgb = RECOIL.#getZxPaletteColor((x & 4) == 0 ? b >> 3 : b);
					if ((b & 64) == 0)
						rgb &= 13487565;
					this.#pixels[((f * 192 + y) << 8) + x] = rgb;
				}
			}
		}
		return this.#applyBlend();
	}

	#decodeZxRgb3(content, contentLength, frameComponents)
	{
		if (contentLength != 18432)
			return false;
		this.#setSize(256, 192, RECOILResolution.SPECTRUM1X1);
		this.#frames = 3;
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let offset = RECOIL.#getZxLineOffset(y) + (x >> 3);
				let c = 0;
				for (let frame = 0; frame < 3; frame++) {
					if ((content[frame * 6144 + offset] >> (~x & 7) & 1) != 0)
						c |= 255 << frameComponents[frame];
				}
				this.#pixels[(y << 8) + x] = c;
			}
		}
		return true;
	}

	#decodeZxRgb(content, contentLength)
	{
		return this.#decodeZxRgb3(content, contentLength, RECOIL.#DECODE_ZX_RGB_FRAME_COMPONENTS);
	}

	#decode3(content, contentLength)
	{
		return this.#decodeZxRgb3(content, contentLength, RECOIL.#DECODE3_FRAME_COMPONENTS);
	}

	#decodeZxs(content, contentLength)
	{
		if (contentLength != 2452 || !RECOIL.isStringAt(content, 0, "ZX_SSCII") || content[8] != 148 || content[9] != 9 || content[10] != 0 || content[11] != 0)
			return false;
		this.#setZx(RECOILResolution.SPECTRUM1X1);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let offset = (x & ~7) * 3 + (y >> 3);
				let c = content[908 + offset];
				if (c >= 112)
					return false;
				c = content[12 + (c << 3) + (y & 7)] >> (~x & 7);
				this.#pixels[(y << 8) + x] = this.contentPalette[RECOIL.#getZxIndex(c, content[1676 + offset])];
			}
		}
		return true;
	}

	#decodeSev(content, contentLength)
	{
		if (contentLength < 23 || content[0] != 83 || content[1] != 101 || content[2] != 118 || content[3] != 0 || content[6] != 1 || content[7] != 0)
			return false;
		let width = content[10] | content[11] << 8;
		let height = content[12] | content[13] << 8;
		let columns = (width + 7) >> 3;
		let rows = (height + 7) >> 3;
		if (contentLength < 14 + rows * columns * 9 || !this.#setZxSize(width, height, RECOILResolution.SPECTRUM1X1))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let offset = 14 + ((y >> 3) * columns + (x >> 3)) * 9;
				let c = content[offset + (y & 7)] >> (~x & 7);
				this.#pixels[y * width + x] = this.contentPalette[RECOIL.#getZxIndex(c, content[offset + 8])];
			}
		}
		return true;
	}

	#decodeCh8(content, contentLength)
	{
		if ((contentLength & 7) != 0 || !this.#setSize(256, (contentLength + 248) >> 8 << 3, RECOILResolution.SPECTRUM1X1))
			return false;
		this.#decodeBlackAndWhiteFont(content, 0, contentLength, 8);
		return true;
	}

	static #getChxTileOffset(content, tile)
	{
		return content[5 + (tile << 1)] | content[6 + (tile << 1)] << 8;
	}

	#decodeChx(content, contentLength)
	{
		if (contentLength < 517 || content[0] != 67 || content[1] != 72 || content[2] != 88 || content[3] != 0 || content[4] != 0)
			return false;
		let maxColumns = 0;
		let maxRows = 0;
		for (let tile = 0; tile < 256; tile++) {
			let offset = RECOIL.#getChxTileOffset(content, tile);
			if (offset == 0)
				continue;
			if (offset + 2 >= contentLength)
				return false;
			let transparent = content[offset];
			if (transparent > 1)
				return false;
			let columns = content[offset + 1];
			let rows = content[offset + 2];
			if (offset + 3 + rows * columns * (9 - transparent) > contentLength)
				return false;
			if (maxColumns < columns)
				maxColumns = columns;
			if (maxRows < rows)
				maxRows = rows;
		}
		let width = maxColumns << 7;
		let height = maxRows << 7;
		if (!this.#setZxSize(width, height, RECOILResolution.SPECTRUM1X1))
			return false;
		for (let y = 0; y < height; y++) {
			let row = y >> 3;
			let rowTile = (row / maxRows | 0) << 4;
			row %= maxRows;
			for (let x = 0; x < width; x++) {
				let column = x >> 3;
				let tile = rowTile + (column / maxColumns | 0);
				column %= maxColumns;
				let c = ~x ^ y;
				let a = 56;
				let offset = RECOIL.#getChxTileOffset(content, tile);
				if (offset > 0) {
					let columns = content[offset + 1];
					if (column < columns && row < content[offset + 2]) {
						let transparent = content[offset];
						offset += 3 + (row * columns + column) * (9 - transparent);
						c = content[offset + (y & 7)] >> (~x & 7);
						if (transparent == 0)
							a = content[offset + 8];
					}
				}
				this.#pixels[y * width + x] = this.contentPalette[RECOIL.#getZxIndex(c, a)];
			}
		}
		return true;
	}

	#decodeZxp(content, contentLength)
	{
		if (contentLength < 25 || !RECOIL.isStringAt(content, 0, "ZX-Paintbrush "))
			return false;
		const s = Object.assign(new ZxpStream(), { content: content, contentOffset: RECOIL.isStringAt(content, 14, "extended ") ? 23 : 14, contentLength: contentLength });
		if (!s.expect("image") || s.readChar() != 10 || s.readChar() != 10)
			return false;
		let bitmapOffset = s.contentOffset;
		let width = 0;
		let height = 0;
		for (let x = 0;;) {
			switch (s.readChar()) {
			case 42:
			case 48:
			case 49:
				x++;
				continue;
			case 10:
				break;
			default:
				return false;
			}
			if (x == 0)
				break;
			if (height == 0)
				width = x;
			else if (x != width)
				return false;
			height++;
			x = 0;
		}
		let attributesOffset = s.contentOffset;
		let attributesHeight = 0;
		let resolution = RECOILResolution.SPECTRUM1X1;
		this.#setZxPalette();
		while (!s.isEof()) {
			let b = content[s.contentOffset];
			if (b == 13 || b == 10) {
				for (let i = 0; i < 64; i++) {
					if (s.readChar() != (i == 0 ? 10 : 32))
						return false;
					b = s.readHexByte();
					if (b < 0)
						return false;
					this.contentPalette[i] = RECOIL.#getG3R3B2Color(b);
				}
				if (s.readChar() != 10 || !s.isEof())
					return false;
				resolution = RECOILResolution.SPECTRUM_ULA_PLUS1X1;
				break;
			}
			if (s.readHexByte() < 0)
				return false;
			switch (s.readChar()) {
			case 32:
				break;
			case 10:
				attributesHeight++;
				break;
			default:
				return false;
			}
		}
		if ((attributesHeight != height && attributesHeight != (height + 7) >> 3) || !this.#setSize(width, height, resolution))
			return false;
		s.contentOffset = attributesOffset;
		for (let y = 0; y < height; y++) {
			if (attributesHeight != height) {
				if ((y & 7) == 0)
					attributesOffset = s.contentOffset;
				else
					s.contentOffset = attributesOffset;
			}
			let a = 0;
			for (let x = 0; x < width; x++) {
				if ((x & 7) == 0) {
					if (x > 0 && s.readChar() != 32)
						return false;
					a = s.readHexByte();
				}
				this.#pixels[y * width + x] = this.contentPalette[(a >> 2 & 48) | (content[bitmapOffset++] != 49 ? 8 | (a >> 3 & 7) : a & 7)];
			}
			if (content[bitmapOffset] == 13)
				bitmapOffset++;
			if (content[bitmapOffset++] != 10 || s.readChar() != 10)
				return false;
		}
		return true;
	}

	#decodeBsc(content, contentLength)
	{
		let borderOffset;
		switch (contentLength) {
		case 11136:
			borderOffset = 6912;
			break;
		case 11904:
			borderOffset = 7680;
			break;
		default:
			return false;
		}
		this.#setSize(384, 304, RECOILResolution.SPECTRUM1X1);
		for (let y = 0; y < 304; y++) {
			let c = 0;
			for (let x = 0; x < 384; x++) {
				if (y >= 64 && y < 256 && x >= 64 && x < 320) {
					let bY = y - 64;
					let col = (x >> 3) - 8;
					let a = 6144 + (bY >> 3 << 5) + col;
					if (contentLength == 11904 && (bY & 4) != 0)
						a += 768;
					c = a = content[a];
					if ((content[RECOIL.#getZxLineOffset(bY) + col] >> (~x & 7) & 1) == 0)
						c >>= 3;
					c = RECOIL.#getZxPaletteColor(c);
					if ((a & 64) == 0)
						c &= 13487565;
				}
				else if ((x & 7) == 0) {
					c = content[borderOffset];
					if ((x & 8) != 0) {
						borderOffset++;
						c >>= 3;
					}
					c = RECOIL.#getZxPaletteColor(c) & 13487565;
				}
				this.#pixels[y * 384 + x] = c;
			}
		}
		return true;
	}

	#decodeChrd(content, contentLength)
	{
		if (contentLength < 15 || !RECOIL.isStringAt(content, 0, "chr$"))
			return false;
		let columns = content[4];
		let rows = content[5];
		let bytesPerCell = content[6];
		let cells = rows * columns;
		let frames;
		switch (bytesPerCell) {
		case 9:
			frames = 1;
			break;
		case 18:
			frames = 2;
			break;
		default:
			return false;
		}
		if (contentLength != 7 + cells * bytesPerCell || !this.#setSize(columns << 3, rows << 3, RECOILResolution.SPECTRUM1X1, frames))
			return false;
		let contentOffset = 7;
		for (let row = 0; row < rows; row++) {
			for (let column = 0; column < columns; column++) {
				for (let frame = 0; frame < frames; frame++) {
					let a = content[contentOffset + 8];
					for (let y = 0; y < 8; y++) {
						for (let x = 0; x < 8; x++) {
							let c = content[contentOffset + y] >> (7 - x) & 1;
							c = RECOIL.#getZxPaletteColor(c == 0 ? a >> 3 : a);
							if ((a & 64) == 0)
								c &= 13487565;
							this.#pixels[(((((frame * rows + row) << 3) + y) * columns + column) << 3) + x] = c;
						}
					}
					contentOffset += 9;
				}
			}
		}
		if (frames == 2)
			this.#applyBlend();
		return true;
	}

	static #getBspBitmapPixel(content, bitmapOffset, x, y)
	{
		let col = x >> 3;
		let a = content[bitmapOffset + 6144 + (y >> 3 << 5) + col];
		let c = a;
		if ((content[bitmapOffset + RECOIL.#getZxLineOffset(y) + col] >> (~x & 7) & 1) == 0)
			c >>= 3;
		c = RECOIL.#getZxPaletteColor(c);
		if ((a & 64) == 0)
			c &= 13487565;
		return c;
	}

	#decodeBspFrame(pixelsOffset, content, contentLength, bitmapOffset, borderOffset)
	{
		for (let y = 0; y < this.#height; y++) {
			let c = 0;
			let b = 1;
			for (let x = 0; x < this.#width; x++) {
				if (borderOffset < 0)
					c = RECOIL.#getBspBitmapPixel(content, bitmapOffset, x, y);
				else if (x >= 64 && x < 320 && y >= 64 && y < 256) {
					c = RECOIL.#getBspBitmapPixel(content, bitmapOffset, x - 64, y - 64);
					b = 1;
				}
				else if (b > 0) {
					if (--b == 0) {
						if (borderOffset >= contentLength)
							return false;
						b = content[borderOffset++];
						c = RECOIL.#getZxPaletteColor(b) & 13487565;
						b >>= 3;
						switch (b) {
						case 0:
							break;
						case 1:
							if (borderOffset >= contentLength)
								return false;
							b = content[borderOffset++];
							break;
						case 2:
							b = 12;
							break;
						default:
							b += 13;
							break;
						}
						b <<= 1;
					}
				}
				this.#pixels[pixelsOffset + y * this.#width + x] = c;
			}
		}
		return true;
	}

	#decodeBsp(content, contentLength)
	{
		if (contentLength < 6982)
			return false;
		if ((content[3] & 64) == 0) {
			if (content[3] < 128) {
				this.#setSize(256, 192, RECOILResolution.SPECTRUM1X1);
				return this.#decodeBspFrame(0, content, contentLength, 70, -1);
			}
			return contentLength == 13894 && this.#setSize(256, 192, RECOILResolution.SPECTRUM1X1, 2) && this.#decodeBspFrame(0, content, contentLength, 70, -1) && this.#decodeBspFrame(49152, content, contentLength, 6982, -1) && this.#applyBlend();
		}
		if (content[3] < 128) {
			this.#setSize(384, 304, RECOILResolution.SPECTRUM1X1);
			return this.#decodeBspFrame(0, content, contentLength, 70, 6982);
		}
		this.#setSize(384, 304, RECOILResolution.SPECTRUM1X1, 2);
		return this.#decodeBspFrame(0, content, contentLength, 72, 13896) && this.#decodeBspFrame(116736, content, contentLength, 6984, content[70] | content[71] << 8) && this.#applyBlend();
	}

	#decodeRad(content, contentLength)
	{
		if (contentLength != 6160)
			return false;
		this.#setUlaPlus(RECOILResolution.ZX_UNO2X2, content, 6144, 16);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++)
				this.#pixels[(y << 8) + x] = this.contentPalette[RECOIL.getNibble(content, y >> 1 << 6, x >> 1)];
		}
		return true;
	}

	#decodeNxi(content, contentLength)
	{
		if (contentLength != 49664)
			return false;
		for (let i = 0; i < 256; i++) {
			let c = content[i << 1];
			this.contentPalette[i] = (c >> 5) * 73 >> 1 << 16 | (c >> 2 & 7) * 73 >> 1 << 8 | ((c & 3) << 1 | (content[(i << 1) + 1] & 1)) * 73 >> 1;
		}
		this.#setSize(256, 192, RECOILResolution.SPECTRUM_NEXT1X1);
		this.#decodeBytes(content, 512);
		return true;
	}

	#decodeProfiGrf(content, contentLength)
	{
		if (contentLength != 30848 || content[0] != 0 || content[1] != 2 || content[2] != 240 || content[3] != 0 || content[4] != 4 || content[5] != 0 || content[6] != 128 || content[7] != 0 || content[8] != 1 || content[9] != 19)
			return false;
		this.#setSize(512, 480, RECOILResolution.SPECTRUM_PROFI1X2);
		for (let c = 0; c < 16; c++)
			this.contentPalette[c] = RECOIL.#getG3R3B2Color(content[10 + c]);
		for (let y = 0; y < 480; y++) {
			for (let x = 0; x < 512; x++) {
				let offset = 128 + (y >> 1 << 7) + (x >> 3 << 1);
				let b = content[offset] >> (~x & 7) & 1;
				let a = content[offset + 1];
				this.#pixels[(y << 9) + x] = this.contentPalette[b == 0 ? (a >> 4 & 8) | (a >> 3 & 7) : (a >> 3 & 8) | (a & 7)];
			}
		}
		return true;
	}

	#decodeSxg(content, contentLength)
	{
		if (contentLength < 19 || content[0] != 127 || content[1] != 83 || content[2] != 88 || content[3] != 71 || content[6] != 0)
			return false;
		let width = content[8] | content[9] << 8;
		let height = content[10] | content[11] << 8;
		if (!this.#setSize(width, height, RECOILResolution.ZX_EVOLUTION1X1))
			return false;
		let paletteOffset = 14 + content[12] + (content[13] << 8);
		let bitmapOffset = 16 + content[14] + (content[15] << 8);
		let paletteLength = bitmapOffset - paletteOffset;
		if ((paletteLength & 1) != 0 || paletteLength > 512 || contentLength < paletteOffset + paletteLength)
			return false;
		this.contentPalette.fill(0);
		let colors = paletteLength >> 1;
		for (let i = 0; i < colors; i++) {
			let offset = paletteOffset + (i << 1);
			let c = content[offset] | content[offset + 1] << 8;
			if (c < 32768) {
				let r = c >> 10;
				let g = c >> 5 & 31;
				let b = c & 31;
				if (r > 24 || g > 24 || b > 24)
					return false;
				c = (r * 255 / 24 | 0) << 16 | (g * 255 / 24 | 0) << 8 | b * 255 / 24 | 0;
			}
			else
				c = RECOIL.#getR5G5B5Color(c);
			this.contentPalette[i] = c;
		}
		switch (content[7]) {
		case 1:
			width = (width + 1) >> 1;
			if (contentLength != bitmapOffset + width * height)
				return false;
			this.#decodeNibbles(content, bitmapOffset, width);
			return true;
		case 2:
			if (contentLength != bitmapOffset + width * height)
				return false;
			this.#decodeBytes(content, bitmapOffset);
			return true;
		default:
			return false;
		}
	}

	#decodeSkl(content, contentLength)
	{
		if (contentLength != 13825)
			return false;
		this.#setZxSize(256, 192, RECOILResolution.ELEMENT_ZX1X1);
		this.#decodeZx(content, 6912, 13056, 3, 0);
		let key = content[13824];
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let bitmapOffset = RECOIL.#getZxLineOffset(y) + (x >> 3);
				let attributesOffset = 6144 + (y >> 3 << 5) + (x >> 3);
				let c = content[6912 + bitmapOffset] >> (~x & 7);
				c = RECOIL.#getZxIndex(c, content[6912 + attributesOffset]);
				if ((c & 23) == key || ((c | key) & 7) == 0) {
					c = content[bitmapOffset] >> (~x & 7);
					c = RECOIL.#getZxIndex(c, content[attributesOffset]);
				}
				this.#pixels[(y << 8) + x] = this.contentPalette[c];
			}
		}
		return true;
	}

	#decodeHrcScreen(content, contentOffset, yOffset, key = -1)
	{
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 512; x++) {
				let bitmapOffset = contentOffset + (y << 6) + (x >> 3);
				let attributeOffset = contentOffset + 12288 + (y >> 2 << 6) + (x >> 3);
				let c = RECOIL.#getZxIndex(content[bitmapOffset] >> (~x & 7), content[attributeOffset]);
				if ((c & 23) == key || ((c | key) & 7) == 0)
					c = RECOIL.#getZxIndex(content[bitmapOffset - 15360] >> (~x & 7), content[attributeOffset - 15360]);
				this.#setScaledPixel(x, yOffset + y, this.contentPalette[c]);
			}
		}
	}

	#decodeHrc(content, contentLength)
	{
		if (contentLength != 15360)
			return false;
		this.#setZxSize(512, 384, RECOILResolution.ELEMENT_ZX1X2);
		this.#decodeHrcScreen(content, 0, 0);
		return true;
	}

	#decodeHkl(content, contentLength)
	{
		if (contentLength != 30721 || content[30720] > 15)
			return false;
		this.#setZxSize(512, 384, RECOILResolution.ELEMENT_ZX1X2);
		this.#decodeHrcScreen(content, 15360, 0, content[30720]);
		return true;
	}

	#decodeHgs(content, contentLength)
	{
		if (contentLength != 30720)
			return false;
		this.#setZxSize(512, 384, RECOILResolution.ELEMENT_ZX1X2, 2);
		this.#decodeHrcScreen(content, 0, 0);
		this.#decodeHrcScreen(content, 15360, 192);
		return this.#applyBlend();
	}

	#setElementZxPalette(content, paletteOffset, colors, c = 0)
	{
		for (; c < colors; c++)
			this.contentPalette[c] = RECOIL.#getB8G8R8Color(content, paletteOffset + c * 3);
	}

	#decodeHrxScreen(content, contentOffset, key)
	{
		this.#setSize(512, 384, RECOILResolution.ELEMENT_ZX1X2);
		this.#setElementZxPalette(content, contentOffset + 15360, 32);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 512; x++) {
				let attributeOffset = 12288 + (y >> 2 << 6) + (x >> 3);
				let bitmapOffset = (y << 6) + (x >> 3);
				let a = content[contentOffset + attributeOffset];
				let c = (content[contentOffset + bitmapOffset] >> (~x & 7) & 1) == 0 ? 16 + (a >> 4) : a & 15;
				if (c == key) {
					a = content[attributeOffset];
					c = (content[bitmapOffset] >> (~x & 7) & 1) == 0 ? 48 + (a >> 4) : 32 + (a & 15);
				}
				this.#setScaledPixel(x, y, this.contentPalette[c]);
			}
		}
	}

	#decodeHrx(content, contentLength)
	{
		if (contentLength != 15456)
			return false;
		this.#decodeHrxScreen(content, 0, -1);
		return true;
	}

	#decodeXkl(content, contentLength)
	{
		if (contentLength != 30913)
			return false;
		this.#setElementZxPalette(content, 15264, 64, 32);
		this.#decodeHrxScreen(content, 15456, content[30912]);
		return true;
	}

	#decodeHgfx(content, contentLength, width, ultra)
	{
		let bitplaneLength = width * 24 << ultra;
		let bitplanes = contentLength / bitplaneLength | 0;
		if (bitplanes < 1 || bitplanes > 8 >> ultra)
			return false;
		let paletteOffset = bitplanes * bitplaneLength;
		let colors = 1 << bitplanes;
		if (paletteOffset + colors * 3 != contentLength)
			return false;
		this.#setElementZxPalette(content, paletteOffset, colors);
		return this.#decodeAmigaPlanar(content, 0, width, 192 << ultra, width == 512 && ultra == 0 ? RECOILResolution.ELEMENT_ZX1X2 : RECOILResolution.ELEMENT_ZX1X1, bitplanes, this.contentPalette);
	}

	#decode546(content, contentLength)
	{
		if (contentLength != 98292 || !this.#setSize(720, 546, RECOILResolution.ELEMENT_ZX1X1))
			return false;
		this.#setElementZxPalette(content, 98280, 4);
		for (let i = 0; i < 393120; i++)
			this.#pixels[i] = this.contentPalette[content[i >> 2] >> ((~i & 3) << 1) & 3];
		return true;
	}

	#decodeElementZxHam(content, contentLength)
	{
		let width;
		switch (contentLength) {
		case 49344:
			width = 256;
			this.#setSize(256, 192, RECOILResolution.ELEMENT_ZX1X1);
			break;
		case 98496:
			width = 512;
			this.#setSize(512, 384, RECOILResolution.ELEMENT_ZX1X2);
			break;
		default:
			return false;
		}
		this.#setElementZxPalette(content, contentLength - 192, 64);
		for (let y = 0; y < 192; y++) {
			let rgb = this.contentPalette[0];
			for (let x = 0; x < width; x++) {
				let c = RECOIL.#getBitplanePixel(content, (y * width + x) >> 3, x, 8, width * 24);
				rgb = this.#decodeHamPixel(rgb, c, 6);
				this.#setScaledPixel(x, y, rgb);
			}
		}
		return true;
	}

	#setMsx1Palette()
	{
		this.contentPalette[0] = 2048;
		this.contentPalette[1] = 1024;
		this.contentPalette[2] = 3849027;
		this.contentPalette[3] = 7394167;
		this.contentPalette[4] = 5528023;
		this.contentPalette[5] = 8092648;
		this.contentPalette[6] = 11756363;
		this.contentPalette[7] = 6414311;
		this.contentPalette[8] = 13920851;
		this.contentPalette[9] = 16289399;
		this.contentPalette[10] = 13092697;
		this.contentPalette[11] = 14275713;
		this.contentPalette[12] = 3581243;
		this.contentPalette[13] = 11561902;
		this.contentPalette[14] = 13095109;
		this.contentPalette[15] = 16449528;
	}

	static #MSX2_DEFAULT_PALETTE = new Uint8Array([ 0, 0, 0, 0, 17, 6, 51, 7, 23, 1, 39, 3, 81, 1, 39, 6,
		113, 1, 115, 3, 97, 6, 100, 6, 17, 4, 101, 2, 85, 5, 119, 7 ]);

	static #getMsxHeader(content)
	{
		if (content[1] != 0 || content[2] != 0 || content[5] != 0 || content[6] != 0)
			return -1;
		return content[3] | content[4] << 8;
	}

	static #isMsxPalette(content, contentOffset)
	{
		let ored = 0;
		for (let i = 0; i < 16; i++) {
			let rb = content[contentOffset + (i << 1)];
			let g = content[contentOffset + (i << 1) + 1];
			if ((rb & 136) != 0 || (g & 248) != 0)
				return false;
			ored |= rb | g;
		}
		return ored != 0;
	}

	#setMsxPalette(content, contentOffset, colors)
	{
		for (let i = 0; i < colors; i++) {
			let rb = content[contentOffset + (i << 1)];
			let g = content[contentOffset + (i << 1) + 1];
			let rgb = (rb & 112) << 12 | (rb & 7) | (g & 7) << 8;
			this.contentPalette[i] = rgb << 5 | rgb << 2 | (rgb >> 1 & 197379);
		}
	}

	#setMsx2Palette(content, contentOffset, contentLength)
	{
		if (contentLength >= contentOffset + 32)
			this.#setMsxPalette(content, contentOffset, 16);
		else
			this.#setMsxPalette(RECOIL.#MSX2_DEFAULT_PALETTE, 0, 16);
	}

	#decodeSc2Sc4(content, contentOffset, resolution)
	{
		this.#setSize(256, 192, resolution);
		for (let y = 0; y < 192; y++) {
			let fontOffset = contentOffset + ((y & 192) << 5) + (y & 7);
			for (let x = 0; x < 256; x++) {
				let b = fontOffset + (content[contentOffset + 6144 + ((y & ~7) << 2) + (x >> 3)] << 3);
				let c = content[8192 + b];
				this.#pixels[(y << 8) + x] = this.contentPalette[(content[b] >> (~x & 7) & 1) == 0 ? c & 15 : c >> 4];
			}
		}
	}

	#decodeMsxSprites(content, mode, attributesOffset, patternsOffset)
	{
		let height = mode <= 4 ? 192 : 212;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < 256; x++) {
				let color = 0;
				let enableOr = false;
				let spritesPerLine = mode >= 4 ? 8 : 4;
				for (let sprite = 0; sprite < 32; sprite++) {
					let attributeOffset = attributesOffset + (sprite << 2);
					let spriteY = content[attributeOffset];
					if (spriteY == (mode >= 4 ? 216 : 208))
						break;
					let row = (y - spriteY - 1) & 255;
					if (row >= 16)
						continue;
					if (--spritesPerLine < 0)
						break;
					let c = content[mode >= 4 ? attributesOffset - 512 + (sprite << 4) + row : attributeOffset + 3];
					if (mode < 4 || (c & 64) == 0) {
						if (color != 0)
							break;
						enableOr = true;
					}
					else if (!enableOr)
						continue;
					let column = x - content[attributeOffset + 1];
					if (c >= 128)
						column += 32;
					if (column < 0 || column >= 16)
						continue;
					let pattern = patternsOffset + ((content[attributeOffset + 2] & 252) << 3) + row;
					if ((content[pattern + ((column & 8) << 1)] >> (~column & 7) & 1) == 0)
						continue;
					color |= c;
					if (mode >= 4)
						color |= 16;
				}
				if (color != 0) {
					let offset;
					switch (mode) {
					case 6:
						offset = (y << 10) + (x << 1);
						this.#pixels[offset + 512] = this.#pixels[offset] = this.contentPalette[color >> 2 & 3];
						this.#pixels[offset + 513] = this.#pixels[offset + 1] = this.contentPalette[color & 3];
						break;
					case 7:
						offset = (y << 10) + (x << 1);
						this.#pixels[offset + 513] = this.#pixels[offset + 512] = this.#pixels[offset + 1] = this.#pixels[offset] = this.contentPalette[color & 15];
						break;
					default:
						this.#pixels[(y << 8) + x] = this.contentPalette[color & 15];
						break;
					}
				}
			}
		}
	}

	#decodeSc2(content, contentLength)
	{
		if (contentLength < 14343 || content[0] != 254 || RECOIL.#getMsxHeader(content) < 14335)
			return false;
		if (RECOIL.#isMsxPalette(content, 7047)) {
			this.#setMsxPalette(content, 7047, 16);
			this.#decodeSc2Sc4(content, 7, RECOILResolution.MSX21X1);
		}
		else {
			this.#setMsx1Palette();
			this.#decodeSc2Sc4(content, 7, RECOILResolution.MSX11X1);
		}
		if (contentLength == 16391)
			this.#decodeMsxSprites(content, 2, 6919, 14343);
		return true;
	}

	#decodeSc3Screen(content, contentOffset, isLong)
	{
		this.#setSize(256, 192, RECOILResolution.MSX14X4);
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 256; x++) {
				let c = isLong ? content[2055 + ((y & ~7) << 2) + (x >> 3)] : (y & 224) + (x >> 3);
				c = content[contentOffset + (c << 3) + (y >> 2 & 7)] >> (~x & 4) & 15;
				this.#pixels[(y << 8) + x] = this.contentPalette[c];
			}
		}
	}

	#decodeSc3(content, contentLength)
	{
		if (contentLength < 1543 || content[0] != 254 || RECOIL.#getMsxHeader(content) < 1535)
			return false;
		if (contentLength >= 8263 && RECOIL.#isMsxPalette(content, 8231))
			this.#setMsxPalette(content, 8231, 16);
		else
			this.#setMsx1Palette();
		this.#decodeSc3Screen(content, 7, contentLength >= 2823);
		if (contentLength == 16391)
			this.#decodeMsxSprites(content, 3, 6919, 14343);
		return true;
	}

	#decodeSc4(content, contentLength)
	{
		if (contentLength < 14343 || content[0] != 254 || RECOIL.#getMsxHeader(content) < 14335)
			return false;
		if (RECOIL.#isMsxPalette(content, 7047))
			this.#setMsxPalette(content, 7047, 16);
		else
			this.#setMsxPalette(RECOIL.#MSX2_DEFAULT_PALETTE, 0, 16);
		this.#decodeSc2Sc4(content, 7, RECOILResolution.MSX21X1);
		if (contentLength >= 16391)
			this.#decodeMsxSprites(content, 4, 7687, 14343);
		return true;
	}

	#getMsx128Height(content, contentLength, sr)
	{
		if (contentLength < 135 || content[0] != 254)
			return -1;
		let header = RECOIL.#getMsxHeader(content);
		if (header < 127)
			return -1;
		let height = (header + 1) >> 7;
		if (contentLength < 7 + (height << 7))
			return -1;
		if (sr && height == 256)
			return 256;
		return Math.min(height, 212);
	}

	static #clampU5(x)
	{
		return x < 0 ? 0 : x > 31 ? 31 : x;
	}

	#decodeMsxYjk(content, contentOffset, x, width, usePalette)
	{
		let y = content[contentOffset + x] >> 3;
		if (usePalette && (y & 1) != 0)
			return this.contentPalette[y >> 1];
		let rgb;
		if ((x | 3) >= width) {
			rgb = y * 65793;
		}
		else {
			x = contentOffset + (x & ~3);
			let k = (content[x] & 7) | (content[x + 1] & 7) << 3;
			let j = (content[x + 2] & 7) | (content[x + 3] & 7) << 3;
			k -= (k & 32) << 1;
			j -= (j & 32) << 1;
			let r = RECOIL.#clampU5(y + j);
			let g = RECOIL.#clampU5(y + k);
			let b = RECOIL.#clampU5((5 * y - 2 * j - k + 2) >> 2);
			rgb = r << 16 | g << 8 | b;
		}
		return rgb << 3 | (rgb >> 2 & 460551);
	}

	#decodeMsxScreen(content, contentOffset, interlace, height, mode, interlaceMask)
	{
		if (interlaceMask != 0) {
			this.#setSize(512, height << 1, mode >= 10 ? RECOILResolution.MSX2_PLUS2X1I : mode >> 1 == 3 ? RECOILResolution.MSX21X1I : RECOILResolution.MSX22X1I);
			this.#frames = 2;
		}
		else if (mode >> 1 == 3)
			this.#setSize(512, height << 1, RECOILResolution.MSX21X2);
		else
			this.#setSize(256, height, mode >= 10 ? RECOILResolution.MSX2_PLUS1X1 : RECOILResolution.MSX21X1);
		for (let y = 0; y < this.#height; y++) {
			let screen = (y & interlaceMask) == 0 ? content : interlace;
			let screenOffset = (y & interlaceMask) == 0 || content != interlace ? contentOffset : contentOffset + (mode <= 6 ? 27143 : 54279);
			for (let x = 0; x < this.#width; x++) {
				let rgb = 0;
				switch (mode) {
				case 5:
					rgb = this.contentPalette[RECOIL.getNibble(screen, screenOffset + (y >> interlaceMask << 7), x >> interlaceMask)];
					break;
				case 6:
					rgb = this.contentPalette[screen[screenOffset + (y >> 1 << 7) + (x >> 2)] >> ((~x & 3) << 1) & 3];
					break;
				case 7:
					rgb = this.contentPalette[RECOIL.getNibble(screen, screenOffset + (y >> 1 << 8), x)];
					break;
				case 8:
					rgb = this.contentPalette[screen[screenOffset + (y >> interlaceMask << 8) + (x >> interlaceMask)]];
					break;
				case 10:
					rgb = this.#decodeMsxYjk(screen, screenOffset + (y >> interlaceMask << 8), x >> interlaceMask, 256, true);
					break;
				case 12:
					rgb = this.#decodeMsxYjk(screen, screenOffset + (y >> interlaceMask << 8), x >> interlaceMask, 256, false);
					break;
				default:
					throw new Error();
				}
				this.#pixels[y * this.#width + x] = rgb;
			}
		}
	}

	#decodeMsxSc(filename, content, contentOffset, upperExt, lowerExt, height, mode)
	{
		if (filename != null) {
			const interlace = new Uint8Array(54279);
			let interlaceLength = 7 + (height << (mode <= 6 ? 7 : 8));
			if (this.#readCompanionFile(filename, upperExt, lowerExt, interlace, interlaceLength) == interlaceLength && interlace[0] == 254 && RECOIL.#getMsxHeader(interlace) >= interlaceLength - 8) {
				this.#decodeMsxScreen(content, contentOffset, interlace, height, mode, 1);
				return true;
			}
		}
		this.#decodeMsxScreen(content, contentOffset, null, height, mode, 0);
		return false;
	}

	#decodeSc5(filename, content, contentLength)
	{
		let height = this.#getMsx128Height(content, contentLength, false);
		if (height <= 0)
			return false;
		this.#setMsx2Palette(content, 30343, contentLength);
		if (!this.#decodeMsxSc(filename, content, 7, "S15", "s15", height, 5) && contentLength == 32775)
			this.#decodeMsxSprites(content, 5, 30215, 30727);
		return true;
	}

	#setMsxCompanionPalette(filename, upperExt, lowerExt)
	{
		const palette = new Uint8Array(32);
		this.#setMsxPalette(this.#readCompanionFile(filename, upperExt, lowerExt, palette, 32) == 32 ? palette : RECOIL.#MSX2_DEFAULT_PALETTE, 0, 16);
	}

	#decodeSr5(filename, content, contentLength)
	{
		let height = this.#getMsx128Height(content, contentLength, true);
		if (height <= 0)
			return false;
		this.#setMsxCompanionPalette(filename, "PL5", "pl5");
		this.#setSize(256, height, RECOILResolution.MSX21X1);
		this.#decodeNibbles(content, 7, 128);
		return true;
	}

	#decodeMsx6(content, contentOffset)
	{
		let height = this.getOriginalHeight();
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < this.#width; x++) {
				let offset = y * this.#width + x;
				let b = content[contentOffset + (offset >> 2)];
				this.#setScaledPixel(x, y, this.contentPalette[b >> ((~offset & 3) << 1) & 3]);
			}
		}
		return true;
	}

	#setMsx6DefaultPalette()
	{
		this.contentPalette[0] = 0;
		this.contentPalette[1] = 2396708;
		this.contentPalette[2] = 2415396;
		this.contentPalette[3] = 7208813;
	}

	#decodeSc6(filename, content, contentLength)
	{
		let height = this.#getMsx128Height(content, contentLength, false);
		if (height <= 0)
			return false;
		if (contentLength >= 30351)
			this.#setMsxPalette(content, 30343, 4);
		else
			this.#setMsx6DefaultPalette();
		if (!this.#decodeMsxSc(filename, content, 7, "S16", "s16", height, 6) && contentLength == 32775)
			this.#decodeMsxSprites(content, 6, 30215, 30727);
		return true;
	}

	#setMsx6Palette(filename)
	{
		const palette = new Uint8Array(8);
		if (this.#readCompanionFile(filename, "PL6", "pl6", palette, 8) == 8)
			this.#setMsxPalette(palette, 0, 4);
		else
			this.#setMsx6DefaultPalette();
	}

	#decodeSr6(filename, content, contentLength)
	{
		let height = this.#getMsx128Height(content, contentLength, true);
		if (height <= 0)
			return false;
		this.#setSize(512, height << 1, RECOILResolution.MSX21X2);
		this.#setMsx6Palette(filename);
		return this.#decodeMsx6(content, 7);
	}

	#decodeGl6(filename, content, contentLength)
	{
		if (contentLength < 5)
			return false;
		let width = content[0] | content[1] << 8;
		let height = content[2] | content[3] << 8;
		if (contentLength < 4 + ((width * height + 3) >> 2) || !this.#setSize(width, height << 1, RECOILResolution.MSX21X2))
			return false;
		if (filename != null)
			this.#setMsx6Palette(filename);
		else {
			this.contentPalette[0] = 16777215;
			this.contentPalette[1] = 0;
			this.contentPalette[3] = this.contentPalette[2] = 0;
		}
		return this.#decodeMsx6(content, 4);
	}

	static #unpackSr(content, contentLength, unpacked)
	{
		if (contentLength < 7)
			return null;
		switch (content[0]) {
		case 254:
			if (contentLength < 54279 || RECOIL.#getMsxHeader(content) < 54271)
				return null;
			return content;
		case 253:
			if (7 + RECOIL.#getMsxHeader(content) != contentLength)
				return null;
			const rle = Object.assign(new SrStream(), { content: content, contentOffset: 7, contentLength: contentLength });
			rle.unpack(unpacked, 7, 1, 54279);
			return unpacked;
		default:
			return null;
		}
	}

	#decodeSc7(filename, content, contentLength)
	{
		if (contentLength < 54279 || content[0] != 254 || RECOIL.#getMsxHeader(content) < 54271)
			return false;
		this.#setMsx2Palette(content, 64135, contentLength);
		if (!this.#decodeMsxSc(filename, content, 7, "S17", "s17", 212, 7) && contentLength == 64167)
			this.#decodeMsxSprites(content, 7, 64007, 61447);
		return true;
	}

	#decodeSri(filename, content, contentLength)
	{
		if (contentLength != 108544)
			return false;
		this.#setMsxCompanionPalette(filename, "PL7", "pl7");
		this.#setSize(512, 424, RECOILResolution.MSX21X1I);
		this.#frames = 2;
		this.#decodeNibbles(content, 0, 256);
		return true;
	}

	static #isMsx256Lines(content, contentLength)
	{
		return contentLength == 65543 && content[0] == 254 && RECOIL.#getMsxHeader(content) == 65535;
	}

	#decodeSr7(filename, content, contentLength)
	{
		const unpacked = new Uint8Array(54279);
		let height;
		if (RECOIL.#isMsx256Lines(content, contentLength))
			height = 512;
		else {
			let source = RECOIL.#unpackSr(content, contentLength, unpacked);
			if (source == null)
				return false;
			content = source;
			height = 424;
		}
		this.#setMsxCompanionPalette(filename, "PL7", "pl7");
		this.#setSize(512, height, RECOILResolution.MSX21X2);
		this.#decodeNibbles(content, 7, 256);
		return true;
	}

	#decodeGl16(filename, content, contentLength, resolution, upperExt, lowerExt)
	{
		if (contentLength < 5)
			return false;
		let width = content[0] | content[1] << 8;
		let height = content[2] | content[3] << 8;
		if (contentLength < 4 + ((width * height + 1) >> 1) || !this.#setScaledSize(width, height, resolution))
			return false;
		this.#setMsxCompanionPalette(filename, upperExt, lowerExt);
		for (let y = 0; y < height; y++)
			for (let x = 0; x < width; x++)
				this.#setScaledPixel(x, y, this.contentPalette[RECOIL.getNibble(content, 4, y * width + x)]);
		return true;
	}

	#decodeGl5(filename, content, contentLength)
	{
		return this.#decodeGl16(filename, content, contentLength, RECOILResolution.MSX21X1, "PL5", "pl5");
	}

	#decodeGl7(filename, content, contentLength)
	{
		return this.#decodeGl16(filename, content, contentLength, RECOILResolution.MSX21X2, "PL7", "pl7");
	}

	#setSc8Palette()
	{
		for (let c = 0; c < 256; c++) {
			let rgb = (c & 28) << 14 | (c & 224) << 3 | RECOIL.#SET_SC8_PALETTE_BLUES[c & 3];
			this.contentPalette[c] = rgb << 5 | rgb << 2 | (rgb >> 1 & 197379);
		}
	}

	#decodeSc8(filename, content, contentLength)
	{
		const unpacked = new Uint8Array(54279);
		let height;
		if (RECOIL.#isMsx256Lines(content, contentLength))
			height = 256;
		else {
			let source = RECOIL.#unpackSr(content, contentLength, unpacked);
			if (source == null)
				return false;
			content = source;
			height = 212;
		}
		this.#setSc8Palette();
		if (!this.#decodeMsxSc(filename, content, 7, "S18", "s18", height, 8) && contentLength == 64167) {
			this.#setMsxPalette(RECOIL.#DECODE_SC8_SPRITE_PALETTE, 0, 16);
			this.#decodeMsxSprites(content, 8, 64007, 61447);
		}
		return true;
	}

	#decodeGl8(content, contentLength)
	{
		if (contentLength < 5)
			return false;
		let width = content[0] | content[1] << 8;
		let height = content[2] | content[3] << 8;
		if (contentLength != 4 + width * height || !this.#setSize(width, height, RECOILResolution.MSX21X1))
			return false;
		this.#setSc8Palette();
		this.#decodeBytes(content, 4);
		return true;
	}

	#decodePct(content, contentLength)
	{
		if (contentLength < 384 || (!RECOIL.isStringAt(content, 0, "DYNAMIC") && !RECOIL.isStringAt(content, 0, "E U R O")) || !RECOIL.isStringAt(content, 7, " PUBLISHER "))
			return false;
		let height;
		let contentOffset;
		if (RECOIL.isStringAt(content, 18, "SCREEN")) {
			height = 704;
			contentOffset = 384;
		}
		else if (RECOIL.isStringAt(content, 18, "FONT")) {
			height = 160;
			contentOffset = 512;
		}
		else
			return false;
		this.#setSize(512, height << 1, RECOILResolution.MSX21X2);
		const rle = Object.assign(new CciStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
		for (let y = 0; y < height; y++) {
			let b = 0;
			for (let x = 0; x < 512; x++) {
				if ((x & 7) == 0) {
					b = rle.readRle();
					if (b < 0)
						return false;
				}
				let offset = (y << 10) + x;
				this.#pixels[offset + 512] = this.#pixels[offset] = (b >> ((x ^ 3) & 7) & 1) == 0 ? 16777215 : 0;
			}
		}
		return true;
	}

	#decodeDdGraph(filename, content, contentLength)
	{
		if (contentLength < 4)
			return false;
		let width = content[0];
		if (width == 0 || width > 128)
			return false;
		let height = content[1];
		if (height == 0 || height > 212)
			return false;
		let verbatimLines = content[2];
		if (verbatimLines == 0 || verbatimLines > height)
			return false;
		const stream = Object.assign(new ZimStream(), { content: content, contentOffset: 3, contentLength: contentLength });
		let flagsOffset = 64;
		const unpacked = new Uint8Array(27136);
		let unpackedOffset = 0;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				if (flagsOffset >= 64) {
					if (!stream.unpackFlags2())
						return false;
					flagsOffset = 0;
				}
				let b = stream.readUnpacked(stream.flags2, flagsOffset++);
				if (b < 0)
					return false;
				if (y >= verbatimLines)
					b ^= unpacked[unpackedOffset - width];
				unpacked[unpackedOffset++] = b;
			}
		}
		if (stream.contentOffset != stream.contentLength)
			return false;
		this.#setMsxCompanionPalette(filename, "PL5", "pl5");
		this.#setSize(width << 1, height, RECOILResolution.MSX21X1);
		this.#decodeNibbles(unpacked, 0, width);
		return true;
	}

	#decodeMsxYjkScreen(content, contentOffset, usePalette)
	{
		let width = this.getOriginalWidth();
		for (let y = 0; y < this.#height; y++)
			for (let x = 0; x < width; x++)
				this.#setScaledPixel(x, y, this.#decodeMsxYjk(content, contentOffset + y * width, x, width, usePalette));
	}

	#decodeSccSca(filename, content, contentLength, height, usePalette)
	{
		if (!this.#decodeMsxSc(filename, content, 7, usePalette ? "S1A" : "S1C", usePalette ? "s1a" : "s1c", height, usePalette ? 10 : 12) && contentLength == 64167 && content[0] == 254) {
			this.#setMsxPalette(content, 64135, 16);
			this.#decodeMsxSprites(content, 12, 64007, 61447);
		}
	}

	#decodeScc(filename, content, contentLength)
	{
		let height;
		if (RECOIL.#isMsx256Lines(content, contentLength))
			height = 256;
		else if (contentLength >= 49159 && content[0] == 254 && RECOIL.#getMsxHeader(content) == 49151)
			height = 192;
		else {
			const unpacked = new Uint8Array(54279);
			let source = RECOIL.#unpackSr(content, contentLength, unpacked);
			if (source == null)
				return false;
			content = source;
			height = 212;
		}
		this.#decodeSccSca(filename, content, contentLength, height, false);
		return true;
	}

	#decodeSca(filename, content, contentLength)
	{
		if (contentLength < 64167 || content[0] != 254 || RECOIL.#getMsxHeader(content) < 54271)
			return false;
		let height;
		if (RECOIL.#isMsx256Lines(content, contentLength)) {
			this.#setMsxCompanionPalette(filename, "PLA", "pla");
			height = 256;
		}
		else {
			this.#setMsxPalette(content, 64135, 16);
			height = 212;
		}
		this.#decodeSccSca(filename, content, contentLength, height, true);
		return true;
	}

	#decodeGlYjk(filename, content, contentLength)
	{
		if (contentLength < 8)
			return false;
		let width = content[0] | content[1] << 8;
		let height = content[2] | content[3] << 8;
		if (contentLength != 4 + width * height || !this.#setSize(width, height, RECOILResolution.MSX2_PLUS1X1))
			return false;
		if (filename != null)
			this.#setMsxCompanionPalette(filename, "PLA", "pla");
		this.#decodeMsxYjkScreen(content, 4, filename != null);
		return true;
	}

	#setG9bPalette(content, colors)
	{
		for (let c = 0; c < colors; c++) {
			let rgb = RECOIL.#getR8G8B8Color(content, 16 + c * 3);
			if ((rgb & 14737632) != 0)
				return false;
			this.contentPalette[c] = rgb << 3 | (rgb >> 2 & 460551);
		}
		return true;
	}

	#decodeG9bUnpacked(content, depth, headerLength)
	{
		let pixelsLength;
		switch (depth) {
		case 2:
			this.#decodeMsx6(content, 28);
			break;
		case 4:
			this.#decodeNibbles(content, 64, (this.#width + 1) >> 1);
			break;
		case 8:
			this.#decodeBytes(content, headerLength);
			break;
		case 0:
			this.#decodeMsxYjkScreen(content, 16, false);
			break;
		case 1:
			pixelsLength = this.#width * this.#height;
			for (let i = 0; i < pixelsLength; i++) {
				let y = content[16 + i] >> 3;
				let x = 16 + (i & ~3);
				let v = (content[x] & 7) | (content[x + 1] & 7) << 3;
				let u = (content[x + 2] & 7) | (content[x + 3] & 7) << 3;
				u -= (u & 32) << 1;
				v -= (v & 32) << 1;
				let r = RECOIL.#clampU5(y + u);
				let g = RECOIL.#clampU5((((5 * y - v) >> 1) - u) >> 1);
				let b = RECOIL.#clampU5(y + v);
				let rgb = r << 16 | g << 8 | b;
				this.#pixels[i] = rgb << 3 | (rgb >> 2 & 460551);
			}
			break;
		case 16:
			pixelsLength = this.#width * this.#height;
			for (let i = 0; i < pixelsLength; i++) {
				let c = content[16 + (i << 1)] | content[17 + (i << 1)] << 8;
				let rgb = (c & 992) << 14 | (c & 31744) << 1 | (c & 31) << 3;
				this.#pixels[i] = rgb | (rgb >> 5 & 460551);
			}
			break;
		default:
			throw new Error();
		}
	}

	#decodeG9b(content, contentLength)
	{
		if (contentLength < 17 || content[0] != 71 || content[1] != 57 || content[2] != 66 || content[3] != 11 || content[4] != 0)
			return false;
		let depth = content[5];
		let headerLength = 16 + content[7] * 3;
		let width = content[8] | content[9] << 8;
		let height = content[10] | content[11] << 8;
		if (contentLength <= headerLength || !this.#setSize(width, height, RECOILResolution.MSX_V99901X1))
			return false;
		let unpackedLength = headerLength + ((width * depth + 7) >> 3) * height;
		switch (depth) {
		case 2:
			if (content[7] != 4 || !this.#setG9bPalette(content, 4))
				return false;
			break;
		case 4:
			if (content[7] != 16 || !this.#setG9bPalette(content, 16))
				return false;
			break;
		case 8:
			switch (content[7]) {
			case 0:
				if ((width & 3) != 0)
					return false;
				switch (content[6]) {
				case 64:
					this.#setSc8Palette();
					break;
				case 128:
					depth = 0;
					break;
				case 192:
					depth = 1;
					break;
				default:
					return false;
				}
				break;
			case 64:
				if (!this.#setG9bPalette(content, 64))
					return false;
				this.contentPalette.fill(0, 64, 256);
				break;
			default:
				return false;
			}
			break;
		case 16:
			break;
		default:
			return false;
		}
		switch (content[12]) {
		case 0:
			if (contentLength != unpackedLength)
				return false;
			this.#decodeG9bUnpacked(content, depth, headerLength);
			return true;
		case 1:
			let unpacked = new Uint8Array(unpackedLength);
			const s = Object.assign(new G9bStream(), { content: content, contentLength: contentLength });
			let ok = s.unpack(unpacked, headerLength, unpackedLength);
			if (ok)
				this.#decodeG9bUnpacked(unpacked, depth, headerLength);
			return ok;
		default:
			return false;
		}
	}

	#unpackMif(content, contentLength, unpacked, unpackedLength, palette)
	{
		const s = Object.assign(new BitStream(), { content: content, contentOffset: palette ? 34 : 2, contentLength: contentLength });
		const offsets = new Int32Array(5461);
		let codes = 0;
		let codeBits = 2;
		for (let unpackedOffset = 0; unpackedOffset < unpackedLength;) {
			if (codes >= 5461)
				return false;
			offsets[codes++] = unpackedOffset;
			if (codes >> codeBits != 0)
				codeBits++;
			switch (s.readBit()) {
			case 0:
				let code = s.readBits(codeBits);
				if (code < 0 || code >= codes)
					return false;
				if (code == codes - 1) {
					codes = 0;
					codeBits = 2;
					break;
				}
				let sourceOffset = offsets[code];
				let endOffset = offsets[code + 1];
				if (unpackedOffset + endOffset - sourceOffset >= unpackedLength)
					return false;
				do
					unpacked[unpackedOffset++] = unpacked[sourceOffset++];
				while (sourceOffset <= endOffset);
				break;
			case 1:
				let b = s.readBits(8);
				if (b < 0)
					return false;
				unpacked[unpackedOffset++] = b;
				break;
			default:
				return false;
			}
		}
		if (s.readBit() != 0 || s.readBits(codeBits) <= codes || s.contentOffset != contentLength)
			return false;
		if (palette)
			this.#setMsxPalette(content, 2, 16);
		return true;
	}

	#decodeMif(content, contentLength)
	{
		if (contentLength < 35)
			return false;
		const unpacked = new Uint8Array(108544);
		switch (content[0]) {
		case 0:
			if (!this.#unpackMif(content, contentLength, unpacked, 27136, true))
				return false;
			this.#setSize(256, 212, RECOILResolution.MSX21X1);
			this.#decodeNibbles(unpacked, 0, 128);
			return true;
		case 1:
			if (!this.#unpackMif(content, contentLength, unpacked, 27136, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX21X2);
			this.#decodeMsx6(unpacked, 0);
			return true;
		case 2:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX21X2);
			this.#decodeNibbles(unpacked, 0, 256);
			return true;
		case 3:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, false))
				return false;
			this.#setSc8Palette();
			this.#setSize(256, 212, RECOILResolution.MSX21X1);
			this.#decodeBytes(unpacked, 0);
			return true;
		case 4:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, true))
				return false;
			this.#setSize(256, 212, RECOILResolution.MSX2_PLUS1X1);
			this.#decodeMsxYjkScreen(unpacked, 0, true);
			return true;
		case 5:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, false))
				return false;
			this.#setSize(256, 212, RECOILResolution.MSX2_PLUS1X1);
			this.#decodeMsxYjkScreen(unpacked, 0, false);
			return true;
		case 8:
			if (!this.#unpackMif(content, contentLength, unpacked, 14336, true))
				return false;
			this.#decodeSc2Sc4(unpacked, 0, RECOILResolution.MSX21X1);
			return true;
		case 9:
			if (!this.#unpackMif(content, contentLength, unpacked, 1536, true))
				return false;
			this.#decodeSc3Screen(unpacked, 0, false);
			return true;
		case 16:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX22X1I);
			this.#frames = 2;
			this.#decodeNibbles(unpacked, 0, 128);
			return true;
		case 17:
			if (!this.#unpackMif(content, contentLength, unpacked, 54272, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX21X1I);
			this.#frames = 2;
			this.#decodeMsx6(unpacked, 0);
			return true;
		case 18:
			if (!this.#unpackMif(content, contentLength, unpacked, 108544, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX21X1I);
			this.#frames = 2;
			this.#decodeNibbles(unpacked, 0, 256);
			return true;
		case 19:
			if (!this.#unpackMif(content, contentLength, unpacked, 108544, false))
				return false;
			this.#setSc8Palette();
			this.#setSize(512, 424, RECOILResolution.MSX22X1I);
			this.#frames = 2;
			this.#decodeBytes(unpacked, 0);
			return true;
		case 20:
			if (!this.#unpackMif(content, contentLength, unpacked, 108544, true))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX2_PLUS2X1I);
			this.#frames = 2;
			this.#decodeMsxYjkScreen(unpacked, 0, true);
			return true;
		case 21:
			if (!this.#unpackMif(content, contentLength, unpacked, 108544, false))
				return false;
			this.#setSize(512, 424, RECOILResolution.MSX2_PLUS2X1I);
			this.#frames = 2;
			this.#decodeMsxYjkScreen(unpacked, 0, false);
			return true;
		default:
			return false;
		}
	}

	static #getMigMode(reg0, reg1, reg19, length)
	{
		return (reg0 & 14) | (reg1 & 24) << 1 | (reg19 & 24) << 3 | length << 8;
	}

	#decodeMig(content, contentLength)
	{
		if (contentLength < 16 || !RECOIL.isStringAt(content, 0, "MSXMIG") || RECOIL.get32LittleEndian(content, 6) != contentLength - 6)
			return false;
		const unpacked = new Uint8Array(108800);
		const s = Object.assign(new MigStream(), { content: content, contentLength: contentLength });
		let unpackedLength = s.unpack(unpacked);
		let colors = 0;
		const registers = new Uint8Array(256);
		for (let unpackedOffset = 0; unpackedOffset < unpackedLength;) {
			switch (unpacked[unpackedOffset]) {
			case 0:
				if (unpackedOffset + 1 >= unpackedLength)
					return false;
				let c = unpacked[unpackedOffset + 1];
				if (unpackedOffset + 2 + c * 3 > unpackedLength)
					return false;
				for (let i = 0; i < c; i++) {
					let offset = unpackedOffset + 2 + i * 3;
					let r = unpacked[offset];
					let m = unpacked[offset + 2];
					registers[r] = (registers[r] & ~m) | (unpacked[offset + 1] & m);
				}
				unpackedOffset += 2 + c * 3;
				break;
			case 1:
				if (unpackedOffset + 2 >= unpackedLength || unpacked[unpackedOffset + 1] != 0)
					return false;
				colors = unpacked[unpackedOffset + 2];
				if (unpackedOffset + 3 + (colors << 1) > unpackedLength)
					return false;
				this.#setMsxPalette(unpacked, unpackedOffset + 3, colors);
				unpackedOffset += 3 + (colors << 1);
				break;
			case 2:
				if (unpackedOffset + 7 >= unpackedLength || unpacked[unpackedOffset + 1] != 0 || unpacked[unpackedOffset + 2] != 0 || unpacked[unpackedOffset + 3] != 0 || unpacked[unpackedOffset + 4] != 0 || unpacked[unpackedOffset + 6] != 0)
					return false;
				let length = unpacked[unpackedOffset + 5];
				unpackedOffset += 7;
				let interlaceMask;
				switch (registers[9] & 12) {
				case 0:
					if (unpackedOffset + (length << 8) + 1 != unpackedLength)
						return false;
					interlaceMask = 0;
					break;
				case 12:
					if (unpackedOffset + (length << 9) + 7 + 1 != unpackedLength || unpacked[unpackedOffset + (length << 8)] != 2 || unpacked[unpackedOffset + (length << 8) + 1] != 0 || unpacked[unpackedOffset + (length << 8) + 4] != 0 || unpacked[unpackedOffset + (length << 8) + 5] != length || unpacked[unpackedOffset + (length << 8) + 6] != 0)
						return false;
					interlaceMask = 1;
					break;
				default:
					return false;
				}
				let mode;
				switch (RECOIL.#getMigMode(registers[0], registers[1], registers[25], length)) {
				case 14338:
					if (colors < 16 || interlaceMask != 0)
						return false;
					this.#decodeSc2Sc4(unpacked, unpackedOffset, RECOILResolution.MSX21X1);
					return true;
				case 1552:
					if (colors < 16 || interlaceMask != 0)
						return false;
					this.#decodeSc3Screen(unpacked, unpackedOffset, false);
					return true;
				case 27142:
					if (colors < 16)
						return false;
					mode = 5;
					break;
				case 27144:
					if (colors < 4)
						return false;
					mode = 6;
					break;
				case 54282:
					if (colors < 16)
						return false;
					mode = 7;
					break;
				case 54286:
					this.#setSc8Palette();
					mode = 8;
					break;
				case 54478:
					if (colors < 16)
						return false;
					mode = 10;
					break;
				case 54350:
					mode = 12;
					break;
				default:
					return false;
				}
				this.#decodeMsxScreen(unpacked, unpackedOffset, unpacked, 212, mode, interlaceMask);
				return true;
			default:
				return false;
			}
		}
		return false;
	}

	#decodeHgr(content, contentLength)
	{
		if (contentLength < 8184)
			return false;
		this.#setSize(280, 192, RECOILResolution.APPLE_I_I1X1);
		for (let y = 0; y < 192; y++) {
			let lineOffset = (y & 7) << 10 | (y & 56) << 4 | (y >> 6) * 40;
			for (let x = 0; x < 280; x++) {
				let c = content[lineOffset + (x / 7 | 0)] >> x % 7 & 1;
				if (c != 0)
					c = 16777215;
				this.#pixels[y * 280 + x] = c;
			}
		}
		return true;
	}

	#decodeAppleIIDhr(content, contentLength)
	{
		if (contentLength != 16384)
			return false;
		this.#setSize(560, 384, RECOILResolution.APPLE_I_IE1X2);
		for (let y = 0; y < 192; y++) {
			let lineOffset = (y & 7) << 10 | (y & 56) << 4 | (y >> 6) * 40;
			for (let x = 0; x < 560; x++) {
				let b = x / 7 | 0;
				let c = content[((b & 1) << 13) + lineOffset + (b >> 1)] >> x % 7 & 1;
				if (c != 0)
					c = 16777215;
				let pixelsOffset = y * 1120 + x;
				this.#pixels[pixelsOffset + 560] = this.#pixels[pixelsOffset] = c;
			}
		}
		return true;
	}

	#setAppleIIGSPalette(content, contentOffset, reverse)
	{
		for (let c = 0; c < 16; c++) {
			let offset = contentOffset + ((c ^ reverse) << 1);
			let gb = content[offset];
			let r = content[offset + 1] & 15;
			let g = gb >> 4;
			let b = gb & 15;
			let rgb = r << 16 | g << 8 | b;
			rgb |= rgb << 4;
			this.contentPalette[c] = rgb;
		}
	}

	#decodeShrLine(content, y)
	{
		for (let x = 0; x < 320; x++)
			this.#pixels[y * 320 + x] = this.contentPalette[RECOIL.getNibble(content, y * 160, x)];
	}

	#decodeAppleIIShrUnpacked(content)
	{
		this.#setSize(320, 200, RECOILResolution.APPLE_I_I_G_S1X1);
		for (let y = 0; y < 200; y++) {
			this.#setAppleIIGSPalette(content, 32256 + ((content[32000 + y] & 15) << 5), 0);
			this.#decodeShrLine(content, y);
		}
		return true;
	}

	#decodeAppleIIShr(content, contentLength)
	{
		if (contentLength == 32768)
			return this.#decodeAppleIIShrUnpacked(content);
		const unpacked = new Uint8Array(32768);
		const stream = Object.assign(new PackBytesStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (let unpackedOffset = 0; unpackedOffset < 32768; unpackedOffset++) {
			let b = stream.readUnpacked();
			if (b < 0)
				return false;
			unpacked[unpackedOffset] = b;
		}
		return stream.readUnpacked() < 0 && this.#decodeAppleIIShrUnpacked(unpacked);
	}

	#decodeSh3(content, contentLength)
	{
		if (contentLength != 38400)
			return false;
		this.#setSize(320, 200, RECOILResolution.APPLE_I_I_G_S1X1);
		for (let y = 0; y < 200; y++) {
			this.#setAppleIIGSPalette(content, 32000 + (y << 5), 15);
			this.#decodeShrLine(content, y);
		}
		return true;
	}

	#drawSprByte(x1, y, b)
	{
		for (let x = 0; x < 8; x++) {
			if ((b >> (7 - x) & 1) != 0)
				this.#pixels[y * 320 + x1 + x] = 16777215;
		}
	}

	#decodeAppleSpr(content, contentLength)
	{
		this.#setSize(320, 200, RECOILResolution.APPLE_I_I1X1);
		this.#pixels.fill(0, 0, 64000);
		const s = Object.assign(new AppleSprStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (;;) {
			let cols = s.readSprInt();
			if (cols < 0)
				return false;
			let rows = s.readSprInt();
			if (rows < 0)
				return false;
			let order = s.readSprInt();
			if (order < 0)
				return false;
			let x = s.readSprInt();
			if (x < 0)
				return false;
			let y = s.readSprInt();
			if (y < 0)
				return false;
			if (rows == 0)
				break;
			if (cols == 0 || x + (cols << 3) > 320 || y + rows > 200)
				return false;
			if (order == 2) {
				for (let col = 0; col < cols; col++) {
					for (let row = 0; row < rows; row++) {
						let b = s.readSprInt();
						if (b < 0)
							return false;
						this.#drawSprByte(x + (col << 3), y + row, b);
					}
				}
			}
			else {
				for (let row = 0; row < rows; row++) {
					for (let col = 0; col < cols; col++) {
						let b = s.readSprInt();
						if (b < 0)
							return false;
						this.#drawSprByte(x + (col << 3), y + row, b);
					}
				}
			}
		}
		return true;
	}

	#decodePackBytes(stream, pixelsOffset, unpackedBytes)
	{
		for (let x = 0; x < unpackedBytes; x++) {
			let b = stream.readUnpacked();
			if (b < 0)
				return false;
			if (this.#resolution == RECOILResolution.APPLE_I_I_G_S1X2) {
				let offset = (pixelsOffset << 1) + (x << 2);
				this.#pixels[offset + this.#width] = this.#pixels[offset] = this.contentPalette[8 + (b >> 6)];
				this.#pixels[offset + this.#width + 1] = this.#pixels[offset + 1] = this.contentPalette[12 + (b >> 4 & 3)];
				this.#pixels[offset + this.#width + 2] = this.#pixels[offset + 2] = this.contentPalette[b >> 2 & 3];
				this.#pixels[offset + this.#width + 3] = this.#pixels[offset + 3] = this.contentPalette[4 + (b & 3)];
			}
			else {
				this.#pixels[pixelsOffset + (x << 1)] = this.contentPalette[b >> 4];
				this.#pixels[pixelsOffset + (x << 1) + 1] = this.contentPalette[b & 15];
			}
		}
		return true;
	}

	#decodePaintworks(content, contentLength)
	{
		if (contentLength < 1041)
			return false;
		this.#setSize(320, 396, RECOILResolution.APPLE_I_I_G_S1X1);
		this.#setAppleIIGSPalette(content, 0, 0);
		const stream = Object.assign(new PackBytesStream(), { content: content, contentOffset: 546, contentLength: contentLength });
		return this.#decodePackBytes(stream, 0, 63360);
	}

	#decode3201(content, contentLength)
	{
		if (contentLength < 6654 || content[0] != 193 || content[1] != 208 || content[2] != 208 || content[3] != 0)
			return false;
		this.#setSize(320, 200, RECOILResolution.APPLE_I_I_G_S1X1);
		const stream = Object.assign(new PackBytesStream(), { content: content, contentOffset: 6404, contentLength: contentLength });
		for (let y = 0; y < 200; y++) {
			this.#setAppleIIGSPalette(content, 4 + (y << 5), 15);
			if (!this.#decodePackBytes(stream, y * 320, 160))
				return false;
		}
		return true;
	}

	#decodeApfShr(content, contentLength)
	{
		if (contentLength < 1249 || content[4] != 4 || !RECOIL.isStringAt(content, 5, "MAIN") || content[14] != 0)
			return false;
		let paletteCount = content[13];
		if (paletteCount > 16)
			return false;
		let dirOffset = 17 + (paletteCount << 5);
		if (dirOffset >= contentLength)
			return false;
		let mode = content[9] & 240;
		let width = content[11] | content[12] << 8;
		let height = content[dirOffset - 2] | content[dirOffset - 1] << 8;
		let bytesPerLine;
		switch (mode) {
		case 0:
			if ((width & 1) != 0 || !this.#setSize(width, height, RECOILResolution.APPLE_I_I_G_S1X1))
				return false;
			bytesPerLine = width >> 1;
			break;
		case 128:
			if ((width & 3) != 0 || !this.#setSize(width, height << 1, RECOILResolution.APPLE_I_I_G_S1X2))
				return false;
			bytesPerLine = width >> 2;
			break;
		default:
			return false;
		}
		let multipalOffset = -1;
		let contentOffset = 0;
		if (height == 200) {
			for (let chunkLength = RECOIL.get32LittleEndian(content, 0);;) {
				if (chunkLength <= 0)
					return false;
				contentOffset += chunkLength;
				if (contentOffset < 0 || contentOffset > contentLength - 6415)
					break;
				chunkLength = RECOIL.get32LittleEndian(content, contentOffset);
				if (chunkLength == 6415 && content[contentOffset + 4] == 8 && RECOIL.isStringAt(content, contentOffset + 5, "MULTIPAL") && content[contentOffset + 13] == 200 && content[contentOffset + 14] == 0) {
					multipalOffset = contentOffset + 15;
					break;
				}
			}
		}
		contentOffset = dirOffset + (height << 2);
		if (contentOffset >= contentLength)
			return false;
		const stream = Object.assign(new PackBytesStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
		for (let y = 0; y < height; y++) {
			if (multipalOffset >= 0)
				this.#setAppleIIGSPalette(content, multipalOffset + (y << 5), 0);
			else {
				let lineMode = content[dirOffset + (y << 2) + 2];
				let palette = lineMode & 15;
				if ((lineMode & 240) != mode || palette >= paletteCount || content[dirOffset + (y << 2) + 3] != 0)
					return false;
				this.#setAppleIIGSPalette(content, 15 + (palette << 5), 0);
			}
			let nextLineOffset = stream.contentOffset + content[dirOffset + (y << 2)] + (content[dirOffset + (y << 2) + 1] << 8);
			if (!this.#decodePackBytes(stream, y * width, bytesPerLine))
				return false;
			stream.contentOffset = nextLineOffset;
		}
		return true;
	}

	static #getSamCoupeColor(c)
	{
		let rgb = 0;
		if ((c & 1) != 0)
			rgb |= 73;
		if ((c & 2) != 0)
			rgb |= 4784128;
		if ((c & 4) != 0)
			rgb |= 18688;
		if ((c & 8) != 0)
			rgb |= 2368548;
		if ((c & 16) != 0)
			rgb |= 146;
		if ((c & 32) != 0)
			rgb |= 9568256;
		if ((c & 64) != 0)
			rgb |= 37376;
		return rgb;
	}

	#setSamCoupePalette(content, contentOffset, colors)
	{
		for (let i = 0; i < colors; i++)
			this.contentPalette[i] = RECOIL.#getSamCoupeColor(content[contentOffset + i]);
	}

	static #getSamCoupeMode12Color(content, bitmapOffset, attributeOffset, x)
	{
		let a = content[attributeOffset + (x >> 3)];
		return (a >> 3 & 8) | (((content[bitmapOffset + (x >> 3)] >> (~x & 7) & 1) == 0 ? a >> 3 : a) & 7);
	}

	#decodeSamCoupeScreen(content, contentOffset, contentLength, mode, interruptOffset)
	{
		if (interruptOffset >= contentLength)
			return -1;
		this.#setSamCoupePalette(content, interruptOffset - 40, 16);
		let width = this.getOriginalWidth();
		for (let y = 0; y < 192; y++) {
			while (interruptOffset + 3 < contentLength && y == content[interruptOffset] + 1) {
				let c = content[interruptOffset + 1];
				if (c > 15)
					return -1;
				this.contentPalette[c] = RECOIL.#getSamCoupeColor(content[interruptOffset + 2]);
				interruptOffset += 4;
			}
			let row = y << (this.#frames - 1);
			if (contentOffset != 0)
				row++;
			for (let x = 0; x < width; x++) {
				let c;
				switch (mode) {
				case 1:
					c = RECOIL.#getSamCoupeMode12Color(content, RECOIL.#getZxLineOffset(y), 6144 + (y >> 3 << 5), x);
					break;
				case 2:
					c = RECOIL.#getSamCoupeMode12Color(content, y << 5, 8192 + (y << 5), x);
					break;
				case 3:
					c = content[y << 7 | x >> 2] >> ((~x & 3) << 1);
					c = (c & 1) << 1 | (c >> 1 & 1);
					break;
				case 4:
					c = RECOIL.getNibble(content, contentOffset + (y << 7), x);
					break;
				default:
					throw new Error();
				}
				this.#setScaledPixel(x, row, this.contentPalette[c]);
			}
		}
		if (interruptOffset >= contentLength || content[interruptOffset] != 255)
			return -1;
		return interruptOffset + 1;
	}

	#decodeSs1(content, contentLength)
	{
		this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
		return this.#decodeSamCoupeScreen(content, 0, contentLength, 1, 6952) == contentLength;
	}

	#decodeSs2(content, contentLength)
	{
		this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
		return this.#decodeSamCoupeScreen(content, 0, contentLength, 2, 14376) == contentLength;
	}

	#decodeSs3(content, contentLength)
	{
		this.#setSize(512, 384, RECOILResolution.SAM_COUPE1X2);
		return this.#decodeSamCoupeScreen(content, 0, contentLength, 3, 24616) == contentLength;
	}

	#decodeSs4(content, contentLength)
	{
		this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
		return this.#decodeSamCoupeScreen(content, 0, contentLength, 4, 24616) == contentLength;
	}

	#decodeLce(content, contentLength)
	{
		this.#setSize(512, 384, RECOILResolution.SAM_COUPE2X1I);
		this.#frames = 2;
		let contentOffset = this.#decodeSamCoupeScreen(content, 0, contentLength, 4, 24616);
		if (contentOffset < 0)
			return false;
		return this.#decodeSamCoupeScreen(content, contentOffset, contentLength, 4, contentOffset + 24616) == contentLength;
	}

	#setSamCoupeAttrPalette(content, contentOffset)
	{
		for (let i = 0; i < 64; i++)
			this.contentPalette[i] = RECOIL.#getSamCoupeColor(content[contentOffset + (i >> 1 & 8) + (i & 7)]);
	}

	#decodeSsx(content, contentLength)
	{
		switch (contentLength) {
		case 6928:
			this.#setSamCoupeAttrPalette(content, 6912);
			this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
			this.#decodeZx(content, 0, 6144, 3, 0);
			return true;
		case 12304:
			this.#setSamCoupeAttrPalette(content, 12288);
			this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
			this.#decodeZx(content, -1, 6144, 0, 0);
			return true;
		case 24580:
			this.#setSamCoupePalette(content, 24576, 4);
			this.#setSize(512, 384, RECOILResolution.SAM_COUPE1X2);
			for (let y = 0; y < 192; y++) {
				for (let x = 0; x < 512; x++) {
					let c = content[y << 7 | x >> 2] >> ((~x & 3) << 1) & 3;
					this.#pixels[(y << 10) + x + 512] = this.#pixels[(y << 10) + x] = this.contentPalette[c];
				}
			}
			return true;
		case 24592:
			this.#setSamCoupePalette(content, 24576, 16);
			this.#setSize(256, 192, RECOILResolution.SAM_COUPE1X1);
			this.#decodeNibbles(content, 0, 128);
			return true;
		case 98304:
			for (let c = 0; c < 128; c++)
				this.contentPalette[c] = RECOIL.#getSamCoupeColor(c);
			this.#setSize(512, 384, RECOILResolution.SAM_COUPE1X2);
			for (let y = 0; y < 192; y++) {
				for (let x = 0; x < 512; x++) {
					let c = content[(y << 9) + x];
					if (c >= 128)
						return false;
					this.#pixels[(y << 10) + x + 512] = this.#pixels[(y << 10) + x] = this.contentPalette[c];
				}
			}
			return true;
		default:
			return false;
		}
	}

	static #getX68KColor(color)
	{
		let rgb = (color & 1984) << 13 | (color & 63488) | (color & 62) << 2;
		if ((color & 1) != 0)
			rgb |= 263172;
		return rgb | (rgb >> 6 & 197379);
	}

	#restrictPlatformColor(rgb, colors)
	{
		switch (this.#resolution) {
		case RECOILResolution.FM_TOWNS1X1:
			return (rgb & 16316664) | (rgb >> 5 & 460551);
		case RECOILResolution.MSX21X1:
		case RECOILResolution.MSX21X2:
		case RECOILResolution.MSX21X1I:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS1X1:
		case RECOILResolution.MSX2_PLUS2X1I:
			rgb &= 14737632;
			return rgb | rgb >> 3 | (rgb >> 6 & 197379);
		case RECOILResolution.PC881X2:
			rgb &= 15790320;
			return rgb | rgb >> 4;
		case RECOILResolution.PC88_VA1X1:
			return (rgb & 16317688) | (rgb >> 5 & 458759) | (rgb >> 6 & 768);
		case RECOILResolution.PC981X1:
			if (colors == 16) {
				rgb &= 15790320;
				rgb |= rgb >> 4;
			}
			return rgb;
		case RECOILResolution.X68_K1X1:
			return (rgb & 16316664) | (rgb >> 10 & 1) * 263172 | (rgb >> 6 & 197379);
		default:
			return rgb;
		}
	}

	#decodeX68KPicChain(stream, pixelsOffset, color)
	{
		for (;;) {
			switch (stream.readBits(2)) {
			case 0:
				switch (stream.readBit()) {
				case 0:
					return true;
				case 1:
					break;
				default:
					return false;
				}
				switch (stream.readBit()) {
				case 0:
					pixelsOffset -= 2;
					break;
				case 1:
					pixelsOffset += 2;
					break;
				default:
					return false;
				}
				break;
			case 1:
				pixelsOffset--;
				break;
			case 2:
				break;
			case 3:
				pixelsOffset++;
				break;
			default:
				return false;
			}
			pixelsOffset += this.#width;
			if (pixelsOffset < 0 || pixelsOffset >= this.#width * this.#height)
				return false;
			this.#pixels[pixelsOffset] = color;
		}
	}

	#decodeX68KPicScreen(stream, pixelsLength, platform, depth)
	{
		for (let pixelsOffset = 0; pixelsOffset < pixelsLength; pixelsOffset++)
			this.#pixels[pixelsOffset] = -1;
		const colors = new RecentInts();
		let color = 0;
		for (let pixelsOffset = -1;;) {
			let length = stream.readLength();
			if (length < 0)
				return false;
			while (--length > 0) {
				let got = this.#pixels[++pixelsOffset];
				if (got < 0)
					this.#pixels[pixelsOffset] = color;
				else
					color = got;
				if (pixelsOffset >= pixelsLength - 1)
					return true;
			}
			if (depth <= 8) {
				color = stream.readBits(depth);
				if (color < 0)
					return false;
				color = this.contentPalette[color];
			}
			else {
				switch (stream.readBit()) {
				case 0:
					color = stream.readBits(depth);
					if (color < 0)
						return false;
					switch (platform) {
					case 0:
						if (depth == 15)
							color <<= 1;
						color = RECOIL.#getX68KColor(color);
						break;
					case 17:
						color = RECOIL.#getG6R5B5Color(color);
						break;
					default:
						break;
					}
					colors.add(color);
					break;
				case 1:
					color = stream.readBits(7);
					if (color < 0)
						return false;
					color = colors.get(color);
					break;
				default:
					return false;
				}
			}
			this.#pixels[++pixelsOffset] = color;
			if (pixelsOffset >= pixelsLength - 1)
				return true;
			switch (stream.readBit()) {
			case 0:
				break;
			case 1:
				if (!this.#decodeX68KPicChain(stream, pixelsOffset, color))
					return false;
				break;
			default:
				return false;
			}
		}
	}

	#decodeX68KPic(content, contentLength)
	{
		if (contentLength < 14 || content[0] != 80 || content[1] != 73 || content[2] != 67)
			return false;
		let resolution = RECOIL.isStringAt(content, 3, "/MM/") ? RECOILResolution.MSX21X1 : RECOILResolution.X68_K1X1;
		const stream = Object.assign(new X68KPicStream(), { content: content, contentOffset: 3, contentLength: contentLength });
		for (;;) {
			let b = stream.readByte();
			if (b < 0)
				return false;
			if (b == 26)
				break;
			if (b == 47 && resolution == RECOILResolution.MSX21X1 && stream.contentOffset + 4 < contentLength && content[stream.contentOffset] == 77 && content[stream.contentOffset + 1] == 83) {
				b = content[stream.contentOffset + 2];
				if (b >= 65 && b <= 67)
					resolution = RECOILResolution.MSX2_PLUS1X1;
			}
		}
		if (!stream.skipUntilByte(0))
			return false;
		let platform = stream.readBits(16);
		let depth = stream.readBits(16);
		let width = stream.readBits(16);
		let height = stream.readBits(16);
		let pixelsLength = width * height;
		switch (platform) {
		case 0:
			if (!this.#setSize(width, height, resolution))
				return false;
			break;
		case 2:
			if (!this.#setSize(width, height, RECOILResolution.FM_TOWNS1X1))
				return false;
			stream.contentOffset += 6;
			break;
		case 17:
			return depth == 16 && this.#setSize(width, height, RECOILResolution.PC88_VA1X1) && this.#decodeX68KPicScreen(stream, pixelsLength, 17, 16);
		case 31:
			if (!this.#setSize(width, height, RECOILResolution.X68_K1X1))
				return false;
			stream.contentOffset += 6;
			break;
		case 33:
			if (depth != 16 || !this.#setSize(width, height << 1, RECOILResolution.PC88_VA1X1) || !this.#decodeX68KPicScreen(stream, pixelsLength, 33, 16))
				return false;
			for (let offset = pixelsLength - 1; offset >= 0; offset--) {
				let color = this.#pixels[offset];
				this.#pixels[(offset << 1) + 1] = RECOIL.#getG3R3B2Color(color >> 8);
				this.#pixels[offset << 1] = RECOIL.#getG3R3B2Color(color & 255);
			}
			return true;
		case 194:
			if (!this.#setSize(width, height, RECOILResolution.FM_TOWNS1X1))
				return false;
			break;
		default:
			return false;
		}
		switch (depth) {
		case 4:
		case 8:
			for (let c = 0; c < 1 << depth; c++) {
				let color = stream.readBits(16);
				if (color < 0)
					return false;
				this.contentPalette[c] = this.#restrictPlatformColor(RECOIL.#getX68KColor(color), 1 << depth);
			}
			break;
		case 15:
		case 16:
			break;
		default:
			return false;
		}
		return this.#decodeX68KPicScreen(stream, pixelsLength, 0, depth);
	}

	#setPc88EightPixels(column, y, b)
	{
		for (let x = 0; x < 8; x++) {
			let offset = y * 1280 + column + x;
			this.#pixels[offset + 640] = this.#pixels[offset] = (b >> (7 - x) & 65793) * 255;
		}
	}

	#decodeDaVinci(content, contentLength)
	{
		if ((contentLength & 255) != 0)
			return false;
		this.#setSize(640, 400, RECOILResolution.PC881X2);
		const rle = Object.assign(new DaVinciStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (let y = 0; y < 200; y++) {
			for (let column = 0; column < 640; column += 8) {
				let b = rle.readRle();
				if (b < 0)
					return false;
				this.#setPc88EightPixels(column, y, b);
			}
		}
		return rle.repeatCount == 0 && contentLength - rle.contentOffset < 256;
	}

	#decodeArtMaster88(content, contentLength)
	{
		if (contentLength < 42 || !RECOIL.isStringAt(content, 0, "SS_SIF    0.0") || content[19] != 66 || content[20] != 82 || content[21] != 71 || content[24] != 128 || content[25] != 2)
			return false;
		const rle = Object.assign(new ArtMaster88Stream(), { content: content, contentOffset: 40, contentLength: contentLength });
		if (content[16] == 73 && !rle.skipChunk())
			return false;
		switch (content[26] | content[27] << 8) {
		case 200:
			this.#setSize(640, 400, RECOILResolution.PC881X2);
			if (content[18] == 66 && !rle.skipChunk())
				return false;
			if (!rle.readPlanes(3, 16000))
				return false;
			for (let y = 0; y < 200; y++) {
				for (let column = 0; column < 80; column++) {
					let offset = y * 80 + column;
					this.#setPc88EightPixels(column << 3, y, rle.planes[1][offset] << 16 | rle.planes[2][offset] << 8 | rle.planes[0][offset]);
				}
			}
			break;
		case 400:
			this.#setSize(640, 400, RECOILResolution.PC981X1);
			if (content[17] != 82 || rle.contentOffset + 50 >= contentLength || content[rle.contentOffset + 1] != 0)
				return false;
			let paletteLength = content[rle.contentOffset];
			let planes;
			switch (paletteLength) {
			case 50:
				planes = 3;
				break;
			case 98:
				planes = 4;
				break;
			default:
				return false;
			}
			if (rle.contentOffset + paletteLength >= contentLength)
				return false;
			for (let c = 0; c < 1 << planes; c++) {
				let offset = rle.contentOffset + 2 + c * 6;
				let rgb = content[offset] << 16 | content[offset + 2] << 8 | content[offset + 4];
				if ((rgb & 15790320) != 0 || content[offset + 1] != 0 || content[offset + 3] != 0 || content[offset + 5] != 0)
					return false;
				this.contentPalette[c] = rgb * 17;
			}
			rle.contentOffset += paletteLength;
			if (content[18] == 66 && !rle.skipChunk())
				return false;
			if (!rle.readPlanes(planes, 32000))
				return false;
			for (let y = 0; y < 400; y++) {
				for (let column = 0; column < 80; column++) {
					let offset = y * 80 + column;
					for (let x = 0; x < 8; x++) {
						let c = 0;
						for (let plane = 0; plane < planes; plane++)
							c |= (rle.planes[plane][offset] >> (7 - x) & 1) << plane;
						this.#pixels[y * 640 + (column << 3) + x] = this.contentPalette[c];
					}
				}
			}
			break;
		default:
			return false;
		}
		return true;
	}

	static #getKtyTile(content, contentOffset)
	{
		return content[contentOffset + 1] << 16 | content[contentOffset + 2] << 8 | content[contentOffset];
	}

	#setKtyFourPixels(pixelsOffset, tile)
	{
		for (let x = 0; x < 4; x++)
			this.#pixels[pixelsOffset + x] = (tile >> (3 - x) & 65793) * 255;
	}

	#setKtyTileOffset(pixelsOffset, mode, content, tileOffset)
	{
		let tile = RECOIL.#getKtyTile(content, tileOffset);
		this.#setKtyFourPixels(pixelsOffset, tile >> 4);
		this.#setKtyFourPixels(pixelsOffset + 640, tile);
		if (mode != 0) {
			if (mode >= 2)
				tile = RECOIL.#getKtyTile(content, tileOffset + 3);
			this.#setKtyFourPixels(pixelsOffset + 1280, tile >> 4);
			this.#setKtyFourPixels(pixelsOffset + 1920, tile);
		}
	}

	#setKtyTile(x, y, mode, content, tileOffset)
	{
		if (mode != 0)
			y <<= 1;
		this.#setKtyTileOffset((y * 320 + x) << 2, mode, content, tileOffset);
	}

	#decodeKty(content, contentLength)
	{
		this.#setSize(640, 400, RECOILResolution.PC88_VA1X1);
		for (let i = 0; i < 256000; i += 4)
			this.#pixels[i] = 1;
		let mode = 0;
		for (let contentOffset = 0; contentOffset < contentLength;) {
			let b = content[contentOffset++];
			if (b == 255) {
				if (mode != 0)
					mode = 2;
				for (let y = 0; y < 100; y++) {
					for (let x = 0; x < 160; x++) {
						let pixelsOffset = (y * (mode == 0 ? 320 : 640) + x) << 2;
						if (this.#pixels[pixelsOffset] == 1) {
							let nextOffset = contentOffset + (mode == 0 ? 3 : 6);
							if (nextOffset > contentLength)
								return false;
							this.#setKtyTileOffset(pixelsOffset, mode, content, contentOffset);
							contentOffset = nextOffset;
						}
					}
				}
				if (contentOffset != contentLength)
					return false;
				if (mode == 0) {
					for (let pixelsOffset = 127360; pixelsOffset >= 0; pixelsOffset -= 640) {
						this.#pixels.set(this.#pixels.subarray(pixelsOffset, pixelsOffset + 640), (pixelsOffset << 1) + 640);
						this.#pixels.set(this.#pixels.subarray(pixelsOffset, pixelsOffset + 640), pixelsOffset << 1);
					}
					this.#resolution = RECOILResolution.PC881X2;
				}
				return true;
			}
			mode = b;
			let tileOffset = contentOffset;
			contentOffset += mode < 2 ? 3 : 6;
			for (;;) {
				if (contentOffset >= contentLength)
					return false;
				let hi = content[contentOffset++];
				if (hi == 255)
					break;
				if (contentOffset + 2 > contentLength)
					return false;
				let offset = (hi & 63) << 8 | content[contentOffset++];
				let left = offset % 160;
				let top = offset / 160 | 0;
				if (top >= 100)
					return false;
				let right;
				let bottom;
				if (hi >= 128) {
					right = left;
					bottom = content[contentOffset++];
				}
				else {
					right = content[contentOffset++];
					if (right < left || right >= 160)
						return false;
					if (hi >= 64)
						bottom = top;
					else if (contentOffset >= contentLength)
						return false;
					else {
						bottom = content[contentOffset++];
						if (bottom < top || bottom >= 100)
							return false;
					}
				}
				for (let y = top; y <= bottom; y++) {
					for (let x = left; x <= right; x++)
						this.#setKtyTile(x, y, mode, content, tileOffset);
				}
			}
			for (;;) {
				if (contentOffset >= contentLength)
					return false;
				let x = content[contentOffset++];
				if (x == 255)
					break;
				if (x >= 160 || contentOffset >= contentLength)
					return false;
				let y = content[contentOffset++];
				if (y >= 100)
					return false;
				this.#setKtyTile(x, y, mode, content, tileOffset);
			}
		}
		return false;
	}

	#decodeEbd(content, contentLength)
	{
		if (contentLength < 368 || contentLength % 320 != 48)
			return false;
		for (let c = 0; c < 16; c++) {
			let rgb = RECOIL.#getR8G8B8Color(content, c * 3);
			if (((rgb >> 4 ^ rgb) & 986895) != 0) {
				if ((rgb & 15790320) != 0)
					return false;
				rgb *= 17;
			}
			this.contentPalette[c] = rgb;
		}
		return this.#decodeAmigaPlanar(content, 48, 640, contentLength / 320 | 0, RECOILResolution.PC981X1, 4, this.contentPalette);
	}

	#decodeNl3(content, contentLength)
	{
		const stream = Object.assign(new Nl3Stream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (let i = 0; i < 64; i++) {
			let c = stream.readValue();
			if (c < 0 || c > 127)
				return false;
			c |= stream.readValue() << 7;
			if (c < 0 || c >= 729)
				return false;
			this.contentPalette[i] = RECOIL.#get729Color(c);
		}
		this.#setSize(160, 100, RECOILResolution.PC981X1);
		for (let x = 0; x < 160; x++) {
			for (let y = 0; y < 100; y++) {
				let b = stream.readRle();
				if (b < 0)
					return false;
				this.#pixels[y * 160 + x] = this.contentPalette[b];
			}
		}
		return true;
	}

	#decodeMl1Chain(stream, pixelsOffset, rgb)
	{
		for (;;) {
			switch (stream.readBit()) {
			case 0:
				break;
			case 1:
				switch (stream.readBits(2)) {
				case 0:
					pixelsOffset++;
					break;
				case 1:
					pixelsOffset--;
					break;
				case 2:
					return true;
				case 3:
					switch (stream.readBit()) {
					case 0:
						pixelsOffset += 2;
						break;
					case 1:
						pixelsOffset -= 2;
						break;
					default:
						return false;
					}
					break;
				default:
					return false;
				}
				break;
			default:
				return false;
			}
			pixelsOffset += this.#width;
			if (pixelsOffset < 0 || pixelsOffset >= this.#width * this.#height)
				return false;
			this.#pixels[pixelsOffset] = rgb;
		}
	}

	#decodeMl1Mx1(stream, imageOffset)
	{
		if (stream.readBits(32) != 825241626 || stream.readBits(32) < 0 || stream.readBits(16) < 0)
			return -1;
		let left = stream.readBits(16);
		let top = stream.readBits(16);
		let width = stream.readBits(16) - left + 1;
		let height = stream.readBits(16) - top + 1;
		for (let i = 0; i < 624; i++) {
			if (stream.readBit() < 0)
				return -1;
		}
		let mode = stream.readBits(2);
		let lastColor;
		switch (mode) {
		case 0:
			lastColor = 127;
			break;
		case 1:
		case 2:
			lastColor = stream.readBits(7);
			break;
		default:
			return -1;
		}
		if (imageOffset == -1) {
			if (!this.#setSize(width, height, RECOILResolution.PC981X1))
				return -1;
			imageOffset = 0;
		}
		this.contentPalette.fill(0);
		for (let i = 0; i <= lastColor; i++) {
			let j = 0;
			if (mode > 0)
				j = stream.readBits(7);
			let c = stream.readBits(10);
			if (c < 0 || c >= 729)
				return -1;
			this.contentPalette[mode == 1 ? j : i] = RECOIL.#get729Color(c);
		}
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++)
				this.#pixels[imageOffset + y * this.#width + x] = 1;
		}
		let distance = 1;
		let rgb = 0;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let pixelsOffset = imageOffset + y * this.#width + x;
				if (--distance > 0) {
					let old = this.#pixels[pixelsOffset];
					if (old == 1)
						this.#pixels[pixelsOffset] = rgb;
					else
						rgb = old;
				}
				else {
					distance = stream.readLength();
					if (distance < 0)
						return -1;
					let c = mode == 2 ? stream.readLength() - 1 : stream.readBits(7);
					if (c < 0 || c >= 128)
						return -1;
					rgb = this.contentPalette[c];
					switch (stream.readBit()) {
					case 0:
						break;
					case 1:
						if (!this.#decodeMl1Chain(stream, pixelsOffset, rgb))
							return -1;
						break;
					default:
						return -1;
					}
					this.#pixels[pixelsOffset] = rgb;
				}
			}
		}
		return distance == 1 && stream.readLength() == width * height + 1 ? height : -1;
	}

	#decodeMl1(content, contentLength)
	{
		const stream = Object.assign(new X68KPicStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		return this.#decodeMl1Mx1(stream, -1) > 0;
	}

	#decodeMx1Tiles(stream, width, height, shift)
	{
		if (!this.#setSize(width << shift, height << shift, RECOILResolution.PC981X1))
			return false;
		for (let y = 0; y < this.#height; y += height) {
			for (let x = 0; x < this.#width; x += width) {
				if (!stream.findImage() || this.#decodeMl1Mx1(stream, y * this.#width + x) < 0)
					return false;
			}
		}
		return true;
	}

	#decodeMx1(content, contentLength)
	{
		const stream = Object.assign(new Mx1Stream(), { content: content, contentOffset: 0, contentLength: contentLength });
		if (!stream.findImage() || this.#decodeMl1Mx1(stream, -1) < 0)
			return false;
		if (!stream.findImage())
			return true;
		let sameSizeImages = 1;
		let width = this.#width;
		let height = this.#height;
		do {
			if (this.#decodeMl1Mx1(stream, -1) < 0)
				return false;
			if (sameSizeImages > 0 && this.#width == width && this.#height == height)
				sameSizeImages++;
			else {
				if (width < this.#width)
					width = this.#width;
				if (sameSizeImages > 0) {
					height *= sameSizeImages;
					sameSizeImages = 0;
				}
				height += this.#height;
			}
		}
		while (stream.findImage());
		stream.contentOffset = 0;
		switch (sameSizeImages) {
		case 4:
			return this.#decodeMx1Tiles(stream, width, height, 1);
		case 16:
			return this.#decodeMx1Tiles(stream, width, height, 2);
		case 0:
			break;
		default:
			height *= sameSizeImages;
			break;
		}
		if (!this.#setSize(width, height, RECOILResolution.PC981X1))
			return false;
		this.#pixels.fill(0, 0, width * height);
		let imageOffset = 0;
		while (stream.findImage())
			imageOffset += this.#decodeMl1Mx1(stream, imageOffset) * width;
		return true;
	}

	#decodeZim(content, contentLength)
	{
		if (contentLength < 700 || !RECOIL.isStringAt(content, 0, "FORMAT-A"))
			return false;
		let contentOffset = 512 + ((content[506] | content[507] << 8) << 1);
		if (contentOffset + 26 > contentLength || content[contentOffset] != 0 || content[contentOffset + 1] != 0 || content[contentOffset + 2] != 0 || content[contentOffset + 3] != 0 || content[contentOffset + 20] != 1 || content[contentOffset + 21] != 0)
			return false;
		let width = content[contentOffset + 4] + (content[contentOffset + 5] << 8) + 1;
		let height = content[contentOffset + 6] + (content[contentOffset + 7] << 8) + 1;
		if (!this.#setSize(width, height, RECOILResolution.PC981X1))
			return false;
		contentOffset += 24;
		if (content[contentOffset - 2] != 0 || content[contentOffset - 1] != 0) {
			if (contentOffset + 66 > contentLength)
				return false;
			for (let c = 0; c < 16; c++) {
				this.contentPalette[c] = RECOIL.#getKtyTile(content, contentOffset);
				contentOffset += 4;
			}
		}
		else {
			for (let c = 0; c < 16; c++)
				this.contentPalette[c] = RECOIL.#getZxPaletteColor(c);
			this.contentPalette[8] = 16777215;
		}
		let pixelsLength = width * height;
		for (let pixelsOffset = 0; pixelsOffset < pixelsLength; pixelsOffset++)
			this.#pixels[pixelsOffset] = this.contentPalette[0];
		const flags3 = new Uint8Array(64);
		const data = new Uint8Array(512);
		const stream = Object.assign(new ZimStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
		let skip = stream.readWord();
		stream.contentOffset += skip << 1;
		for (;;) {
			let dot = stream.readWord();
			switch (dot) {
			case -1:
				return false;
			case 0:
				return true;
			default:
				break;
			}
			let x = stream.readWord();
			if (x < 0 || x >= width)
				return false;
			let y = stream.readWord();
			if (y < 0 || y >= height)
				return false;
			let len = stream.readWord();
			if (len < 0)
				return false;
			stream.contentLength = stream.contentOffset + len;
			if (stream.contentLength >= contentLength)
				return false;
			let size = stream.readWord();
			if (size > 512 || (size & 3) != 0 || size << 1 < dot)
				return false;
			let pixelsOffset = y * width + x;
			if (pixelsOffset + dot > pixelsLength)
				return false;
			stream.unpackFlags2();
			stream.unpack(stream.flags2, flags3, 64);
			stream.unpack(flags3, data, size);
			stream.contentLength = contentLength;
			for (let i = 1; i < size; i++)
				data[i] ^= data[i - 1];
			for (let i = 2; i < size; i++)
				data[i] ^= data[i - 2];
			size >>= 2;
			for (let i = 0; i < dot; i++) {
				let bit = ~i & 7;
				let c = (data[i >> 3] >> bit & 1) << 3 | (data[size + (i >> 3)] >> bit & 1) << 2 | (data[2 * size + (i >> 3)] >> bit & 1) << 1 | (data[3 * size + (i >> 3)] >> bit & 1);
				this.#pixels[pixelsOffset + i] = this.contentPalette[c];
			}
		}
	}

	#decodeQ4(content, contentLength)
	{
		if (contentLength < 22 || (content[2] != 2 && (content[1] > 1 || content[3] > 1)) || content[8] + (content[9] << 8) != contentLength || !RECOIL.isStringAt(content, 11, "MAJYO"))
			return false;
		const rle = Object.assign(new Q4Stream(), { content: content, contentOffset: 16, contentLength: contentLength });
		let nextChunkOffset = rle.startChunk();
		if (nextChunkOffset < 0 || !rle.unpackQ4())
			return false;
		for (let i = 0; i < 16; i++) {
			let rgb = 0;
			for (let c = 0; c < 3; c++) {
				if (rle.readRle() < 0)
					return false;
				let b = rle.readRle();
				if (b < 0)
					return false;
				rgb = rgb << 8 | b * 17;
			}
			this.contentPalette[(i & 8) | (i & 1) << 2 | (i >> 1 & 3)] = rgb;
		}
		this.#setSize(640, 400, RECOILResolution.PC981X1);
		let chunkPixels = 0;
		for (let i = 0; i < 256000; i++) {
			if (--chunkPixels <= 0) {
				if (nextChunkOffset >= contentLength - 6)
					return false;
				chunkPixels = (content[nextChunkOffset + 4] | content[nextChunkOffset + 5] << 8) << 1;
				rle.content = content;
				rle.contentOffset = nextChunkOffset;
				rle.contentLength = contentLength;
				nextChunkOffset = rle.startChunk();
				if (nextChunkOffset < 0 || !rle.unpackQ4())
					return false;
			}
			this.#pixels[i] = this.contentPalette[Math.max(rle.readRle(), 0)];
		}
		return true;
	}

	static #packPiPlatform(s)
	{
		return s.charCodeAt(0) | s.charCodeAt(1) << 8 | s.charCodeAt(2) << 16 | s.charCodeAt(3) << 24;
	}

	static #getPiPlatform(content, contentOffset, highPixel)
	{
		switch (RECOIL.get32LittleEndian(content, contentOffset)) {
		case 1314344788:
			return RECOILResolution.FM_TOWNS1X1;
		case 808993616:
			return RECOILResolution.PC801X2;
		case 943211344:
			return RECOILResolution.PC881X2;
		case 1096172368:
			return highPixel ? RECOILResolution.PC881X2 : RECOILResolution.PC88_VA1X1;
		case 827872077:
		case 844649293:
		case 1347965773:
		case 1381520205:
			return highPixel ? RECOILResolution.MSX21X2 : RECOILResolution.MSX21X1;
		case 1261975128:
			return RECOILResolution.X68_K1X1;
		default:
			return highPixel ? RECOILResolution.PC881X2 : RECOILResolution.PC981X1;
		}
	}

	#setPiPalette(content, paletteOffset, colors, rOffset)
	{
		for (let c = 0; c < colors; c++) {
			let offset = paletteOffset + c * 3;
			this.contentPalette[c] = this.#restrictPlatformColor(content[offset + rOffset] << 16 | content[offset + 1 - rOffset] << 8 | content[offset + 2], colors);
		}
	}

	#decodePi(content, contentLength)
	{
		if (contentLength < 18 || content[0] != 80 || content[1] != 105)
			return false;
		const s = Object.assign(new PiStream(), { content: content, contentOffset: 2, contentLength: contentLength });
		if (!s.skipUntilByte(26) || !s.skipUntilByte(0))
			return false;
		let contentOffset = s.contentOffset;
		if (contentOffset + 14 > contentLength || content[contentOffset] != 0)
			return false;
		let depth = content[contentOffset + 3];
		if (depth != 4 && depth != 8)
			return false;
		let resolution = RECOIL.#getPiPlatform(content, contentOffset + 4, content[contentOffset + 1] == 2 && content[contentOffset + 2] == 1);
		contentOffset += 8 + (content[contentOffset + 8] << 8) + content[contentOffset + 9];
		if (contentOffset + 6 >= contentLength)
			return false;
		let width = content[contentOffset + 2] << 8 | content[contentOffset + 3];
		let height = content[contentOffset + 4] << 8 | content[contentOffset + 5];
		if (!this.#setScaledSize(width, height, resolution))
			return false;
		s.contentOffset = contentOffset + 6 + (3 << depth);
		if (s.unpack(width, height, depth)) {
			this.#setPiPalette(content, contentOffset + 6, 1 << depth, 0);
			this.#decodeBytes(s.indexes, 0);
			return true;
		}
		return false;
	}

	#decodeMaki1(content, contentLength)
	{
		if (contentLength < 1096 || content[40] != 0 || content[41] != 0 || content[42] != 0 || content[43] != 0 || content[44] != 2 || content[45] != 128 || content[46] != 1 || content[47] != 144)
			return false;
		this.#setSize(640, 400, RECOIL.#getPiPlatform(content, 8, false));
		this.#setPiPalette(content, 48, 16, 1);
		let contentOffset = 1096;
		const haveBuffer = new Uint16Array(8000);
		const haveBlock = Object.assign(new BitStream(), { content: content, contentOffset: 96, contentLength: 1096 });
		for (let i = 0; i < 8000; i++) {
			let have = 0;
			if (haveBlock.readBit() == 1) {
				if (contentOffset + 1 >= contentLength)
					return false;
				have = content[contentOffset] << 8 | content[contentOffset + 1];
				contentOffset += 2;
			}
			haveBuffer[i] = have;
		}
		let xorYOffset = content[6] == 65 ? 2 : 0;
		const indexBuffer = new Uint8Array(1280);
		for (let y = 0; y < 400; y++) {
			for (let x = 0; x < 320; x++) {
				let row = y & 3;
				let index = indexBuffer[(row ^ xorYOffset) * 320 + x];
				if ((haveBuffer[(y & ~3) * 20 + (x >> 2)] >> (15 - (row << 2) - (x & 3)) & 1) != 0) {
					if (contentOffset >= contentLength)
						return false;
					index ^= content[contentOffset++];
				}
				indexBuffer[row * 320 + x] = index;
				let pixelsOffset = (y * 320 + x) << 1;
				this.#pixels[pixelsOffset] = this.contentPalette[index >> 4];
				this.#pixels[pixelsOffset + 1] = this.contentPalette[index & 15];
			}
		}
		return true;
	}

	static #unpackMag(content, headerOffset, contentLength, bytesPerLine, height, unpacked)
	{
		const haveDelta = Object.assign(new BitStream(), { content: content, contentOffset: headerOffset + RECOIL.get32LittleEndian(content, headerOffset + 12), contentLength: contentLength });
		let deltaOffset = headerOffset + RECOIL.get32LittleEndian(content, headerOffset + 16);
		let colorOffset = headerOffset + RECOIL.get32LittleEndian(content, headerOffset + 24);
		if (haveDelta.contentOffset < 0 || deltaOffset < 0 || colorOffset < 0)
			return false;
		let deltas = new Uint8Array((bytesPerLine + 3) >> 2);
		deltas.fill(0, 0, (bytesPerLine + 3) >> 2);
		for (let y = 0; y < height; y++) {
			let delta = 0;
			for (let x = 0; x < bytesPerLine; x++) {
				if ((x & 1) == 0) {
					delta = deltas[x >> 2];
					if ((x & 2) == 0) {
						switch (haveDelta.readBit()) {
						case 0:
							break;
						case 1:
							if (deltaOffset >= contentLength)
								return false;
							delta ^= content[deltaOffset++];
							deltas[x >> 2] = delta;
							break;
						default:
							return false;
						}
						delta >>= 4;
					}
					else
						delta &= 15;
				}
				if (delta == 0) {
					if (colorOffset >= contentLength)
						return false;
					unpacked[y * bytesPerLine + x] = content[colorOffset++];
				}
				else {
					let sourceX = x - RECOIL.#UNPACK_MAG_DELTA_X[delta];
					let sourceY = y - RECOIL.#UNPACK_MAG_DELTA_Y[delta];
					if (sourceX < 0 || sourceY < 0)
						return false;
					unpacked[y * bytesPerLine + x] = unpacked[sourceY * bytesPerLine + sourceX];
				}
			}
			if ((bytesPerLine & 1) != 0 && delta == 0)
				colorOffset++;
			if (((bytesPerLine + 1) & 2) != 0 && (deltas[bytesPerLine >> 2] & 15) == 0)
				colorOffset += 2;
		}
		return true;
	}

	#decodeMag(content, contentLength)
	{
		if (contentLength < 8)
			return false;
		if (RECOIL.isStringAt(content, 0, "MAKI01A ") || RECOIL.isStringAt(content, 0, "MAKI01B "))
			return this.#decodeMaki1(content, contentLength);
		if (!RECOIL.isStringAt(content, 0, "MAKI02  "))
			return false;
		let headerOffset = 0;
		do {
			if (headerOffset >= contentLength)
				return false;
		}
		while (content[headerOffset++] != 26);
		if (headerOffset + 80 > contentLength || content[headerOffset] != 0)
			return false;
		let left = content[headerOffset + 4] + (content[headerOffset + 5] << 8);
		let width = content[headerOffset + 8] + (content[headerOffset + 9] << 8) + 1;
		let bytesPerLine;
		let colors;
		if (content[headerOffset + 3] < 128) {
			width -= left & ~7;
			bytesPerLine = (width + 1) >> 1;
			colors = 16;
		}
		else {
			if (headerOffset + 800 >= contentLength)
				return false;
			bytesPerLine = width -= left & ~3;
			colors = 256;
		}
		let resolution;
		let msxMode = 0;
		switch (content[headerOffset + 1]) {
		case 0:
		case 136:
			resolution = (content[headerOffset + 3] & 1) == 0 ? RECOILResolution.PC88_VA1X1 : RECOILResolution.PC881X2;
			break;
		case 3:
			msxMode = content[headerOffset + 2] & 252;
			switch (msxMode) {
			case 0:
			case 20:
			case 84:
				resolution = RECOILResolution.MSX21X1;
				break;
			case 4:
				resolution = RECOILResolution.MSX21X2;
				break;
			case 16:
			case 80:
				resolution = RECOILResolution.MSX22X1I;
				break;
			case 32:
			case 64:
				if (colors == 16)
					width >>= 1;
				resolution = RECOILResolution.MSX2_PLUS2X1I;
				break;
			case 36:
			case 68:
				if (colors == 16)
					width >>= 1;
				resolution = RECOILResolution.MSX2_PLUS1X1;
				break;
			case 96:
				width = bytesPerLine << 2;
				resolution = RECOILResolution.MSX21X1I;
				break;
			case 100:
				width = bytesPerLine << 2;
				resolution = RECOILResolution.MSX21X2;
				break;
			default:
				return false;
			}
			break;
		case 98:
		case 112:
			resolution = RECOILResolution.PC981X1;
			break;
		case 104:
			resolution = RECOILResolution.X68_K1X1;
			break;
		case 128:
			resolution = RECOILResolution.PC801X2;
			break;
		case 153:
			resolution = RECOILResolution.MACINTOSH1X1;
			break;
		default:
			resolution = (content[headerOffset + 3] & 1) == 0 ? RECOILResolution.MSX21X1 : RECOILResolution.MSX21X2;
			break;
		}
		let height = content[headerOffset + 10] - content[headerOffset + 6] + ((content[headerOffset + 11] - content[headerOffset + 7]) << 8) + 1;
		if (!this.#setScaledSize(width, height, resolution))
			return false;
		let unpacked = new Uint8Array(bytesPerLine * height);
		if (!RECOIL.#unpackMag(content, headerOffset, contentLength, bytesPerLine, height, unpacked))
			return false;
		this.#setPiPalette(content, headerOffset + 32, colors, 1);
		switch (msxMode) {
		case 32:
		case 36:
			this.#decodeMsxYjkScreen(unpacked, 0, true);
			break;
		case 64:
		case 68:
			this.#decodeMsxYjkScreen(unpacked, 0, false);
			break;
		case 96:
		case 100:
			this.#decodeMsx6(unpacked, 0);
			break;
		default:
			if (colors == 16)
				this.#decodeNibbles(unpacked, 0, bytesPerLine);
			else
				this.#decodeBytes(unpacked, 0);
			break;
		}
		return true;
	}

	#decodeVbm(content, contentLength)
	{
		if (contentLength < 9 || content[0] != 66 || content[1] != 77 || content[2] != 203)
			return false;
		let width = content[4] << 8 | content[5];
		let height = content[6] << 8 | content[7];
		if (!this.#setSize(width, height, RECOILResolution.C1281X1))
			return false;
		switch (content[3]) {
		case 2:
			return this.#decodeBlackAndWhite(content, 8, contentLength, false, 16777215);
		case 3:
			if (contentLength < 19)
				return false;
			let contentOffset = 18 + (content[16] << 8) + content[17];
			if (content[8] == 0)
				return this.#decodeBlackAndWhite(content, contentOffset, contentLength, false, 0);
			const rle = Object.assign(new VbmStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
			return this.#decodeRleBlackAndWhite(rle, 0);
		default:
			return false;
		}
	}

	#decodeBrus(content, contentLength)
	{
		if (contentLength < 20 || !RECOIL.isStringAt(content, 2, "BRUS") || content[6] != 4 || content[10] != 1 || content[11] != 2)
			return false;
		let columns = content[12];
		if (columns == 0 || columns > 90)
			return false;
		let height = content[13] | content[14] << 8;
		if (height == 0 || height > 700)
			return false;
		let width = columns << 3;
		this.#setSize(width, height, RECOILResolution.C1281X1);
		let bitmapLength = height * columns;
		const bitmap = new Uint8Array(63000);
		const rle = Object.assign(new PgcStream(), { content: content, contentOffset: 18, contentLength: contentLength });
		if (!rle.unpack(bitmap, 0, 1, bitmapLength))
			return false;
		let contentOffset = rle.contentOffset;
		if (contentOffset + 4 >= contentLength || !RECOIL.isStringAt(content, contentOffset, "COLR")) {
			return this.#decodeBlackAndWhite(bitmap, 0, bitmapLength, false, 16777215);
		}
		rle.contentOffset = contentOffset + 4;
		const colors = new Uint8Array(180);
		for (let y = 0; y < height; y++) {
			if ((y & 7) == 0 && !rle.unpack(colors, 0, 1, columns << 1))
				return false;
			for (let x = 0; x < width; x++) {
				let column = x >> 3;
				let c = colors[(y & 1) * columns + column];
				if ((bitmap[y * columns + column] >> (~x & 7) & 1) == 0)
					c >>= 4;
				this.#pixels[y * width + x] = RECOIL.#DECODE_BRUS_PALETTE[c & 15];
			}
		}
		return true;
	}

	static #VIC20_PALETTE = new Int32Array([ 0, 16777215, 7152423, 10551032, 9321623, 8313461, 2433936, 16777094, 10773563, 16763041, 15902635, 14417919, 16758015, 14155726, 10328831, 16777161 ]);

	#decodeBp(content, contentLength)
	{
		if (contentLength != 4083 || content[0] != 0 || content[1] != 17)
			return false;
		this.#setSize(160, 192, RECOILResolution.VIC201X1);
		let screenColor = content[4082] >> 4;
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 160; x++) {
				let c;
				if ((content[2 + (((x >> 3) * 12 + (y >> 4)) << 4) + (y & 15)] >> (~x & 7) & 1) == 0)
					c = screenColor;
				else {
					c = content[3842 + (y >> 4) * 20 + (x >> 3)] & 15;
					if (c >= 8)
						return false;
				}
				this.#pixels[y * 160 + x] = RECOIL.#VIC20_PALETTE[c];
			}
		}
		return true;
	}

	#decodePic0(filename, content, contentLength)
	{
		if (contentLength != 3890 || content[0] != 0 || content[1] != 13 || content[3876] != 150 || content[3877] != 23 || content[3879] != 140)
			return false;
		const colors = new Uint8Array(245);
		if (this.#readCompanionFile(filename, "PIC1", "pic1", colors, 245) != 244)
			return false;
		this.#setSize(176, 176, RECOILResolution.VIC202X1);
		for (let y = 0; y < 176; y++) {
			for (let x = 0; x < 176; x++) {
				let charOffset = (y >> 4) * 22 + (x >> 3);
				let c = colors[2 + charOffset];
				if ((c & 8) == 0)
					return false;
				switch (content[2 + (charOffset << 4) + (y & 15)] >> (~x & 6) & 3) {
				case 0:
					c = content[3889] >> 4;
					break;
				case 1:
					c = content[3889] & 7;
					break;
				case 2:
					c &= 7;
					break;
				default:
					c = content[3888] >> 4;
					break;
				}
				this.#pixels[y * 176 + x] = RECOIL.#VIC20_PALETTE[c];
			}
		}
		return true;
	}

	#decodeVic20Mg(content, contentLength)
	{
		if (contentLength != 4097 || content[0] != 241 || content[1] != 16 || content[2] != 12 || content[3] != 18 || content[4] != 216 || content[5] != 7 || content[6] != 158 || content[7] != 32 || content[8] != 56 || content[9] != 53 || content[10] != 56 || content[11] != 52 || content[12] != 0 || content[13] != 0 || content[14] != 0)
			return false;
		this.#setSize(160, 192, RECOILResolution.VIC202X1);
		const palette = new Uint8Array(4);
		palette[0] = content[16] >> 4;
		palette[1] = content[16] & 7;
		palette[3] = content[15] >> 4;
		let invert = ~(content[16] >> 3) & 1;
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 160; x++) {
				palette[2] = content[3857 + (y >> 4) * 10 + (x >> 4)] >> (x >> 1 & 4) & 15;
				let b = content[17 + (x >> 3) * 192 + y];
				if (palette[2] >= 8) {
					palette[2] &= 7;
					b = b >> (~x & 6) & 3;
				}
				else {
					this.#resolution = RECOILResolution.VIC201X1;
					b = ((b >> (~x & 7) & 1) ^ invert) << 1;
				}
				this.#pixels[y * 160 + x] = RECOIL.#VIC20_PALETTE[palette[b]];
			}
		}
		return true;
	}

	#decodeP4i(content, contentLength)
	{
		switch (contentLength) {
		case 10050:
			if (RECOIL.isStringAt(content, 1020, "MULT")) {
				this.#setSize(320, 200, RECOILResolution.C162X1);
				for (let y = 0; y < 200; y++) {
					for (let x = 0; x < 320; x++) {
						let offset = (y & ~7) * 40 + (x & ~7) + (y & 7);
						let c = content[2050 + offset] >> (~x & 6) & 3;
						switch (c) {
						case 0:
							c = (content[1025] & 7) << 4 | content[1025] >> 4;
							break;
						case 1:
							offset >>= 3;
							c = (content[2 + offset] & 7) << 4 | content[1026 + offset] >> 4;
							break;
						case 2:
							offset >>= 3;
							c = (content[2 + offset] & 112) | (content[1026 + offset] & 15);
							break;
						default:
							c = (content[1024] & 7) << 4 | content[1024] >> 4;
							break;
						}
						this.#pixels[y * 320 + x] = this.#c16Palette[c];
					}
				}
			}
			else {
				this.#setSize(320, 200, RECOILResolution.C161X1);
				for (let y = 0; y < 200; y++) {
					for (let x = 0; x < 320; x++) {
						let offset = (y & ~7) * 40 + (x & ~7) + (y & 7);
						let c = content[2050 + offset] >> (~x & 7) & 1;
						offset >>= 3;
						if (c == 0)
							c = (content[2 + offset] & 112) | (content[1026 + offset] & 15);
						else
							c = (content[2 + offset] & 7) << 4 | content[1026 + offset] >> 4;
						this.#pixels[y * 320 + x] = this.#c16Palette[c];
					}
				}
			}
			break;
		case 2050:
			this.#setSize(256, 64, RECOILResolution.C162X1);
			for (let y = 0; y < 64; y++) {
				for (let x = 0; x < 256; x++) {
					let c = RECOIL.#DECODE_P4I_LOGO_COLORS[content[2 + ((x & ~7) << 3) + y] >> (~x & 6) & 3];
					this.#pixels[(y << 8) + x] = this.#c16Palette[c];
				}
			}
			break;
		default:
			return false;
		}
		return true;
	}

	#decodeZs(content, contentLength)
	{
		if (contentLength != 1026 || content[0] != 176 || content[1] != 240)
			return false;
		this.#setSize(256, 32, RECOILResolution.C641X1);
		for (let y = 0; y < 32; y++) {
			for (let x = 0; x < 256; x++) {
				let c = y >> 3 << 5 | x >> 3;
				if (c < 113) {
					c = content[3 + c * 9 + (y & 7)] >> (~x & 7) & 1;
					if (c != 0)
						c = 16777215;
				}
				else
					c = 0;
				this.#pixels[(y << 8) + x] = c;
			}
		}
		return true;
	}

	#decodeG(content, contentLength)
	{
		if (contentLength != 514 || content[0] != 66 || content[1] != 0)
			return false;
		this.#setSize(256, 16, RECOILResolution.C641X1);
		this.#decodeBlackAndWhiteFont(content, 2, 514, 8);
		return true;
	}

	#decode64c(content, contentLength)
	{
		if (contentLength < 10 || contentLength > 2050 || content[0] != 0)
			return false;
		this.#setSize(256, (contentLength + 253) >> 8 << 3, RECOILResolution.C641X1);
		this.#decodeBlackAndWhiteFont(content, 2, contentLength, 8);
		return true;
	}

	#decodePrintfox(content, contentLength)
	{
		if (contentLength < 4)
			return false;
		let columns;
		let rows;
		const rle = Object.assign(new PrintfoxStream(), { content: content, contentOffset: 1, contentLength: contentLength });
		switch (content[0]) {
		case 66:
			columns = 40;
			rows = 25;
			break;
		case 71:
			columns = 80;
			rows = 50;
			break;
		case 80:
			columns = content[2];
			rows = content[1];
			if (!rle.skipUntilByte(0))
				return false;
			break;
		default:
			return false;
		}
		if (!this.#setSize(columns << 3, rows << 3, RECOILResolution.C641X1))
			return false;
		for (let row = 0; row < rows; row++) {
			for (let column = 0; column < columns; column++) {
				for (let y = 0; y < 8; y++) {
					let b = rle.readRle();
					if (b < 0)
						return false;
					for (let x = 0; x < 8; x++)
						this.#pixels[((((row << 3) + y) * columns + column) << 3) + x] = (b >> (7 - x) & 1) == 0 ? 16777215 : 0;
				}
			}
		}
		return true;
	}

	#decodeC64FourColor(content, contentOffset, frame)
	{
		for (let y = 0; y < this.#height; y++) {
			for (let x = 0; x < 320; x++) {
				let i = x - frame;
				let c = i < 0 ? 0 : content[contentOffset + (y & ~7) * 40 + (i & ~7) + (y & 7)] >> (~i & 6) & 3;
				this.#pixels[(frame * this.#height + y) * 320 + x] = this.contentPalette[c];
			}
		}
	}

	#decodeCle(content, contentLength)
	{
		if (contentLength != 8194)
			return false;
		this.#setSize(320, 200, RECOILResolution.C641X1);
		this.contentPalette[0] = this.#c64Palette[content[8004] & 15];
		this.contentPalette[1] = this.#c64Palette[content[8002] >> 4];
		this.contentPalette[2] = this.#c64Palette[content[8002] & 15];
		this.contentPalette[3] = this.#c64Palette[content[8003] & 15];
		this.#decodeC64FourColor(content, 2, 0);
		return true;
	}

	#decodeIle(content, contentLength)
	{
		if (contentLength != 4098)
			return false;
		this.#setSize(320, 48, RECOILResolution.C641X1, 2);
		for (let i = 0; i < 4; i++)
			this.contentPalette[i] = this.#c64Palette[content[4094 + i] & (i < 3 ? 15 : 7)];
		this.#decodeC64FourColor(content, 2050, 0);
		this.#decodeC64FourColor(content, 2, 1);
		return this.#applyBlend();
	}

	#decodeCfli(content, contentLength)
	{
		if (contentLength != 8170)
			return false;
		this.#setSize(296, 200, RECOILResolution.C641X1);
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 296; x++)
				this.#pixels[y * 296 + x] = this.#c64Palette[content[5 + ((y & 7) << 10) + (y & ~7) * 5 + (x >> 3)] >> ((~x & 1) << 2) & 15];
		}
		return true;
	}

	static #isGodot(content, contentLength)
	{
		return content[0] == 71 && content[1] == 79 && content[2] == 68 && content[contentLength - 1] == 173;
	}

	#decodeGodot(width, height, content, contentOffset, contentLength, compressed)
	{
		if (!this.#setSize(width, height, RECOILResolution.C641X1))
			return false;
		const rle = Object.assign(new UflStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength, escape: 173 });
		for (let row = 0; row < height; row += 8) {
			for (let column = 0; column < width; column += 8) {
				for (let y = 0; y < 8; y++) {
					let pixelsOffset = (row + y) * width + column;
					for (let x = 0; x < 4; x++) {
						let b = compressed ? rle.readRle() : rle.readByte();
						if (b < 0)
							return false;
						this.#pixels[pixelsOffset++] = this.#c64Palette[RECOIL.#DECODE_GODOT_BY_BRIGHTNESS[b >> 4]];
						this.#pixels[pixelsOffset++] = this.#c64Palette[RECOIL.#DECODE_GODOT_BY_BRIGHTNESS[b & 15]];
					}
				}
			}
		}
		return true;
	}

	#decode4bt(content, contentLength)
	{
		if (contentLength < 5)
			return false;
		if (contentLength == 32002 && content[0] == 0)
			return this.#decodeGodot(320, 200, content, 2, contentLength, false);
		return content[3] == 48 && RECOIL.#isGodot(content, contentLength) && this.#decodeGodot(320, 200, content, 4, contentLength - 1, true);
	}

	#decodeGodotClp(content, contentLength)
	{
		return contentLength >= 9 && content[3] == 49 && RECOIL.#isGodot(content, contentLength) && this.#decodeGodot(content[6] << 3, content[7] << 3, content, 8, contentLength - 1, true);
	}

	#decodeC64HiresFrame(content, bitmapOffset, videoMatrixOffset, afli, stride, pixelsOffset)
	{
		for (let y = 0; y < this.#height; y++) {
			for (let x = 0; x < this.#width; x++) {
				let offset = (y & ~7) * stride + (x & ~7) + (y & 7);
				let c = content[bitmapOffset + offset] >> (~x & 7) & 1;
				let v;
				if (videoMatrixOffset >= 0) {
					offset >>= 3;
					if (afli)
						offset += (y & 7) << 10;
					v = content[videoMatrixOffset + offset];
				}
				else
					v = -videoMatrixOffset;
				c = c == 0 ? v & 15 : v >> 4;
				this.#pixels[pixelsOffset + y * this.#width + x] = this.#c64Palette[c];
			}
		}
	}

	#decodeC64Hires(content, bitmapOffset, videoMatrixOffset)
	{
		this.#setSize(320, 200, RECOILResolution.C641X1);
		this.#decodeC64HiresFrame(content, bitmapOffset, videoMatrixOffset, false, 40, 0);
		return true;
	}

	#decodeRpo(content, contentLength)
	{
		return contentLength == 8002 && this.#decodeC64Hires(content, 2, -1);
	}

	#decodeGr(content, contentLength)
	{
		if (contentLength < 10)
			return false;
		let columns = content[0];
		let height = content[1] << 3;
		if (contentLength != 2 + columns * height || !this.#setSize(columns << 3, height, RECOILResolution.C641X1))
			return false;
		this.#decodeC64HiresFrame(content, 2, -1, false, columns, 0);
		return true;
	}

	#decodeC64Hir(content, contentLength)
	{
		switch (contentLength) {
		case 8002:
		case 8194:
			return this.#decodeC64Hires(content, 2, -16);
		default:
			return false;
		}
	}

	#decodeIph(content, contentLength)
	{
		switch (contentLength) {
		case 9002:
		case 9003:
		case 9009:
			return this.#decodeC64Hires(content, 2, 8002);
		default:
			return false;
		}
	}

	#decodeHed(content)
	{
		return this.#decodeC64Hires(content, 2, 8194);
	}

	#decodeJj(content, contentLength)
	{
		const unpacked = new Uint8Array(9024);
		const rle = Object.assign(new C64KoalaStream(), { content: content, contentOffset: 2, contentLength: contentLength });
		return rle.unpack(unpacked, 0, 1, 9024) && this.#decodeC64Hires(unpacked, 1024, 0);
	}

	#decodeDd(content, contentLength)
	{
		switch (contentLength) {
		case 9026:
		case 9217:
		case 9218:
		case 9346:
			return this.#decodeC64Hires(content, 1026, 2);
		default:
			return this.#decodeJj(content, contentLength);
		}
	}

	#getC64Multicolor(content, bitmapOffset, videoMatrixOffset, colorOffset, background, bottomBfli, x, y, strideColumns)
	{
		x += this.#leftSkip;
		if (x < 0)
			return background;
		let charOffset = (y >> 3) * strideColumns + (x >> 3);
		if (bottomBfli)
			charOffset = (charOffset - 21) & 1023;
		switch (content[bitmapOffset + (charOffset << 3) + (y & 7)] >> (~x & 6) & 3) {
		case 1:
			return content[videoMatrixOffset + charOffset] >> 4;
		case 2:
			return content[videoMatrixOffset + charOffset];
		case 3:
			return colorOffset < 0 ? content[-colorOffset] : content[colorOffset + charOffset];
		default:
			return background;
		}
	}

	#decodeC64MulticolorLine(content, bitmapOffset, videoMatrixOffset, colorOffset, background, bottomBfli, y, pixelsOffset, width, strideColumns)
	{
		for (let x = 0; x < width; x++)
			this.#pixels[pixelsOffset + x] = this.#c64Palette[this.#getC64Multicolor(content, bitmapOffset, videoMatrixOffset, colorOffset, background, bottomBfli, x, y, strideColumns) & 15];
	}

	#decodeC64MulticolorFrame(content, bitmapOffset, videoMatrixOffset, colorOffset, backgroundOffset, pixelsOffset)
	{
		let background = backgroundOffset < 0 ? 0 : content[backgroundOffset];
		for (let y = 0; y < 200; y++)
			this.#decodeC64MulticolorLine(content, bitmapOffset, videoMatrixOffset, colorOffset, background, false, y, pixelsOffset + y * 320, 320, 40);
	}

	#decodeC64Multicolor(content, bitmapOffset, videoMatrixOffset, colorOffset, backgroundOffset)
	{
		this.#setSize(320, 200, RECOILResolution.C642X1);
		this.#decodeC64MulticolorFrame(content, bitmapOffset, videoMatrixOffset, colorOffset, backgroundOffset, 0);
		return true;
	}

	#decodeIpt(content)
	{
		return this.#decodeC64Multicolor(content, 2, 8002, 9002, 10002);
	}

	#decodeOcp(content, contentLength)
	{
		return contentLength == 10018 && this.#decodeC64Multicolor(content, 2, 8002, 9018, 9003);
	}

	#decodeBpl(content, contentLength)
	{
		return contentLength == 10242 && this.#decodeC64Multicolor(content, 2, 8194, 9218, 8066);
	}

	#decodeC64MulticolorFliFrame(content, bitmapOffset, videoMatrixOffset, colorOffset, background, bottomBfli, pixelsOffset)
	{
		for (let y = 0; y < 200; y++)
			this.#decodeC64MulticolorLine(content, bitmapOffset, videoMatrixOffset + ((y & 7) << 10), colorOffset, background, bottomBfli, y, pixelsOffset + y * 296, 296, 40);
	}

	#decodeC64MulticolorFliBarsFrame(content, bitmapOffset, videoMatrixOffset, colorOffset, backgroundOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++)
			this.#decodeC64MulticolorLine(content, bitmapOffset, videoMatrixOffset + ((y & 7) << 10), colorOffset, content[backgroundOffset + y], false, y, pixelsOffset + y * 296, 296, 40);
	}

	#decodeC64MulticolorFli(content, bitmapOffset, videoMatrixOffset, colorOffset, background)
	{
		this.#setSize(296, 200, RECOILResolution.C642X1);
		this.#decodeC64MulticolorFliFrame(content, bitmapOffset + 24, videoMatrixOffset + 3, colorOffset + 3, background, false, 0);
		return true;
	}

	#decodeC64MulticolorFliBars(content, bitmapOffset, videoMatrixOffset, colorOffset, backgroundOffset)
	{
		this.#setSize(296, 200, RECOILResolution.C642X1);
		this.#decodeC64MulticolorFliBarsFrame(content, bitmapOffset + 24, videoMatrixOffset + 3, colorOffset + 3, backgroundOffset, 0);
		return true;
	}

	#decodeHfc(content, contentLength)
	{
		if (contentLength != 16386)
			return false;
		this.#setSize(296, 112, RECOILResolution.C641X1);
		this.#decodeC64HiresFrame(content, 26, 8197, true, 40, 0);
		return true;
	}

	#decodeAfl(content, contentLength)
	{
		if (contentLength != 16385)
			return false;
		this.#setSize(296, 200, RECOILResolution.C641X1);
		this.#decodeC64HiresFrame(content, 8218, 5, true, 40, 0);
		return true;
	}

	#decodePmg(content, contentLength)
	{
		return contentLength == 9332 && this.#decodeC64Multicolor(content, 116, 8308, -8119, 8116);
	}

	#decodeKoa(content, contentLength)
	{
		switch (contentLength) {
		case 10001:
			return this.#decodeC64Multicolor(content, 0, 8000, 9000, 10000);
		case 10003:
		case 10006:
			return this.#decodeIpt(content);
		default:
			return this.#decodeGg(content, contentLength);
		}
	}

	#decodeZom(content, contentLength)
	{
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(10001);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength - 1, escape: content[contentLength - 1] });
		return rle.unpackBackwards(unpacked, 0, 10000) && this.#decodeKoa(unpacked, 10001);
	}

	#decodeKoaPacked(rle)
	{
		const unpacked = new Uint8Array(10001);
		return rle.unpack(unpacked, 0, 1, 10001) && this.#decodeKoa(unpacked, 10001);
	}

	#decodeGg(content, contentLength)
	{
		if (contentLength < 2)
			return false;
		const rle = Object.assign(new C64KoalaStream(), { content: content, contentOffset: 2, contentLength: contentLength });
		return this.#decodeKoaPacked(rle);
	}

	#decodeDol(content, contentLength)
	{
		switch (contentLength) {
		case 10241:
		case 10242:
		case 10050:
			return this.#decodeC64Multicolor(content, 2050, 1026, 2, 2026);
		default:
			return false;
		}
	}

	#decodeAmi(content, contentLength)
	{
		if (contentLength < 2)
			return false;
		const rle = Object.assign(new DrpStream(), { content: content, contentOffset: 2, contentLength: contentLength, escape: 194 });
		return this.#decodeKoaPacked(rle);
	}

	#decodeBdp(content, contentLength)
	{
		if (contentLength < 13)
			return false;
		if (content[2] == 2 && content[3] == 4 && content[4] == 16 && content[5] == 54 && content[6] == 48 && content[7] == 48) {
			const rle = Object.assign(new UflStream(), { content: content, contentOffset: 10, contentLength: contentLength, escape: content[8] });
			return this.#decodeKoaPacked(rle);
		}
		if (RECOIL.isStringAt(content, 2, "BDP 5.00")) {
			const rle = Object.assign(new Bdp5Stream(), { content: content, contentOffset: 12, contentLength: contentLength });
			return this.#decodeKoaPacked(rle);
		}
		else {
			const rle = Object.assign(new Bdp4Stream(), { content: content, contentOffset: 2, contentLength: contentLength });
			return this.#decodeKoaPacked(rle);
		}
	}

	#decodeMwi(content, contentLength)
	{
		if (contentLength < 7)
			return false;
		let width = content[3] << 1;
		let height = content[4];
		if (!this.#setSize(width, height, RECOILResolution.C642X1))
			return false;
		let charactersPerRow = (width + 7) >> 3;
		let left = (content[1] & 3) << 1;
		if (left != 0)
			charactersPerRow++;
		let rows = (height + 7) >> 3;
		let top = content[2] & 7;
		if (top != 0)
			rows++;
		if (contentLength != 5 + rows * charactersPerRow * 10)
			return false;
		for (let y = 0; y < height; y++) {
			let screenY = top + y;
			for (let x = 0; x < width; x++) {
				let screenX = left + x;
				let offset = 5 + ((screenY >> 3) * charactersPerRow + (screenX >> 3)) * 10;
				let c;
				switch (content[offset + 2 + (screenY & 7)] >> (~screenX & 6) & 3) {
				case 1:
					c = content[offset] >> 4;
					break;
				case 2:
					c = content[offset];
					break;
				case 3:
					c = content[offset + 1];
					break;
				default:
					c = 0;
					break;
				}
				this.#pixels[y * width + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeC64Shp(content, contentLength)
	{
		if (contentLength < 8)
			return false;
		let columns = 40;
		let height = 200;
		const rle = new UflStream();
		switch (content[2]) {
		case 0:
			rle.escape = content[3];
			rle.contentOffset = 5;
			break;
		case 128:
			rle.escape = content[3];
			rle.contentOffset = 4;
			break;
		case 167:
			if (content[3] != 25)
				return false;
			columns = 39;
			rle.escape = content[4];
			rle.contentOffset = 5;
			break;
		case 168:
			height = content[3] << 3;
			if (height == 0 || height > 200)
				return false;
			rle.escape = content[4];
			rle.contentOffset = 5;
			break;
		case 232:
			if (content[3] != 25)
				return false;
			rle.escape = content[5];
			rle.contentOffset = 6;
			break;
		default:
			return false;
		}
		rle.content = content;
		rle.contentLength = contentLength;
		let bitmapLength = height * columns;
		const unpacked = new Uint8Array(10001);
		if (!rle.unpack(unpacked, 0, 1, bitmapLength))
			return false;
		rle.escape = 0;
		if (!rle.unpack(unpacked, bitmapLength, 1, (bitmapLength >> 3) * 9))
			return false;
		switch (content[2]) {
		case 0:
			rle.escape = 255;
			break;
		case 232:
			if (rle.readByte() != 255)
				return false;
			rle.escape = 216;
			break;
		default:
			if (rle.contentOffset != contentLength)
				return false;
			this.#setSize(columns << 3, height, RECOILResolution.C641X1);
			this.#decodeC64HiresFrame(unpacked, 0, bitmapLength, false, columns, 0);
			return true;
		}
		unpacked[10000] = content[4];
		return rle.unpack(unpacked, 9000, 1, 10000) && rle.contentOffset == contentLength && this.#decodeKoa(unpacked, 10001);
	}

	#decodeC64HiresInterlace(content, bitmap1Offset, videoMatrix1Offset, bitmap2Offset, videoMatrix2Offset)
	{
		this.#setSize(320, 200, RECOILResolution.C641X1, 2);
		this.#decodeC64HiresFrame(content, bitmap1Offset, videoMatrix1Offset, false, 40, 0);
		this.#decodeC64HiresFrame(content, bitmap2Offset, videoMatrix2Offset, false, 40, 64000);
		return this.#applyBlend();
	}

	#decodeIhe(content, contentLength)
	{
		return contentLength == 16194 && this.#decodeC64HiresInterlace(content, 2, -12, 8194, -12);
	}

	#decodeHlf(content, contentLength)
	{
		return contentLength == 24578 && this.#decodeC64HiresInterlace(content, 2, 10242, 16386, 9218);
	}

	#decodeHle(content, contentLength)
	{
		return contentLength == 32770 && this.#decodeC64HiresInterlace(content, 2, 8194, 24578, 16386);
	}

	#decodeVhi(content, contentLength)
	{
		if (contentLength == 17389)
			return this.#decodeC64HiresInterlace(content, 2, 16386, 8194, 16386);
		const unpacked = new Uint8Array(17384);
		const rle = Object.assign(new VhiStream(), { content: content, contentOffset: 2, contentLength: contentLength });
		return rle.unpack(unpacked, 0, 1, 17384) && this.#decodeC64HiresInterlace(unpacked, 0, 16384, 8192, 16384);
	}

	#decodeMciLike(content, bitmap1Offset, videoMatrix1Offset, bitmap2Offset, videoMatrix2Offset, colorOffset, backgroundOffset, shift)
	{
		this.#setSize(320, 200, shift == 0 ? RECOILResolution.C642X1 : RECOILResolution.C641X1, 2);
		this.#decodeC64MulticolorFrame(content, bitmap1Offset, videoMatrix1Offset, colorOffset, backgroundOffset, 0);
		this.#leftSkip = -shift;
		this.#decodeC64MulticolorFrame(content, bitmap2Offset, videoMatrix2Offset, colorOffset, backgroundOffset, 64000);
		return this.#applyBlend();
	}

	#decodeFp(content, contentLength)
	{
		return contentLength == 19266 && this.#decodeMciLike(content, 3074, 1026, 11266, 2050, 2, 11074, 1);
	}

	#decodeMciUnpacked(content)
	{
		return this.#decodeMciLike(content, 1026, 2, 9218, 17410, 18434, 1002, 1);
	}

	#decodeMci(content, contentLength)
	{
		if (contentLength == 19434)
			return this.#decodeMciUnpacked(content);
		if (contentLength < 142)
			return false;
		const unpacked = new Uint8Array(19434);
		const rle = Object.assign(new MciStream(), { content: content, contentOffset: contentLength - 1 });
		return rle.unpackBackwards(unpacked, 2, 19433) && this.#decodeMciUnpacked(unpacked);
	}

	#decodeDrz(content, contentLength)
	{
		const unpacked = new Uint8Array(10051);
		let source = DrpStream.unpackFile(content, contentLength, "DRAZPAINT 1.4", unpacked, 10051);
		return source != null && this.#decodeC64Multicolor(source, 2050, 1026, 2, 10050);
	}

	#decodeDrl(content, contentLength)
	{
		const unpacked = new Uint8Array(18242);
		let source = DrpStream.unpackFile(content, contentLength, "DRAZLACE! 1.0", unpacked, 18242);
		if (source == null)
			return false;
		let shift = source[10052];
		return shift <= 1 && this.#decodeMciLike(source, 2050, 1026, 10242, 1026, 2, 10050, shift);
	}

	#decodeMleFrame(content, contentOffset, pixelsOffset)
	{
		for (let y = 0; y < 56; y++) {
			for (let x = 0; x < 320; x++) {
				let c = 0;
				let i = x + this.#leftSkip;
				if (i >= 0) {
					let ch = (y >> 3) * 40 + (i >> 3);
					if (ch < 256) {
						c = RECOIL.#DECODE_MLE_FRAME_COLORS[content[contentOffset + (ch << 3) + (y & 7)] >> (~i & 6) & 3];
					}
				}
				this.#pixels[pixelsOffset + y * this.#width + x] = this.#c64Palette[c];
			}
		}
	}

	#decodeMle(content, contentLength)
	{
		if (contentLength != 4098)
			return false;
		this.#setSize(320, 56, RECOILResolution.C641X1, 2);
		this.#decodeMleFrame(content, 2050, 0);
		this.#leftSkip = -1;
		this.#decodeMleFrame(content, 2, 17920);
		return this.#applyBlend();
	}

	#decodeHcb(content, contentLength)
	{
		if (contentLength != 12148)
			return false;
		this.#setSize(296, 200, RECOILResolution.C642X1);
		for (let y = 0; y < 200; y++)
			this.#decodeC64MulticolorLine(content, 4122, 2053 + ((y & 4) << 8), 2053 + ((y & 4) << 8), content[12098 + (y >> 2)], false, y, y * 296, 296, 40);
		return true;
	}

	#decodeFed(content, contentLength)
	{
		return contentLength == 17665 && this.#decodeC64MulticolorFliBars(content, 9474, 1282, 258, 8);
	}

	#decodeHimUnpacked(content)
	{
		this.#setSize(296, 192, RECOILResolution.C641X1);
		this.#decodeC64HiresFrame(content, 346, 8237, true, 40, 0);
		return true;
	}

	#decodeHim(content, contentLength)
	{
		if (contentLength < 18 || content[0] != 0 || content[1] != 64)
			return false;
		if (content[3] == 255)
			return contentLength == 16385 && this.#decodeHimUnpacked(content);
		if (content[2] + (content[3] << 8) != 16381 + contentLength || content[4] != 242 || content[5] != 127)
			return false;
		const unpacked = new Uint8Array(16372);
		const rle = Object.assign(new HimStream(), { content: content, contentOffset: contentLength - 1 });
		return rle.unpackBackwards(unpacked, 322, 16371) && this.#decodeHimUnpacked(unpacked);
	}

	#decodeEci(content, contentLength)
	{
		if (contentLength != 32770)
			return this.#decodeEcp(content, contentLength);
		this.#setSize(296, 200, RECOILResolution.C641X1, 2);
		this.#decodeC64HiresFrame(content, 26, 8197, true, 40, 0);
		this.#decodeC64HiresFrame(content, 16410, 24581, true, 40, 59200);
		return this.#applyBlend();
	}

	#decodeEcp(content, contentLength)
	{
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(32770);
		const rle = Object.assign(new DrpStream(), { content: content, contentOffset: 3, contentLength: contentLength, escape: content[2] });
		return rle.unpack(unpacked, 2, 1, 32770) && this.#decodeEci(unpacked, 32770);
	}

	#decodeFli(content, contentLength)
	{
		switch (contentLength) {
		case 17218:
		case 17409:
			return this.#decodeC64MulticolorFli(content, 9218, 1026, 2, 0);
		default:
			return false;
		}
	}

	#decodeFbi(content, contentLength)
	{
		if (contentLength < 19)
			return false;
		const unpacked = new Uint8Array(17216);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[2] });
		return rle.unpackBackwards(unpacked, 0, 17215) && this.#decodeC64MulticolorFli(unpacked, 9216, 1024, 0, 0);
	}

	#decodeBml(content, contentLength)
	{
		switch (contentLength) {
		case 17474:
		case 17665:
		case 17666:
			return this.#decodeC64MulticolorFliBars(content, 9474, 1282, 258, 2);
		default:
			if (contentLength < 5)
				return false;
			const unpacked = new Uint8Array(17472);
			const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[2] });
			return rle.unpackBackwards(unpacked, 0, 17471) && this.#decodeC64MulticolorFliBars(unpacked, 9472, 1280, 256, 0);
		}
	}

	#decodeEmc(content, contentLength)
	{
		if (contentLength != 17412)
			return false;
		this.#setSize(296, 192, RECOILResolution.C642X1);
		for (let y = 0; y < 192; y++)
			this.#decodeC64MulticolorLine(content, 8218, 5 + (((y + 4) & 7) << 10), 16389, content[17411], false, y + 4, y * 296, 296, 40);
		return true;
	}

	#decodeFlm(content, contentLength)
	{
		if (contentLength == 17410)
			return this.#decodeC64MulticolorFli(content, 9218, 1026, 2, content[17281]);
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(17280);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength });
		rle.escape = rle.readValue();
		if (!rle.unpackBackwards(unpacked, 0, 17279))
			return false;
		for (let i = 0; i < 1000; i++) {
			if (unpacked[i] != 0)
				return this.#decodeC64MulticolorFli(unpacked, 9216, 1024, 0, unpacked[17279]);
		}
		this.#setSize(296, 200, RECOILResolution.C641X1);
		this.#decodeC64HiresFrame(unpacked, 9240, 1027, true, 40, 0);
		return true;
	}

	#decodeFfli(content, contentLength)
	{
		if (contentLength != 26115 || content[2] != 102)
			return false;
		this.#setSize(296, 200, RECOILResolution.C642X1, 2);
		this.#decodeC64MulticolorFliBarsFrame(content, 9499, 1286, 262, 3, 0);
		this.#decodeC64MulticolorFliBarsFrame(content, 9499, 17670, 262, 25859, 59200);
		return this.#applyBlend();
	}

	#decodeIfli(content, bitmap1Offset, bitmap2Offset, videoMatrix1Offset, videoMatrix2Offset, colorOffset, background)
	{
		this.#setSize(296, 200, RECOILResolution.C641X1, 2);
		this.#decodeC64MulticolorFliFrame(content, bitmap1Offset + 24, videoMatrix1Offset + 3, colorOffset + 3, background, false, 0);
		this.#leftSkip = -1;
		this.#decodeC64MulticolorFliFrame(content, bitmap2Offset + 24, videoMatrix2Offset + 3, colorOffset + 3, background, false, 59200);
		return this.#applyBlend();
	}

	#decodePpUnpacked(content)
	{
		return this.#decodeIfli(content, 9218, 25602, 1026, 17410, 2, content[17281]);
	}

	#decodePp(content, contentLength)
	{
		if (contentLength < 8)
			return false;
		if (content[2] == 16 && content[3] == 16 && content[4] == 16) {
			const unpacked = new Uint8Array(33602);
			const rle = Object.assign(new CmpStream(), { content: content, contentOffset: 6, contentLength: contentLength, escape: content[5] });
			return rle.unpack(unpacked, 2, 1, 33602) && rle.readRle() < 0 && this.#decodePpUnpacked(unpacked);
		}
		return contentLength == 33602 && this.#decodePpUnpacked(content);
	}

	#decodeFunUnpacked(content)
	{
		return this.#decodeIfli(content, 8210, 25594, 18, 17402, 16402, 0);
	}

	#decodeC64Fun(content, contentLength)
	{
		if (contentLength < 18 || !RECOIL.isStringAt(content, 2, "FUNPAINT (MT) "))
			return false;
		if (content[16] != 0) {
			const unpacked = new Uint8Array(33694);
			const rle = Object.assign(new DrpStream(), { content: content, contentOffset: 18, contentLength: contentLength, escape: content[17] });
			return rle.unpack(unpacked, 18, 1, 33694) && rle.readRle() < 0 && this.#decodeFunUnpacked(unpacked);
		}
		return contentLength == 33694 && this.#decodeFunUnpacked(content);
	}

	#decodeGunFrame(content, bitmapOffset, videoMatrixOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			let background = content[y < 177 ? 16209 + y : y < 197 ? 18233 + y : 18429];
			this.#decodeC64MulticolorLine(content, bitmapOffset + 24, videoMatrixOffset + 3 + ((y & 7) << 10), 16389, background, false, y, pixelsOffset + y * 296, 296, 40);
		}
	}

	#decodeGun(content, contentLength)
	{
		if (contentLength != 33602 && contentLength != 33603)
			return false;
		this.#setSize(296, 200, RECOILResolution.C641X1, 2);
		this.#decodeGunFrame(content, 8194, 2, 0);
		this.#leftSkip = -1;
		this.#decodeGunFrame(content, 25602, 17410, 59200);
		return this.#applyBlend();
	}

	#decodeBfli(content, contentLength)
	{
		if (contentLength != 33795 || content[2] != 98)
			return false;
		this.#setSize(296, 400, RECOILResolution.C642X1);
		this.#decodeC64MulticolorFliFrame(content, 9243, 1030, 6, 0, false, 0);
		this.#decodeC64MulticolorFliFrame(content, 25603, 17411, 3, 0, true, 59200);
		return true;
	}

	#decodeLp3(content, contentLength)
	{
		switch (contentLength) {
		case 4098:
		case 4174:
			break;
		default:
			return false;
		}
		if (content[0] != 0 || content[1] != 24)
			return false;
		this.#setSize(320, 400, RECOILResolution.C642X1);
		const colors = new Uint8Array(4);
		if (contentLength == 4174) {
			colors[0] = content[2045] & 15;
			colors[1] = content[2047] & 15;
			colors[2] = content[2048] & 15;
			colors[3] = content[2046] & 7;
		}
		else {
			colors[0] = 0;
			colors[1] = 10;
			colors[2] = 2;
			colors[3] = 1;
		}
		for (let y = 0; y < 400; y++) {
			for (let x = 0; x < 320; x++) {
				let c = content[2 + (y >> 3) * 40 + (x >> 3)];
				c = content[2050 + (c << 3) + (y & 7)] >> (~x & 6) & 3;
				this.#pixels[y * 320 + x] = this.#c64Palette[colors[c]];
			}
		}
		return true;
	}

	#decodeMilPacked(content, contentLength, vertical)
	{
		const unpacked = new Uint8Array(10000);
		const rle = Object.assign(new XeKoalaStream(), { content: content, contentOffset: 22, contentLength: contentLength });
		if (!rle.unpack(unpacked, 0, 1, 10000))
			return false;
		this.#setSize(320, 200, RECOILResolution.C642X1);
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 320; x++) {
				let column = x >> 3;
				let charOffset = vertical ? column * 25 + (y >> 3 & 1) * 13 + (y >> 4) : (y & ~7) * 5 + column;
				let c;
				switch (unpacked[2000 + (vertical ? column * 200 + (y & 1) * 100 + (y >> 1) : y * 40 + column)] >> (~x & 6) & 3) {
				case 1:
					c = unpacked[charOffset] >> 4;
					break;
				case 2:
					c = unpacked[charOffset];
					break;
				case 3:
					c = unpacked[1000 + charOffset];
					break;
				default:
					c = content[8];
					break;
				}
				this.#pixels[y * 320 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeMil(content, contentLength)
	{
		if (contentLength < 26)
			return false;
		switch (content[7]) {
		case 0:
			return contentLength == 10022 && this.#decodeC64Multicolor(content, 2022, 22, 1022, 8);
		case 1:
			return this.#decodeMilPacked(content, contentLength, true);
		case 2:
			return this.#decodeMilPacked(content, contentLength, false);
		default:
			return false;
		}
	}

	#decodeVic(content, contentLength)
	{
		switch (contentLength) {
		case 9002:
		case 9003:
		case 9009:
			return this.#decodeIph(content, contentLength);
		case 10018:
			return this.#decodeOcp(content, contentLength);
		case 10241:
			return this.#decodeDol(content, contentLength);
		case 10242:
			return this.#decodeBpl(content, contentLength);
		case 17218:
		case 17409:
			return this.#decodeFli(content, contentLength);
		case 17410:
			return this.#decodeFlm(content, contentLength);
		case 17474:
		case 17665:
		case 17666:
			return this.#decodeBml(content, contentLength);
		case 18242:
			return this.#decodeDrl(content, contentLength);
		case 33602:
		case 33603:
			return this.#decodeGun(content, contentLength);
		case 33694:
			return this.#decodeC64Fun(content, contentLength);
		default:
			return false;
		}
	}

	#decodeA(content, contentLength)
	{
		if (contentLength != 8130 || content[0] != 66 || content[1] != 0)
			return false;
		this.#setSize(416, 182, RECOILResolution.C642X1);
		for (let y = 0; y < 182; y++) {
			for (let x = 0; x < 416; x++) {
				let c = 11;
				let row = y % 23;
				if (row < 21) {
					let column = x % 26;
					if (column < 24) {
						let spriteNo = (x / 26 | 0) + ((y / 23 | 0) << 4);
						if (spriteNo < 127) {
							let spriteOffset = 2 + (spriteNo << 6);
							switch (content[spriteOffset + row * 3 + (column >> 3)] >> (~column & 6) & 3) {
							case 1:
								c = 0;
								break;
							case 2:
								c = content[spriteOffset + 63] & 15;
								break;
							case 3:
								c = 1;
								break;
							default:
								break;
							}
						}
					}
				}
				this.#pixels[y * 416 + x] = this.#c64Palette[c];
			}
		}
		return true;
	}

	#decodeSpd(content, contentLength)
	{
		if (contentLength < 67)
			return false;
		let headerLength;
		let spriteCount;
		if (content[0] == 83 && content[1] == 80 && content[2] == 68 && content[3] == 1) {
			headerLength = 6;
			spriteCount = content[4] + 1;
			if (contentLength < 9 + (spriteCount << 6))
				return false;
		}
		else {
			if ((contentLength & 63) != 3 || content[0] > 15 || content[1] > 15 || content[2] > 15)
				return false;
			headerLength = 0;
			spriteCount = contentLength >> 6;
		}
		let resolution = RECOILResolution.C642X1;
		for (let spriteNo = 0; spriteNo < spriteCount; spriteNo++) {
			if (content[headerLength + 66 + (spriteNo << 6)] < 128) {
				resolution = RECOILResolution.C641X1;
				break;
			}
		}
		let width;
		let height;
		if (spriteCount <= 16) {
			width = spriteCount * 26 - 2;
			height = 21;
		}
		else {
			width = 414;
			height = ((spriteCount + 15) >> 4) * 23 - 2;
		}
		if (!this.#setSize(width, height, resolution))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let c = 0;
				let row = y % 23;
				if (row < 21) {
					let column = x % 26;
					if (column < 24) {
						let spriteNo = (x / 26 | 0) + ((y / 23 | 0) << 4);
						if (spriteNo < spriteCount) {
							let spriteOffset = 3 + (spriteNo << 6);
							let b = content[headerLength + spriteOffset + row * 3 + (column >> 3)];
							if (content[headerLength + spriteOffset + 63] < 128) {
								if ((b >> (~column & 7) & 1) != 0)
									c = spriteOffset + 63;
							}
							else {
								switch (b >> (~column & 6) & 3) {
								case 1:
									c = 1;
									break;
								case 2:
									c = spriteOffset + 63;
									break;
								case 3:
									c = 2;
									break;
								default:
									break;
								}
							}
						}
					}
				}
				this.#pixels[y * width + x] = this.#c64Palette[content[headerLength + c] & 15];
			}
		}
		return true;
	}

	static #getAtari8Gr0Pixel(font, fontOffset, ch, x, y)
	{
		return (font[fontOffset + ((ch & 127) << 3) + (y & 7)] >> (~x & 7) ^ ch >> 7) & 1;
	}

	#decodePetScreenCustom(content, screenOffset, fontOffset, colors, colorsOffset, background, columns, rows)
	{
		let width = columns << 3;
		let height = rows << 3;
		if (!this.#setSize(width, height, RECOILResolution.C641X1))
			return false;
		let font = Fu.c64_fnt;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let offset = (y >> 3) * columns + (x >> 3);
				let ch = content[screenOffset + offset];
				let c;
				if ((fontOffset == 0 ? RECOIL.#getAtari8Gr0Pixel(font, 0, ch, x, y) : content[fontOffset + (ch << 3) + (y & 7)] >> (~x & 7) & 1) == 0)
					c = background;
				else
					c = colors[colorsOffset + offset];
				this.#pixels[y * width + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodePetScreen(content, screenOffset, colorsOffset, background, columns, rows)
	{
		return this.#decodePetScreenCustom(content, screenOffset, 0, content, colorsOffset, background, columns, rows);
	}

	#decodePet(content, contentLength)
	{
		switch (contentLength) {
		case 2026:
			return this.#decodePetScreen(content, 2, 1026, content[1003], 40, 25);
		case 4105:
			return content[0] == 208 && content[1] == 197 && content[2] == 212 && content[3] == 50 && this.#decodePetScreenCustom(content, 55, 2057, content, 1055, content[2056], 40, 25);
		default:
			return false;
		}
	}

	#decodePdr(content, contentLength)
	{
		return contentLength == 2029 && this.#decodePetScreen(content, 5, 1029, content[3], 40, 25);
	}

	#decodePbot(content, contentLength)
	{
		switch (contentLength) {
		case 70:
			return this.#decodePetScreen(content, 35, 0, 0, 5, 7);
		case 384:
			return this.#decodePetScreen(content, 192, 0, 0, 12, 16);
		default:
			return false;
		}
	}

	#decodeScrCol(filename, content, contentLength)
	{
		if (contentLength != 1002)
			return false;
		const colors = new Uint8Array(1003);
		return this.#readCompanionFile(filename, "COL", "col", colors, 1003) == 1002 && this.#decodePetScreenCustom(content, 2, 0, colors, 2, 0, 40, 25);
	}

	#decodeCgx(content, contentLength)
	{
		if (contentLength < 40 || !RECOIL.isStringAt(content, 0, "RIFF") || RECOIL.get32LittleEndian(content, 4) + 8 != contentLength || !RECOIL.isStringAt(content, 8, "CGFX"))
			return false;
		let contentOffset = 12;
		let matrixRows = 0;
		let matrixColumns = 0;
		let frameRows = 0;
		let frameColumns = 0;
		while (contentOffset + 8 <= contentLength) {
			let chunkLength = RECOIL.get32LittleEndian(content, contentOffset + 4);
			let nextChunkOffset = contentOffset + 8 + chunkLength;
			if (nextChunkOffset < 0 || nextChunkOffset > contentLength)
				return false;
			if (RECOIL.isStringAt(content, contentOffset, "FRMT") && chunkLength == 12) {
				matrixRows = content[contentOffset + 8];
				matrixColumns = content[contentOffset + 9];
				frameRows = content[contentOffset + 16];
				frameColumns = content[contentOffset + 17];
				if (content[contentOffset + 12] != matrixRows * matrixColumns || content[contentOffset + 18] != 4 || content[contentOffset + 19] != 0)
					return false;
			}
			else if (RECOIL.isStringAt(content, contentOffset, "DATA")) {
				let frameChars = frameRows * frameColumns;
				let frameLength = frameChars * 10 + 2;
				let frames = matrixRows * matrixColumns;
				let width = matrixColumns * frameColumns << 3;
				let height = matrixRows * frameRows << 3;
				if (chunkLength != frames * frameLength || !this.#setSize(width, height, RECOILResolution.C642X1))
					return false;
				for (let matrixRow = 0; matrixRow < matrixRows; matrixRow++) {
					for (let matrixColumn = 0; matrixColumn < matrixColumns; matrixColumn++) {
						let frameOffset = contentOffset + 8 + (matrixRow * matrixColumns + matrixColumn) * frameLength;
						let background = content[frameOffset + frameLength - 1];
						let pixelsOffset = (matrixRow * frameRows * width + matrixColumn * frameColumns) << 3;
						for (let y = 0; y < frameRows << 3; y++)
							this.#decodeC64MulticolorLine(content, frameOffset, frameOffset + (frameChars << 3), frameOffset + frameChars * 9, background, false, y, pixelsOffset + y * width, frameColumns << 3, frameColumns);
					}
				}
				return true;
			}
			else if (!RECOIL.isStringAt(content, contentOffset, "META"))
				return false;
			contentOffset = nextChunkOffset;
		}
		return false;
	}

	#decodeFpr(content, contentLength)
	{
		if (contentLength != 18370)
			return false;
		this.#setSize(320, 200, RECOILResolution.C642X1);
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 320; x++) {
				let offset = (y >> 3) * 40 + (x >> 3);
				let c = x < 24 ? 255 : content[2178 + offset + ((y & 7) << 10)];
				switch (content[10370 + (offset << 3) + (y & 7)] >> (~x & 6) & 3) {
				case 0:
					c = 0;
					break;
				case 1:
					c >>= 4;
					break;
				case 3:
					c = x < 24 ? content[898 + y] >> 4 : content[1154 + offset];
					break;
				default:
					break;
				}
				if (x < 24) {
					switch (content[2 + (((((y + 1) & 2) != 0 ? 5 : 0) + (y / 42 | 0)) << 6) + (y >> 1) % 21 * 3 + (x >> 3)] >> (~x & 6) & 3) {
					case 1:
						c = content[642 + y];
						break;
					case 2:
						c = content[1098];
						break;
					case 3:
						c = content[1099];
						break;
					default:
						break;
					}
				}
				this.#pixels[y * 320 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeCtm(content, contentLength)
	{
		if (contentLength < 30 || content[0] != 67 || content[1] != 84 || content[2] != 77 || content[3] != 5)
			return false;
		let colorMethod = content[8];
		if (colorMethod > 2)
			return false;
		let flags = content[9];
		let tiles = (flags & 1) != 0;
		if (colorMethod == 1 && !tiles)
			return false;
		let charex = (flags & 2) != 0;
		let multi = (flags & 4) != 0;
		let charCount = content[10] + (content[11] << 8) + 1;
		let tileCount = tiles ? content[12] + (content[13] << 8) + 1 : 0;
		let tileWidth = tiles ? content[14] : 1;
		let tileHeight = tiles ? content[15] : 1;
		if (tileWidth == 0 || tileHeight == 0)
			return false;
		let mapWidth = content[16] | content[17] << 8;
		let mapHeight = content[18] | content[19] << 8;
		let tilesOffset = 20 + charCount * 9;
		let tileColorsOffset = charex ? tilesOffset : tilesOffset + tileCount * (tileWidth * tileHeight << 1);
		let mapOffset = colorMethod == 1 ? tileColorsOffset + tileCount : tileColorsOffset;
		if (contentLength != mapOffset + (mapWidth * mapHeight << 1))
			return false;
		let width = mapWidth * tileWidth << 3;
		let height = mapHeight * tileHeight << 3;
		if (!this.#setSize(width, height, multi ? RECOILResolution.C642X1 : RECOILResolution.C641X1))
			return false;
		for (let y = 0; y < height; y++) {
			let mapRowOffset = mapOffset + (((y >> 3) / tileHeight | 0) * mapWidth << 1);
			for (let x = 0; x < width; x++) {
				let mapTileOffset = mapRowOffset + (((x >> 3) / tileWidth | 0) << 1);
				let tile = content[mapTileOffset] | content[mapTileOffset + 1] << 8;
				let ch;
				if (tiles) {
					if (tile >= tileCount)
						return false;
					ch = (tile * tileHeight + (y >> 3) % tileHeight) * tileWidth + (x >> 3) % tileWidth;
					if (!charex) {
						let tileOffset = tilesOffset + (ch << 1);
						ch = content[tileOffset] | content[tileOffset + 1] << 8;
					}
				}
				else
					ch = tile;
				if (ch >= charCount)
					return false;
				let foregroundOffset;
				switch (colorMethod) {
				case 1:
					foregroundOffset = tileColorsOffset + tile;
					break;
				case 2:
					foregroundOffset = 20 + (charCount << 3) + ch;
					break;
				default:
					foregroundOffset = 7;
					break;
				}
				let c = content[20 + (ch << 3) + (y & 7)];
				if (multi) {
					c = c >> (~x & 6) & 3;
					if (c == 3)
						c = content[foregroundOffset] & 7;
					else
						c = content[4 + c];
				}
				else {
					c = c >> (~x & 7) & 1;
					c = content[c == 0 ? 4 : foregroundOffset];
				}
				this.#pixels[y * width + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeEshFrame(content, bitmapOffset, spriteOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 192; x++) {
				let bit = ~x & 7;
				let column = x >> 3;
				let c;
				if ((content[spriteOffset + ((((y / 21 | 0) << 3) + (column / 3 | 0)) << 6) + y % 21 * 3 + column % 3] >> bit & 1) != 0)
					c = content[20443 + (column / 3 | 0)];
				else {
					let offset = (y & ~7) * 3 + column;
					c = content[19843 + offset] >> ((content[bitmapOffset + (offset << 3) + (y & 7)] >> bit & 1) << 2);
				}
				this.#pixels[pixelsOffset + y * 192 + x] = this.#c64Palette[c & 15];
			}
		}
	}

	#decodeEshUnpacked(content)
	{
		this.#setSize(192, 200, RECOILResolution.C641X1, 2);
		this.#decodeEshFrame(content, 3, 9603, 0);
		this.#decodeEshFrame(content, 4803, 14723, 38400);
		return this.#applyBlend();
	}

	#decodeEsh(content, contentLength)
	{
		if (contentLength < 5)
			return false;
		if (content[2] == 0)
			return contentLength == 20454 && this.#decodeEshUnpacked(content);
		const unpacked = new Uint8Array(20452);
		const rle = Object.assign(new PgcStream(), { content: content, contentOffset: 3, contentLength: contentLength });
		return rle.unpack(unpacked, 3, 1, 20452) && this.#decodeEshUnpacked(unpacked);
	}

	#decodeShx(content, contentLength)
	{
		if (contentLength == 15362) {
			this.#setSize(144, 168, RECOILResolution.C641X1);
			for (let y = 0; y < 168; y++) {
				for (let x = 0; x < 144; x++) {
					let bit = ~x & 7;
					let column = x >> 3;
					let spriteInLine = column / 3 | 0;
					let spriteNo = ((y - 1) & 7) * 15 + spriteInLine;
					if (spriteNo < 105)
						spriteNo += ((spriteInLine + 1) >> 1) * 3;
					let c;
					if ((content[8194 + (spriteNo << 6) + y % 21 * 3 + column % 3] >> bit & 1) != 0)
						c = content[1003];
					else {
						let offset = (y & ~7) * 5 + column;
						c = content[13 + ((y & 7) << 10) + offset] >> ((content[8282 + (offset << 3) + (y & 7)] >> bit & 1) << 2);
					}
					this.#pixels[y * 144 + x] = this.#c64Palette[c & 15];
				}
			}
			return true;
		}
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(9168);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength });
		rle.escape = rle.readValue();
		if (!rle.unpackBackwards(unpacked, 0, 9167))
			return false;
		this.#setSize(144, 168, RECOILResolution.C641X1);
		for (let y = 0; y < 168; y++) {
			for (let x = 0; x < 144; x++) {
				let bit = ~x & 7;
				let offset = y * 18 + (x >> 3);
				let c;
				if ((unpacked[offset] >> bit & 1) != 0)
					c = unpacked[3025];
				else
					c = unpacked[6144 + offset] >> ((unpacked[3072 + offset] >> bit & 1) << 2);
				this.#pixels[y * 144 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	static #getShsPixel(content, x, y)
	{
		let bit = ~x & 7;
		let column = x >> 3;
		if (y >= 17 && y < 185 && column >= 2 && column < 14) {
			let spriteColumn = column - 2;
			let spriteInLine = spriteColumn / 3 | 0;
			let spriteY = y - 17;
			let spriteOffset = (((spriteInLine << 3) + (spriteY / 21 | 0)) << 6) + spriteY % 21 * 3 + spriteColumn % 3;
			if ((content[10242 + spriteOffset] >> bit & 1) != 0)
				return content[8006 + spriteInLine] & 15;
			if ((content[8194 + spriteOffset] >> bit & 1) != 0)
				return content[8002 + spriteInLine] & 15;
		}
		let offset = (y >> 3) * 40 + column;
		return content[13314 + offset] >> ((content[2 + (offset << 3) + (y & 7)] >> bit & 1) << 2);
	}

	#decodeShs(content, contentLength)
	{
		if (contentLength != 14338)
			return false;
		this.#setSize(320, 200, RECOILResolution.C641X1);
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 320; x++)
				this.#pixels[y * 320 + x] = this.#c64Palette[RECOIL.#getShsPixel(content, x, y) & 15];
		}
		return true;
	}

	static #getShSpriteOffset(x, y, rowShift)
	{
		return ((((y / 21 | 0) << rowShift) + (x / 24 | 0)) << 6) + y % 21 * 3 + (x >> 3) % 3;
	}

	#decodeSh1Frame(content, bitmapOffset, videoMatrixOffset, screenStride, foreSpriteOffset, backSpriteOffset, foreColorOffset, backColorOffset, rowShift, pixelsOffset)
	{
		for (let y = 0; y < this.#height; y++) {
			for (let x = 0; x < 96; x++) {
				let bit = ~x & 7;
				let spriteOffset = rowShift == 0 ? (x >> 3) * 168 + y : RECOIL.#getShSpriteOffset(x, y, rowShift);
				let c;
				if ((content[foreSpriteOffset + spriteOffset] >> bit & 1) != 0)
					c = content[foreColorOffset + (x / 24 | 0)] >> (foreColorOffset == backColorOffset ? 4 : 0);
				else if ((content[backSpriteOffset + spriteOffset] >> bit & 1) != 0)
					c = content[backColorOffset + (x / 24 | 0)];
				else {
					let offset = (y >> 3) * screenStride + (x >> 3);
					c = content[videoMatrixOffset + offset] >> ((content[bitmapOffset + (offset << 3) + (y & 7)] >> bit & 1) << 2);
				}
				this.#pixels[pixelsOffset + y * 96 + x] = this.#c64Palette[c & 15];
			}
		}
	}

	#decodeSh1Unpacked(content, bitmapOffset, videoMatrixOffset, screenStride, foreSpriteOffset, backSpriteOffset, foreColorOffset, backColorOffset, rowShift)
	{
		this.#setSize(96, 168, RECOILResolution.C641X1);
		this.#decodeSh1Frame(content, bitmapOffset, videoMatrixOffset, screenStride, foreSpriteOffset, backSpriteOffset, foreColorOffset, backColorOffset, rowShift, 0);
		return true;
	}

	static #unpackSh(content, contentLength, unpacked, unpackedLength)
	{
		if (contentLength < 3)
			return false;
		const rle = Object.assign(new DrpStream(), { content: content, contentOffset: 1, contentLength: contentLength, escape: content[0] });
		return rle.unpack(unpacked, 0, 1, unpackedLength);
	}

	#decodeSh1(content, contentLength)
	{
		if (contentLength == 14770)
			return this.#decodeSh1Unpacked(content, 6690, 448, 40, 4530, 2482, 430, 426, 2);
		const unpacked = new Uint8Array(6304);
		return RECOIL.#unpackSh(content, contentLength, unpacked, 6304) && this.#decodeSh1Unpacked(unpacked, 0, 6048, 12, 4032, 2016, 6300, 6300, 0);
	}

	#decodeShiUnpacked(content)
	{
		this.#setSize(96, 200, RECOILResolution.C641X1, 2);
		this.#decodeSh1Frame(content, 3, 15043, 12, 4803, 5059, 15343, 15347, 3, 0);
		this.#decodeSh1Frame(content, 2403, 15043, 12, 9923, 10179, 15343, 15347, 3, 19200);
		return this.#applyBlend();
	}

	#decodeShi(content, contentLength)
	{
		if (contentLength == 15355 && content[2] == 0)
			return this.#decodeShiUnpacked(content);
		const unpacked = new Uint8Array(15355);
		const rle = Object.assign(new PgcStream(), { content: content, contentOffset: 3, contentLength: contentLength });
		return rle.unpack(unpacked, 3, 1, 15355) && this.#decodeShiUnpacked(unpacked);
	}

	#decodeSuperHires2(content, bitmapOffset, videoMatrixOffset, screenStride, spritesOffset, spritesY, spriteColorsOffset)
	{
		this.#setSize(192, 168, RECOILResolution.C641X1);
		for (let y = 0; y < 168; y++) {
			for (let x = 0; x < 192; x++) {
				let bit = ~x & 7;
				let c;
				if (y >= spritesY && (content[spritesOffset + (spritesOffset == 4032 ? (x >> 3) * 168 + y : RECOIL.#getShSpriteOffset(x, y - spritesY, 3))] >> bit & 1) != 0)
					c = content[spriteColorsOffset + (x / 24 | 0)];
				else {
					let offset = (y >> 3) * screenStride + (x >> 3);
					c = content[videoMatrixOffset + offset] >> ((content[bitmapOffset + (offset << 3) + (y & 7)] >> bit & 1) << 2);
				}
				this.#pixels[y * 192 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeSh2(content, contentLength)
	{
		if (contentLength == 14770)
			return this.#decodeSuperHires2(content, 6642, 442, 40, 2482, 0, 426);
		const unpacked = new Uint8Array(8576);
		return RECOIL.#unpackSh(content, contentLength, unpacked, 8576) && this.#decodeSuperHires2(unpacked, 0, 8064, 24, 4032, 0, 8568);
	}

	static #getShe1Pixel(content, x, y)
	{
		let bit = ~x & 7;
		if (y < 84) {
			let spriteOffset = RECOIL.#getShSpriteOffset(x, y, 3);
			if ((content[1446 + spriteOffset] >> bit & 1) != 0)
				return content[3239];
			if ((content[1190 + spriteOffset] >> bit & 1) != 0)
				return content[3238];
		}
		let offset = (y >> 3) * 12 + (x >> 3);
		return content[1058 + offset] >> ((content[2 + (offset << 3) + (y & 7)] >> bit & 1) << 2);
	}

	#decodeShe(content, contentLength)
	{
		switch (contentLength) {
		case 3250:
			this.#setSize(96, 88, RECOILResolution.C641X1);
			for (let y = 0; y < 88; y++) {
				for (let x = 0; x < 96; x++)
					this.#pixels[y * 96 + x] = this.#c64Palette[RECOIL.#getShe1Pixel(content, x, y) & 15];
			}
			return true;
		case 8642:
			return this.#decodeSuperHires2(content, 2, 8130, 24, 4034, 1, 8634);
		default:
			return false;
		}
	}

	static #getIshPixel(content, contentOffset, x, y)
	{
		let bit = ~x & 7;
		let column = x >> 3;
		if (column < 12) {
			let spriteInLine = column / 3 | 0;
			let spriteOffset = contentOffset + ((spriteInLine * 10 + (y / 21 | 0)) << 6) + y % 21 * 3 + column % 3;
			if ((content[10752 + spriteOffset] >> bit & 1) != 0)
				return content[contentOffset + 15364 + spriteInLine];
			if ((content[8192 + spriteOffset] >> bit & 1) != 0)
				return content[contentOffset + 15360 + spriteInLine];
		}
		let offset = (y & ~7) * 5 + column;
		return content[contentOffset + 13312 + column] >> ((content[contentOffset + (offset << 3) + (y & 7)] >> bit & 1) << 2);
	}

	#decodeIshFrame(content, contentOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 320; x++)
				this.#pixels[pixelsOffset + y * 320 + x] = this.#c64Palette[RECOIL.#getIshPixel(content, contentOffset, x, y) & 15];
		}
	}

	#decodeIsh(content, contentLength)
	{
		switch (contentLength) {
		case 9194:
			return this.#decodeHed(content);
		case 30738:
			this.#setSize(320, 200, RECOILResolution.C641X1, 2);
			this.#decodeIshFrame(content, 2, 0);
			this.#decodeIshFrame(content, 15370, 64000);
			return this.#applyBlend();
		default:
			return false;
		}
	}

	static #getShfPixel(content, x, y)
	{
		let column = x >> 3;
		let bit = ~x & 7;
		if (column < 12) {
			let spriteIndex = ((y & 7) << 3) + (column / 3 | 0);
			let spriteOffset = y % 21 * 3 + column % 3;
			if ((content[2 + (RECOIL.#GET_SHF_PIXEL_SPRITES[spriteIndex] << 6) + spriteOffset] >> bit & 1) != 0)
				return content[1002];
			if ((content[2 + (RECOIL.#GET_SHF_PIXEL_SPRITES[spriteIndex + 4] << 6) + spriteOffset] >> bit & 1) != 0)
				return content[1003];
		}
		y++;
		let offset = (y & ~7) * 5 + column;
		return content[16 + ((y & 7) << 10) + offset] >> ((content[8306 + (offset << 3) + (y & 7)] >> bit & 1) << 2);
	}

	#decodeShfFrame(content, foreColor, backColor, pixelsOffset)
	{
		for (let y = 0; y < 167; y++) {
			for (let x = 0; x < 96; x++) {
				let offset = y * 12 + (x >> 3);
				let bit = ~x & 7;
				let c;
				if ((content[offset] >> bit & 1) != 0)
					c = foreColor;
				else if ((content[2048 + offset] >> bit & 1) != 0)
					c = backColor;
				else
					c = content[6144 + offset] >> ((content[4096 + offset] >> bit & 1) << 2);
				this.#pixels[pixelsOffset + y * 96 + x] = this.#c64Palette[c & 15];
			}
		}
	}

	#decodeShf(content, contentLength)
	{
		if (contentLength == 15874) {
			this.#setSize(208, 167, RECOILResolution.C641X1);
			for (let y = 0; y < 167; y++) {
				for (let x = 0; x < 208; x++)
					this.#pixels[y * 208 + x] = this.#c64Palette[RECOIL.#getShfPixel(content, x, y) & 15];
			}
			return true;
		}
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(8170);
		const rle = Object.assign(new UflStream(), { content: content, contentOffset: 3, contentLength: contentLength, escape: content[2] });
		if (!rle.unpack(unpacked, 0, 1, 8170))
			return false;
		this.#setSize(96, 167, RECOILResolution.C641X1);
		this.#decodeShfFrame(unpacked, unpacked[8168], unpacked[8168], 0);
		return true;
	}

	#decodeC64Sif(content, contentLength)
	{
		const rle = Object.assign(new UifStream(), { content: content, contentLength: contentLength });
		if (!rle.startSifFrame(0))
			return false;
		let frame2Offset = rle.contentOffset;
		const unpacked = new Uint8Array(8176);
		if (!rle.unpackBackwards(unpacked, 0, 8175) || !rle.startSifFrame(frame2Offset) || contentLength != rle.contentOffset + 4)
			return false;
		this.#setSize(96, 167, RECOILResolution.C641X1, 2);
		this.#decodeShfFrame(unpacked, content[contentLength - 4], content[contentLength - 3], 0);
		if (!rle.unpackBackwards(unpacked, 0, 8175))
			return false;
		this.#decodeShfFrame(unpacked, content[contentLength - 2], content[contentLength - 1], 16032);
		return this.#applyBlend();
	}

	#decodeUflFrame(content, bitmapOffset, videoMatrixOffset, spritesOffset, spriteColorsOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 288; x++) {
				let column = x >> 3;
				let offset = 3 + (y & ~7) * 5 + column;
				let c = content[videoMatrixOffset + ((y & 6) << 9) + offset];
				if ((content[bitmapOffset + (offset << 3) + (y & 7)] >> (~x & 7) & 1) != 0)
					c >>= 4;
				else if ((content[spritesOffset + (((y / 40 | 0) * 12 + (y & 2) * 3 + (column / 6 | 0)) << 6) + ((y + 1) >> 1) % 21 * 3 + (column >> 1) % 3] >> (~x >> 1 & 7) & 1) != 0)
					c = content[spriteColorsOffset == 4084 ? 4084 + (column / 6 | 0) : spriteColorsOffset];
				this.#pixels[pixelsOffset + y * 288 + x] = this.#c64Palette[c & 15];
			}
		}
	}

	#decodeUflUnpacked(content)
	{
		this.#setSize(288, 200, RECOILResolution.C641X1);
		this.#decodeUflFrame(content, 8194, 4098, 2, content[4081] == 1 ? 4084 : 4082, 0);
		return true;
	}

	#decodeUfl(content, contentLength)
	{
		if (contentLength == 16194)
			return this.#decodeUflUnpacked(content);
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(16194);
		const rle = Object.assign(new UflStream(), { content: content, contentOffset: 3, contentLength: contentLength, escape: content[2] });
		return rle.unpack(unpacked, 2, 1, 16194) && this.#decodeUflUnpacked(unpacked);
	}

	#decodeUif(content, contentLength)
	{
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(32576);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[2] });
		if (!rle.unpackBackwards(unpacked, 0, 32575))
			return false;
		this.#setSize(288, 200, RECOILResolution.C641X1, 2);
		this.#decodeUflFrame(unpacked, 8192, 0, 4096, 4080, 0);
		this.#decodeUflFrame(unpacked, 24576, 16384, 20480, 4080, 57600);
		return this.#applyBlend();
	}

	#decodeXfl(content, contentLength)
	{
		const unpacked = new Uint8Array(16192);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[2] });
		if (!rle.unpackBackwards(unpacked, 0, 16191))
			return false;
		const spriteColors = new Uint8Array(16);
		spriteColors.set(unpacked.subarray(8174, 8184), 1);
		this.#setSize(192, 167, RECOILResolution.C641X1);
		for (let y = 0; y < 167; y++) {
			if (y >= 3 && (y & 1) != 0) {
				let offset = (y - 3) >> 1;
				offset = ((offset / 28 | 0) << 10) + offset % 28;
				spriteColors[unpacked[988 + offset] & 15] = unpacked[960 + offset];
			}
			for (let x = 0; x < 192; x++) {
				let column = x >> 3;
				let offset = ((1 + y) & ~7) * 5 + 16 + column;
				let c;
				if ((unpacked[8192 + (offset << 3) + ((1 + y) & 7)] >> (~x & 7) & 1) != 0)
					c = unpacked[(((y - 1) & 7) << 10) + offset] >> 4;
				else {
					let spriteInLine = column / 3 | 0;
					switch (unpacked[(RECOIL.#DECODE_XFL_SPRITES[((y & 7) << 3) + spriteInLine] << 6) + (y >> 1) % 21 * 3 + column % 3] >> (~x & 6) & 3) {
					case 1:
						c = spriteColors[1];
						break;
					case 2:
						c = spriteColors[3 + spriteInLine];
						break;
					case 3:
						c = spriteColors[2];
						break;
					default:
						c = unpacked[(((y - 1) & 7) << 10) + offset];
						break;
					}
				}
				this.#pixels[y * 192 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	static #getNufVideoMatrixOffset(y)
	{
		if (y < 128)
			return 8194 + ((~y >> 1 & 7) << 10);
		else
			return 2 + ((((y >> 1) + (y >= 168 ? 1 : 0)) & 3) << 10);
	}

	static #getMufTableOffset(spriteInLine)
	{
		return ((spriteInLine & 6) << 9) + ((spriteInLine & 1) << 7);
	}

	#decodeMufFrame(content, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			let videoMatrixOffset = RECOIL.#getNufVideoMatrixOffset(y) - 256;
			for (let x = 0; x < 296; x++) {
				let column = x >> 3;
				let offset = (y & ~7) * 5 + 3 + column;
				let c = content[videoMatrixOffset + offset];
				if ((content[16130 - ((y & 128) << 7) + (offset << 3) + (y & 7)] >> (~x & 7) & 1) != 0)
					c >>= 4;
				else if (column < 36) {
					let spriteInLine = column / 6 | 0;
					offset = 124 - ((y & 128) << 1) + content[videoMatrixOffset + 1017 + spriteInLine];
					if (offset < 0 || offset >= 340)
						return false;
					let b = content[2 + (offset << 6) + ((((y + 47) >> 1) * 3 + (column >> 1) % 3 + (y < 123 ? 0 : y < 165 ? 1 : 2)) & 63)];
					offset = (y + 1) >> 1;
					if ((content[4610 + offset] >> spriteInLine & 2) != 0) {
						switch (b >> (~x >> 1 & 6) & 3) {
						case 1:
							c = content[7923];
							break;
						case 2:
							c = content[770 + RECOIL.#getMufTableOffset(spriteInLine) + offset];
							break;
						case 3:
							c = content[7922];
							break;
						default:
							break;
						}
					}
					else if ((b >> (~x >> 1 & 7) & 1) != 0)
						c = content[770 + RECOIL.#getMufTableOffset(spriteInLine) + offset];
				}
				this.#pixels[pixelsOffset + y * 296 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeMuf(content, contentLength)
	{
		if (contentLength != 21826)
			return false;
		this.#setSize(296, 200, RECOILResolution.C641X1);
		return this.#decodeMufFrame(content, 0);
	}

	#decodeMup(content, contentLength)
	{
		if (contentLength < 6)
			return false;
		const unpacked = new Uint8Array(21762);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[2] });
		return rle.unpackBackwards(unpacked, 2, 21761) && this.#decodeMuf(unpacked, 21826);
	}

	#decodeMui(content, contentLength)
	{
		if (contentLength != 44034)
			return false;
		this.#setSize(296, 200, RECOILResolution.C641X1, 2);
		if (!this.#decodeMufFrame(content, 0))
			return false;
		const second = new Uint8Array(21762);
		second.set(content.subarray(32770, 44034), 2);
		second.set(content.subarray(22018, 32514), 11266);
		return this.#decodeMufFrame(second, 59200) && this.#applyBlend();
	}

	#decodeNuf(content, contentLength)
	{
		if (contentLength != 23042)
			return false;
		this.#setSize(320, 200, RECOILResolution.C641X1);
		const spriteColors = new Uint8Array(10);
		spriteColors[0] = content[8185];
		for (let i = 0; i < 6; i++)
			spriteColors[1 + i] = content[1026 + RECOIL.#getMufTableOffset(i)];
		spriteColors[7] = content[8179];
		spriteColors[8] = content[8184];
		spriteColors[9] = content[8178];
		for (let y = 0; y < 200; y++) {
			if (y > 0) {
				for (let i = 0; i < 6; i++) {
					let b = content[1026 + RECOIL.#getMufTableOffset(i) + ((y + 1) >> 1)];
					switch (b >> 4) {
					case 0:
						if ((y & 1) != 0)
							spriteColors[1 + i] = b;
						break;
					case 5:
						if ((y & 1) == (i == 0 ? 1 : 0))
							spriteColors[7] = b;
						break;
					case 6:
						if ((y & 1) == (i == 0 ? 1 : 0))
							spriteColors[9] = b;
						break;
					case 7:
						if ((y & 1) == (i == 0 ? 1 : 0))
							spriteColors[0] = b;
						break;
					case 14:
						if ((y & 1) == (i == 0 ? 1 : 0))
							spriteColors[8] = b;
						break;
					default:
						break;
					}
				}
			}
			let videoMatrixOffset = RECOIL.#getNufVideoMatrixOffset(y);
			for (let x = 0; x < 320; x++) {
				let column = x >> 3;
				let offset = (y & ~7) * 5 + column;
				let c = column >= 3 || (y & 6) == 0 ? content[videoMatrixOffset + offset] : 255;
				if ((content[(y < 128 ? 16386 : 2) + (offset << 3) + (y & 7)] >> (~x & 7) & 1) != 0)
					c >>= 4;
				else if (column < 39) {
					let spriteInLine = (3 + column) / 6 | 0;
					offset = 128 - ((y & 128) << 1) + content[videoMatrixOffset + 1016 + spriteInLine];
					if (offset < 0 || offset >= 360)
						return false;
					let spriteX = column < 3 ? x : ((x - 24) >> 1) % 24;
					let b = content[2 + (offset << 6) + ((((y + 47) >> 1) * 3 + (spriteX >> 3) + (y < 123 ? 0 : y < 165 ? 1 : 2)) & 63)];
					if ((b >> (~spriteX & 7) & 1) != 0)
						c = spriteColors[spriteInLine];
					else if (column < 3) {
						offset = 128 - ((y & 128) << 1) + content[videoMatrixOffset + 1023];
						if (offset < 0 || offset >= 360)
							return false;
						b = content[2 + (offset << 6) + ((((y + 47) >> 1) * 3 + column + (y < 123 ? 0 : y < 165 ? 1 : 2)) & 63)] >> (~x & 6) & 3;
						if (b != 0)
							c = spriteColors[6 + b];
					}
				}
				this.#pixels[y * 320 + x] = this.#c64Palette[c & 15];
			}
		}
		return true;
	}

	#decodeNup(content, contentLength)
	{
		if (contentLength < 7 || content[2] != 253)
			return false;
		const unpacked = new Uint8Array(23042);
		const rle = Object.assign(new UifStream(), { content: content, contentOffset: contentLength, escape: content[3] });
		return rle.unpackBackwards(unpacked, 2, 23041) && this.#decodeNuf(unpacked, 23042);
	}

	#decodeDoo(content, contentLength)
	{
		this.#setSize(640, 400, RECOILResolution.ST1X1);
		return this.#decodeBlackAndWhite(content, 0, contentLength, false, 16777215);
	}

	#decodeDa4(content, contentLength)
	{
		this.#setSize(640, 800, RECOILResolution.ST1X1);
		return this.#decodeBlackAndWhite(content, 0, contentLength, false, 16777215);
	}

	#decodeStCmp(content, contentLength)
	{
		if (contentLength < 5)
			return false;
		switch (content[1]) {
		case 0:
			this.#setSize(640, 400, RECOILResolution.ST1X1);
			break;
		case 200:
			this.#setSize(640, 800, RECOILResolution.ST1X1);
			break;
		default:
			return false;
		}
		const rle = Object.assign(new CmpStream(), { content: content, contentOffset: 2, contentLength: contentLength, escape: content[0] });
		return this.#decodeRleBlackAndWhite(rle, 16777215);
	}

	#decodeBld(content, contentLength)
	{
		if (contentLength < 5)
			return false;
		let width = content[0] << 8 | content[1];
		let height = (content[2] << 8) + content[3] + 1;
		if (content[0] < 128)
			return this.#setSize(width + 1, height, RECOILResolution.ST1X1) && this.#decodeBlackAndWhite(content, 4, contentLength, false, 16777215);
		if (!this.#setSize(65537 - width, height, RECOILResolution.ST1X1))
			return false;
		const rle = Object.assign(new BldStream(), { content: content, contentOffset: 4, contentLength: contentLength });
		return this.#decodeRleBlackAndWhite(rle, 16777215);
	}

	#decodeCrg(content, contentLength)
	{
		if (contentLength < 43 || !RECOIL.isStringAt(content, 0, "CALAMUSCRG") || content[10] != 3 || content[11] != 232 || content[12] != 0 || content[13] != 2)
			return false;
		let width = RECOIL.get32BigEndian(content, 20);
		let height = RECOIL.get32BigEndian(content, 24);
		if (!this.#setSize(width, height, RECOILResolution.ST1X1))
			return false;
		const rle = Object.assign(new CciStream(), { content: content, contentOffset: 42, contentLength: contentLength });
		return this.#decodeRleBlackAndWhite(rle, 16777215);
	}

	#decodePac(content, contentLength)
	{
		if (contentLength < 8 || content[0] != 112 || content[1] != 77 || content[2] != 56)
			return false;
		let unpackedStride;
		switch (content[3]) {
		case 53:
			unpackedStride = 1;
			break;
		case 54:
			unpackedStride = 80;
			break;
		default:
			return false;
		}
		const rle = Object.assign(new PacStream(), { content: content, contentOffset: 7, contentLength: contentLength });
		const unpacked = new Uint8Array(32000);
		return rle.unpackColumns(unpacked, 0, unpackedStride, 32000) && this.#decodeDoo(unpacked, 32000);
	}

	static #fillPscLine(unpacked, unpackedOffset, unpackedStride, value)
	{
		for (let i = 0; i < unpackedStride; i++)
			unpacked[unpackedOffset + i] = value;
	}

	static #copyPscLines(unpacked, unpackedOffset, unpackedStride, unpackedLength, count)
	{
		if (unpackedOffset < unpackedStride || unpackedOffset + count * unpackedStride > unpackedLength)
			return -1;
		do {
			unpacked.set(unpacked.subarray(unpackedOffset - unpackedStride, unpackedOffset - unpackedStride + unpackedStride), unpackedOffset);
			unpackedOffset += unpackedStride;
		}
		while (--count > 0);
		return unpackedOffset;
	}

	#decodePsc(content, contentLength)
	{
		if (contentLength < 18 || !RECOIL.isStringAt(content, 0, "tm89") || content[8] != 2 || content[9] != 1)
			return false;
		let width = (content[10] << 8) + content[11] + 1;
		let height = (content[12] << 8) + content[13] + 1;
		if (width > 640 || height > 400)
			return false;
		this.#setSize(width, height, RECOILResolution.ST1X1);
		let unpackedStride = (width + 7) >> 3;
		let unpackedLength = unpackedStride * height;
		if (content[14] == 99 && contentLength == 16 + unpackedLength && content[15 + unpackedLength] == 255)
			return this.#decodeBlackAndWhite(content, 15, contentLength - 1, false, 16777215);
		const unpacked = new Uint8Array(32000);
		let contentOffset = 14;
		for (let unpackedOffset = 0; unpackedOffset < unpackedLength;) {
			if (contentOffset + 1 >= contentLength)
				return false;
			switch (content[contentOffset++]) {
			case 0:
				RECOIL.#fillPscLine(unpacked, unpackedOffset, unpackedStride, 0);
				unpackedOffset += unpackedStride;
				break;
			case 10:
				unpackedOffset = RECOIL.#copyPscLines(unpacked, unpackedOffset, unpackedStride, unpackedLength, 1 + content[contentOffset++]);
				if (unpackedOffset < 0)
					return false;
				break;
			case 12:
				unpackedOffset = RECOIL.#copyPscLines(unpacked, unpackedOffset, unpackedStride, unpackedLength, 257 + content[contentOffset++]);
				if (unpackedOffset < 0)
					return false;
				break;
			case 100:
				RECOIL.#fillPscLine(unpacked, unpackedOffset, unpackedStride, content[contentOffset++]);
				unpackedOffset += unpackedStride;
				break;
			case 102:
				if (contentOffset + 2 >= contentLength)
					return false;
				for (let i = 0; i < unpackedStride; i++)
					unpacked[unpackedOffset + i] = content[contentOffset + (i & 1)];
				contentOffset += 2;
				unpackedOffset += unpackedStride;
				break;
			case 110:
				if (contentOffset + unpackedStride >= contentLength)
					return false;
				unpacked.set(content.subarray(contentOffset, contentOffset + unpackedStride), unpackedOffset);
				contentOffset += unpackedStride;
				unpackedOffset += unpackedStride;
				break;
			case 200:
				RECOIL.#fillPscLine(unpacked, unpackedOffset, unpackedStride, 255);
				unpackedOffset += unpackedStride;
				break;
			default:
				return false;
			}
		}
		if (contentOffset >= contentLength || content[contentOffset] != 255)
			return false;
		return this.#decodeBlackAndWhite(unpacked, 0, unpackedLength, false, 16777215);
	}

	#decodeCp3(content, contentLength)
	{
		if (contentLength < 4)
			return false;
		let countLength = (1 + (content[0] << 8) + content[1]) << 2;
		if (contentLength <= countLength)
			return false;
		let valueOffset = countLength;
		const unpacked = new Uint8Array(32000);
		let unpackedOffset = 0;
		let count;
		for (let countOffset = 4; countOffset < countLength; countOffset += 4) {
			count = (content[countOffset] << 8 | content[countOffset + 1]) << 3;
			if (valueOffset + count + 8 > contentLength || unpackedOffset + count > 32000)
				return false;
			unpacked.set(content.subarray(valueOffset, valueOffset + count), unpackedOffset);
			valueOffset += count;
			unpackedOffset += count;
			count = (content[countOffset + 2] << 8 | content[countOffset + 3]) << 3;
			if (unpackedOffset + count > 32000)
				return false;
			for (let offset = 0; offset < count; offset += 8)
				unpacked.set(content.subarray(valueOffset, valueOffset + 8), unpackedOffset + offset);
			valueOffset += 8;
			unpackedOffset += count;
		}
		count = 32000 - unpackedOffset;
		if (valueOffset + count != contentLength)
			return false;
		unpacked.set(content.subarray(valueOffset, valueOffset + count), unpackedOffset);
		return this.#decodeDoo(unpacked, 32000);
	}

	#decodeStFnt(content, contentLength)
	{
		switch (contentLength) {
		case 2050:
			this.#setSize(256, 64, RECOILResolution.ST1X1);
			break;
		case 4096:
		case 4098:
			this.#setSize(256, 128, RECOILResolution.ST1X1);
			break;
		default:
			return false;
		}
		if ((contentLength & 2) != 0) {
			if (content[contentLength - 2] != 0 || content[contentLength - 2] > 1)
				return false;
			contentLength -= 2;
		}
		this.#decodeBlackAndWhiteFont(content, 0, contentLength, 16);
		return true;
	}

	#decodeGdosFnt(content, contentLength)
	{
		if (contentLength < 88 || content[62] != 85 || content[63] != 85)
			return false;
		const stream = new GdosFntStream();
		if (content[3] == 0) {
			if (content[2] == 0)
				return false;
			stream.bigEndian = false;
		}
		else if (content[2] == 0)
			stream.bigEndian = true;
		else
			return false;
		stream.content = content;
		stream.contentLength = contentLength;
		stream.contentOffset = 36;
		let firstCharacter = stream.readWord();
		let lastCharacter = stream.readWord();
		if (firstCharacter > lastCharacter)
			return false;
		stream.contentOffset = 72;
		let characterOffset = stream.readInt();
		if (characterOffset <= 0 || characterOffset >= contentLength)
			return false;
		let bitmapOffset = stream.readInt();
		if (bitmapOffset < 0 || bitmapOffset >= contentLength)
			return false;
		let bytesPerLine = stream.readWord();
		if (bytesPerLine == 0)
			return false;
		let height = stream.readWord();
		if (height == 0 || bitmapOffset + height * bytesPerLine > contentLength)
			return false;
		let characterEndOffset = characterOffset + ((lastCharacter - firstCharacter + 2) << 1);
		if (characterEndOffset > bitmapOffset)
			return false;
		let width = Math.min(height << 4, 3840);
		stream.contentOffset = characterOffset;
		stream.contentLength = characterEndOffset;
		stream.bitmapWidth = bytesPerLine << 3;
		stream.width = width;
		stream.nextX = stream.rightX = 0;
		let row;
		for (row = 0; stream.nextX >= 0; row += height) {
			if (!stream.fitRow())
				return false;
		}
		if (!this.#setSize(width, row, RECOILResolution.ST1X1))
			return false;
		stream.contentOffset = characterOffset;
		stream.nextX = stream.rightX = 0;
		for (row = 0; stream.nextX >= 0; row += height) {
			stream.fitRow();
			for (let y = 0; y < height; y++) {
				for (let x = 0; x < width; x++) {
					let fontX = stream.leftX + x;
					let c;
					if (fontX < stream.rightX) {
						let offset = bitmapOffset + y * bytesPerLine + (fontX >> 3);
						c = (content[offset] >> (~fontX & 7) & 1) == 0 ? 16777215 : 0;
					}
					else
						c = 16777215;
					this.#pixels[(row + y) * width + x] = c;
				}
			}
		}
		return true;
	}

	static #isStePalette(content, contentOffset, colors)
	{
		while (--colors >= 0) {
			if ((content[contentOffset] & 8) != 0 || (content[contentOffset + 1] & 136) != 0)
				return true;
			contentOffset += 2;
		}
		return false;
	}

	#getStColor(content, contentOffset)
	{
		let r = content[contentOffset];
		let gb = content[contentOffset + 1];
		let rgb;
		switch (this.#resolution) {
		case RECOILResolution.ST1X1:
		case RECOILResolution.ST1X2:
			rgb = (r & 7) << 16 | (gb & 112) << 4 | (gb & 7);
			return rgb << 5 | rgb << 2 | (rgb >> 1 & 197379);
		case RECOILResolution.TT1X1:
		case RECOILResolution.TT2X1:
			rgb = (r & 15) << 16 | (gb & 240) << 4 | (gb & 15);
			return rgb << 4 | rgb;
		default:
			rgb = (r & 7) << 17 | (r & 8) << 13 | (gb & 112) << 5 | (gb & 135) << 1 | (gb & 8) >> 3;
			return rgb << 4 | rgb;
		}
	}

	setStPalette(content, contentOffset, colors, c = 0)
	{
		for (; c < colors; c++)
			this.contentPalette[c] = this.#getStColor(content, contentOffset + (c << 1));
	}

	static getSteInterlacedColor(rgb)
	{
		rgb = (rgb & 1792) << 10 | (rgb & 2160) << 6 | (rgb & 16519) << 2 | (rgb & 8192) >> 5 | (rgb & 8) >> 2 | (rgb & 4096) >> 12;
		return rgb << 3 | (rgb >> 2 & 460551);
	}

	static #getStVdiColor(content, contentOffset)
	{
		let rgb = 0;
		for (let i = 0; i < 6; i += 2) {
			let c = content[contentOffset + i] << 8 | content[contentOffset + i + 1];
			c = c < 1000 ? c * 255 / 1000 | 0 : 255;
			rgb = rgb << 8 | c;
		}
		return rgb;
	}

	setStVdiColor(i, rgb, bitplanes)
	{
		switch (i) {
		case 1:
			i = (1 << bitplanes) - 1;
			break;
		case 2:
			i = 1;
			break;
		case 3:
			i = 2;
			break;
		case 5:
			i = 6;
			break;
		case 6:
			i = 3;
			break;
		case 7:
			i = 5;
			break;
		case 8:
			i = 7;
			break;
		case 9:
			i = 8;
			break;
		case 10:
			i = 9;
			break;
		case 11:
			i = 10;
			break;
		case 13:
			i = 14;
			break;
		case 14:
			i = 11;
			break;
		case 15:
			i = 13;
			break;
		case 255:
			i = 15;
			break;
		default:
			break;
		}
		this.contentPalette[i] = rgb;
	}

	#setStVdiPalette(content, contentOffset, colors, bitplanes)
	{
		for (let i = 0; i < colors; i++)
			this.setStVdiColor(i, RECOIL.#getStVdiColor(content, contentOffset + i * 6), bitplanes);
	}

	static #getStLowPixel(content, contentOffset, x)
	{
		return RECOIL.#getBitplaneWordsPixel(content, contentOffset, x, 4);
	}

	#decodeStLowWithStride(bitmap, bitmapOffset, bitmapStride, palette, paletteOffset, width, height, frames)
	{
		this.#setSize(width, height, RECOIL.#isStePalette(palette, paletteOffset, 16) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1, frames);
		this.setStPalette(palette, paletteOffset, 16);
		this.#decodeBitplanes(bitmap, bitmapOffset, bitmapStride, 4, 0, width, height);
		return true;
	}

	#decodeStLow(bitmap, bitmapOffset, palette, paletteOffset, width, height, frames = 1)
	{
		return this.#decodeStLowWithStride(bitmap, bitmapOffset, (width + 15) >> 4 << 3, palette, paletteOffset, width, height, frames);
	}

	#decodeStMedium(bitmap, bitmapOffset, palette, paletteOffset, width, height, frames)
	{
		this.#setSize(width, height << 1, RECOIL.#isStePalette(palette, paletteOffset, 4) ? RECOILResolution.STE1X2 : RECOILResolution.ST1X2, frames);
		this.setStPalette(palette, paletteOffset, 4);
		this.#decodeScaledBitplanes(bitmap, bitmapOffset, width, height * frames, 2, false, null);
	}

	#decodeSrt(content, contentLength)
	{
		if (contentLength != 32038 || !RECOIL.isStringAt(content, 32000, "JHSy") || content[32004] != 0 || content[32005] != 1)
			return false;
		this.#decodeStMedium(content, 0, content, 32006, 640, 200, 1);
		return true;
	}

	decodeSt(bitmap, bitmapOffset, palette, paletteOffset, mode, doubleHeight)
	{
		switch (mode) {
		case 0:
			return this.#decodeStLow(bitmap, bitmapOffset, palette, paletteOffset, 320, 200 << doubleHeight);
		case 1:
			this.#decodeStMedium(bitmap, bitmapOffset, palette, paletteOffset, 640, 200 << doubleHeight, 1);
			return true;
		case 2:
			this.#setSize(640, 400 << doubleHeight, RECOILResolution.ST1X1);
			return this.#decodeBlackAndWhite(bitmap, bitmapOffset, bitmapOffset + (32000 << doubleHeight), false, 16777215);
		default:
			return false;
		}
	}

	#decodeStPi(content, contentLength)
	{
		if (contentLength < 32034 || content[0] != 0)
			return false;
		switch (contentLength) {
		case 32034:
		case 32066:
		case 32128:
			return this.decodeSt(content, 34, content, 2, content[1], 0);
		case 38434:
			return content[1] == 4 && this.#decodeStLow(content, 34, content, 2, 320, 240);
		case 44834:
			return content[1] == 0 && this.#decodeStLow(content, 34, content, 2, 320, 280);
		case 64034:
			return this.decodeSt(content, 34, content, 2, content[1], 1);
		case 116514:
			return content[1] == 0 && this.#decodeStLow(content, 34, content, 2, 416, 560);
		case 153606:
			if (content[1] != 6)
				return false;
			this.#setSize(1280, 960, RECOILResolution.TT1X1);
			return this.#decodeBlackAndWhite(content, 6, contentLength, false, 16777215);
		case 153634:
			if (content[1] != 4)
				return false;
			this.#setSize(640, 480, RECOILResolution.TT1X1);
			this.setStPalette(content, 2, 16);
			this.#decodeBitplanes(content, 34, 320, 4, 0, 640, 480);
			return true;
		case 154114:
			if (content[1] != 7)
				return false;
			this.#setSize(640, 480, RECOILResolution.TT2X1);
			this.setStPalette(content, 2, 256);
			this.#decodeScaledBitplanes(content, 514, 320, 480, 8, false, null);
			return true;
		default:
			return false;
		}
	}

	#decodePc(content, contentLength)
	{
		if (contentLength < 68 || content[0] != 128 || content[1] > 2)
			return false;
		let bitplanes = 4 >> content[1];
		const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: 34, contentLength: contentLength });
		const unpacked = new Uint8Array(32000);
		return rle.unpackBitplaneLines(unpacked, 320 << content[1], 200, bitplanes, true, false) && this.decodeSt(unpacked, 0, content, 2, content[1], 0);
	}

	#decodeEza(content, contentLength)
	{
		if (contentLength < 44 || content[0] != 69 || content[1] != 90 || content[2] != 0 || content[3] != 200)
			return false;
		const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: 44, contentLength: contentLength });
		const unpacked = new Uint8Array(32000);
		return rle.unpackBitplaneLines(unpacked, 320, 200, 4, true, false) && this.#decodeStLow(unpacked, 0, content, 4, 320, 200);
	}

	#decodeNeo(filename, content, contentLength)
	{
		switch (contentLength) {
		case 32128:
			if (content[0] != 0 || content[1] != 0 || content[2] != 0)
				return false;
			if (content[3] == 0) {
				const rst = new Uint8Array(6801);
				if (this.#readCompanionFile(filename, "RST", "rst", rst, 6801) == 6800) {
					this.#setSize(320, 200, RECOILResolution.ST1X1);
					this.setStPalette(content, 4, 16);
					const palette = Object.assign(new RastPalette(), { content: rst, contentOffset: 0, contentLength: 6800, colors: 16 });
					this.#decodeScaledBitplanes(content, 128, 320, 200, 4, false, palette);
					return true;
				}
			}
			return this.decodeSt(content, 128, content, 4, content[3], 0);
		case 128128:
			return content[0] == 186 && content[1] == 190 && content[2] == 0 && content[3] == 0 && this.#decodeStLow(content, 128, content, 4, 640, 400);
		default:
			return false;
		}
	}

	#decodeArtDirector(content, contentLength)
	{
		return contentLength == 32512 && content[32287] < 8 && this.#decodeStLow(content, 0, content, 32000 + (content[32287] << 5), 320, 200);
	}

	#decodeSsb(content, contentLength)
	{
		return contentLength == 32768 && this.#decodeStLow(content, 0, content, 32000, 320, 200);
	}

	#decodeGfaArtist(content, contentLength)
	{
		switch (contentLength) {
		case 32032:
			return this.#decodeStLow(content, 32, content, 0, 320, 200);
		case 34360:
			this.#setSize(320, 200, RECOILResolution.ST1X1);
			const palette = Object.assign(new GfaArtistPalette(), { content: content });
			this.#decodeScaledBitplanes(content, 4, 320, 200, 4, false, palette);
			return true;
		default:
			return false;
		}
	}

	#decodeBil(content, contentLength)
	{
		switch (contentLength) {
		case 32032:
			return this.#decodeStLow(content, 32, content, 0, 320, 200);
		case 32034:
			return content[0] == 0 && content[1] == 0 && this.#decodeStLow(content, 34, content, 2, 320, 200);
		default:
			return false;
		}
	}

	#decodePaletteMaster(content, contentLength)
	{
		if (contentLength != 36864 || content[35968] != 255 || content[35969] != 255)
			return false;
		this.#setSize(320, 200, RECOILResolution.ST1X1);
		const palette = Object.assign(new ArtPalette(), { content: content, contentOffset: 32800 });
		this.#decodeScaledBitplanes(content, 0, 320, 200, 4, false, palette);
		return true;
	}

	#decodeCel(content, contentLength)
	{
		if (contentLength < 128 || content[0] != 255 || content[1] != 255 || content[2] != 0 || content[3] != 0)
			return false;
		let width = content[58] << 8 | content[59];
		let height = content[60] << 8 | content[61];
		return contentLength == 128 + ((width + 15) >> 4 << 3) * height && this.#decodeStLow(content, 128, content, 4, width, height);
	}

	#decodeMur(filename, content, contentLength)
	{
		if (contentLength != 32000)
			return false;
		const pal = new Uint8Array(97);
		if (this.#readCompanionFile(filename, "PAL", "pal", pal, 97) != 96)
			return false;
		this.#setSize(320, 200, RECOILResolution.STE1X1);
		this.#setStVdiPalette(pal, 0, 16, 4);
		this.#decodeBitplanes(content, 0, 160, 4, 0, 320, 200);
		return true;
	}

	#decodeKid(content, contentLength)
	{
		return contentLength == 63054 && content[0] == 75 && content[1] == 68 && this.#decodeStLowWithStride(content, 34, 230, content, 2, 448, 274, 1);
	}

	#decodeStPpp(content, contentLength)
	{
		return contentLength == 32079 && RECOIL.isStringAt(content, 0, "PABLO PACKED PICTURE: Groupe CDND \r\n32036\r\n") && content[44] == 0 && content[45] == 125 && content[46] == 36 && this.decodeSt(content, 79, content, 47, content[43], 0);
	}

	#decodeStRgb(content, contentLength)
	{
		if (contentLength != 96102)
			return false;
		this.#setSize(320, 200, RECOILResolution.STE1X1);
		this.#frames = 3;
		for (let i = 0; i < 64000; i++) {
			let rgb = RECOIL.#getStLowPixel(content, 34, i) << 16 | RECOIL.#getStLowPixel(content, 32068, i) << 8 | RECOIL.#getStLowPixel(content, 64102, i);
			this.#pixels[i] = rgb * 17;
		}
		return true;
	}

	#decodeSd(content, contentLength, mode)
	{
		return contentLength == 32128 && this.decodeSt(content, 128, content, 4, mode, 0);
	}

	#decodeObj(content, contentLength)
	{
		if (contentLength < 8)
			return false;
		if (content[4] == 0 && content[5] == 1) {
			return this.#setSize((content[0] << 8) + content[1] + 1, (content[2] << 8) + content[3] + 1, RECOILResolution.ST1X1) && this.#decodeBlackAndWhite(content, 6, contentLength, true, 16777215);
		}
		const s = Object.assign(new Stream(), { content: content, contentOffset: 0, contentLength: contentLength });
		for (let i = 0; i < 16; i++) {
			let rgb = s.parseDaliInt();
			if (rgb < 0 || rgb > 1911)
				return false;
			rgb = (rgb & 1792) << 8 | (rgb & 112) << 4 | (rgb & 7);
			this.contentPalette[i] = rgb << 5 | rgb << 2 | (rgb >> 1 & 197379);
		}
		let contentOffset = s.contentOffset;
		if (contentOffset + 6 >= contentLength || content[contentOffset + 2] != 0 || content[contentOffset + 4] != 0 || content[contentOffset + 5] != 4)
			return false;
		let width = (content[contentOffset] << 8) + content[contentOffset + 1] + 1;
		let height = content[contentOffset + 3] + 1;
		let stride = (width + 15) >> 4 << 3;
		if (contentOffset + 6 + height * stride != contentLength || !this.#setSize(width, height, RECOILResolution.ST1X1))
			return false;
		this.#decodeBitplanes(content, contentOffset + 6, stride, 4, 0, width, height);
		return true;
	}

	#decodeIc(content, contentLength)
	{
		if (contentLength < 68 || !RECOIL.isStringAt(content, 0, "IMDC") || content[4] != 0 || content[64] != 200 || content[65] != 2)
			return false;
		const unpacked = new Uint8Array(32000);
		const rle = Object.assign(new IcStream(), { content: content, contentOffset: 67, contentLength: contentLength });
		return rle.unpackColumns(unpacked, 0, 160, 32000) && this.decodeSt(unpacked, 0, content, 6, content[5], 0);
	}

	#decodeGraphicsProcessor(content, contentLength)
	{
		if (contentLength < 493 || content[0] != 0)
			return false;
		let mode = content[1];
		switch (mode) {
		case 0:
		case 1:
		case 2:
			return contentLength == 32331 && this.decodeSt(content, 331, content, 2, mode, 0);
		case 10:
		case 11:
		case 12:
			break;
		default:
			return false;
		}
		mode -= 10;
		let bitplanes = 4 >> mode;
		const unpacked = new Uint8Array(32000);
		let contentOffset = 333;
		let count = 0;
		for (let unpackedOffset = 0; unpackedOffset < 32000; unpackedOffset += bitplanes) {
			if (count == 0) {
				if (contentOffset + bitplanes >= contentLength)
					return false;
				count = content[contentOffset];
				if (count == 0)
					return false;
				contentOffset += 1 + bitplanes;
			}
			unpacked.set(content.subarray(contentOffset - bitplanes, contentOffset - bitplanes + bitplanes), unpackedOffset);
			count--;
		}
		return this.decodeSt(unpacked, 0, content, 2, mode, 0);
	}

	#decodeDaliCompressed(content, contentLength, mode)
	{
		const stream = Object.assign(new DaliStream(), { content: content, contentOffset: 32, contentLength: contentLength });
		let countLength = stream.parseDaliInt();
		return countLength > 0 && stream.parseDaliInt() > 0 && stream.decode(countLength, this, 0, mode);
	}

	#decodeRgh(content, contentLength)
	{
		if (contentLength < 14 || !RECOIL.isStringAt(content, 0, "(c)F.MARCHAL"))
			return false;
		const stream = Object.assign(new DaliStream(), { content: content, contentOffset: 12, contentLength: contentLength });
		let countLength = stream.parseDaliInt();
		let paletteOffset = stream.contentOffset;
		stream.contentOffset = paletteOffset + 32;
		return stream.decode(countLength, this, paletteOffset, 0);
	}

	#decodeSc(content, contentLength)
	{
		if (contentLength < 128 || !RECOIL.isStringAt(content, 54, "ANvisionA"))
			return false;
		let flags = content[63];
		let doubleHeight;
		switch (flags & 15) {
		case 0:
			doubleHeight = 1;
			break;
		case 1:
		case 2:
			doubleHeight = 0;
			break;
		default:
			return false;
		}
		let bitmapLength = 32000 << doubleHeight;
		let mode = flags >> 4 & 3;
		if (flags >= 128) {
			const unpacked = new Uint8Array(64000);
			const rle = Object.assign(new ScStream(), { content: content, contentOffset: 128, contentLength: contentLength });
			let bytesPer16Pixels = 8 >> mode;
			for (let bitplane = 0; bitplane < bytesPer16Pixels; bitplane += 2) {
				if (!rle.unpackWords(unpacked, bitplane, bytesPer16Pixels, bitmapLength))
					return false;
			}
			return this.decodeSt(unpacked, 0, content, 4, mode, doubleHeight);
		}
		return contentLength >= 128 + bitmapLength && this.decodeSt(content, 128, content, 4, mode, doubleHeight);
	}

	#decodeGfb(content, contentLength)
	{
		if (contentLength < 20 || !RECOIL.isStringAt(content, 0, "GF25"))
			return false;
		let bitplanes;
		switch (RECOIL.get32BigEndian(content, 4)) {
		case 2:
			bitplanes = 1;
			break;
		case 4:
			bitplanes = 2;
			break;
		case 16:
			bitplanes = 4;
			break;
		case 256:
			bitplanes = 8;
			break;
		default:
			return false;
		}
		let width = RECOIL.get32BigEndian(content, 8);
		if (width <= 0)
			return false;
		let height = RECOIL.get32BigEndian(content, 12);
		if (height <= 0)
			return false;
		let bitmapLength = RECOIL.get32BigEndian(content, 16);
		if (bitmapLength <= 0)
			return false;
		if (1556 + bitmapLength != contentLength || bitmapLength != ((width + 15) >> 4 << 1) * bitplanes * height || !this.#setSizeStOrFalcon(width, height, bitplanes, false))
			return false;
		this.#setStVdiPalette(content, 20 + bitmapLength, 1 << bitplanes, bitplanes);
		this.#decodeScaledBitplanes(content, 20, width, height, bitplanes, false, null);
		return true;
	}

	#decodeCa(content, contentLength)
	{
		if (contentLength < 8 || content[0] != 67 || content[1] != 65)
			return false;
		let contentOffset;
		switch (content[3]) {
		case 0:
			contentOffset = 36;
			break;
		case 1:
			contentOffset = 12;
			break;
		case 2:
			contentOffset = 4;
			break;
		default:
			return false;
		}
		switch (content[2]) {
		case 0:
			return contentOffset + 32000 == contentLength && this.decodeSt(content, contentOffset, content, 4, content[3], 0);
		case 1:
			{
				const unpacked = new Uint8Array(32000);
				const rle = Object.assign(new CaStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
				return rle.unpackCa(unpacked, 0) && this.decodeSt(unpacked, 0, content, 4, content[3], 0);
			}
		default:
			return false;
		}
	}

	#decodeTny(content, contentLength)
	{
		if (contentLength < 42)
			return false;
		let mode = content[0];
		let contentOffset;
		if (mode > 2) {
			if (mode > 5)
				return false;
			mode -= 3;
			contentOffset = 4;
		}
		else
			contentOffset = 0;
		let controlLength = content[contentOffset + 33] << 8 | content[contentOffset + 34];
		let valueLength = (content[contentOffset + 35] << 8 | content[contentOffset + 36]) << 1;
		if (contentOffset + 37 + controlLength + valueLength > contentLength)
			return false;
		const rle = Object.assign(new TnyStream(), { content: content, contentOffset: contentOffset + 37 });
		rle.valueOffset = rle.contentLength = contentOffset + 37 + controlLength;
		rle.valueLength = contentOffset + 37 + controlLength + valueLength;
		const unpacked = new Uint8Array(32000);
		for (let bitplane = 0; bitplane < 8; bitplane += 2) {
			for (let x = bitplane; x < 160; x += 8) {
				for (let unpackedOffset = x; unpackedOffset < 32000; unpackedOffset += 160) {
					let b = rle.readRle();
					if (b < 0)
						return false;
					unpacked[unpackedOffset] = b >> 8;
					unpacked[unpackedOffset + 1] = b & 255;
				}
			}
		}
		return this.decodeSt(unpacked, 0, content, contentOffset + 1, mode, 0);
	}

	static #unpackGrx(packed, packedOffset, packedLength, unpacked, unpackedOffset, unpackedLength)
	{
		let bits = 0;
		let bitsCount = 0;
		const offsets = new Int32Array(1024);
		let codes = 258;
		let codeBits = 9;
		while (unpackedOffset < unpackedLength) {
			while (bitsCount < codeBits) {
				if (packedOffset >= packedLength)
					return false;
				bits |= packed[packedOffset++] << bitsCount;
				bitsCount += 8;
			}
			let code = bits & ((1 << codeBits) - 1);
			bits >>= codeBits;
			bitsCount -= codeBits;
			switch (code) {
			case 256:
				if (codeBits == 10)
					return false;
				codeBits = 10;
				break;
			case 257:
				codes = 258;
				codeBits = 9;
				break;
			default:
				if (codes >= 1024)
					return false;
				offsets[codes] = unpackedOffset;
				if (code < 256) {
					unpacked[unpackedOffset++] = code;
				}
				else if (code >= codes)
					return false;
				else {
					let sourceOffset = offsets[code];
					let endOffset = offsets[code + 1];
					if (unpackedOffset + endOffset - sourceOffset >= unpackedLength)
						return false;
					do
						unpacked[unpackedOffset++] = unpacked[sourceOffset++];
					while (sourceOffset <= endOffset);
				}
				codes++;
				break;
			}
		}
		return true;
	}

	#decodeGrx(content, contentLength)
	{
		if (contentLength < 1588 || !RECOIL.isStringAt(content, 0, "GRXP") || content[4] != 1 || content[5] != 1 || content[28] != 0)
			return false;
		let width = content[30] << 8 | content[31];
		let height = content[32] << 8 | content[33];
		let bitplanes;
		switch (content[34] << 8 | content[35]) {
		case 2:
			bitplanes = 1;
			break;
		case 4:
			bitplanes = 2;
			break;
		case 16:
			bitplanes = 4;
			break;
		case 256:
			bitplanes = 8;
			break;
		default:
			return false;
		}
		let contentStride = ((width + 15) >> 4) * bitplanes << 1;
		let bitmapLength = RECOIL.get32BigEndian(content, 1574);
		if (bitmapLength != contentStride * height || !this.#setSizeStOrFalcon(width, height, bitplanes, true))
			return false;
		this.#setStVdiPalette(content, 36, 1 << bitplanes, bitplanes);
		switch (content[29]) {
		case 0:
			if (contentLength != 1586 + bitmapLength)
				return false;
			this.#decodeBitplanes(content, 1586, contentStride, bitplanes, 0, width, height);
			return true;
		case 1:
			let packed1Length = RECOIL.get32BigEndian(content, 1578);
			if (packed1Length <= 0)
				return false;
			let packed2Offset = 1586 + packed1Length;
			if (contentLength != packed2Offset + RECOIL.get32BigEndian(content, 1582))
				return false;
			let unpacked = new Uint8Array(bitmapLength);
			if (!RECOIL.#unpackGrx(content, 1586, packed2Offset, unpacked, 0, bitmapLength >> 1) || !RECOIL.#unpackGrx(content, packed2Offset, contentLength, unpacked, bitmapLength >> 1, bitmapLength))
				return false;
			this.#decodeBitplanes(unpacked, 0, contentStride, bitplanes, 0, width, height);
			return true;
		default:
			return false;
		}
	}

	#decodeCptFul(content, contentOffset, contentLength, palette)
	{
		if (contentLength < contentOffset + 40 || content[contentOffset + 32] != 0)
			return false;
		let mode = content[contentOffset + 33];
		if (mode > 2)
			return false;
		let bitplanes = 4 >> mode;
		const unpacked = new Uint8Array(32000);
		const isFilled = new Uint8Array(16000);
		contentOffset += 34;
		for (;;) {
			let nextContentOffset = contentOffset + 4 + bitplanes * 2;
			if (nextContentOffset > contentLength)
				return false;
			let repeatCount = content[contentOffset] << 8 | content[contentOffset + 1];
			if (repeatCount == 65535) {
				contentOffset = nextContentOffset;
				break;
			}
			let offset = (content[contentOffset + 2] << 8 | content[contentOffset + 3]) * bitplanes;
			do {
				if (offset >= 16000)
					return false;
				unpacked.set(content.subarray(contentOffset + 4, contentOffset + 4 + (bitplanes << 1)), offset << 1);
				isFilled[offset] = 1;
				offset += bitplanes;
			}
			while (--repeatCount >= 0);
			contentOffset = nextContentOffset;
		}
		for (let offset = 0; offset < 16000; offset += bitplanes) {
			if (isFilled[offset] == 0) {
				let nextContentOffset = contentOffset + bitplanes * 2;
				if (nextContentOffset > contentLength)
					return false;
				unpacked.set(content.subarray(contentOffset, contentOffset + (bitplanes << 1)), offset << 1);
				contentOffset = nextContentOffset;
			}
		}
		if (palette == null)
			return this.decodeSt(unpacked, 0, content, 0, mode, 0);
		if (mode == 0)
			this.#setSize(320, 200, RECOILResolution.ST1X1);
		else
			this.#setSize(640, 400, RECOILResolution.ST1X2);
		this.#decodeScaledBitplanes(unpacked, 0, 320 << mode, 200, bitplanes, false, palette);
		return true;
	}

	#decodeCpt(filename, content, contentLength)
	{
		if (contentLength < 40)
			return false;
		if (content[33] <= 1) {
			const hbl = new Uint8Array(3249);
			let hblLength = this.#readCompanionFile(filename, "HBL", "hbl", hbl, 3249);
			if (hblLength >= 896 && hblLength <= 3248) {
				const palette = Object.assign(new HblPalette(), { content: hbl, contentLength: hblLength });
				if (palette.init())
					return this.#decodeCptFul(content, 0, contentLength, palette);
			}
		}
		return this.#decodeCptFul(content, 0, contentLength, null);
	}

	#decodeFul(content, contentLength)
	{
		if (contentLength < 1544)
			return false;
		const palette = Object.assign(new HblPalette(), { content: content, contentLength: contentLength });
		return palette.init() && palette.contentOffset + 641 < contentLength && content[palette.contentOffset + 641] <= 1 && this.#decodeCptFul(content, palette.contentOffset + 608, contentLength, palette);
	}

	#setDefaultStPalette(bitplanes)
	{
		this.contentPalette[0] = 16777215;
		if (bitplanes >= 2) {
			this.contentPalette[1] = 16711680;
			this.contentPalette[2] = 65280;
			if (bitplanes == 4) {
				this.contentPalette[3] = 16776960;
				this.contentPalette[4] = 255;
				this.contentPalette[5] = 16711935;
				this.contentPalette[6] = 65535;
				this.contentPalette[7] = 11184810;
				this.contentPalette[8] = 5592405;
				this.contentPalette[9] = 11141120;
				this.contentPalette[10] = 43520;
				this.contentPalette[11] = 11184640;
				this.contentPalette[12] = 170;
				this.contentPalette[13] = 11141290;
				this.contentPalette[14] = 43690;
			}
		}
		this.contentPalette[(1 << bitplanes) - 1] = 0;
	}

	static #isXimg(content)
	{
		return RECOIL.isStringAt(content, 16, "XIMG") && content[20] == 0 && content[21] == 0;
	}

	#decodeSttt(rle, width, bytesPerBitplane)
	{
		let bitplanes = rle.content[5];
		this.setStPalette(rle.content, 22, 16);
		this.contentPalette.fill(0, 16, 256);
		let unpacked = new Uint8Array(bytesPerBitplane);
		let doubleWidth = this.#resolution == RECOILResolution.TT2X1 ? 1 : 0;
		for (let bitplane = 0; bitplane < bitplanes; bitplane++) {
			for (let y = 0; y < this.#height;) {
				let lineRepeatCount = rle.getLineRepeatCount();
				if (this.#resolution == RECOILResolution.ST1X2 || this.#resolution == RECOILResolution.STE1X2)
					lineRepeatCount <<= 1;
				if (lineRepeatCount > this.#height - y)
					lineRepeatCount = this.#height - y;
				if (!rle.unpackLine(unpacked, bytesPerBitplane, y))
					return false;
				while (--lineRepeatCount >= 0) {
					for (let x = 0; x < width; x++) {
						let c = unpacked[x >> 3] >> (~x & 7) & 1;
						let pixelsOffset = (y * width + x) << doubleWidth;
						if (bitplane != 0)
							c = c << bitplane | this.#pixels[pixelsOffset];
						if (bitplane == bitplanes - 1) {
							c = this.contentPalette[c];
							if (doubleWidth != 0)
								this.#pixels[pixelsOffset + 1] = c;
						}
						this.#pixels[pixelsOffset] = c;
					}
					y++;
				}
			}
		}
		return true;
	}

	#decodeStImg(content, contentLength)
	{
		if (contentLength < 17 || content[0] != 0 || content[1] > 3 || content[4] != 0)
			return false;
		let headerLength = (content[2] << 8 | content[3]) << 1;
		if (headerLength < 16 || headerLength >= contentLength)
			return false;
		let bitplanes = content[5];
		let width = content[12] << 8 | content[13];
		let height = content[14] << 8 | content[15];
		if (headerLength == 18 && content[16] == 0 && content[17] == 3) {
			if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			let contentOffset = 18;
			let pixelsLength = width * height;
			let count = 0;
			for (let i = 0; i < pixelsLength; i++) {
				if (count == 0) {
					if (contentOffset + 1 >= contentLength)
						return false;
					if (content[contentOffset++] != 128)
						return false;
					count = content[contentOffset++];
					if (count == 0)
						return false;
				}
				if (contentOffset + 2 >= contentLength)
					return false;
				this.#pixels[i] = RECOIL.#getB8G8R8Color(content, contentOffset);
				contentOffset += 3;
				count--;
			}
			return true;
		}
		let xRatio = content[8] << 8 | content[9];
		let yRatio = content[10] << 8 | content[11];
		if (bitplanes <= 2 && width <= 640 && height <= 200 && yRatio * 2 > xRatio * 3)
			this.#setSize(width, height << 1, RECOILResolution.ST1X2);
		else if (bitplanes <= 8 && width <= 320 && height <= 480 && xRatio * 2 > yRatio * 3)
			this.#setSize(width << 1, height, RECOILResolution.TT2X1);
		else if (!this.#setSizeStOrFalcon(width, height, bitplanes, true))
			return false;
		const rle = Object.assign(new ImgStream(), { content: content, contentOffset: headerLength, contentLength: contentLength });
		let bytesPerBitplane = (width + 7) >> 3;
		let chunky = false;
		if (headerLength == 28 && RECOIL.isStringAt(content, 16, "TIMG") && content[20] == 0 && content[21] == 3 && content[22] == 0 && content[24] == 0 && content[26] == 0) {
			switch (bitplanes << 24 | content[23] << 16 | content[25] << 8 | content[27]) {
			case 251987205:
			case 268764677:
			case 403179528:
				break;
			default:
				return false;
			}
		}
		else {
			switch (bitplanes) {
			case 1:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			case 8:
				if (headerLength == 22 + (6 << bitplanes) && RECOIL.#isXimg(content)) {
					for (let i = 0; i < 1 << bitplanes; i++)
						this.contentPalette[i] = RECOIL.#getStVdiColor(content, 22 + i * 6);
				}
				else if (headerLength == 54 && RECOIL.isStringAt(content, 16, "STTT") && content[20] == 0 && content[21] == 16)
					return this.#decodeSttt(rle, width, bytesPerBitplane);
				else if (bitplanes == 8) {
					if (headerLength == 22 && RECOIL.#isXimg(content))
						this.#setGrayscalePalette(255);
					else {
						let rgb = 16777215;
						for (let c = 0; c < 256; c++) {
							this.contentPalette[c] = rgb;
							for (let mask = 8421504;; mask >>= 1) {
								rgb ^= mask;
								if ((rgb & mask) == 0)
									break;
							}
						}
					}
				}
				else if (bitplanes > 2 && bitplanes != 4)
					return false;
				else if (headerLength == 50 && content[16] == 0 && content[17] == 128)
					this.setStPalette(content, 18, 16);
				else
					this.#setDefaultStPalette(bitplanes);
				break;
			case 16:
			case 24:
			case 32:
				chunky = true;
				break;
			default:
				return false;
			}
		}
		if (chunky && bitplanes == 24)
			bytesPerBitplane = (bytesPerBitplane + 1) & ~1;
		let bytesPerLine = bitplanes * bytesPerBitplane;
		let unpacked = new Uint8Array(bytesPerLine);
		for (let y = 0; y < height;) {
			let lineRepeatCount = Math.min(rle.getLineRepeatCount(), height - y);
			if (!rle.unpackLine(unpacked, bytesPerLine, y))
				return false;
			for (let x = 0; x < width; x++) {
				let c;
				if (chunky) {
					switch (bitplanes) {
					case 16:
						c = RECOIL.getFalconTrueColor(unpacked, x << 1);
						break;
					case 24:
						c = RECOIL.#getR8G8B8Color(unpacked, x * 3);
						break;
					case 32:
						c = RECOIL.#getR8G8B8Color(unpacked, (x << 2) + 1);
						break;
					default:
						throw new Error();
					}
				}
				else {
					c = RECOIL.#getBitplanePixel(unpacked, x >> 3, x, bitplanes, bytesPerBitplane);
					switch (bitplanes) {
					case 15:
						c = RECOIL.#getB5G5R5Color(c);
						break;
					case 16:
						c = (c & 31) << 19 | (c & 2016) << 5 | (c >> 8 & 248);
						c |= (c >> 5 & 458759) | (c >> 6 & 768);
						break;
					case 24:
						c = (c & 255) << 16 | (c & 65280) | c >> 16;
						break;
					default:
						c = this.contentPalette[c];
						break;
					}
				}
				for (let i = 0; i < lineRepeatCount; i++)
					this.#setScaledPixel(x, y + i, c);
			}
			y += lineRepeatCount;
		}
		return true;
	}

	#decodeStLowBlend(bitmap, bitmapOffset, palette, paletteOffset, width, height)
	{
		this.#decodeStLow(bitmap, bitmapOffset, palette, paletteOffset, width, height, 2);
		this.#decodeBitplanes(bitmap, bitmapOffset + (width >> 1) * height, width >> 1, 4, width * height, width, height);
		return this.#applyBlend();
	}

	#decodeDuo(content, contentLength)
	{
		return contentLength == 113600 && this.#decodeStLowBlend(content, 32, content, 0, 416, 273);
	}

	#decodeDu2(content, contentLength)
	{
		if (contentLength != 113576 && contentLength != 113600)
			return false;
		this.#decodeStMedium(content, 8, content, 0, 832, 273, 2);
		return this.#applyBlend();
	}

	#decodeP3c(content, contentLength)
	{
		const rle = Object.assign(new CaStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		let compressedLength = rle.parseDaliInt();
		if (compressedLength < 0)
			return false;
		let paletteOffset = rle.contentOffset;
		rle.contentLength = paletteOffset + 32 + compressedLength;
		if (rle.contentLength >= contentLength)
			return false;
		rle.contentOffset = paletteOffset + 32;
		const unpacked = new Uint8Array(64000);
		if (!rle.unpackCa(unpacked, 0))
			return false;
		rle.contentLength = contentLength;
		compressedLength = rle.parseDaliInt();
		if (compressedLength < 0 || rle.contentOffset + compressedLength != contentLength)
			return false;
		rle.contentLength = contentLength;
		return rle.unpackCa(unpacked, 32000) && this.#decodeStLowBlend(unpacked, 0, content, paletteOffset, 320, 200);
	}

	#unpackLz4(content, contentLength, unpacked, unpackedLength)
	{
		if (contentLength < 11 || content[0] != 4 || content[1] != 34 || content[2] != 77 || content[3] != 24 || (content[4] & 195) != 64)
			return false;
		const stream = Object.assign(new Lz4Stream(), { content: content, contentOffset: 7 });
		if ((content[4] & 8) != 0)
			stream.contentOffset += 8;
		stream.unpacked = unpacked;
		stream.unpackedOffset = 0;
		stream.unpackedLength = unpackedLength;
		for (;;) {
			if (stream.contentOffset + 4 > contentLength)
				return false;
			let blockSize = RECOIL.get32LittleEndian(content, stream.contentOffset);
			stream.contentOffset += 4;
			stream.contentLength = contentLength;
			if (blockSize == 0)
				break;
			if (blockSize >> 31 != 0) {
				if (!stream.copy(blockSize & 2147483647))
					return false;
				continue;
			}
			stream.contentLength = stream.contentOffset + blockSize;
			if (stream.contentLength > contentLength)
				return false;
			for (;;) {
				let token = stream.readByte();
				if (token < 0)
					return false;
				let count = stream.readCount(token >> 4);
				if (count < 0 || !stream.copy(count))
					return false;
				if (stream.contentOffset == stream.contentLength)
					break;
				if (stream.contentOffset > stream.contentLength - 2)
					return false;
				let distance = stream.readByte();
				distance += stream.readByte() << 8;
				if (distance == 0)
					return false;
				count = stream.readCount(token & 15);
				if (count < 0)
					return false;
				count += 4;
				let nextOffset = stream.unpackedOffset + count;
				if (nextOffset > unpackedLength || !RECOIL.copyPrevious(unpacked, stream.unpackedOffset, distance, count))
					return false;
				stream.unpackedOffset = nextOffset;
			}
			if ((content[4] & 16) != 0)
				stream.contentOffset += 4;
		}
		if ((content[4] & 4) != 0)
			stream.contentOffset += 4;
		return stream.contentOffset == contentLength && stream.unpackedOffset == unpackedLength;
	}

	#decodePl4(content, contentLength)
	{
		const unpacked = new Uint8Array(64070);
		if (!this.#unpackLz4(content, contentLength, unpacked, 64070) || unpacked[0] != 0 || unpacked[1] != 0 || unpacked[32036] != 0 || unpacked[32037] != 0)
			return false;
		this.#setSize(320, 200, RECOIL.#isStePalette(unpacked, 2, 16) || RECOIL.#isStePalette(unpacked, 32038, 16) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1, 2);
		this.setStPalette(unpacked, 2, 16);
		this.#decodeBitplanes(unpacked, 34, 160, 4, 0, 320, 200);
		this.setStPalette(unpacked, 32038, 16);
		this.#decodeBitplanes(unpacked, 32070, 160, 4, 64000, 320, 200);
		return this.#applyBlend();
	}

	#decodeSpuVariable(content, height, bitmapOffset, paletteOffset, enhanced)
	{
		if (!this.#setSize(320, height, enhanced || RECOIL.#isStePalette(content, paletteOffset, height * 48) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1))
			return false;
		if (enhanced)
			this.#frames = 2;
		let pixelsOffset = 0;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < 320; x++) {
				let c = RECOIL.#getStLowPixel(content, bitmapOffset, pixelsOffset);
				let x1 = c * 10 + 1 - (c & 1) * 6;
				if (x >= x1 + 160)
					c += 32;
				else if (x >= x1)
					c += 16;
				let colorOffset = paletteOffset + y * 96 + (c << 1);
				this.#pixels[pixelsOffset++] = enhanced ? RECOIL.getSteInterlacedColor(content[colorOffset] << 8 | content[colorOffset + 1]) : this.#getStColor(content, colorOffset);
			}
		}
		return true;
	}

	#decodeSpuScreen(content, enhanced)
	{
		return this.#decodeSpuVariable(content, 199, 160, 32000, enhanced);
	}

	#decodeSpu(content, contentLength)
	{
		return contentLength == 51104 && this.#decodeSpuScreen(content, RECOIL.isStringAt(content, 0, "5BIT"));
	}

	static #unpackSpc(rle, unpacked)
	{
		for (let bitplane = 0; bitplane < 8; bitplane += 2) {
			if (!rle.unpackWords(unpacked, 160 + bitplane, 8, 32000))
				return false;
		}
		return true;
	}

	#decodeStSpc(content, contentLength)
	{
		if (contentLength < 12 || content[0] != 83 || content[1] != 80)
			return false;
		const unpacked = new Uint8Array(51104);
		const rle = Object.assign(new SpcStream(), { content: content, contentOffset: 12, contentLength: contentLength });
		if (!RECOIL.#unpackSpc(rle, unpacked))
			return false;
		let contentOffset = 12 + RECOIL.get32BigEndian(content, 4);
		if (contentOffset < 12)
			return false;
		for (let unpackedOffset = 32000; unpackedOffset < 51104;) {
			if (contentOffset >= contentLength - 1)
				return false;
			let got = (content[contentOffset] & 127) << 8 | content[contentOffset + 1];
			contentOffset += 2;
			for (let i = 0; i < 16; i++) {
				if ((got >> i & 1) == 0) {
					unpacked[unpackedOffset] = 0;
					unpacked[unpackedOffset + 1] = 0;
				}
				else {
					if (contentOffset >= contentLength - 1)
						return false;
					unpacked[unpackedOffset] = content[contentOffset];
					unpacked[unpackedOffset + 1] = content[contentOffset + 1];
					contentOffset += 2;
				}
				unpackedOffset += 2;
			}
		}
		return this.#decodeSpuScreen(unpacked, false);
	}

	#decodeSps(content, contentLength)
	{
		if (contentLength < 13 || content[0] != 83 || content[1] != 80 || content[2] != 0 || content[3] != 0)
			return false;
		const unpacked = new Uint8Array(51104);
		const rle = Object.assign(new SpsStream(), { content: content, contentOffset: 12, contentLength: contentLength });
		if ((content[contentLength - 1] & 1) == 0) {
			for (let bitplane = 0; bitplane < 8; bitplane += 2) {
				for (let x = 0; x < 40; x++) {
					if (!rle.unpack(unpacked, 160 + ((x & ~1) << 2) + bitplane + (x & 1), 160, 32000))
						return false;
				}
			}
		}
		else if (!RECOIL.#unpackSpc(rle, unpacked))
			return false;
		const bitStream = Object.assign(new BitStream(), { content: content, contentOffset: 12 + RECOIL.get32BigEndian(content, 4) });
		if (bitStream.contentOffset < 12)
			return false;
		bitStream.contentLength = contentLength;
		for (let unpackedOffset = 32000; unpackedOffset < 51104;) {
			let got = bitStream.readBits(14);
			if (got < 0)
				return false;
			got <<= 1;
			for (let i = 15; i >= 0; i--) {
				let rgb;
				if ((got >> i & 1) == 0)
					rgb = 0;
				else {
					rgb = bitStream.readBits(9);
					if (rgb < 0)
						return false;
				}
				unpacked[unpackedOffset] = rgb >> 6;
				unpacked[unpackedOffset + 1] = (rgb & 63) + (rgb & 56);
				unpackedOffset += 2;
			}
		}
		return this.#decodeSpuScreen(unpacked, false);
	}

	#decodeSpxV2(content, contentLength, stream)
	{
		if (content[5] != 1)
			return false;
		let unpackedLength = RECOIL.get32BigEndian(content, stream.contentStart);
		if (unpackedLength <= 0 || unpackedLength > 134217728)
			return false;
		let bitmapLength = RECOIL.get32BigEndian(content, stream.contentStart - 8);
		let paletteOffset = RECOIL.get32BigEndian(content, stream.contentStart - 4);
		let packedLength = RECOIL.get32BigEndian(content, stream.contentStart + 4);
		stream.contentStart += 8;
		let packedEnd = stream.contentStart + packedLength;
		if (bitmapLength != 8 + packedLength || packedEnd > contentLength || packedEnd < 0)
			return false;
		stream.contentOffset = packedEnd;
		let unpacked = new Uint8Array(unpackedLength);
		if (!stream.unpackV2(unpacked, unpackedLength))
			return false;
		if (paletteOffset == 98336 && unpackedLength == 155552)
			return this.#decodeSpuVariable(unpacked, 597, 160, 98240, false);
		let height = (unpackedLength - paletteOffset) / 96 | 0;
		return paletteOffset >= 320 + height * 160 && this.#decodeSpuVariable(unpacked, height, 320, paletteOffset, false);
	}

	#decodeSpx(content, contentLength)
	{
		if (contentLength < 12 || content[0] != 83 || content[1] != 80 || content[2] != 88)
			return false;
		let contentOffset = 10;
		for (let zerosToSkip = 2;;) {
			if (contentOffset + 16 >= contentLength)
				return false;
			if (content[contentOffset++] == 0) {
				if (--zerosToSkip == 0)
					break;
			}
		}
		let bitmapLength = RECOIL.get32BigEndian(content, contentOffset);
		let paletteOffset = contentOffset + 8 + bitmapLength;
		if (paletteOffset > contentLength)
			return false;
		const stream = Object.assign(new SpxStream(), { content: content, contentStart: contentOffset + 8, contentOffset: paletteOffset });
		switch (content[4]) {
		case 0:
			break;
		case 1:
			switch (content[3]) {
			case 1:
				bitmapLength = stream.getUnpackedLength();
				break;
			case 2:
				return this.#decodeSpxV2(content, contentLength, stream);
			default:
				return false;
			}
			break;
		default:
			return false;
		}
		bitmapLength -= 160;
		if (bitmapLength <= 0 || bitmapLength % 160 != 0)
			return false;
		let height = bitmapLength / 160 | 0;
		let unpacked = new Uint8Array(height << 8);
		let paletteLength = RECOIL.get32BigEndian(content, stream.contentStart - 4);
		if (content[4] == 0)
			unpacked.set(content.subarray(stream.contentStart + 160, stream.contentStart + 160 + bitmapLength));
		else if (content[3] == 1) {
			if (!stream.unpack(unpacked, 0, bitmapLength))
				return false;
		}
		if (content[5] == 0) {
			if (paletteLength != height * 96)
				return false;
			unpacked.set(content.subarray(paletteOffset, paletteOffset + paletteLength), bitmapLength);
		}
		else {
			stream.contentStart = paletteOffset;
			stream.contentOffset = paletteOffset + paletteLength;
			if (stream.contentOffset > contentLength || stream.getUnpackedLength() != height * 96 || !stream.unpack(unpacked, bitmapLength, height << 8))
				return false;
		}
		return this.#decodeSpuVariable(unpacked, height, 0, height * 160, false);
	}

	static #getStLowSeparateBitplanes(content, contentOffset, bitplaneLength, x)
	{
		return RECOIL.#getBitplanePixel(content, contentOffset + (x >> 3), x, 4, bitplaneLength);
	}

	#decodePci(content, contentLength)
	{
		if (contentLength != 115648)
			return false;
		this.#setSize(352, 278, RECOIL.#isStePalette(content, 97856, 8896) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1, 2);
		let bitmapOffset = 0;
		for (let y = 0; y < 556; y++) {
			if (y == 278)
				bitmapOffset = 48928;
			this.setStPalette(content, 97856 + (y << 5), 16);
			for (let x = 0; x < 352; x++)
				this.#pixels[y * 352 + x] = this.contentPalette[RECOIL.#getStLowSeparateBitplanes(content, bitmapOffset, 12232, x)];
			bitmapOffset += 44;
		}
		return this.#applyBlend();
	}

	#decodePcsScreen(unpacked, pixelsOffset)
	{
		for (let y = 0; y < 199; y++) {
			for (let x = 0; x < 320; x++) {
				let c = RECOIL.#getStLowSeparateBitplanes(unpacked, 40 + y * 40, 8000, x) << 1;
				if (x >= c * 2) {
					if (c < 28) {
						if (x >= c * 2 + 76) {
							if (x >= 176 + c * 5 - (c & 2) * 3)
								c += 32;
							c += 32;
						}
					}
					else if (x >= c * 2 + 92)
						c += 32;
					c += 32;
				}
				this.#pixels[pixelsOffset++] = this.#getStColor(unpacked, 32000 + y * 96 + c);
			}
		}
	}

	#decodePcs(content, contentLength)
	{
		if (contentLength < 18 || content[0] != 1 || content[1] != 64 || content[2] != 0 || content[3] != 200)
			return false;
		const rle = Object.assign(new PcsStream(), { content: content, contentOffset: 6, contentLength: contentLength });
		const unpacked1 = new Uint8Array(51136);
		if (!rle.unpackPcs(unpacked1))
			return false;
		if (content[4] == 0) {
			this.#setSize(320, 199, RECOIL.#isStePalette(unpacked1, 32000, 9616) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1);
			this.#decodePcsScreen(unpacked1, 0);
			return true;
		}
		const unpacked2 = new Uint8Array(51136);
		if (!rle.unpackPcs(unpacked2))
			return false;
		if ((content[4] & 1) == 0) {
			for (let i = 0; i < 32000; i++)
				unpacked2[i] ^= unpacked1[i];
		}
		if ((content[4] & 2) == 0) {
			for (let i = 32000; i < 51136; i++)
				unpacked2[i] ^= unpacked1[i];
		}
		this.#setSize(320, 199, RECOIL.#isStePalette(unpacked1, 32000, 9616) || RECOIL.#isStePalette(unpacked2, 32000, 9616) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1, 2);
		this.#decodePcsScreen(unpacked1, 0);
		this.#decodePcsScreen(unpacked2, 63680);
		return this.#applyBlend();
	}

	#unpackPbx(content, contentLength, unpacked, bitmapOffset, bytesPer16Pixels, unpackedLength)
	{
		if (content[4] != 128 || content[5] != 1)
			return contentLength == unpackedLength ? content : null;
		const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: 128, contentLength: contentLength });
		if (!rle.unpack(unpacked, 128, 1, bitmapOffset))
			return null;
		for (let bitplane = 0; bitplane < bytesPer16Pixels; bitplane += 2) {
			for (let x = bitplane; x < 160; x += bytesPer16Pixels) {
				if (!rle.unpackWords(unpacked, bitmapOffset + x, 160, unpackedLength))
					return null;
			}
		}
		return unpacked;
	}

	#decodePbx01(content, contentLength, bitplanes, lineHeight)
	{
		const unpacked = new Uint8Array(32512);
		let source = this.#unpackPbx(content, contentLength, unpacked, 512, bitplanes << 1, 32512);
		if (source == null || source[161] != 0)
			return false;
		let paletteOffset = 128;
		for (let y = 0; y < 200; y++) {
			if (paletteOffset < 512 && y == source[paletteOffset + 33]) {
				this.setStPalette(source, paletteOffset, 16);
				do
					paletteOffset += 48;
				while (paletteOffset < 512 && source[paletteOffset + 34] == 0 && source[paletteOffset + 35] == 0);
			}
			this.#decodeBitplanes(source, 512 + y * 160, 0, bitplanes, y * lineHeight * this.#width, this.#width, lineHeight);
		}
		return true;
	}

	#decodePbx8(content, paletteOffset, bitmapOffset, pixelsOffset)
	{
		for (let y = 0; y < 200; y++) {
			for (let x = 0; x < 320; x++) {
				let c = RECOIL.#getStLowPixel(content, bitmapOffset + y * 160, x);
				if (x >= (c > 7 ? 88 : 76) + c * 10 - (c & 1) * 6)
					c += 16;
				this.#pixels[pixelsOffset + x] = this.#getStColor(content, paletteOffset + (y << 6) + (c << 1));
			}
			pixelsOffset += 320;
		}
	}

	#decodePbx(content, contentLength)
	{
		if (contentLength < 128 || content[0] != 0 || content[1] != 0 || content[2] != 0)
			return false;
		switch (content[3]) {
		case 0:
			this.#setSize(320, 200, RECOILResolution.ST1X1);
			return this.#decodePbx01(content, contentLength, 4, 1);
		case 1:
			this.#setSize(640, 400, RECOILResolution.ST1X2);
			return this.#decodePbx01(content, contentLength, 2, 2);
		case 128:
			{
				const unpacked = new Uint8Array(44928);
				let source = this.#unpackPbx(content, contentLength, unpacked, 12928, 8, 44928);
				if (source == null)
					return false;
				this.#setSize(320, 200, RECOILResolution.ST1X1);
				this.#decodePbx8(source, 128, 12928, 0);
				return true;
			}
		case 129:
			{
				const unpacked = new Uint8Array(57728);
				let source = this.#unpackPbx(content, contentLength, unpacked, 25728, 8, 57728);
				if (source == null)
					return false;
				this.#setSize(320, 200, RECOILResolution.ST1X1, 2);
				this.#decodePbx8(source, 128, 25728, 0);
				this.#decodePbx8(source, 12928, 25728, 64000);
				return this.#applyBlend();
			}
		default:
			return false;
		}
	}

	#decodeMppScreen(content, paletteOffset, paletteLength, pixelsOffset)
	{
		let mode = content[3];
		let bitmapOffset = paletteOffset + paletteLength;
		const palette = new Int32Array(16);
		const paletteStream = Object.assign(new MppPaletteStream(), { content: content, contentOffset: paletteOffset, contentLength: bitmapOffset });
		for (let y = 0; y < this.#height; y++) {
			for (let c = mode == 3 ? 6 : 1; c < 16; c++)
				palette[c] = paletteStream.read();
			let changeX = RECOIL.#DECODE_MPP_SCREEN_FIRST_CHANGE_X[mode];
			let changeColor = 0;
			for (let x = 0; x < this.#width; x++) {
				if (x == changeX) {
					palette[changeColor & 15] = changeColor == RECOIL.#DECODE_MPP_SCREEN_RIGHT_BORDER_COLOR[mode] ? 0 : paletteStream.read();
					switch (mode) {
					case 0:
					case 3:
						switch (changeColor) {
						case 15:
							changeX += mode == 0 ? 88 : 112;
							break;
						case 31:
							changeX += 12;
							break;
						case 37:
							changeX += 100;
							break;
						default:
							changeX += 4;
							break;
						}
						break;
					case 1:
						changeX += (changeColor & 1) == 0 ? 4 : 16;
						break;
					case 2:
						changeX += 8;
						break;
					default:
						throw new Error();
					}
					changeColor++;
				}
				this.#pixels[pixelsOffset + x] = palette[RECOIL.#getStLowPixel(content, bitmapOffset, x)];
			}
			bitmapOffset += this.#width >> 1;
			pixelsOffset += this.#width;
		}
	}

	#decodeMpp(content, contentLength)
	{
		if (contentLength < 12 || content[0] != 77 || content[1] != 80 || content[2] != 80)
			return false;
		let mode = content[3];
		if (mode > 3)
			return false;
		let width = mode < 3 ? 320 : 416;
		let height = mode < 3 ? 199 : 273;
		let frames = 1 + (content[4] >> 2 & 1);
		let paletteLength = RECOIL.#DECODE_MPP_MODE_COLORS_PER_LINE[mode] * height;
		switch (content[4] & 3) {
		case 0:
			this.#setSize(width, height, RECOILResolution.ST1X1, frames);
			paletteLength *= 9;
			break;
		case 1:
			this.#setSize(width, height, RECOILResolution.STE1X1, frames);
			paletteLength *= 12;
			break;
		case 3:
			this.#setSize(width, height, RECOILResolution.STE1X1, frames);
			this.#frames = 2;
			paletteLength *= 15;
			break;
		default:
			return false;
		}
		paletteLength = (paletteLength + 15) >> 4 << 1;
		let paletteOffset = 12 + RECOIL.get32BigEndian(content, 8);
		if (paletteOffset < 12)
			return false;
		let pixelsLength = width * height;
		if (contentLength != paletteOffset + (paletteLength + (pixelsLength >> 1)) * frames)
			return false;
		this.#decodeMppScreen(content, paletteOffset, paletteLength, 0);
		if (frames == 1)
			return true;
		this.#decodeMppScreen(content, paletteOffset + paletteLength + (pixelsLength >> 1), paletteLength, pixelsLength);
		return this.#applyBlend();
	}

	#decodeHrm(content, contentLength)
	{
		if (contentLength != 92000)
			return false;
		this.#setSize(640, 400, RECOILResolution.STE1X2);
		this.#frames = 2;
		for (let y = 0; y < 400; y++) {
			for (let x = 0; x < 640; x++) {
				let offset = y * 160 + (x >> 2 & ~3) + (x >> 3 & 1);
				let bit = ~x & 7;
				let c = (content[offset] >> bit & 1) | (content[offset + 2] >> bit & 1) << 1;
				c += (((x + RECOIL.#DECODE_HRM_COLOR_OFFSETS[c]) / 80 | 0) << 2) - 1;
				let rgb = this.#getStColor(content, 64000 + y * 70 + (c << 1));
				let pixelsOffset = y * 640 + x;
				if ((y & 1) == 0)
					this.#pixels[pixelsOffset] = rgb;
				else {
					let rgb1 = this.#pixels[pixelsOffset - 640];
					this.#pixels[pixelsOffset] = this.#pixels[pixelsOffset - 640] = (rgb1 & rgb) + ((rgb1 ^ rgb) >> 1 & 8355711);
				}
			}
		}
		return true;
	}

	#decodeStIcn(content, contentLength)
	{
		const parser = Object.assign(new IcnParser(), { content: content, contentOffset: 0, contentLength: contentLength });
		let width = parser.parseDefine("ICON_W");
		if (width <= 0 || width >= 256)
			return false;
		let height = parser.parseDefine("ICON_H");
		if (height <= 0 || height >= 256)
			return false;
		let size = parser.parseDefine("ICONSIZE");
		if (size != ((width + 15) >> 4) * height)
			return false;
		if (!parser.expectAfterWhitespace("int") || !parser.expectAfterWhitespace("image[ICONSIZE]") || !parser.expectAfterWhitespace("=") || !parser.expectAfterWhitespace("{"))
			return false;
		const bitmap = new Uint8Array(8192);
		for (let i = 0;;) {
			let value = parser.parseHex();
			if (value < 0)
				return false;
			bitmap[i * 2] = value >> 8;
			bitmap[i * 2 + 1] = value & 255;
			if (++i >= size)
				break;
			if (parser.contentOffset >= contentLength)
				return false;
			if (content[parser.contentOffset++] != 44)
				return false;
		}
		if (!parser.expectAfterWhitespace("};"))
			return false;
		this.#setSize(width, height, RECOILResolution.ST1X1);
		return this.#decodeBlackAndWhite(bitmap, 0, size << 1, true, 16777215);
	}

	#decodeIm(content, contentLength)
	{
		switch (contentLength) {
		case 16384:
			this.#setSize(128, 128, RECOILResolution.ST1X1);
			break;
		case 65536:
			this.#setSize(256, 256, RECOILResolution.ST1X1);
			break;
		default:
			return false;
		}
		this.#setGrayscalePalette(0);
		this.#decodeBytes(content, 0);
		return true;
	}

	#decodeCol(content, contentLength)
	{
		let width;
		switch (contentLength) {
		case 65536:
			width = 128;
			break;
		case 262144:
			width = 256;
			break;
		default:
			return false;
		}
		this.#setSize(width, width, RECOILResolution.ST1X1);
		let pixelsLength = contentLength >> 2;
		for (let i = 0; i < pixelsLength; i++)
			this.#pixels[i] = content[pixelsLength + i] << 16 | content[pixelsLength * 2 + i] << 8 | content[pixelsLength * 3 + i];
		return true;
	}

	#decodeCe(content, contentLength)
	{
		if (contentLength < 192022 || !RECOIL.isStringAt(content, 0, "EYES") || content[4] != 0)
			return false;
		switch (content[5]) {
		case 0:
			if (contentLength != 192022)
				return false;
			this.#setSize(320, 200, RECOILResolution.ST1X1);
			for (let y = 0; y < 200; y++) {
				for (let x = 0; x < 320; x++) {
					let offset = 22 + x * 200 + y;
					let rgb = content[offset] << 16 | content[64000 + offset] << 8 | content[128000 + offset];
					if ((rgb & 12632256) != 0)
						return false;
					this.#pixels[y * 320 + x] = rgb << 2 | (rgb >> 4 & 197379);
				}
			}
			return true;
		case 1:
			if (contentLength != 256022)
				return false;
			this.#setSize(640, 400, RECOILResolution.ST1X2);
			for (let y = 0; y < 200; y++) {
				for (let x = 0; x < 640; x++) {
					let offset = (11 + x * 200 + y) << 1;
					let c = content[offset] << 8 | content[offset + 1];
					if (c >= 32768)
						return false;
					offset = y * 1280 + x;
					this.#pixels[offset + 640] = this.#pixels[offset] = RECOIL.#getR5G5B5Color(c);
				}
			}
			return true;
		case 2:
			if (contentLength != 256022)
				return false;
			this.#setSize(640, 400, RECOILResolution.ST1X1);
			for (let y = 0; y < 400; y++) {
				for (let x = 0; x < 640; x++) {
					let b = content[22 + x * 400 + (y & 1) * 200 + (y >> 1)];
					if (b > 191)
						return false;
					this.#pixels[y * 640 + x] = (b * 4 / 3 | 0) * 65793;
				}
			}
			return true;
		default:
			return false;
		}
	}

	#decodeIbi(content, contentLength)
	{
		if ((contentLength != 704 && contentLength != 1600) || content[0] != 73 || content[1] != 67 || content[2] != 66 || (content[3] != 73 && content[3] != 51) || content[8] != 0 || content[9] != 32 || content[10] != 0 || content[11] != 32)
			return false;
		this.#setSize(32, 32, RECOILResolution.FALCON1X1);
		this.#setDefaultStPalette(4);
		this.#decodeBitplanes(content, 64, 16, 4, 0, 32, 32);
		return true;
	}

	#decodeBw(content, contentLength)
	{
		if (contentLength < 11 || !RECOIL.isStringAt(content, 0, "B&W256"))
			return false;
		let width = content[6] << 8 | content[7];
		let height = content[8] << 8 | content[9];
		if (contentLength != 10 + width * height || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
			return false;
		this.#setGrayscalePalette(0);
		this.#decodeBytes(content, 10);
		return true;
	}

	#decodeFalconHir(content, contentLength)
	{
		if (contentLength < 11 || content[0] != 15 || content[1] != 15 || content[2] != 0 || content[3] != 1 || content[8] != 0 || content[9] != 1)
			return false;
		let width = content[4] << 8 | content[5];
		let height = content[6] << 8 | content[7];
		let pixelsLength = width * height;
		if (contentLength != 10 + pixelsLength || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
			return false;
		for (let i = 0; i < pixelsLength; i++) {
			let b = content[10 + i];
			if (b >= 128)
				return false;
			this.#pixels[i] = b * 131586;
		}
		return true;
	}

	#decodeRw(content, contentLength)
	{
		switch (contentLength) {
		case 64000:
			this.#setSize(320, 200, RECOILResolution.FALCON1X1);
			break;
		case 128000:
			this.#setSize(640, 200, RECOILResolution.FALCON1X1);
			break;
		case 256000:
			this.#setSize(640, 400, RECOILResolution.FALCON1X1);
			break;
		default:
			return false;
		}
		this.#setGrayscalePalette(255);
		this.#decodeBytes(content, 0);
		return true;
	}

	#decodeR8G8G8X8Colors(content, contentOffset, count)
	{
		for (let i = 0; i < count; i++)
			this.#pixels[i] = RECOIL.#getR8G8B8Color(content, contentOffset + (i << 2));
	}

	#decodeIim(content, contentLength)
	{
		if (contentLength < 17 || !RECOIL.isStringAt(content, 0, "IS_IMAGE") || content[8] != 0)
			return false;
		let width = content[12] << 8 | content[13];
		let height = content[14] << 8 | content[15];
		let pixelsLength = width * height;
		switch (content[9]) {
		case 0:
			return this.#setSize(width, height, RECOILResolution.FALCON1X1) && this.#decodeBlackAndWhite(content, 16, contentLength, false, 16777215);
		case 1:
			if (contentLength != 16 + pixelsLength || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			this.#setGrayscalePalette(255);
			this.#decodeBytes(content, 16);
			return true;
		case 4:
			if (contentLength != 16 + pixelsLength * 3 || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			RECOIL.#decodeR8G8B8Colors(content, 16, pixelsLength, this.#pixels, 0);
			return true;
		case 5:
			if (contentLength != 16 + (pixelsLength << 2) || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			this.#decodeR8G8G8X8Colors(content, 17, pixelsLength);
			return true;
		default:
			return false;
		}
	}

	#setFalconPalette(content, contentOffset, colors)
	{
		for (let i = 0; i < colors; i++) {
			let offset = contentOffset + (i << 2);
			this.contentPalette[i] = content[offset] << 16 | content[offset + 1] << 8 | content[offset + 3];
		}
	}

	#decodeFalconPalette(content, bitplanesOffset, paletteOffset, width, height)
	{
		this.#setFalconPalette(content, paletteOffset, 256);
		this.#setSize(width, height, RECOILResolution.FALCON1X1);
		this.#decodeBitplanes(content, bitplanesOffset, width, 8, 0, width, height);
	}

	#decodeFuckpaint(content, contentLength)
	{
		switch (contentLength) {
		case 65024:
			this.#decodeFalconPalette(content, 1024, 0, 320, 200);
			return true;
		case 77824:
			this.#decodeFalconPalette(content, 1024, 0, 320, 240);
			return true;
		case 308224:
			this.#decodeFalconPalette(content, 1024, 0, 640, 480);
			return true;
		default:
			return false;
		}
	}

	#decodeDg1(content, contentLength)
	{
		if (contentLength != 65032 || content[0] != 68 || content[1] != 71 || content[2] != 85 || content[3] != 1 || content[4] != 1 || content[5] != 64 || content[6] != 0 || content[7] != 200)
			return false;
		this.#decodeFalconPalette(content, 1032, 8, 320, 200);
		return true;
	}

	#decodeDc1(content, contentLength)
	{
		if (contentLength < 1042 || content[0] != 68 || content[1] != 71 || content[2] != 67 || content[4] != 1 || content[5] != 64 || content[6] != 0 || content[7] != 200)
			return false;
		let compression = content[3];
		if (compression == 0) {
			if (contentLength != 65034)
				return false;
			this.#decodeFalconPalette(content, 1034, 10, 320, 200);
			return true;
		}
		if (compression > 3)
			return false;
		const unpacked = new Uint8Array(64000);
		let contentOffset = 1038;
		let valueBytes = 1 << (compression - 1);
		let repeatCount = 0;
		for (let bitplane = 0; bitplane < 16; bitplane += 2) {
			for (let unpackedOffset = bitplane; unpackedOffset < 64000; unpackedOffset += 16) {
				for (let x = 0; x < 2; x++) {
					if (repeatCount == 0) {
						let nextContentOffset = contentOffset + compression * 2;
						if (nextContentOffset > contentLength) {
							unpacked[unpackedOffset + x] = 0;
							continue;
						}
						switch (compression) {
						case 1:
							repeatCount = content[contentOffset] + 1;
							break;
						case 2:
							repeatCount = ((content[contentOffset] << 8) + content[contentOffset + 1] + 1) << 1;
							break;
						case 3:
							repeatCount = ((content[contentOffset] << 8) + content[contentOffset + 1] + 1) << 2;
							break;
						default:
							throw new Error();
						}
						contentOffset = nextContentOffset;
					}
					unpacked[unpackedOffset + x] = content[contentOffset - (--repeatCount & (valueBytes - 1)) - 1];
				}
			}
		}
		this.#setFalconPalette(content, 10, 256);
		this.#setSize(320, 200, RECOILResolution.FALCON1X1);
		this.#decodeBitplanes(unpacked, 0, 320, 8, 0, 320, 200);
		return true;
	}

	#decodeDel(content, contentLength)
	{
		const unpacked = new Uint8Array(96000);
		return CaStream.unpackDel(content, contentLength, unpacked, 2) && this.#decodeFuckpaint(unpacked, 77824);
	}

	#decodeDph(content, contentLength)
	{
		let unpacked = new Uint8Array(320000);
		if (!CaStream.unpackDel(content, contentLength, unpacked, 10))
			return false;
		this.#setFalconPalette(unpacked, 0, 256);
		this.#setSize(640, 480, RECOILResolution.FALCON1X1);
		this.#decodeBitplanes(unpacked, 1024, 320, 8, 0, 320, 240);
		this.#decodeBitplanes(unpacked, 77824, 320, 8, 320, 320, 240);
		this.#decodeBitplanes(unpacked, 154624, 320, 8, 153600, 320, 240);
		this.#decodeBitplanes(unpacked, 231424, 320, 8, 153920, 320, 240);
		return true;
	}

	#decodeFalconTrueColor(content, contentOffset, width, height, resolution)
	{
		if (!this.#setScaledSize(width, height, resolution))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				this.#setScaledPixel(x, y, RECOIL.getFalconTrueColor(content, contentOffset));
				contentOffset += 2;
			}
		}
		return true;
	}

	#decodeFalconTrueColorVariable(content, contentLength, widthOffset, dataOffset)
	{
		let width = content[widthOffset] << 8 | content[widthOffset + 1];
		let height = content[widthOffset + 2] << 8 | content[widthOffset + 3];
		return dataOffset + width * height * 2 == contentLength && this.#decodeFalconTrueColor(content, dataOffset, width, height, RECOILResolution.FALCON1X1);
	}

	#decodeFtc(content, contentLength)
	{
		return contentLength == 184320 && this.#decodeFalconTrueColor(content, 0, 384, 240, RECOILResolution.FALCON1X1);
	}

	#decodeXga(content, contentLength)
	{
		switch (contentLength) {
		case 153600:
			return this.#decodeFalconTrueColor(content, 0, 320, 240, RECOILResolution.FALCON1X1);
		case 368640:
			return this.#decodeFalconTrueColor(content, 0, 384, 480, RECOILResolution.FALCON2X1);
		default:
			return false;
		}
	}

	#decodeGod(content, contentLength)
	{
		return contentLength > 6 && this.#decodeFalconTrueColorVariable(content, contentLength, 2, 6);
	}

	#decodeTrp(content, contentLength)
	{
		return contentLength >= 9 && (RECOIL.isStringAt(content, 0, "TRUP") || RECOIL.isStringAt(content, 0, "tru?")) && this.#decodeFalconTrueColorVariable(content, contentLength, 4, 8);
	}

	#decodeTru(content, contentLength)
	{
		return contentLength >= 256 && RECOIL.isStringAt(content, 0, "Indy") && this.#decodeFalconTrueColorVariable(content, contentLength, 4, 256);
	}

	#decodeTg1(content, contentLength)
	{
		return contentLength >= 20 && RECOIL.isStringAt(content, 0, "COKE format.") && content[16] == 0 && content[17] == 18 && this.#decodeFalconTrueColorVariable(content, contentLength, 12, 18);
	}

	#decodeTcp(content, contentLength)
	{
		return contentLength >= 218 && RECOIL.isStringAt(content, 0, "TRUECOLR") && content[12] == 0 && content[13] == 18 && content[14] == 0 && content[15] == 1 && content[16] == 0 && content[17] == 1 && RECOIL.isStringAt(content, 18, "PICT") && this.#decodeFalconTrueColorVariable(content, contentLength, 28, 216);
	}

	#decodeTre(content, contentLength)
	{
		if (contentLength < 13 || !RECOIL.isStringAt(content, 0, "tre1"))
			return false;
		let width = content[4] << 8 | content[5];
		let height = content[6] << 8 | content[7];
		if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
			return false;
		const rle = Object.assign(new Tre1Stream(), { content: content, contentOffset: 12, contentLength: contentLength });
		let pixelsLength = width * height;
		for (let i = 0; i < pixelsLength; i++) {
			let rgb = rle.readRle();
			if (rgb < 0)
				return false;
			this.#pixels[i] = rgb;
		}
		return true;
	}

	static #isRag(content, contentLength)
	{
		return contentLength >= 55 && RECOIL.isStringAt(content, 0, "RAG-D!") && content[6] == 0 && content[7] == 0 && content[16] == 0;
	}

	#decodeRag(content, contentLength)
	{
		if (!RECOIL.#isRag(content, contentLength))
			return false;
		let width = content[12] << 8 | content[13];
		if ((width & 15) != 0)
			return false;
		let height = (content[14] << 8) + content[15] + 1;
		let bitplanes = content[17];
		let paletteLength = RECOIL.get32BigEndian(content, 18);
		switch (bitplanes) {
		case 1:
		case 2:
		case 4:
		case 8:
			switch (paletteLength) {
			case 32:
				if (bitplanes > 4)
					return false;
				break;
			case 1024:
				break;
			default:
				return false;
			}
			let bytesPerLine = (width >> 3) * bitplanes;
			if (30 + paletteLength + height * bytesPerLine > contentLength || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			if (paletteLength == 32)
				this.setStPalette(content, 30, 16);
			else
				this.#setFalconPalette(content, 30, 256);
			this.#decodeBitplanes(content, 30 + paletteLength, bytesPerLine, bitplanes, 0, width, height);
			return true;
		case 16:
			return paletteLength == 1024 && contentLength >= 1054 + width * height * 2 && this.#decodeFalconTrueColor(content, 1054, width, height, RECOILResolution.FALCON1X1);
		default:
			return false;
		}
	}

	#decodeRagc(content, contentLength)
	{
		if (!RECOIL.#isRag(content, contentLength) || content[17] != 8 || RECOIL.get32BigEndian(content, 18) != 1024)
			return false;
		let width = content[12] << 8 | content[13];
		let height = (content[14] << 8) + content[15] + 1;
		if (1054 + width * height > contentLength || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
			return false;
		this.#setFalconPalette(content, 30, 256);
		this.#decodeBytes(content, 1054);
		return true;
	}

	#decodeFalconFun(content, contentLength)
	{
		if (contentLength < 14 || content[0] != 0 || content[1] != 10 || content[2] != 207 || content[3] != 226 || content[8] != 0)
			return false;
		let width = content[4] << 8 | content[5];
		if ((width & 15) != 0)
			return false;
		let height = content[6] << 8 | content[7];
		let bitplanes = content[9];
		switch (bitplanes) {
		case 1:
		case 2:
		case 4:
		case 8:
			let bytesPerLine = (width >> 3) * bitplanes;
			let paletteOffset = 25 + height * bytesPerLine;
			let colors = 1 << bitplanes;
			if (contentLength != paletteOffset + colors * 6 || !this.#setSizeStOrFalcon(width, height, bitplanes, false))
				return false;
			if (bitplanes == 1)
				this.#setDefaultStPalette(1);
			else
				this.#setStVdiPalette(content, paletteOffset, colors, bitplanes);
			this.#decodeScaledBitplanes(content, 13, width, height, bitplanes, false, null);
			return true;
		case 16:
			return contentLength >= 13 + width * height * 2 && this.#decodeFalconTrueColor(content, 13, width, height, RECOILResolution.FALCON1X1);
		default:
			return false;
		}
	}

	#decodeEsm(content, contentLength)
	{
		if (contentLength < 812 || content[0] != 84 || content[1] != 77 || content[2] != 83 || content[3] != 0 || content[4] != 3 || content[5] != 44 || content[10] != 0)
			return false;
		let width = content[6] << 8 | content[7];
		let height = content[8] << 8 | content[9];
		if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
			return false;
		let pixelsLength = width * height;
		switch (content[11]) {
		case 1:
			return this.#decodeBlackAndWhite(content, 812, contentLength, false, 16777215);
		case 8:
			if (contentLength != 812 + pixelsLength)
				return false;
			for (let i = 0; i < 256; i++)
				this.contentPalette[i] = content[36 + i] << 16 | content[292 + i] << 8 | content[548 + i];
			for (let i = 0; i < pixelsLength; i++)
				this.#pixels[i] = this.contentPalette[content[812 + i]];
			return true;
		case 24:
			if (contentLength != 812 + pixelsLength * 3)
				return false;
			RECOIL.#decodeR8G8B8Colors(content, 812, pixelsLength, this.#pixels, 0);
			return true;
		default:
			return false;
		}
	}

	#decodeFalconPix(content, contentLength)
	{
		if (contentLength < 15 || !RECOIL.isStringAt(content, 0, "PIXT") || content[4] != 0)
			return false;
		let contentOffset;
		switch (content[5]) {
		case 1:
			contentOffset = 14;
			break;
		case 2:
			contentOffset = 16;
			break;
		default:
			return false;
		}
		let width = content[8] << 8 | content[9];
		if ((width & 15) != 0)
			return false;
		let bitplanes = content[7];
		let height = content[10] << 8 | content[11];
		let pixelsLength;
		switch (bitplanes) {
		case 1:
			return content[6] == 1 && this.#setSizeStOrFalcon(width, height, 1, false) && this.#decodeBlackAndWhite(content, contentOffset, contentLength, true, 16777215);
		case 2:
		case 4:
			let bitmapOffset = contentOffset + (3 << bitplanes);
			if (content[6] != 1 || contentLength != bitmapOffset + (width >> 3) * bitplanes * height || !this.#setSizeStOrFalcon(width, height, bitplanes, false))
				return false;
			RECOIL.#decodeR8G8B8Colors(content, contentOffset, 1 << bitplanes, this.contentPalette, 0);
			this.#decodeScaledBitplanes(content, bitmapOffset, width, height, bitplanes, false, null);
			return true;
		case 8:
			if (content[6] != 0 || contentLength != contentOffset + 768 + width * height || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			RECOIL.#decodeR8G8B8Colors(content, contentOffset, 256, this.contentPalette, 0);
			this.#decodeBytes(content, contentOffset + 768);
			return true;
		case 16:
			return content[6] == 1 && contentLength == contentOffset + width * height * 2 && this.#decodeFalconTrueColor(content, contentOffset, width, height, RECOILResolution.FALCON1X1);
		case 24:
			pixelsLength = width * height;
			if (content[6] != 1 || contentLength != contentOffset + pixelsLength * 3 || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			RECOIL.#decodeR8G8B8Colors(content, contentOffset, pixelsLength, this.#pixels, 0);
			return true;
		case 32:
			pixelsLength = width * height;
			if (contentLength != contentOffset + (pixelsLength << 2) || !this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			this.#decodeR8G8G8X8Colors(content, contentOffset + 1, pixelsLength);
			return true;
		default:
			return false;
		}
	}

	#decodePntUnpacked(content, bitmap, bitmapOffset, width, height)
	{
		let bitplanes = content[13];
		switch (bitplanes) {
		case 1:
		case 2:
		case 4:
		case 8:
			if (!this.#setSizeStOrFalcon(width, height, bitplanes, false))
				return false;
			this.contentPalette.fill(0);
			this.#setStVdiPalette(content, 128, content[6] << 8 | content[7], bitplanes);
			this.#decodeScaledBitplanes(bitmap, bitmapOffset, width, height, bitplanes, false, null);
			return true;
		case 16:
			return this.#decodeFalconTrueColor(bitmap, bitmapOffset, width, height, RECOILResolution.FALCON1X1);
		case 24:
			if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			for (let y = 0; y < height; y++) {
				RECOIL.#decodeR8G8B8Colors(bitmap, bitmapOffset, width, this.#pixels, y * width);
				bitmapOffset += ((width + 15) & ~15) * 3;
			}
			return true;
		default:
			return false;
		}
	}

	#decodeFalconPnt(content, contentLength)
	{
		if (contentLength < 128 || content[0] != 80 || content[1] != 78 || content[2] != 84 || content[3] != 0 || content[4] != 1 || content[5] != 0 || content[12] != 0 || content[14] != 0)
			return false;
		let colors = content[6] << 8 | content[7];
		if (colors > 256)
			return false;
		let bitmapOffset = 128 + colors * 6;
		let bitmapLength = RECOIL.get32BigEndian(content, 16);
		if (bitmapLength <= 0 || contentLength < bitmapOffset + bitmapLength)
			return false;
		let width = content[8] << 8 | content[9];
		let height = content[10] << 8 | content[11];
		if (width <= 0 || height > (134217728 / width | 0))
			return false;
		let bitplanes = content[13];
		let unpackedLength = ((width + 15) >> 4 << 1) * height * bitplanes;
		switch (content[15]) {
		case 0:
			return bitmapLength == unpackedLength && this.#decodePntUnpacked(content, content, bitmapOffset, width, height);
		case 1:
			let unpacked = new Uint8Array(unpackedLength);
			const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: bitmapOffset, contentLength: contentLength });
			return rle.unpackBitplaneLines(unpacked, width, height, bitplanes, true, false) && this.#decodePntUnpacked(content, unpacked, 0, width, height);
		default:
			return false;
		}
	}

	#decodeUimg(content, contentLength)
	{
		if (contentLength < 15 || !RECOIL.isStringAt(content, 0, "UIMG") || content[6] != 0)
			return false;
		let palette = content[7];
		if (palette > 4)
			return false;
		let depth = content[8];
		let chunk = content[9];
		let width = content[10] << 8 | content[11];
		let height = content[12] << 8 | content[13];
		let bitmapOffset = 14 + (RECOIL.#DECODE_UIMG_PALETTE_UNIT[palette] << depth);
		let pixelsLength = width * height;
		switch (chunk) {
		case 255:
		case 0:
			if (palette == 0 || depth > 8 || (width & 15) != 0 || contentLength != bitmapOffset + (pixelsLength >> 3) * depth)
				return false;
			break;
		case 1:
			if (palette == 0 || depth > 8 || contentLength != bitmapOffset + pixelsLength)
				return false;
			break;
		case 2:
		case 3:
		case 4:
			if (palette != 0 || depth != chunk << 3 || contentLength != 14 + pixelsLength * chunk)
				return false;
			break;
		default:
			return false;
		}
		switch (palette) {
		case 0:
			if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			break;
		case 1:
			if (!this.#setSize(width, height, depth > 4 ? RECOILResolution.FALCON1X1 : RECOIL.#isStePalette(content, 14, 1 << depth) ? RECOILResolution.STE1X1 : RECOILResolution.ST1X1))
				return false;
			this.contentPalette.fill(0);
			this.setStPalette(content, 14, 1 << depth);
			break;
		case 2:
			if (!this.#setSize(width, height, RECOILResolution.TT1X1))
				return false;
			this.contentPalette.fill(0);
			this.setStPalette(content, 14, 1 << depth);
			break;
		case 3:
			if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			this.contentPalette.fill(0);
			this.#setFalconPalette(content, 14, 1 << depth);
			break;
		case 4:
			if (!this.#setSize(width, height, RECOILResolution.FALCON1X1))
				return false;
			this.#setStVdiPalette(content, 14, 1 << depth, depth);
			break;
		default:
			return false;
		}
		switch (chunk) {
		case 0:
			this.#decodeBitplanes(content, bitmapOffset, (width >> 3) * depth, depth, 0, width, height);
			return true;
		case 1:
			this.#decodeBytes(content, bitmapOffset);
			return true;
		case 2:
			for (let i = 0; i < pixelsLength; i++)
				this.#pixels[i] = RECOIL.getFalconTrueColor(content, 14 + (i << 1));
			return true;
		case 3:
			RECOIL.#decodeR8G8B8Colors(content, 14, pixelsLength, this.#pixels, 0);
			return true;
		case 4:
			this.#decodeR8G8G8X8Colors(content, 15, pixelsLength);
			return true;
		case 255:
			switch (depth) {
			case 1:
				this.#decodeBitplanes(content, bitmapOffset, width >> 3, 1, 0, width, height);
				return true;
			case 2:
				this.#decodeMsx6(content, bitmapOffset);
				return true;
			case 4:
				this.#decodeNibbles(content, bitmapOffset, width >> 1);
				return true;
			default:
				return false;
			}
		default:
			throw new Error();
		}
	}

	setOcsColor(c, r, gb)
	{
		let rgb = (r & 15) << 16 | (gb & 240) << 4 | (gb & 15);
		this.contentPalette[c] = rgb * 17;
	}

	setOcsPalette(content, contentOffset, colors)
	{
		for (let c = 0; c < colors; c++) {
			let r = content[contentOffset++];
			let gb = content[contentOffset++];
			this.setOcsColor(c, r, gb);
		}
	}

	#decodeInfo(content, contentLength)
	{
		if (contentLength < 98 || content[0] != 227 || content[1] != 16 || content[2] != 0 || content[3] != 1)
			return false;
		let palette;
		switch (RECOIL.get32BigEndian(content, 44)) {
		case 0:
			palette = RECOIL.#DECODE_INFO_OS1_PALETTE;
			break;
		case 1:
			palette = RECOIL.#DECODE_INFO_OS2_PALETTE;
			break;
		default:
			return false;
		}
		let contentOffset = RECOIL.get32BigEndian(content, 66) == 0 ? 78 : 134;
		let width = content[contentOffset + 4] << 8 | content[contentOffset + 5];
		let height = content[contentOffset + 6] << 8 | content[contentOffset + 7];
		let bitplanes = content[contentOffset + 8] << 8 | content[contentOffset + 9];
		switch (bitplanes) {
		case 2:
			break;
		case 3:
			if (palette == RECOIL.#DECODE_INFO_OS1_PALETTE)
				return false;
			break;
		default:
			return false;
		}
		let bytesPerLine = (width + 15) >> 4 << 1;
		let bitplaneLength = height * bytesPerLine;
		contentOffset += 20;
		return contentLength >= contentOffset + bitplanes * bitplaneLength && this.#decodeAmigaPlanar(content, contentOffset, width, height, RECOILResolution.AMIGA1X2, bitplanes, palette);
	}

	#decodeAbkSprite(content, contentLength)
	{
		let sprites = content[4] << 8 | content[5];
		let contentOffset = 6;
		let width = 0;
		let height = 0;
		for (let sprite = 0; sprite < sprites; sprite++) {
			if (contentOffset + 10 >= contentLength || content[contentOffset + 4] != 0)
				return false;
			let spriteWidth = (content[contentOffset] << 8 | content[contentOffset + 1]) << 4;
			let spriteHeight = content[contentOffset + 2] << 8 | content[contentOffset + 3];
			let bitplanes = content[contentOffset + 5];
			if (bitplanes == 0 || bitplanes > 5)
				return false;
			width += spriteWidth;
			if (height < spriteHeight)
				height = spriteHeight;
			if (width <= 0 || height > (134217728 / width | 0))
				return false;
			contentOffset += 10 + (spriteWidth >> 3) * spriteHeight * bitplanes;
		}
		if (contentOffset + 64 != contentLength || !this.#setSize(width, height, RECOILResolution.AMIGA1X1))
			return false;
		this.setOcsPalette(content, contentOffset, 32);
		contentOffset = 6;
		let left = 0;
		for (let sprite = 0; sprite < sprites; sprite++) {
			let spriteWidth = (content[contentOffset] << 8 | content[contentOffset + 1]) << 4;
			let spriteHeight = content[contentOffset + 2] << 8 | content[contentOffset + 3];
			let bitplanes = content[contentOffset + 5];
			let bytesPerLine = spriteWidth >> 3;
			let bitplaneLength = height * bytesPerLine;
			for (let y = 0; y < spriteHeight; y++) {
				for (let x = 0; x < spriteWidth; x++)
					this.#pixels[y * width + left + x] = this.contentPalette[RECOIL.#getBitplanePixel(content, contentOffset + 10 + y * bytesPerLine + (x >> 3), x, bitplanes, bitplaneLength)];
			}
			for (let y = spriteHeight; y < height; y++)
				this.#pixels.fill(0, y * width + left, y * width + left + spriteWidth);
			contentOffset += 10 + bitplanes * bitplaneLength;
			left += spriteWidth;
		}
		return true;
	}

	#decodeAbk(content, contentLength)
	{
		if (contentLength < 82 || content[0] != 65 || content[1] != 109)
			return false;
		switch (content[2]) {
		case 83:
			return content[3] == 112 && this.#decodeAbkSprite(content, contentLength);
		case 73:
			return content[3] == 99 && this.#decodeAbkSprite(content, contentLength);
		case 66:
			break;
		default:
			return false;
		}
		if (content[3] != 107 || contentLength < 135 || !RECOIL.isStringAt(content, 12, "Pac.Pic") || content[110] != 6 || content[111] != 7 || content[112] != 25 || content[113] != 99 || content[124] != 0)
			return false;
		let width = content[118] << 8 | content[119];
		if ((width & 1) != 0)
			return false;
		let lumps = content[120] << 8 | content[121];
		let lumpLines = content[122] << 8 | content[123];
		let height = lumps * lumpLines;
		let bitplanes = content[125];
		if (bitplanes == 0 || bitplanes > 5 || !this.#setSize(width << 3, height, RECOILResolution.AMIGA1X1))
			return false;
		let rleOffset = 110 + RECOIL.get32BigEndian(content, 126);
		if (rleOffset < 0 || rleOffset >= contentLength)
			return false;
		let pointsOffset = 110 + RECOIL.get32BigEndian(content, 130);
		if (pointsOffset < 0)
			return false;
		let unpacked = new Uint8Array(bitplanes * width * height);
		let picOffset = 135;
		let pic = content[134];
		let rleBits = content[rleOffset++] << 8 | 128;
		let pointsBits = 0;
		for (let bitplane = 0; bitplane < bitplanes; bitplane++) {
			for (let lump = 0; lump < lumps; lump++) {
				for (let x = 0; x < width; x++) {
					for (let y = 0; y < lumpLines; y++) {
						rleBits <<= 1;
						if ((rleBits & 255) == 0) {
							pointsBits <<= 1;
							if ((pointsBits & 255) == 0) {
								if (pointsOffset >= contentLength)
									return false;
								pointsBits = content[pointsOffset++] << 1 | 1;
							}
							if ((pointsBits >> 8 & 1) != 0) {
								if (rleOffset >= contentLength)
									return false;
								rleBits = content[rleOffset++] << 1 | 1;
							}
							else
								rleBits >>= 8;
						}
						if ((rleBits >> 8 & 1) != 0) {
							if (picOffset >= contentLength)
								return false;
							pic = content[picOffset++];
						}
						unpacked[((bitplane * lumps + lump) * lumpLines + y) * width + x] = pic;
					}
				}
			}
		}
		this.setOcsPalette(content, 46, 32);
		return this.#decodeAmigaPlanar(unpacked, 0, width << 3, height, RECOILResolution.AMIGA1X1, bitplanes, this.contentPalette);
	}

	static #getAmigaAspectRatio(xRatio, yRatio, resolution)
	{
		if (xRatio <= 0 || yRatio <= 0)
			return resolution;
		if (xRatio > yRatio * 6)
			return RECOILResolution.AMIGA8X1;
		if (xRatio > yRatio * 3)
			return RECOILResolution.AMIGA4X1;
		if (xRatio * 2 > yRatio * 3)
			return RECOILResolution.AMIGA2X1;
		if (yRatio > xRatio * 3)
			return RECOILResolution.AMIGA1X4;
		if (yRatio * 2 > xRatio * 3)
			return resolution == RECOILResolution.AMIGA1X1 ? RECOILResolution.AMIGA1X2 : RECOILResolution.ST1X2;
		return resolution;
	}

	static #getCamgAspectRatio(camg, resolution)
	{
		let log;
		switch (camg & ~61439) {
		case 0:
		case 69632:
		case 135168:
		case 462848:
		case 790528:
		case 856064:
			camg &= 32812;
			log = 0;
			break;
		case 266240:
			return RECOILResolution.AMIGA1X1;
		case 331776:
		case 528384:
		case 724992:
		case 921600:
			camg &= 32812;
			log = -1;
			break;
		case 200704:
		case 397312:
			camg &= 32805;
			log = -1;
			break;
		case 593920:
		case 659456:
			camg &= 33285;
			log = 0;
			break;
		default:
			return resolution;
		}
		switch (camg & 33312) {
		case 0:
			break;
		case 32768:
			log++;
			break;
		case 32800:
			log += 2;
			break;
		case 512:
			log--;
			break;
		default:
			return resolution;
		}
		switch (camg & 13) {
		case 0:
			break;
		case 4:
			log--;
			break;
		case 5:
			log -= 2;
			break;
		case 8:
			log++;
			break;
		default:
			return resolution;
		}
		switch (log) {
		case 0:
			return RECOILResolution.AMIGA1X1;
		case -1:
			return RECOILResolution.AMIGA2X1;
		case -2:
			return RECOILResolution.AMIGA4X1;
		case -3:
			return RECOILResolution.AMIGA8X1;
		case 1:
			return RECOILResolution.AMIGA1X2;
		case 2:
			return RECOILResolution.AMIGA1X4;
		default:
			return resolution;
		}
	}

	#decodeDeep(content, contentLength)
	{
		let width = 0;
		let height = 0;
		let compression = 0;
		let resolution = RECOILResolution.AMIGA1X1;
		const rle = Object.assign(new DeepStream(), { content: content });
		let tvdcOffset = -1;
		for (let contentOffset = 12; contentOffset < contentLength - 7;) {
			let chunkLength = RECOIL.get32BigEndian(content, contentOffset + 4);
			let chunkEndOffset = contentOffset + 8 + chunkLength;
			if (chunkEndOffset > contentLength || chunkEndOffset < contentOffset + 8)
				break;
			if (RECOIL.isStringAt(content, contentOffset, "DGBL")) {
				if (chunkLength < 8 || content[contentOffset + 12] != 0)
					return false;
				width = content[contentOffset + 8] << 8 | content[contentOffset + 9];
				height = content[contentOffset + 10] << 8 | content[contentOffset + 11];
				compression = content[contentOffset + 13];
				resolution = RECOIL.#getAmigaAspectRatio(content[contentOffset + 14], content[contentOffset + 15], resolution);
			}
			else if (RECOIL.isStringAt(content, contentOffset, "DPEL")) {
				if (!rle.setDpel(contentOffset, chunkLength))
					return false;
			}
			else if (RECOIL.isStringAt(content, contentOffset, "DLOC")) {
				if (chunkLength < 4)
					return false;
				width = content[contentOffset + 8] << 8 | content[contentOffset + 9];
				height = content[contentOffset + 10] << 8 | content[contentOffset + 11];
			}
			else if (RECOIL.isStringAt(content, contentOffset, "TVDC")) {
				if (chunkLength != 32)
					return false;
				tvdcOffset = contentOffset + 8;
			}
			else if (RECOIL.isStringAt(content, contentOffset, "DBOD")) {
				if (chunkEndOffset + 8 < contentLength && RECOIL.isStringAt(content, chunkEndOffset, "DBOD"))
					return false;
				if (rle.components <= 0 || !this.#setScaledSize(width, height, resolution))
					return false;
				rle.contentOffset = contentOffset + 8;
				rle.contentLength = chunkEndOffset;
				for (let y = 0; y < height; y++) {
					if (compression == 5) {
						if (tvdcOffset < 0 || !rle.readDeltaLine(width, tvdcOffset))
							return false;
					}
					for (let x = 0; x < width; x++) {
						let rgb;
						switch (compression) {
						case 0:
							rgb = rle.readValue();
							break;
						case 1:
							rgb = rle.readRle();
							break;
						case 5:
							rgb = rle.line[x];
							break;
						default:
							return false;
						}
						if (rgb < 0)
							return false;
						this.#setScaledPixel(x, y, rgb);
					}
				}
				return true;
			}
			contentOffset = (chunkEndOffset + 1) & ~1;
		}
		return false;
	}

	#decodeRgbn(content, contentOffset, contentLength, width, height, rgb8)
	{
		let rgb = 0;
		let count = 0;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				if (count == 0) {
					if (rgb8) {
						if (contentOffset > contentLength - 4)
							return false;
						rgb = RECOIL.#getR8G8B8Color(content, contentOffset);
						count = content[contentOffset + 3] & 127;
						contentOffset += 4;
					}
					else {
						if (contentOffset > contentLength - 2)
							return false;
						rgb = content[contentOffset];
						count = content[contentOffset + 1];
						rgb = (((rgb & 240) << 4 | (rgb & 15)) << 8 | count >> 4) * 17;
						count &= 7;
						contentOffset += 2;
					}
					if (count == 0) {
						if (contentOffset >= contentLength)
							return false;
						count = content[contentOffset++];
						if (count == 0) {
							if (contentOffset > contentLength - 2)
								return false;
							count = content[contentOffset] << 8 | content[contentOffset + 1];
							contentOffset += 2;
						}
					}
				}
				this.#setScaledPixel(x, y, rgb);
				count--;
			}
		}
		return true;
	}

	#decodeRast(content, contentOffset, contentLength, unpacked, width, height, bitplanes)
	{
		if (!this.#setSizeStOrFalcon(width, height, bitplanes, false))
			return false;
		const rast = Object.assign(new RastPalette(), { content: content, contentOffset: contentOffset + 8, contentLength: contentLength, colors: 1 << bitplanes });
		this.#decodeScaledBitplanes(unpacked, 0, width, height, bitplanes, false, rast);
		return true;
	}

	#decodeHamPixel(rgb, c, holdBits)
	{
		switch (c >> holdBits) {
		case 0:
			return this.contentPalette[c];
		case 1:
			c = c << (8 - holdBits) & 255;
			c |= c >> holdBits;
			return (rgb & 16776960) | c;
		case 2:
			c = c << (8 - holdBits) & 255;
			c |= c >> holdBits;
			return (rgb & 65535) | c << 16;
		case 3:
			c = c << (8 - holdBits) & 255;
			c |= c >> holdBits;
			return (rgb & 16711935) | c << 8;
		default:
			throw new Error();
		}
	}

	#decodeHam(unpacked, width, height, bitplanes, multiPalette)
	{
		let bytesPerLine = ((width + 15) >> 4 << 1) * bitplanes;
		let holdBits = bitplanes > 6 ? 6 : 4;
		for (let y = 0; y < height; y++) {
			if (multiPalette != null)
				multiPalette.setLinePalette(this, y);
			let rgb = this.contentPalette[0];
			for (let x = 0; x < width; x++) {
				let c = RECOIL.#getBitplaneWordsPixel(unpacked, y * bytesPerLine, x, bitplanes);
				rgb = this.#decodeHamPixel(rgb, c, holdBits);
				this.#setScaledPixel(x, y, rgb);
			}
		}
	}

	#getHameNibble(content, contentOffset, x)
	{
		let c = RECOIL.#getStLowPixel(content, contentOffset, x);
		let rgb = this.contentPalette[c];
		return (rgb >> 20 & 8) | (rgb >> 13 & 4) | (rgb >> 6 & 2) | (rgb >> 4 & 1);
	}

	#getHameByte(content, contentOffset, x)
	{
		return this.#getHameNibble(content, contentOffset, x << 1) << 4 | this.#getHameNibble(content, contentOffset, (x << 1) + 1);
	}

	#isHame(content, contentOffset)
	{
		for (let i = 0; i < 7; i++) {
			if (this.#getHameByte(content, contentOffset, i) != RECOIL.#IS_HAME_MAGIC[i])
				return false;
		}
		switch (this.#getHameByte(content, contentOffset, 7)) {
		case 20:
		case 24:
			return true;
		default:
			return false;
		}
	}

	#decodeHame(content, width)
	{
		const palette = new Int32Array(512);
		const paletteLength = new Int32Array(2);
		let hame = false;
		for (let y = 0; y < this.#height; y++) {
			let lineOffset = y * width;
			let paletteOffset = this.#resolution == RECOILResolution.AMIGA_HAME2X1 && (y & 1) != 0 ? 256 : 0;
			if (this.#isHame(content, lineOffset)) {
				paletteOffset += paletteLength[paletteOffset >> 8];
				for (let c = 0; c < 64; c++) {
					let offset = 8 + c * 3;
					palette[paletteOffset + c] = this.#getHameByte(content, lineOffset, offset) << 16 | this.#getHameByte(content, lineOffset, offset + 1) << 8 | this.#getHameByte(content, lineOffset, offset + 2);
				}
				paletteLength[paletteOffset >> 8] = (paletteLength[paletteOffset >> 8] + 64) & 255;
				hame = this.#getHameByte(content, lineOffset, 7) == 24;
				this.#pixels.fill(0, y * this.#width, y * this.#width + this.#width);
			}
			else {
				let paletteBank = 0;
				let rgb = 0;
				for (let x = 0; x < width; x++) {
					let c = this.#getHameByte(content, lineOffset, x);
					if (hame) {
						switch (c >> 6) {
						case 0:
							if (c < 60)
								rgb = palette[paletteOffset + paletteBank + c];
							else
								paletteBank = (c - 60) << 6;
							break;
						case 1:
							rgb = (c & 63) << 2 | (rgb & 16776960);
							break;
						case 2:
							rgb = (c & 63) << 18 | (rgb & 65535);
							break;
						default:
							rgb = (c & 63) << 10 | (rgb & 16711935);
							break;
						}
					}
					else
						rgb = palette[paletteOffset + c];
					this.#setScaledPixel(x, y, rgb);
				}
			}
		}
	}

	#getDctvValue(content, contentOffset, x, bitplanes)
	{
		let c = RECOIL.#getBitplaneWordsPixel(content, contentOffset, x, bitplanes);
		let rgb = this.contentPalette[c];
		return (rgb << 2 & 64) | (rgb >> 19 & 16) | (rgb >> 5 & 4) | (rgb >> 15 & 1);
	}

	#isDctv(content, contentOffset, bitplanes)
	{
		if (this.#getDctvValue(content, contentOffset, 0, bitplanes) >> 6 != 0)
			return false;
		let r = 125;
		for (let x = 1; x < 256; x++) {
			if (this.#getDctvValue(content, contentOffset, x, bitplanes) >> 6 == (r & 1))
				return false;
			if ((r & 1) != 0)
				r ^= 390;
			r >>= 1;
		}
		return true;
	}

	static #clampByte(x)
	{
		return x <= 0 ? 0 : x >= 255 ? 255 : x;
	}

	#decodeDctv(content, width, height, resolution, bitplanes)
	{
		if (!this.#isDctv(content, 0, bitplanes))
			return false;
		let interlace;
		let bytesPerLine = ((width + 15) >> 4 << 1) * bitplanes;
		if (resolution == RECOILResolution.AMIGA1X2) {
			interlace = 0;
			height--;
			resolution = RECOILResolution.AMIGA_DCTV1X2;
		}
		else {
			if (!this.#isDctv(content, bytesPerLine, bitplanes))
				return false;
			interlace = 1;
			height -= 2;
			resolution = RECOILResolution.AMIGA_DCTV1X1;
		}
		this.#setScaledSize(width, height, resolution);
		let contentOffset = bytesPerLine << interlace;
		const chroma = new Int32Array(2048);
		for (let y = 0; y < height; y++) {
			let odd = y >> interlace & 1;
			let rgb = 0;
			let o = 0;
			let p = 0;
			for (let x = 0; x < width; x++) {
				if ((x & 1) == odd) {
					let n = x + 1 < width ? this.#getDctvValue(content, contentOffset, x, bitplanes) << 1 | this.#getDctvValue(content, contentOffset, x + 1, bitplanes) : 0;
					let i = (o + n) >> 1;
					i = i <= 64 ? 0 : i >= 224 ? 255 : (i - 64) * 8 / 5 | 0;
					let u = n + p - (o << 1);
					if (u < 0)
						u += 3;
					u >>= 2;
					if (((x + 1) & 2) == 0)
						u = -u;
					let chromaOffset = (x & ~1) | (y & interlace);
					let v = y > interlace ? chroma[chromaOffset] : 0;
					chroma[chromaOffset] = u;
					if (odd == 0) {
						u = v;
						v = chroma[chromaOffset];
					}
					p = o;
					o = n;
					let r = i + (v * 4655 / 2560 | 0);
					let b = i + (u * 8286 / 2560 | 0);
					let g = i - ((v * 2372 + u * 1616) / 2560 | 0);
					rgb = RECOIL.#clampByte(r) << 16 | RECOIL.#clampByte(g) << 8 | RECOIL.#clampByte(b);
				}
				this.#setScaledPixel(x, y, rgb);
			}
			contentOffset += bytesPerLine;
		}
		return true;
	}

	#decodeIffUnpacked(unpacked, width, height, resolution, bitplanes, colors, camg, multiPalette)
	{
		if (!this.#setScaledSize(width, height, resolution))
			return false;
		if (bitplanes <= 8) {
			if (colors == 0) {
				colors = 1 << bitplanes;
				for (let c = 0; c < colors; c++)
					this.contentPalette[c] = (c * 255 / colors | 0) * 65793;
			}
			if ((camg & 2048) != 0 || (bitplanes == 6 && colors == 16)) {
				this.#decodeHam(unpacked, width, height, bitplanes, multiPalette);
			}
			else if (width >= 400 && (resolution == RECOILResolution.AMIGA1X2 || resolution == RECOILResolution.AMIGA1X1) && bitplanes == 4 && multiPalette == null && this.#isHame(unpacked, 0)) {
				if (resolution == RECOILResolution.AMIGA1X2)
					this.#setSize(width >> 1, height, RECOILResolution.AMIGA_HAME1X1);
				else
					this.#setSize(width, height, RECOILResolution.AMIGA_HAME2X1);
				this.#decodeHame(unpacked, width >> 1);
			}
			else if (width >= 256 && width <= 2048 && height >= 3 && (resolution == RECOILResolution.AMIGA1X2 || resolution == RECOILResolution.AMIGA1X1) && multiPalette == null && this.#decodeDctv(unpacked, width, height, resolution, bitplanes)) {
			}
			else {
				this.#decodeScaledBitplanes(unpacked, 0, width, height, bitplanes, bitplanes == 6 && ((camg & 128) != 0 || colors == 32), multiPalette);
			}
		}
		else {
			let bytesPerBitplane = (width + 15) >> 4 << 1;
			for (let y = 0; y < height; y++) {
				for (let x = 0; x < width; x++) {
					let offset = (y * bytesPerBitplane + (x >> 3 & ~1)) * bitplanes + (x >> 3 & 1);
					let c = RECOIL.#getBitplanePixel(unpacked, offset, x, 24, 2);
					this.#setScaledPixel(x, y, (c & 255) << 16 | (c & 65280) | c >> 16);
				}
			}
		}
		return true;
	}

	#decodeIff(content, contentLength, resolution)
	{
		if (contentLength < 56 || !RECOIL.isStringAt(content, 0, "FORM"))
			return false;
		if (RECOIL.isStringAt(content, 8, "DEEP") || RECOIL.isStringAt(content, 8, "TVPP"))
			return this.#decodeDeep(content, contentLength);
		let contentOffset = 8;
		if (RECOIL.isStringAt(content, 8, "DPSTDPAH") && RECOIL.get32BigEndian(content, 16) == 24 && RECOIL.isStringAt(content, 44, "FORM"))
			contentOffset = 52;
		else if (RECOIL.isStringAt(content, 8, "ANIMFORM"))
			contentOffset = 20;
		let type;
		if (RECOIL.isStringAt(content, contentOffset, "ILBM"))
			type = IffType.ILBM;
		else if (RECOIL.isStringAt(content, contentOffset, "PBM "))
			type = IffType.PBM;
		else if (RECOIL.isStringAt(content, contentOffset, "ACBM"))
			type = IffType.ACBM;
		else if (RECOIL.isStringAt(content, contentOffset, "RGB8"))
			type = IffType.RGB8;
		else if (RECOIL.isStringAt(content, contentOffset, "RGBN"))
			type = IffType.RGBN;
		else
			return false;
		contentOffset += 4;
		let width = 0;
		let height = 0;
		let bitplanes = 0;
		let hasMask = false;
		let compression = 0;
		let ocsPalette = false;
		let colors = 0;
		let camg = 0;
		const ctbl = new CtblPalette();
		const sham = new ShamLacePalette();
		const pchg = new PchgPalette();
		let multiPalette = null;
		while (contentOffset < contentLength - 7) {
			let chunkLength = RECOIL.get32BigEndian(content, contentOffset + 4);
			let chunkEndOffset = contentOffset + 8 + chunkLength;
			if (chunkEndOffset > contentLength || chunkEndOffset < contentOffset + 8) {
				chunkEndOffset = contentLength;
				chunkLength = contentLength - contentOffset - 8;
			}
			if (RECOIL.isStringAt(content, contentOffset, "BMHD") && chunkLength >= 16) {
				width = content[contentOffset + 8] << 8 | content[contentOffset + 9];
				height = content[contentOffset + 10] << 8 | content[contentOffset + 11];
				bitplanes = content[contentOffset + 16];
				hasMask = content[contentOffset + 17] == 1;
				compression = content[contentOffset + 18];
				switch (type) {
				case IffType.PBM:
					if (bitplanes != 8 || compression > 1)
						return false;
					break;
				case IffType.RGB8:
					if (bitplanes != 25 || compression != 4)
						return false;
					break;
				case IffType.RGBN:
					if (bitplanes != 13 || compression != 4)
						return false;
					break;
				default:
					if (bitplanes == 0 || (bitplanes > 8 && bitplanes != 24 && bitplanes != 32) || compression > 2)
						return false;
					break;
				}
				let pixelsCount = width * height;
				if (pixelsCount <= 0 || pixelsCount > 134217728)
					return false;
				ocsPalette = content[contentOffset + 19] != 128;
				resolution = RECOIL.#getAmigaAspectRatio(content[contentOffset + 22], content[contentOffset + 23], resolution);
			}
			else if (RECOIL.isStringAt(content, contentOffset, "CMAP")) {
				colors = chunkLength / 3 | 0;
				if (colors > 256)
					return false;
				if (colors > 32)
					ocsPalette = false;
				for (let c = 0; c < colors; c++) {
					this.contentPalette[c] = RECOIL.#getR8G8B8Color(content, contentOffset + 8 + c * 3);
					if ((this.contentPalette[c] & 986895) != 0)
						ocsPalette = false;
				}
				if (ocsPalette) {
					for (let c = 0; c < colors; c++)
						this.contentPalette[c] |= this.contentPalette[c] >> 4;
				}
				this.contentPalette.fill(0, colors, colors + 256 - colors);
			}
			else if (RECOIL.isStringAt(content, contentOffset, "CAMG") && chunkLength >= 4) {
				camg = RECOIL.get32BigEndian(content, contentOffset + 8);
				resolution = RECOIL.#getCamgAspectRatio(camg, resolution);
			}
			else if ((RECOIL.isStringAt(content, contentOffset, "CTBL") || RECOIL.isStringAt(content, contentOffset, "BEAM")) && height > 0) {
				ctbl.colors = (chunkLength >> 1) / height | 0;
				if (ctbl.colors <= 32) {
					ctbl.content = content;
					ctbl.contentOffset = contentOffset + 8;
					multiPalette = ctbl;
				}
			}
			else if (RECOIL.isStringAt(content, contentOffset, "SHAM") && chunkLength >= 2 && content[contentOffset + 8] == 0 && content[contentOffset + 9] == 0) {
				if (chunkLength == 2 + (height << 5)) {
					ctbl.content = content;
					ctbl.contentOffset = contentOffset + 10;
					ctbl.colors = 16;
					multiPalette = ctbl;
				}
				else if (chunkLength == 2 + (height >> 1 << 5)) {
					sham.content = content;
					sham.contentOffset = contentOffset + 10;
					multiPalette = sham;
				}
			}
			else if (RECOIL.isStringAt(content, contentOffset, "PCHG")) {
				pchg.content = content;
				pchg.contentOffset = contentOffset + 8;
				pchg.contentLength = chunkEndOffset;
				if (!pchg.init())
					return false;
				multiPalette = pchg;
			}
			else if (RECOIL.isStringAt(content, contentOffset, "BODY")) {
				if (width == 0)
					return false;
				if (compression == 4)
					return this.#setScaledSize(width, height, resolution) && this.#decodeRgbn(content, contentOffset + 8, chunkEndOffset, width, height, type == IffType.RGB8);
				let bytesPerLine = ((width + 15) >> 4 << 1) * bitplanes;
				let unpacked;
				if (compression == 2) {
					unpacked = new Uint8Array(bytesPerLine * height);
					const rle = Object.assign(new VdatStream(), { content: content, contentOffset: contentOffset + 8 });
					for (let bitplane = 0; bitplane < bitplanes; bitplane++) {
						if (rle.contentOffset + 14 > chunkEndOffset || !RECOIL.isStringAt(content, rle.contentOffset, "VDAT"))
							return false;
						let nextContentOffset = rle.contentOffset + 8 + RECOIL.get32BigEndian(content, rle.contentOffset + 4);
						if (nextContentOffset > chunkEndOffset)
							return false;
						rle.valueOffset = rle.contentLength = rle.contentOffset + 8 + (content[rle.contentOffset + 8] << 8) + content[rle.contentOffset + 9];
						rle.valueLength = nextContentOffset;
						rle.contentOffset += 10;
						for (let x = bitplane << 1; x < bytesPerLine; x += bitplanes << 1) {
							let unpackedOffset = x;
							for (let y = 0; y < height; y++) {
								let b = rle.readRle();
								if (b < 0)
									return false;
								unpacked[unpackedOffset] = b >> 8;
								unpacked[unpackedOffset + 1] = b & 255;
								unpackedOffset += bytesPerLine;
							}
						}
						rle.contentOffset = nextContentOffset;
					}
					resolution = resolution == RECOILResolution.AMIGA1X2 ? RECOILResolution.ST1X2 : RECOILResolution.ST1X1;
				}
				else {
					const rle = Object.assign(new PackBitsStream(), { content: content, contentOffset: contentOffset + 8, contentLength: chunkEndOffset });
					if (type == IffType.PBM) {
						if (colors == 0 || !this.#setScaledSize(width, height, resolution))
							return false;
						for (let y = 0; y < height; y++) {
							for (let x = 0; x < width; x++) {
								let b = compression == 0 ? rle.readByte() : rle.readRle();
								if (b < 0)
									return false;
								this.#setScaledPixel(x, y, this.contentPalette[b]);
							}
							if ((width & 1) != 0 && (compression == 0 ? rle.readByte() : rle.readRle()) < 0)
								return false;
						}
						return true;
					}
					unpacked = new Uint8Array(bytesPerLine * height);
					if (!rle.unpackBitplaneLines(unpacked, width, height, bitplanes, compression == 1, hasMask))
						return false;
				}
				if (bitplanes <= 8 && chunkEndOffset < contentLength - 8) {
					let nextChunkOffset = (chunkEndOffset + 1) & ~1;
					if (RECOIL.isStringAt(content, nextChunkOffset, "RAST"))
						return this.#decodeRast(content, nextChunkOffset, contentLength, unpacked, width, height, bitplanes);
					if (RECOIL.isStringAt(content, chunkEndOffset, "RAST")) {
						return this.#decodeRast(content, chunkEndOffset, contentLength, unpacked, width, height, bitplanes);
					}
				}
				return this.#decodeIffUnpacked(unpacked, width, height, resolution, bitplanes, colors, camg, multiPalette);
			}
			else if (RECOIL.isStringAt(content, contentOffset, "ABIT")) {
				if (width == 0 || chunkLength != ((width + 15) >> 4 << 1) * height * bitplanes)
					return false;
				contentOffset += 8;
				let unpacked = new Uint8Array(chunkLength);
				for (let bitplane = 0; bitplane < bitplanes; bitplane++) {
					for (let unpackedOffset = bitplane << 1; unpackedOffset < chunkLength; unpackedOffset += bitplanes << 1) {
						unpacked[unpackedOffset] = content[contentOffset++];
						unpacked[unpackedOffset + 1] = content[contentOffset++];
					}
				}
				return this.#decodeIffUnpacked(unpacked, width, height, resolution, bitplanes, colors, camg, multiPalette);
			}
			contentOffset = (chunkEndOffset + 1) & ~1;
		}
		return false;
	}

	static #parseAtari8ExecutableHeader(content, contentOffset)
	{
		if (content[contentOffset] != 255 || content[contentOffset + 1] != 255)
			return -1;
		let startAddress = content[contentOffset + 2] | content[contentOffset + 3] << 8;
		let endAddress = content[contentOffset + 4] | content[contentOffset + 5] << 8;
		return endAddress - startAddress + 1;
	}

	static #getAtari8ExecutableOffset(content, contentLength)
	{
		if (contentLength >= 7) {
			let blockLength = RECOIL.#parseAtari8ExecutableHeader(content, 0);
			if (blockLength > 0 && 6 + blockLength == contentLength)
				return 6;
		}
		return 0;
	}

	#setAtari8RawSize(content, contentLength, resolution)
	{
		let contentOffset = RECOIL.#getAtari8ExecutableOffset(content, contentLength);
		let height = (contentLength - contentOffset) / 40 | 0;
		if (height == 0 || height > 240)
			return false;
		this.#setSize(320, height, resolution);
		return true;
	}
	#gtiaColors = new Uint8Array(16);

	#setGtiaColor(reg, value)
	{
		value &= 254;
		switch (reg) {
		case 0:
		case 1:
		case 2:
		case 3:
			this.#gtiaColors[reg] = value;
			break;
		case 4:
		case 5:
		case 6:
		case 7:
			this.#gtiaColors[8 + reg] = this.#gtiaColors[reg] = value;
			break;
		case 8:
			this.#gtiaColors[11] = this.#gtiaColors[10] = this.#gtiaColors[9] = this.#gtiaColors[8] = value;
			break;
		default:
			throw new Error();
		}
	}

	#setPM123PF0123Bak(content, contentOffset)
	{
		for (let i = 0; i < 8; i++)
			this.#setGtiaColor(1 + i, content[contentOffset + i]);
	}

	#setGtiaColors(content, contentOffset)
	{
		this.#gtiaColors[0] = content[contentOffset] & 254;
		this.#setPM123PF0123Bak(content, contentOffset + 1);
	}

	#setPF21(content, contentOffset)
	{
		this.#gtiaColors[6] = content[contentOffset] & 254;
		this.#gtiaColors[5] = content[contentOffset + 1] & 254;
	}

	#setXeOsDefaultColors()
	{
		this.#gtiaColors[8] = 0;
		this.#gtiaColors[4] = 40;
		this.#gtiaColors[5] = 202;
		this.#gtiaColors[6] = 148;
		this.#gtiaColors[7] = 70;
	}

	#setGr15DefaultColors()
	{
		this.#gtiaColors[8] = 0;
		this.#gtiaColors[4] = 4;
		this.#gtiaColors[5] = 8;
		this.#gtiaColors[6] = 12;
	}

	#setBakPF012(content, contentOffset, contentStride)
	{
		for (let i = 0; i < 4; i++)
			this.#gtiaColors[i == 0 ? 8 : 3 + i] = content[contentOffset + i * contentStride] & 254;
	}

	#setBakPF0123(content, contentOffset)
	{
		for (let i = 0; i < 5; i++)
			this.#gtiaColors[i == 0 ? 8 : 3 + i] = content[contentOffset + i] & 254;
	}

	#setPF012Bak(content, contentOffset)
	{
		for (let i = 0; i < 4; i++)
			this.#gtiaColors[i == 3 ? 8 : 4 + i] = content[contentOffset + i] & 254;
	}

	#setPF0123Bak(content, contentOffset)
	{
		for (let i = 0; i < 5; i++)
			this.#gtiaColors[4 + i] = content[contentOffset + i] & 254;
	}

	#setPF0123Even(content, contentOffset)
	{
		for (let i = 0; i < 4; i++)
			this.#gtiaColors[4 + i] = content[contentOffset + i * 2] & 254;
	}

	#decodeAtari8Gr8(content, contentOffset, frame, frameOffset, height)
	{
		const colors = new Uint8Array(2);
		colors[0] = this.#gtiaColors[6];
		colors[1] = (this.#gtiaColors[6] & 240) | (this.#gtiaColors[5] & 14);
		frameOffset -= this.#leftSkip;
		for (let y = 0; y < height; y++) {
			let x;
			for (x = this.#leftSkip; x < this.#width; x++) {
				let c = content[contentOffset + (x >> 3)] >> (~x & 7) & 1;
				frame[frameOffset + x] = colors[c];
			}
			for (; x < this.#width + this.#leftSkip; x++)
				frame[frameOffset + x] = this.#gtiaColors[8];
			contentOffset += (this.#width + 7) >> 3;
			frameOffset += this.#width;
		}
	}

	#decodeAtari8Gr15(content, contentOffset, contentStride, frame, frameOffset, frameStride, height)
	{
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < this.#width; x++) {
				let c = content[contentOffset + (x >> 3)] >> (~x & 6) & 3;
				frame[frameOffset + x] = this.#gtiaColors[c == 0 ? 8 : c + 3];
			}
			contentOffset += contentStride;
			frameOffset += frameStride;
		}
	}

	#decodeAtari8Gr7(content, contentOffset, frame, frameOffset, height)
	{
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < this.#width; x++) {
				let c = content[contentOffset + (x >> 3)] >> (~x & 6) & 3;
				frame[frameOffset + x + this.#width] = frame[frameOffset + x] = this.#gtiaColors[c == 0 ? 8 : c + 3];
			}
			contentOffset += this.#width >> 3;
			frameOffset += this.#width << 1;
		}
	}

	#decodeAtari8Gr3(content, frame)
	{
		for (let y = 0; y < this.#height; y++) {
			for (let x = 0; x < this.#width; x++) {
				let c = content[(y >> 3) * (this.#width >> 5) + (x >> 5)] >> (~(x >> 2) & 6) & 3;
				frame[y * this.#width + x] = this.#gtiaColors[c == 0 ? 8 : c + 3];
			}
		}
	}

	#decodeAtari8Gr9(content, contentOffset, contentStride, frame, frameOffset, frameStride, width, height)
	{
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let i = x + this.#leftSkip;
				let c = i < 0 || i >= width ? 0 : content[contentOffset + (i >> 3)] >> (~i & 4) & 15;
				frame[frameOffset + x] = this.#gtiaColors[8] | c;
			}
			contentOffset += contentStride;
			frameOffset += frameStride;
		}
	}

	#decodeAtari8Gr11(content, contentOffset, frame, frameOffset, frameStride, height)
	{
		frameOffset -= this.#leftSkip;
		for (let y = 0; y < height; y++) {
			let x;
			for (x = this.#leftSkip; x < this.#width; x++) {
				let c = content[contentOffset + (x >> 3)] << (x & 4) & 240;
				c = c == 0 ? this.#gtiaColors[8] & 240 : this.#gtiaColors[8] | c;
				frame[frameOffset + x] = c;
			}
			for (; x < this.#width + this.#leftSkip; x++)
				frame[frameOffset + x] = this.#gtiaColors[8] & 240;
			contentOffset += this.#width >> 3;
			frameOffset += frameStride;
		}
	}

	#decodeAtari8Gr10(content, contentOffset, frame, frameOffset, frameStride, height)
	{
		frameOffset += 2 - this.#leftSkip;
		for (let y = 0; y < height; y++) {
			let x;
			for (x = this.#leftSkip - 2; x < 0; x++)
				frame[frameOffset + x] = this.#gtiaColors[0];
			for (; x < this.#width + this.#leftSkip - 2; x++) {
				let c = content[contentOffset + (x >> 3)] >> (~x & 4) & 15;
				frame[frameOffset + x] = this.#gtiaColors[c];
			}
			contentOffset += this.#width >> 3;
			frameOffset += frameStride;
		}
	}

	#decodeAtari8Gr11PalBlend(content, contentOffset, contentStride, frame, y)
	{
		for (; y < this.#height; y += 2) {
			let frameOffset = y * this.#width - this.#leftSkip;
			for (let x = this.#leftSkip; x < this.#width; x++) {
				let c = content[contentOffset + (x >> 3)] << (x & 4) & 240;
				let i = ((y == 0 ? 0 : frame[frameOffset - this.#width + x] & 15) + (y == this.#height - 1 ? 0 : frame[frameOffset + this.#width + x] & 15)) >> 1;
				frame[frameOffset + x] = c | i;
				if (y < this.#height - 1)
					frame[frameOffset + this.#width + x] = c | (frame[frameOffset + this.#width + x] & 15);
			}
			frame.fill(0, frameOffset + this.#width, frameOffset + this.#width + this.#leftSkip);
			contentOffset += contentStride;
		}
	}

	static #toAtari8Char(ascii)
	{
		switch (ascii & 96) {
		case 0:
			return ascii + 64;
		case 32:
		case 64:
			return ascii - 32;
		default:
			return ascii;
		}
	}

	#decodeAtari8Gr0Line(characters, charactersOffset, font, fontOffset, frame, frameOffset, lines)
	{
		const colors = new Uint8Array(2);
		colors[0] = this.#gtiaColors[6];
		colors[1] = (this.#gtiaColors[6] & 240) | (this.#gtiaColors[5] & 14);
		for (let y = 0; y < lines; y++) {
			for (let x = 0; x < this.#width; x++) {
				let ch = charactersOffset + (x >> 3);
				if (characters != null)
					ch = characters[ch];
				let b = RECOIL.#getAtari8Gr0Pixel(font, fontOffset, ch, x, y);
				if (lines == 10) {
					switch (((ch & 96) + y) >> 1) {
					case 4:
					case 20:
					case 36:
					case 48:
						b = ch >> 7;
						break;
					default:
						break;
					}
				}
				frame[frameOffset + x] = colors[b];
			}
			frameOffset += this.#width;
		}
	}

	#decodeAtari8Gr0(characters, charactersOffset, charactersStride, font, fontOffset, frame)
	{
		this.#gtiaColors[6] = 0;
		this.#gtiaColors[5] = 14;
		for (let y = 0; y < this.#height; y += 8)
			this.#decodeAtari8Gr0Line(characters, charactersOffset + (y >> 3) * charactersStride, font, fontOffset, frame, y * this.#width, 8);
	}

	#decodeAtari8Gr1Line(content, charactersOffset, font, fontOffset, frame, frameOffset, doubleLine)
	{
		for (let y = 0; y < 8 << doubleLine; y++) {
			for (let x = 0; x < this.#width; x++) {
				let ch = content[charactersOffset + (x >> 4)];
				let b = font[fontOffset + ((ch & 63) << 3) + (y >> doubleLine)] >> (~(x >> 1) & 7) & 1;
				frame[frameOffset + x] = this.#gtiaColors[b == 0 ? 8 : 4 + (ch >> 6)];
			}
			frameOffset += this.#width;
		}
	}

	#decodeAtari8Gr12Line(characters, charactersOffset, font, fontOffset, frame, frameOffset, doubleLine)
	{
		for (let y = 0; y < 8 << doubleLine; y++) {
			for (let x = 0; x < this.#width; x++) {
				let ch = x >> 3;
				if (characters != null)
					ch = characters[charactersOffset + ch];
				let c = font[fontOffset + ((ch & 127) << 3) + (y >> doubleLine)] >> (~x & 6) & 3;
				let gr12Registers = ch >= 128 ? 30024 : 25928;
				frame[frameOffset + x] = this.#gtiaColors[gr12Registers >> (c << 2) & 15];
			}
			frameOffset += this.#width;
		}
	}

	#decodeAtari8Player(content, contentOffset, color, frame, frameOffset, height, multi)
	{
		color &= 254;
		for (let y = 0; y < height; y++) {
			let b = content[contentOffset + y];
			for (let x = 0; x < 8; x++) {
				let c = b >> (7 - x) & 1;
				if (c != 0)
					frame[frameOffset + x * 2 + 1] = frame[frameOffset + x * 2] = multi ? frame[frameOffset + x * 2] | color : color;
			}
			frameOffset += this.#width;
		}
	}

	#applyAtari8Palette(frame)
	{
		let pixelsLength = this.#width * this.#height;
		for (let i = 0; i < pixelsLength; i++)
			this.#pixels[i] = this.#atari8Palette[frame[i]];
		return true;
	}

	#applyAtari8PaletteBlend(frame1, frame2)
	{
		let pixelsLength = this.#width * this.#height;
		this.#frames = 2;
		for (let i = 0; i < pixelsLength; i++) {
			let rgb1 = this.#atari8Palette[frame1[i]];
			let rgb2 = this.#atari8Palette[frame2[i]];
			this.#pixels[i] = (rgb1 & rgb2) + ((rgb1 ^ rgb2) >> 1 & 8355711);
		}
		return true;
	}

	#applyAtari8PaletteBlend3(frame1, frame2, frame3)
	{
		let pixelsLength = this.#width * this.#height;
		this.#frames = 3;
		for (let i = 0; i < pixelsLength; i++) {
			let rgb1 = this.#atari8Palette[frame1[i]];
			let rgb2 = this.#atari8Palette[frame2[i]];
			let rgb3 = this.#atari8Palette[frame3[i]];
			this.#pixels[i] = (((rgb1 >> 16) + (rgb2 >> 16) + (rgb3 >> 16)) / 3 | 0) << 16 | (((rgb1 >> 8 & 255) + (rgb2 >> 8 & 255) + (rgb3 >> 8 & 255)) / 3 | 0) << 8 | ((rgb1 & 255) + (rgb2 & 255) + (rgb3 & 255)) / 3 | 0;
		}
		return true;
	}

	#decodeGr8(content, contentLength)
	{
		if (!this.#setAtari8RawSize(content, contentLength, RECOILResolution.XE1X1))
			return false;
		let contentOffset = RECOIL.#getAtari8ExecutableOffset(content, contentLength);
		if (contentLength == 7682) {
			this.#gtiaColors[6] = content[7680] & 14;
			this.#gtiaColors[5] = content[7681] & 14;
		}
		else {
			this.#gtiaColors[6] = 0;
			this.#gtiaColors[5] = 14;
		}
		const frame = new Uint8Array(76800);
		this.#decodeAtari8Gr8(content, contentOffset, frame, 0, this.#height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeDrg(content, contentLength)
	{
		return contentLength == 6400 && this.#decodeGr8(content, contentLength);
	}

	#decodeGr8Raw(content, contentLength, width, height)
	{
		this.#setSize(width, height, RECOILResolution.XE1X1);
		this.contentPalette[0] = this.#atari8Palette[0];
		this.contentPalette[1] = this.#atari8Palette[14];
		return this.#decodeMono(content, 0, contentLength, false);
	}

	#decodePsf(content, contentLength)
	{
		if (contentLength < 572 || contentLength > 640)
			return false;
		this.#setSize(88, 52, RECOILResolution.XE1X1);
		this.contentPalette[0] = this.#atari8Palette[14];
		this.contentPalette[1] = this.#atari8Palette[0];
		this.#decodeBitplanes(content, 0, 11, 1, 0, 88, 52);
		return true;
	}

	#decodeMonoArt(content, contentLength)
	{
		if (contentLength < 4)
			return false;
		let columns = content[0] + 1;
		let height = content[1] + 1;
		if (columns > 30 || height > 64 || contentLength != 3 + columns * height)
			return false;
		this.#setSize(columns << 3, height, RECOILResolution.XE1X1);
		this.contentPalette[0] = this.#atari8Palette[14];
		this.contentPalette[1] = this.#atari8Palette[0];
		this.#decodeBitplanes(content, 2, columns, 1, 0, columns << 3, height);
		return true;
	}

	#decodeGhg(content, contentLength)
	{
		if (contentLength < 4)
			return false;
		let width = content[0] | content[1] << 8;
		let height = content[2];
		if (width == 0 || width > 320 || height == 0 || height > 200 || contentLength != 3 + ((width + 7) >> 3) * height)
			return false;
		this.#setSize(width, height, RECOILResolution.XE1X1);
		const frame = new Uint8Array(64000);
		this.#gtiaColors[6] = 12;
		this.#gtiaColors[5] = 2;
		this.#decodeAtari8Gr8(content, 3, frame, 0, height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeCpr(content, contentLength)
	{
		if (contentLength < 2)
			return false;
		const rle = Object.assign(new XeKoalaStream(), { content: content, contentOffset: 1, contentLength: contentLength });
		if (!rle.unpackRaw(content[0], 7680))
			return false;
		this.#gtiaColors[6] = 12;
		this.#gtiaColors[5] = 0;
		this.#setSize(320, 192, RECOILResolution.XE1X1);
		const frame = new Uint8Array(61440);
		this.#decodeAtari8Gr8(rle.unpacked, 0, frame, 0, 192);
		return this.#applyAtari8Palette(frame);
	}

	#decodeSg3(content, contentLength)
	{
		if (contentLength != 240)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE8X8);
		const frame = new Uint8Array(61440);
		this.#setXeOsDefaultColors();
		this.#decodeAtari8Gr3(content, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeGr3(content, contentLength)
	{
		if (contentLength != 244)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE8X8);
		const frame = new Uint8Array(61440);
		this.#setBakPF012(content, 240, 1);
		this.#decodeAtari8Gr3(content, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeDit(content, contentLength)
	{
		if (contentLength != 3845)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		this.#setPF0123Bak(content, 3840);
		this.#decodeAtari8Gr7(content, 0, frame, 0, 96);
		return this.#applyAtari8Palette(frame);
	}

	#decodeVisualizer(content)
	{
		this.#setSize(320, 158, RECOILResolution.XE2X2);
		const frame = new Uint8Array(50560);
		this.#setPF0123Bak(content, 0);
		this.#decodeAtari8Gr7(content, 5, frame, 0, 79);
		return this.#applyAtari8Palette(frame);
	}

	#decodeGr7(content, contentOffset, contentSize)
	{
		if (contentSize > 4804 || contentSize % 40 != 4)
			return false;
		let height = contentSize / 40 | 0;
		this.#setSize(320, height * 2, RECOILResolution.XE2X2);
		const frame = new Uint8Array(76800);
		this.#setBakPF012(content, contentOffset + contentSize - 4, 1);
		this.#decodeAtari8Gr7(content, contentOffset, frame, 0, height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeRys(content, contentLength)
	{
		if (contentLength != 3840)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		this.#setXeOsDefaultColors();
		this.#decodeAtari8Gr7(content, 0, frame, 0, 96);
		return this.#applyAtari8Palette(frame);
	}

	#decodeBkg(content, contentLength)
	{
		return contentLength == 3856 && this.#decodeGr7(content, 0, 3844);
	}

	#decodeAtari8Artist(content, contentLength)
	{
		if (contentLength != 3206 || content[0] != 7)
			return false;
		this.#setSize(320, 160, RECOILResolution.XE2X2);
		const frame = new Uint8Array(51200);
		this.#setPF0123Bak(content, 1);
		this.#decodeAtari8Gr7(content, 6, frame, 0, 80);
		return this.#applyAtari8Palette(frame);
	}

	#decodeGr9(content, contentLength)
	{
		if (!this.#setAtari8RawSize(content, contentLength, RECOILResolution.XE4X1))
			return false;
		this.#gtiaColors[8] = 0;
		let contentOffset = RECOIL.#getAtari8ExecutableOffset(content, contentLength);
		const frame = new Uint8Array(76800);
		this.#decodeAtari8Gr9(content, contentOffset, 40, frame, 0, 320, 320, this.#height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeRap(content, contentLength)
	{
		if (contentLength != 7681)
			return false;
		this.#gtiaColors[8] = content[7680] & 254;
		this.#setSize(320, 192, RECOILResolution.XE4X1);
		const frame = new Uint8Array(61440);
		this.#decodeAtari8Gr9(content, 0, 40, frame, 0, 320, 320, 192);
		return this.#applyAtari8Palette(frame);
	}

	#decodeTxe(content, contentLength)
	{
		if (contentLength != 3840)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE4X2);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(content, 0, 40, frame, 320, 640, 320, 96);
		this.#decodeAtari8Gr9(content, 0, 40, frame, 0, 640, 320, 96);
		return this.#applyAtari8Palette(frame);
	}

	#decodeGr9x4(content, contentOffset, width, height)
	{
		if (!this.#setSize(width, height, RECOILResolution.XE4X4))
			return false;
		let frame = new Uint8Array(width * height);
		this.#gtiaColors[8] = 0;
		for (let y = 0; y < 4; y++)
			this.#decodeAtari8Gr9(content, contentOffset, width >> 3, frame, y * width, width << 2, width, height >> 2);
		this.#applyAtari8Palette(frame);
		return true;
	}

	#decodeZm4(content, contentLength)
	{
		return contentLength == 2048 && this.#decodeGr9x4(content, 0, 256, 256);
	}

	#decodeGr9p(content, contentLength)
	{
		return contentLength == 2400 && this.#decodeGr9x4(content, 0, 320, 240);
	}

	#decodeFge(content, contentLength)
	{
		return contentLength == 1286 && this.#decodeGr9x4(content, 6, 256, 160);
	}

	#decode16x16x16(content, contentOffset, colbak)
	{
		this.#setSize(64, 64, RECOILResolution.XE4X4);
		for (let y = 0; y < 64; y++) {
			for (let x = 0; x < 64; x++) {
				let c = content[contentOffset + ((y & ~3) << 2) + (x >> 2)];
				if (c > 15)
					return false;
				this.#pixels[(y << 6) + x] = this.#atari8Palette[colbak | c];
			}
		}
		return true;
	}

	#decodeTx0(content, contentLength)
	{
		return contentLength == 257 && this.#decode16x16x16(content, 0, content[256] & 254);
	}

	#decodeTxs(content, contentLength)
	{
		return contentLength == 262 && content[0] == 255 && content[1] == 255 && content[2] == 0 && content[3] == 6 && content[4] == 255 && content[5] == 6 && this.#decode16x16x16(content, 6, 0);
	}

	#decodeA4r(content, contentLength)
	{
		const s = Object.assign(new A4rStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		if (!s.unpackA4r())
			return false;
		this.#setSize(320, 256, RECOILResolution.XE4X1);
		const frame = new Uint8Array(81920);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(s.unpacked, 512, 40, frame, 0, 320, 320, 256);
		return this.#applyAtari8Palette(frame);
	}

	#decodeG11(content, contentLength)
	{
		if (!this.#setAtari8RawSize(content, contentLength, RECOILResolution.XE4X1))
			return false;
		this.#gtiaColors[8] = 6;
		let contentOffset = RECOIL.#getAtari8ExecutableOffset(content, contentLength);
		const frame = new Uint8Array(76800);
		this.#decodeAtari8Gr11(content, contentOffset, frame, 0, 320, this.#height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeG10(content, contentLength)
	{
		if (!this.#setAtari8RawSize(content, contentLength, RECOILResolution.XE4X1))
			return false;
		let contentOffset = RECOIL.#getAtari8ExecutableOffset(content, contentLength);
		if ((contentLength - contentOffset) % 40 != 9)
			return false;
		this.#leftSkip = 2;
		this.#setGtiaColors(content, contentLength - 9);
		const frame = new Uint8Array(76800);
		this.#decodeAtari8Gr10(content, contentOffset, frame, 0, 320, this.#height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeG09(content, contentLength)
	{
		switch (contentLength) {
		case 7680:
			return this.#decodeGr9(content, contentLength);
		case 15360:
			break;
		default:
			return false;
		}
		this.#setSize(640, 192, RECOILResolution.XE4X1);
		this.#gtiaColors[8] = 0;
		const frame = new Uint8Array(122880);
		this.#decodeAtari8Gr9(content, 0, 40, frame, 0, 640, 320, 192);
		this.#decodeAtari8Gr9(content, 7680, 40, frame, 320, 640, 320, 192);
		return this.#applyAtari8Palette(frame);
	}

	#decodeSkp(content, contentLength)
	{
		if (contentLength != 7680)
			return false;
		this.#gtiaColors[8] = 38;
		this.#gtiaColors[4] = 40;
		this.#gtiaColors[5] = 0;
		this.#gtiaColors[6] = 12;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		this.#decodeAtari8Gr15(content, 0, 40, frame, 0, 320, 192);
		return this.#applyAtari8Palette(frame);
	}

	#decodeKss(content, contentLength)
	{
		if (contentLength != 6404)
			return false;
		this.#setSize(320, 160, RECOILResolution.XE2X1);
		const frame = new Uint8Array(51200);
		this.#setBakPF012(content, 6400, 1);
		this.#decodeAtari8Gr15(content, 0, 40, frame, 0, 320, 160);
		return this.#applyAtari8Palette(frame);
	}

	#decodeMic(filename, content, contentLength)
	{
		if (contentLength == 15872) {
			contentLength = 7680;
			this.#setPF012Bak(content, 7680);
		}
		else {
			switch (contentLength % 40) {
			case 0:
			case 3:
				this.#setGr15DefaultColors();
				break;
			case 4:
				this.#setBakPF012(content, contentLength - 4, 1);
				break;
			case 5:
				this.#setPF012Bak(content, contentLength - 5);
				break;
			default:
				return false;
			}
		}
		let height = contentLength / 40 | 0;
		if (height == 0 || height > 240)
			return false;
		this.#setSize(320, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(76800);
		if (filename != null) {
			if (contentLength % 40 == 0) {
				const asm = new Uint8Array(131072);
				let asmLength = this.#readCompanionFile(filename, "RP.INI", "rp.ini", asm, 131072);
				if (asmLength > 0) {
					const s = Object.assign(new RastaStream(), { content: asm, contentLength: asmLength });
					if (!s.readIni())
						return false;
					s.contentLength = this.#readCompanionFile(filename, "PMG", "pmg", asm, 131072);
					if (!s.readPmg())
						return false;
					s.contentLength = this.#readCompanionFile(filename, "RP", "rp", asm, 131072);
					return s.readRp(content, height, frame) && this.#applyAtari8Palette(frame);
				}
			}
			if (height == 240) {
				const col = new Uint8Array(1281);
				switch (this.#readCompanionFile(filename, "COL", "col", col, 1281)) {
				case 1024:
				case 1280:
					for (let y = 0; y < 240; y++) {
						this.#setBakPF012(col, y, 256);
						this.#decodeAtari8Gr15(content, y * 40, 40, frame, y * 320, 320, 1);
					}
					return this.#applyAtari8Palette(frame);
				default:
					break;
				}
			}
		}
		this.#decodeAtari8Gr15(content, 0, 40, frame, 0, 320, height);
		return this.#applyAtari8Palette(frame);
	}

	#decodePi8(content, contentLength)
	{
		switch (contentLength) {
		case 7680:
			return this.#decodeMic(null, content, contentLength);
		case 7685:
			return this.#decodeGr8(content, contentLength);
		default:
			return false;
		}
	}

	#decodeHpm(content, contentLength)
	{
		const unpacked = new Uint8Array(7684);
		const rle = Object.assign(new HpmStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		if (!rle.unpack(unpacked, 0, 1, 7680))
			return false;
		switch (rle.readByte()) {
		case 52:
		case 53:
			unpacked[7680] = 0;
			unpacked[7681] = 52;
			unpacked[7682] = contentLength == 3494 ? 56 : 200;
			unpacked[7683] = contentLength == 3494 ? 60 : 124;
			break;
		case 81:
			unpacked[7680] = 164;
			unpacked[7681] = 81;
			unpacked[7682] = 185;
			unpacked[7683] = 124;
			break;
		case 228:
			unpacked[7680] = 0;
			unpacked[7681] = 228;
			unpacked[7682] = 200;
			unpacked[7683] = 190;
			break;
		case 4:
			unpacked[7680] = 6;
			unpacked[7681] = 4;
			unpacked[7682] = 0;
			unpacked[7683] = 10;
			break;
		case 48:
			unpacked[7680] = 14;
			unpacked[7681] = 48;
			unpacked[7682] = 199;
			unpacked[7683] = 123;
			break;
		case 116:
			unpacked[7680] = 0;
			unpacked[7681] = 116;
			unpacked[7682] = 88;
			unpacked[7683] = 126;
			break;
		default:
			unpacked[7680] = 0;
			unpacked[7681] = 4;
			unpacked[7682] = 8;
			unpacked[7683] = 12;
			break;
		}
		return this.#decodeMic(null, unpacked, 7684);
	}

	#decodeCpi(content, contentLength)
	{
		const unpacked = new Uint8Array(7936);
		const rle = Object.assign(new CpiStream(), { content: content, contentOffset: 0, contentLength: contentLength });
		if (!rle.unpack(unpacked, 0, 1, 7936))
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#gtiaColors[4] = 12;
		this.#gtiaColors[5] = 8;
		this.#gtiaColors[6] = 4;
		this.#decodeAtari8Gr15(unpacked, 0, 40, frame, 0, 320, 192);
		return this.#applyAtari8Palette(frame);
	}

	#decodeWnd(content, contentLength)
	{
		if (contentLength != 3072)
			return false;
		let width = content[0] + 1;
		let contentStride = (width + 3) >> 2;
		let height = content[1];
		if (contentStride > 40 || height == 0 || height > 192 || contentStride * height > 3070)
			return false;
		this.#setSize(width << 1, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#gtiaColors[4] = 70;
		this.#gtiaColors[5] = 136;
		this.#gtiaColors[6] = 14;
		this.#decodeAtari8Gr15(content, 2, contentStride, frame, 0, width << 1, height);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Koala(content, contentOffset, contentLength)
	{
		if (contentOffset + 22 >= contentLength)
			return false;
		let rows = content[contentOffset + 12];
		if (rows > 192)
			return false;
		const rle = Object.assign(new XeKoalaStream(), { content: content, contentOffset: contentOffset, contentLength: contentLength });
		if (!rle.unpackWrapped(rows * 40))
			return false;
		this.#setPF0123Bak(content, contentOffset + 13);
		const frame = new Uint8Array(61440);
		switch (content[contentOffset + 20] << 16 | content[contentOffset + 8] << 8 | rows) {
		case 536:
			this.#setSize(320, 192, RECOILResolution.XE1X1);
			let font = Fu.atari8_fnt;
			for (let row = 0; row < 24; row++)
				this.#decodeAtari8Gr0Line(rle.unpacked, row * 40, font, 0, frame, row * 2560, 8);
			break;
		case 3776:
			this.#setSize(320, 192, RECOILResolution.XE2X1);
			this.#decodeAtari8Gr15(rle.unpacked, 0, 40, frame, 0, 320, 192);
			break;
		case 69568:
			this.#setSize(320, 192, RECOILResolution.XE4X1);
			this.#decodeAtari8Gr9(rle.unpacked, 0, 40, frame, 0, 320, 320, 192);
			break;
		default:
			return false;
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Pix(content, contentLength)
	{
		return contentLength >= 30 && content[0] == 27 && content[1] == 77 && 4 + (content[2] | content[3] << 8) == contentLength && this.#decodeAtari8Koala(content, 4, contentLength);
	}

	#decodeAt800Players(content, frame)
	{
		for (let i = 0; i < 4; i++)
			this.#decodeAtari8Player(content, 4 + i * 240, content[i], frame, i * 10 * 2, 240, false);
	}

	#decodeAt800Missiles(content, contentOffset, frame, frameOffset)
	{
		for (let y = 0; y < 240; y++) {
			for (let i = 0; i < 4; i++) {
				let b = content[contentOffset + y] >> (i << 1);
				let offset = frameOffset + i * 4 * 2;
				frame[offset + 1] = frame[offset] = (b & 2) == 0 ? 0 : content[i];
				frame[offset + 3] = frame[offset + 2] = (b & 1) == 0 ? 0 : content[i];
			}
			frameOffset += this.#width;
		}
	}

	#decodePla(content, contentLength)
	{
		if (contentLength != 241)
			return false;
		this.#setSize(16, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(3840);
		this.#decodeAtari8Player(content, 1, content[0], frame, 0, 240, false);
		return this.#applyAtari8Palette(frame);
	}

	#decodeMis(content, contentLength)
	{
		if (contentLength != 61 && contentLength != 241)
			return false;
		this.#setSize(4, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(960);
		for (let y = 0; y < 240; y++) {
			let b = content[1 + (y >> 2)] >> ((~y & 3) << 1);
			frame[y * 4 + 1] = frame[y * 4] = (b & 2) == 0 ? 0 : content[0];
			frame[y * 4 + 3] = frame[y * 4 + 2] = (b & 1) == 0 ? 0 : content[0];
		}
		return this.#applyAtari8Palette(frame);
	}

	#decode4pl(content, contentLength)
	{
		if (contentLength != 964)
			return false;
		this.#setSize(80, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(19200);
		this.#decodeAt800Players(content, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decode4mi(content, contentLength)
	{
		if (contentLength != 244)
			return false;
		this.#setSize(32, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(7680);
		this.#decodeAt800Missiles(content, 4, frame, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decode4pm(content, contentLength)
	{
		if (contentLength != 1204)
			return false;
		this.#setSize(112, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(26880);
		this.#decodeAt800Players(content, frame);
		this.#decodeAt800Missiles(content, 964, frame, 80);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Spr(content, contentLength)
	{
		if (contentLength < 3 || contentLength > 42)
			return false;
		let height = content[0];
		if (2 + height != contentLength)
			return false;
		this.#setSize(16, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(640);
		this.#decodeAtari8Player(content, 2, content[1], frame, 0, height, false);
		return this.#applyAtari8Palette(frame);
	}

	#decodeMsl(content, contentLength)
	{
		if (contentLength < 3 || contentLength > 36)
			return false;
		let height = content[0];
		if (2 + height != contentLength)
			return false;
		this.#setSize(4, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(136);
		for (let y = 0; y < height; y++) {
			let b = content[2 + y];
			if (b > 3)
				return false;
			frame[y * 4 + 1] = frame[y * 4] = (b & 2) == 0 ? 0 : content[1];
			frame[y * 4 + 3] = frame[y * 4 + 2] = (b & 1) == 0 ? 0 : content[1];
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeMpl(content, contentLength)
	{
		if (contentLength < 13)
			return false;
		let height = content[0];
		if (height == 0 || height > 40)
			return false;
		let bitmapOffset = contentLength - (height << 2);
		if (bitmapOffset != 9 && bitmapOffset != 14)
			return false;
		let minX = 255;
		let maxX = 0;
		for (let i = 1; i < 5; i++) {
			let x = content[i];
			if (minX > x)
				minX = x;
			if (maxX < x)
				maxX = x;
		}
		if (maxX + 8 > 56)
			return false;
		this.#setSize((maxX + 8 - minX) << 1, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(4480);
		for (let i = 3; i >= 0; i--)
			this.#decodeAtari8Player(content, bitmapOffset + i * height, content[5 + i], frame, (content[1 + i] - minX) << 1, height, false);
		return this.#applyAtari8Palette(frame);
	}

	#decodeLdm(content, contentLength)
	{
		if (contentLength < 281)
			return false;
		for (let i = 0; i < 21; i++)
			if (content[i] != "Ludek Maker data file".charCodeAt(i) + 128)
				return false;
		let shapes = content[24] - content[23];
		if (shapes <= 0 || shapes > 100 || contentLength < 281 + shapes * 120)
			return false;
		let rows = (shapes + 7) >> 3;
		if (rows == 1)
			this.#setSize(shapes * 40, 30, RECOILResolution.XE2X1);
		else
			this.#setSize(320, rows * 32 - 2, RECOILResolution.XE2X1);
		const frame = new Uint8Array(132480);
		for (let shape = 0; shape < shapes; shape++) {
			let contentOffset = 281 + shape * 120;
			let frameOffset = (shape >> 3) * 32 * 320 + (shape & 7) * 40;
			this.#decodeAtari8Player(content, contentOffset, content[21], frame, frameOffset, 30, true);
			this.#decodeAtari8Player(content, contentOffset + 30, content[22], frame, frameOffset, 30, true);
			this.#decodeAtari8Player(content, contentOffset + 60, content[21], frame, frameOffset + 16, 30, true);
			this.#decodeAtari8Player(content, contentOffset + 90, content[22], frame, frameOffset + 16, 30, true);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodePmd(content, contentLength)
	{
		if (contentLength < 12 || content[0] != 240 || content[1] != 237 || content[2] != 228)
			return false;
		let sprites = content[7];
		let shapes = content[8] * content[9];
		let totalShapes = sprites * shapes;
		let height = content[10];
		if (sprites == 0 || sprites > 4 || shapes == 0 || shapes > 160 || height == 0 || height > 48 || 11 + totalShapes * height != contentLength)
			return false;
		if (true)
			totalShapes >>= 1;
		let rows = (totalShapes + 15) >> 4;
		if (rows == 1)
			this.#setSize(totalShapes * 20, height, RECOILResolution.XE2X1);
		else {
			let totalHeight = rows * (height + 2) - 2;
			if (totalHeight > 560)
				return false;
			this.#setSize(320, totalHeight, RECOILResolution.XE2X1);
		}
		const frame = new Uint8Array(179200);
		for (let shape = 0; shape < totalShapes; shape++) {
			let frameOffset = (shape >> 4) * (height + 2) * 320 + (shape & 15) * 20;
			if (true) {
				let spritePair = shape / shapes | 0;
				let contentOffset = 11 + (spritePair * shapes + shape) * height;
				this.#decodeAtari8Player(content, contentOffset, content[3 + spritePair * 2], frame, frameOffset, height, true);
				this.#decodeAtari8Player(content, contentOffset + shapes * height, content[4 + spritePair * 2], frame, frameOffset, height, true);
			}
			else
				this.#decodeAtari8Player(content, 11 + shape * height, content[3 + (shape / shapes | 0)], frame, frameOffset, height, false);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeApl(content, contentLength)
	{
		if (contentLength != 1677 || content[0] != 154 || content[1] != 248 || content[2] != 57 || content[3] != 33)
			return false;
		let frames = content[4];
		let height = content[5];
		let gap = content[6];
		if (frames == 0 || frames > 16 || height == 0 || height > 48 || gap > 8)
			return false;
		let frameWidth = (8 + gap + 2) << 1;
		this.#setSize(frames * frameWidth, height, RECOILResolution.XE2X1);
		const frame = new Uint8Array(27648);
		for (let f = 0; f < frames; f++) {
			this.#decodeAtari8Player(content, 42 + f * 48, content[7 + f], frame, f * frameWidth, height, true);
			this.#decodeAtari8Player(content, 858 + f * 48, content[24 + f], frame, f * frameWidth + gap * 2, height, true);
		}
		return this.#applyAtari8Palette(frame);
	}

	static #getSprEdPixel(content, bitmapOffset, bitmapStride, x)
	{
		if (x < 0 || x >= 10)
			return false;
		let grafp = content[bitmapOffset] << 2;
		if ((content[10] & 1) != 0)
			grafp |= content[bitmapOffset + 4 * bitmapStride] & 3;
		return (grafp >> (9 - x) & 1) != 0;
	}

	static #getSprEdPair(content, bitmapOffset, bitmapStride, colorOffset, colorStride, x, gap01)
	{
		let p1 = RECOIL.#getSprEdPixel(content, bitmapOffset + bitmapStride, bitmapStride, x - gap01);
		if (RECOIL.#getSprEdPixel(content, bitmapOffset, bitmapStride, x)) {
			let c = content[colorOffset];
			if (p1)
				c |= content[colorOffset + colorStride];
			return c;
		}
		if (p1)
			return content[colorOffset + colorStride];
		return -1;
	}

	#decodeSprEd(content, contentLength)
	{
		if (contentLength < 23 || !RECOIL.isStringAt(content, 0, "Spr!"))
			return false;
		let doubleLine = content[9];
		let mergeMode = content[10];
		let gap01;
		let gap23 = content[12];
		let gap02 = content[13];
		let dli = (content[14] & 1) != 0;
		let frames = content[16];
		let height;
		if (frames == 0) {
			gap01 = content[11];
			frames = content[17];
			height = content[18];
		}
		else {
			height = content[17];
			gap01 = content[18];
		}
		let unitWidth = 8 + ((mergeMode & 1) << 1);
		let players = (mergeMode & 4) != 0 ? 4 : 2;
		let dliOffset = 19 + players * frames * (1 + (height << (mergeMode & 1)));
		let bitmapStride = frames * height;
		if (doubleLine > 1 || gap01 > unitWidth || gap23 > unitWidth || gap02 > unitWidth << 1 || contentLength < (dli ? dliOffset + 5 * bitmapStride : dliOffset))
			return false;
		let frameWidth = unitWidth + gap01;
		if (players == 4) {
			let width23 = gap02 + unitWidth + gap23;
			if (frameWidth < width23)
				frameWidth = width23;
		}
		frameWidth += 2;
		let width = frames * frameWidth - 2;
		if (!this.#setSize(width << 1, height << doubleLine, doubleLine == 0 ? RECOILResolution.XE2X1 : RECOILResolution.XE2X2))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let frame = x / frameWidth | 0;
				let h = x % frameWidth;
				let colorOffset = 19 + frame;
				let colorStride = frames;
				if (dli) {
					colorOffset = dliOffset + bitmapStride + frame * height + y;
					colorStride = bitmapStride;
				}
				let bitmapOffset = 19 + players * frames + frame * height + y;
				let c = RECOIL.#getSprEdPair(content, bitmapOffset, bitmapStride, colorOffset, colorStride, h, gap01);
				if (c < 0 && players == 4)
					c = RECOIL.#getSprEdPair(content, bitmapOffset + 2 * bitmapStride, bitmapStride, colorOffset + 2 * colorStride, colorStride, h - gap02, gap23);
				if (c < 0)
					c = content[dli ? colorOffset - bitmapStride : 6];
				c = this.#atari8Palette[c & 254];
				let pixelsOffset = ((y * width << doubleLine) + x) << 1;
				this.#pixels[pixelsOffset + 1] = this.#pixels[pixelsOffset] = c;
				if (doubleLine != 0)
					this.#pixels[pixelsOffset + (width << 1) + 1] = this.#pixels[pixelsOffset + (width << 1)] = c;
			}
		}
		return true;
	}

	#decodeAtari8Hr(content, contentLength)
	{
		if (contentLength != 16384)
			return false;
		this.#setSize(256, 239, RECOILResolution.XE1X1);
		this.#gtiaColors[6] = 0;
		this.#gtiaColors[5] = 14;
		const frame1 = new Uint8Array(61184);
		this.#decodeAtari8Gr8(content, 0, frame1, 0, 239);
		const frame2 = new Uint8Array(61184);
		this.#decodeAtari8Gr8(content, 8192, frame2, 0, 239);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeMcppVariable(content, bitmapOffset, colorsOffset, width, height)
	{
		if (!this.#setSize(width, height, RECOILResolution.XE2X2))
			return false;
		let frame = new Uint8Array(width * height);
		this.#setPF012Bak(content, colorsOffset);
		this.#decodeAtari8Gr15(content, bitmapOffset, width >> 3, frame, 0, width << 1, height >> 1);
		this.#setPF012Bak(content, colorsOffset + 4);
		this.#decodeAtari8Gr15(content, bitmapOffset + (width * height >> 4), width >> 3, frame, width, width << 1, height >> 1);
		this.#applyAtari8Palette(frame);
		return true;
	}

	#decodeMcpp(content, contentLength)
	{
		return contentLength == 8008 && this.#decodeMcppVariable(content, 0, 8000, 320, 200);
	}

	#decodeIld(content, contentLength)
	{
		if (contentLength != 8195)
			return false;
		this.#setSize(256, 128, RECOILResolution.XE2X1);
		this.#gtiaColors[8] = 0;
		this.#gtiaColors[4] = 6;
		this.#gtiaColors[5] = 2;
		this.#gtiaColors[6] = 10;
		const frame1 = new Uint8Array(32768);
		this.#decodeAtari8Gr15(content, 0, 32, frame1, 0, 256, 128);
		const frame2 = new Uint8Array(32768);
		this.#decodeAtari8Gr15(content, 4096, 32, frame2, 0, 256, 128);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeInp(content, contentLength)
	{
		if (contentLength < 16004)
			return false;
		this.#setSize(320, 200, RECOILResolution.XE2X1);
		this.#setBakPF012(content, 16000, 1);
		const frame1 = new Uint8Array(64000);
		this.#decodeAtari8Gr15(content, 0, 40, frame1, 0, 320, 200);
		const frame2 = new Uint8Array(64000);
		this.#decodeAtari8Gr15(content, 8000, 40, frame2, 0, 320, 200);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeIge(content, contentLength)
	{
		if (contentLength != 6160 || content[0] != 255 || content[1] != 255 || content[2] != 246 || content[3] != 163 || content[4] != 255 || content[5] != 187 || content[6] != 255 || content[7] != 95)
			return false;
		this.#setSize(256, 96, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(24576);
		this.#setBakPF012(content, 8, 1);
		this.#decodeAtari8Gr15(content, 16, 32, frame1, 0, 256, 96);
		const frame2 = new Uint8Array(24576);
		this.#setBakPF012(content, 12, 1);
		this.#decodeAtari8Gr15(content, 3088, 32, frame2, 0, 256, 96);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeInt(content, contentLength)
	{
		if (contentLength < 18 || !RECOIL.isStringAt(content, 0, "INT95a") || content[8] != 15 || content[9] != 43)
			return false;
		let contentStride = content[6];
		let height = content[7];
		if (contentStride == 0 || contentStride > 320 || height == 0 || height > 239 || 18 + contentStride * height * 2 != contentLength)
			return false;
		let width = contentStride << 3;
		this.#setSize(width, height, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(76480);
		this.#setBakPF012(content, 10, 1);
		this.#decodeAtari8Gr15(content, 18, contentStride, frame1, 0, width, height);
		const frame2 = new Uint8Array(76480);
		this.#setBakPF012(content, 14, 1);
		this.#decodeAtari8Gr15(content, 18 + contentStride * height, contentStride, frame2, 0, width, height);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeIst(content, contentLength)
	{
		if (contentLength != 17184)
			return false;
		this.#setSize(320, 200, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(64000);
		const frame2 = new Uint8Array(64000);
		for (let y = 0; y < 200; y++) {
			this.#setBakPF012(content, 16384 + y, 200);
			this.#decodeAtari8Gr15(content, 16 + y * 40, 0, frame1, y * 320, 320, 1);
			this.#decodeAtari8Gr15(content, 8208 + y * 40, 0, frame2, y * 320, 320, 1);
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeGr15Blend(content, bitmapOffset, colorsOffset, height)
	{
		this.#setSize(320, height, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(64000);
		this.#setPF012Bak(content, colorsOffset);
		this.#decodeAtari8Gr15(content, bitmapOffset, 80, frame1, 0, 640, height >> 1);
		this.#setPF012Bak(content, colorsOffset + 4);
		this.#decodeAtari8Gr15(content, bitmapOffset + 40, 80, frame1, 320, 640, height >> 1);
		const frame2 = new Uint8Array(64000);
		this.#decodeAtari8Gr15(content, bitmapOffset + height * 40, 80, frame2, 0, 640, height >> 1);
		this.#setPF012Bak(content, colorsOffset);
		this.#decodeAtari8Gr15(content, bitmapOffset + height * 40 + 40, 80, frame2, 320, 640, height >> 1);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeMcp(content, contentLength)
	{
		return contentLength == 16008 && this.#decodeGr15Blend(content, 0, 16000, 200);
	}

	#decodeAtari8Raw(content, contentLength)
	{
		return contentLength == 15372 && RECOIL.isStringAt(content, 0, "XLPB") && this.#decodeGr15Blend(content, 4, 15364, 192);
	}

	#decodeXlp(content, contentLength)
	{
		const rle = Object.assign(new XlpStream(), { content: content, contentLength: contentLength });
		const unpacked = new Uint8Array(16000);
		let height;
		let colorsOffset;
		if (contentLength >= 10 && RECOIL.isStringAt(content, 0, "XLPC")) {
			unpacked.fill(0);
			rle.contentOffset = 8;
			rle.unpackColumns(unpacked, 0, 40, 15360);
			height = 192;
			colorsOffset = 4;
		}
		else {
			rle.contentOffset = 4;
			if (rle.unpackColumns(unpacked, 0, 40, 16000))
				height = 200;
			else {
				rle.contentOffset = 4;
				if (rle.unpackColumns(unpacked, 0, 40, 15360))
					height = 192;
				else
					return false;
			}
			colorsOffset = 0;
		}
		this.#setSize(320, height, RECOILResolution.XE2X1);
		this.#setPF012Bak(content, colorsOffset);
		const frame1 = new Uint8Array(64000);
		this.#decodeAtari8Gr15(unpacked, 0, 40, frame1, 0, 320, height);
		const frame2 = new Uint8Array(64000);
		this.#decodeAtari8Gr15(unpacked, height * 40, 40, frame2, 0, 320, height);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeAtari8Max(content, contentLength)
	{
		if (contentLength < 1732 || !RECOIL.isStringAt(content, 0, "XLPM"))
			return false;
		const rle = Object.assign(new XlpStream(), { content: content, contentOffset: 1732, contentLength: contentLength });
		const unpacked = new Uint8Array(15360);
		if (!rle.unpackColumns(unpacked, 0, 40, 15360))
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(61440);
		const frame2 = new Uint8Array(61440);
		for (let y = 0; y < 192; y++) {
			this.#setBakPF012(content, 772 + y, 192);
			this.#decodeAtari8Gr15(unpacked, y * 40, 40, frame1, y * 320, 320, 1);
			this.#setBakPF012(content, 4 + y, 192);
			this.#decodeAtari8Gr15(unpacked, 7680 + y * 40, 40, frame2, y * 320, 320, 1);
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeHr2(content, contentLength)
	{
		if (contentLength != 16006)
			return false;
		this.#setSize(320, 200, RECOILResolution.XE1X1);
		const frame1 = new Uint8Array(64000);
		this.#setPF21(content, 16000);
		this.#decodeAtari8Gr8(content, 0, frame1, 0, 200);
		const frame2 = new Uint8Array(64000);
		this.#setBakPF012(content, 16002, 1);
		this.#decodeAtari8Gr15(content, 8000, 40, frame2, 0, 320, 200);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeLum(filename, content, contentLength)
	{
		if (contentLength != 4766)
			return false;
		this.#setSize(320, 238, RECOILResolution.XE4X2);
		const frame = new Uint8Array(76160);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(content, 6, 40, frame, 320, 640, 320, 119);
		const col = new Uint8Array(4767);
		if (this.#readCompanionFile(filename, "COL", "col", col, 4767) == 4766) {
			this.#decodeAtari8Gr11PalBlend(col, 6, 40, frame, 0);
		}
		else {
			this.#decodeAtari8Gr9(content, 6, 40, frame, 0, 640, 320, 119);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeApc(content, contentLength)
	{
		if (contentLength != 7680 && contentLength != 7720)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE4X2);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(content, 40, 80, frame, 320, 640, 320, 96);
		this.#decodeAtari8Gr11PalBlend(content, 0, 80, frame, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decode256(content, contentLength)
	{
		if (contentLength != 7680 && contentLength != 7684)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE4X2);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(content, 3840, 40, frame, 320, 640, 320, 96);
		this.#decodeAtari8Gr11PalBlend(content, 0, 40, frame, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decodeMga(content, contentLength)
	{
		if (contentLength != 7856)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE4X2);
		const frame = new Uint8Array(61440);
		this.#gtiaColors[8] = 0;
		this.#decodeAtari8Gr9(content, 0, 80, frame, 320, 640, 320, 96);
		this.#decodeAtari8Gr11PalBlend(content, 40, 80, frame, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAp3(content, contentLength)
	{
		let gr11Offset;
		switch (contentLength) {
		case 15360:
		case 15362:
			gr11Offset = 7680;
			break;
		case 15872:
			gr11Offset = 8192;
			break;
		default:
			return false;
		}
		this.#setSize(320, 192, RECOILResolution.XE4X1);
		this.#gtiaColors[8] = 0;
		const frame1 = new Uint8Array(61440);
		this.#decodeAtari8Gr9(content, 0, 80, frame1, 0, 640, 320, 96);
		this.#decodeAtari8Gr11PalBlend(content, gr11Offset + 40, 80, frame1, 1);
		const frame2 = new Uint8Array(61440);
		this.#decodeAtari8Gr9(content, 40, 80, frame2, 320, 640, 320, 96);
		this.#decodeAtari8Gr11PalBlend(content, gr11Offset, 80, frame2, 0);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeBgp(content, contentLength)
	{
		if (contentLength < 19163 || !RECOIL.isStringAt(content, 0, "BUGBITER_APAC239I_PICTURE_V1.0") || content[30] != 255 || content[31] != 80 || content[32] != 239)
			return false;
		let textLength = content[37] + (content[38] << 8);
		if (contentLength != 19163 + textLength || content[39 + textLength] != 88 || content[40 + textLength] != 37 || content[9601 + textLength] != 88 || content[9602 + textLength] != 37)
			return false;
		this.#setSize(320, 239, RECOILResolution.XE4X1);
		this.#gtiaColors[8] = 0;
		const frame1 = new Uint8Array(76480);
		this.#decodeAtari8Gr9(content, 41 + textLength, 80, frame1, 0, 640, 320, 120);
		this.#decodeAtari8Gr11PalBlend(content, 9643 + textLength, 80, frame1, 1);
		const frame2 = new Uint8Array(76480);
		this.#decodeAtari8Gr9(content, 81 + textLength, 80, frame2, 320, 640, 320, 119);
		this.#decodeAtari8Gr11PalBlend(content, 9603 + textLength, 80, frame2, 0);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeHip(content, contentLength)
	{
		if (contentLength < 80)
			return false;
		const frame1 = new Uint8Array(76800);
		const frame2 = new Uint8Array(76800);
		let frameLength = RECOIL.#parseAtari8ExecutableHeader(content, 0);
		if (frameLength > 0 && frameLength % 40 == 0 && 12 + frameLength * 2 == contentLength && RECOIL.#parseAtari8ExecutableHeader(content, 6 + frameLength) == frameLength) {
			let height = frameLength / 40 | 0;
			if (height > 240)
				return false;
			this.#setSize(320, height, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#setGtiaColors(RECOIL.#DECODE_HIP_GR10_COLORS, 0);
			this.#decodeAtari8Gr10(content, 6, frame1, 0, 320, height);
			this.#gtiaColors[8] = 0;
			this.#decodeAtari8Gr9(content, 12 + frameLength, 40, frame2, 0, 320, 320, height);
		}
		else {
			let height = contentLength / 80 | 0;
			if (height > 240)
				return false;
			this.#setSize(320, height, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = 0;
			this.#decodeAtari8Gr9(content, 0, 40, frame1, 0, 320, 320, height);
			if (contentLength % 80 == 9)
				this.#setGtiaColors(content, contentLength - 9);
			else
				this.#setGtiaColors(RECOIL.#DECODE_HIP_GR10_COLORS, 0);
			this.#decodeAtari8Gr10(content, height * 40, frame2, 0, 320, height);
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeG9s(content, contentLength)
	{
		const unpacked = new Uint8Array(7680);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 7680) && this.#decodeGr9(unpacked, 7680);
	}

	#decodeIns(content, contentLength)
	{
		const unpacked = new Uint8Array(16004);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 16004) && this.#decodeInp(unpacked, 16004);
	}

	#decodePls(content, contentLength)
	{
		const unpacked = new Uint8Array(7680);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 7680) && this.#decodeApc(unpacked, 7680);
	}

	#decodeAps(content, contentLength)
	{
		const unpacked = new Uint8Array(7720);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 7720) && this.#decodeApc(unpacked, 7720);
	}

	#decodeIls(content, contentLength)
	{
		const unpacked = new Uint8Array(15360);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 15360) && this.#decodeAp3(unpacked, 15360);
	}

	#decodeApp(content, contentLength)
	{
		const unpacked = new Uint8Array(15872);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 15872) && this.#decodeAp3(unpacked, 15872);
	}

	#decodeHps(content, contentLength)
	{
		const unpacked = new Uint8Array(16009);
		const s = Object.assign(new SfdnStream(), { content: content, contentLength: contentLength });
		return s.unpack(unpacked, 16009) && this.#decodeHip(unpacked, 16009);
	}

	#decodeTip(content, contentLength)
	{
		if (contentLength < 129 || content[0] != 84 || content[1] != 73 || content[2] != 80 || content[3] != 1 || content[4] != 0)
			return false;
		let width = content[5];
		let height = content[6];
		if (width > 160 || (width & 3) != 0 || height > 119)
			return false;
		let contentStride = width >> 2;
		let frameLength = content[7] | content[8] << 8;
		if (frameLength != contentStride * height || contentLength != 9 + 3 * frameLength)
			return false;
		this.#setSize(width << 1, height << 1, RECOILResolution.XE2X2);
		this.#leftSkip = 1;
		this.#setGtiaColors(RECOIL.#DECODE_TIP_COLORS, 0);
		const frame1 = new Uint8Array(76160);
		this.#decodeAtari8Gr9(content, 9, contentStride, frame1, width << 1, width << 2, width << 1, height);
		this.#decodeAtari8Gr11PalBlend(content, 9 + 2 * frameLength, contentStride, frame1, 0);
		const frame2 = new Uint8Array(76160);
		this.#decodeAtari8Gr10(content, 9 + frameLength, frame2, width << 1, width << 2, height);
		this.#decodeAtari8Gr11PalBlend(content, 9 + 2 * frameLength, contentStride, frame2, 0);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeCin(content, contentLength)
	{
		let height;
		switch (contentLength) {
		case 15360:
			this.#setGr15DefaultColors();
			height = 192;
			break;
		case 16004:
			this.#setBakPF012(content, 16000, 1);
			height = 200;
			break;
		case 16384:
			height = 192;
			break;
		default:
			return false;
		}
		this.#setSize(320, height, RECOILResolution.XE2X1);
		const frame1 = new Uint8Array(64000);
		const frame2 = new Uint8Array(64000);
		for (let y = 0; y < height; y++) {
			if (contentLength == 16384)
				this.#setBakPF012(content, 15360 + y, 256);
			this.#decodeAtari8Gr15(content, y * 40, 40, (y & 1) == 0 ? frame1 : frame2, y * 320, 320, 1);
		}
		this.#decodeAtari8Gr11PalBlend(content, 40 * height + 40, 80, frame1, 1);
		this.#decodeAtari8Gr11PalBlend(content, 40 * height, 80, frame2, 0);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeCci(content, contentLength)
	{
		if (contentLength < 24 || !RECOIL.isStringAt(content, 0, "CIN 1.2 "))
			return false;
		const rle = Object.assign(new CciStream(), { content: content, contentOffset: 8, contentLength: contentLength });
		const unpacked = new Uint8Array(16384);
		if (!rle.unpackGr15(unpacked, 0) || !rle.unpackGr15(unpacked, 40))
			return false;
		rle.contentOffset += 4;
		rle.repeatCount = 0;
		if (!rle.unpackColumns(unpacked, 7680, 40, 15360))
			return false;
		rle.contentOffset += 4;
		rle.repeatCount = 0;
		return rle.unpack(unpacked, 15360, 1, 16384) && this.#decodeCin(unpacked, 16384);
	}

	#decodeAgs(content, contentLength)
	{
		if (contentLength < 17 || content[0] != 65 || content[1] != 71 || content[2] != 83)
			return false;
		let width = content[4];
		let height = content[5] | content[6] << 8;
		if (contentLength != 16 + (width * height << 1))
			return false;
		switch (content[3]) {
		case 11:
			return this.#decodeMcppVariable(content, 16, 7, width << 3, height << 1);
		case 19:
			return this.#decodeGr9x4(content, 16, width << 3, height << 2);
		default:
			return false;
		}
	}

	#unpackRip(content, contentOffset, contentLength, unpacked, unpackedLength)
	{
		if (contentOffset + 304 > contentLength || !RECOIL.isStringAt(content, contentOffset, "PCK"))
			return false;
		const lengthTree = new FanoTree();
		lengthTree.create(content, contentOffset + 16, 64);
		const distanceTree = new FanoTree();
		distanceTree.create(content, contentOffset + 16 + 32, 256);
		const literalTree = new FanoTree();
		literalTree.create(content, contentOffset + 16 + 32 + 128, 256);
		const bitStream = Object.assign(new BitStream(), { content: content, contentOffset: contentOffset + 16 + 288, contentLength: contentLength });
		for (let unpackedOffset = 0; unpackedOffset < unpackedLength;) {
			switch (bitStream.readBit()) {
			case 0:
				let literal = literalTree.readCode(bitStream);
				if (literal < 0)
					return false;
				unpacked[unpackedOffset++] = literal;
				break;
			case 1:
				let distance = distanceTree.readCode(bitStream);
				if (distance < 0)
					return false;
				distance += 2;
				let count = lengthTree.readCode(bitStream);
				if (count < 0)
					return false;
				count = Math.min(count + 2, unpackedLength - unpackedOffset);
				if (!RECOIL.copyPrevious(unpacked, unpackedOffset, distance, count))
					return false;
				unpackedOffset += count;
				if (unpackedOffset >= unpackedLength)
					return true;
				break;
			default:
				return false;
			}
		}
		return true;
	}

	#decodeRip(content, contentLength)
	{
		if (contentLength < 34 || content[0] != 82 || content[1] != 73 || content[2] != 80 || content[18] != 84 || content[19] != 58)
			return false;
		let headerLength = content[11] | content[12] << 8;
		let contentStride = content[13];
		let height = content[15];
		let textLength = content[17];
		if (headerLength >= contentLength || contentStride == 0 || contentStride > 80 || (contentStride & 1) != 0 || height == 0 || height > 239 || 33 + textLength >= contentLength || content[20 + textLength] != 9 || !RECOIL.isStringAt(content, 21 + textLength, "CM:"))
			return false;
		if (content[7] < 16)
			contentStride >>= 1;
		let unpackedLength = contentStride * height;
		if (content[7] == 48)
			unpackedLength += (height + 1) >> 1 << 3;
		const unpacked = new Uint8Array(20080);
		switch (content[9]) {
		case 0:
			if (headerLength + unpackedLength > contentLength)
				return false;
			unpacked.set(content.subarray(headerLength, headerLength + unpackedLength));
			break;
		case 1:
			this.#unpackRip(content, headerLength, contentLength, unpacked, unpackedLength);
			break;
		default:
			return false;
		}
		this.#setGtiaColors(content, 24 + textLength);
		contentStride = content[13] >> 1;
		let width = contentStride << 3;
		const frame1 = new Uint8Array(76480);
		const frame2 = new Uint8Array(76480);
		switch (content[7]) {
		case 14:
			this.#setSize(width, height, RECOILResolution.XE2X1);
			this.#decodeAtari8Gr15(unpacked, 0, contentStride, frame1, 0, width, height);
			return this.#applyAtari8Palette(frame1);
		case 15:
			this.#setSize(width, height, RECOILResolution.XE1X1);
			this.#decodeAtari8Gr8(unpacked, 0, frame1, 0, height);
			return this.#applyAtari8Palette(frame1);
		case 79:
			this.#setSize(width, height, RECOILResolution.XE4X1);
			this.#decodeAtari8Gr9(unpacked, 0, contentStride, frame1, 0, width, width, height);
			return this.#applyAtari8Palette(frame1);
		case 143:
			this.#setSize(width, height, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			this.#decodeAtari8Gr10(unpacked, 0, frame1, 0, width, height);
			return this.#applyAtari8Palette(frame1);
		case 207:
			this.#setSize(width, height, RECOILResolution.XE4X1);
			this.#decodeAtari8Gr11(content, 0, frame1, 0, width, height);
			return this.#applyAtari8Palette(frame1);
		case 30:
			this.#setSize(width, height, RECOILResolution.XE2X1);
			this.#decodeAtari8Gr15(unpacked, 0, contentStride, frame1, 0, width, height);
			this.#decodeAtari8Gr15(unpacked, height * contentStride, contentStride, frame2, 0, width, height);
			return this.#applyAtari8PaletteBlend(frame1, frame2);
		case 16:
			this.#setSize(width, height, RECOILResolution.XE2X1);
			this.#setBakPF012(content, 28 + textLength, 1);
			this.#decodeAtari8Gr15(unpacked, 0, contentStride << 1, frame1, 0, width << 1, height >> 1);
			this.#setBakPF012(content, 24 + textLength, 1);
			this.#decodeAtari8Gr15(unpacked, contentStride, contentStride << 1, frame1, width, width << 1, height >> 1);
			this.#decodeAtari8Gr15(unpacked, height * contentStride, contentStride << 1, frame2, 0, width << 1, height >> 1);
			this.#setBakPF012(content, 28 + textLength, 1);
			this.#decodeAtari8Gr15(unpacked, (height + 1) * contentStride, contentStride << 1, frame2, width, width << 1, height >> 1);
			return this.#applyAtari8PaletteBlend(frame1, frame2);
		case 32:
			this.#setSize(width, height, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#decodeAtari8Gr10(unpacked, 0, frame1, 0, width, height);
			this.#gtiaColors[8] = 0;
			this.#decodeAtari8Gr9(unpacked, height * contentStride, contentStride, frame2, 0, width, width, height);
			return this.#applyAtari8PaletteBlend(frame1, frame2);
		case 48:
			this.#setSize(width, height, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[0] = 0;
			let colorsOffset = height * contentStride << 1;
			for (let y = 0; y < height; y += 2) {
				this.#setPM123PF0123Bak(unpacked, colorsOffset + (y << 2));
				this.#decodeAtari8Gr10(unpacked, y * contentStride, frame1, y * width, width, y + 1 < height ? 2 : 1);
			}
			this.#gtiaColors[8] = 0;
			this.#decodeAtari8Gr9(unpacked, height * contentStride, contentStride, frame2, 0, width, width, height);
			return this.#applyAtari8PaletteBlend(frame1, frame2);
		default:
			return false;
		}
	}

	#decodeVzi(content, contentLength)
	{
		if (contentLength != 16000)
			return false;
		this.#setSize(320, 200, RECOILResolution.XE2X1);
		this.#gtiaColors[8] = 0;
		this.#leftSkip = -1;
		const frame1 = new Uint8Array(64000);
		this.#decodeAtari8Gr9(content, 0, 40, frame1, 0, 320, 320, 200);
		this.#leftSkip = 1;
		const frame2 = new Uint8Array(64000);
		this.#decodeAtari8Gr9(content, 8000, 40, frame2, 0, 320, 320, 200);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeRmUnpacked(content, colorsOffset, dliOffset, bitmap, mode, resolution)
	{
		const dliPresent = new Array(192);
		for (let i = 0; i < 128; i++) {
			let y = content[dliOffset + i];
			switch (y) {
			case 0:
				break;
			case 1:
			case 2:
			case 4:
			case 5:
				return false;
			default:
				if (mode == 0) {
					if (y >= 101)
						return false;
					if (y == 3)
						y = 0;
					else
						y -= 5;
				}
				else {
					if (y == 100 || y == 101 || y >= 198)
						return false;
					if (y == 3)
						y = 1;
					else if (y < 100)
						y -= 4;
					else
						y -= 6;
				}
				dliPresent[y] = true;
				break;
			}
		}
		this.#setSize(320, 192, resolution);
		if (mode == 2)
			this.#leftSkip = 2;
		if (mode == 1)
			this.#gtiaColors[8] = content[colorsOffset + 8] & 240;
		else
			this.#setGtiaColors(content, colorsOffset);
		let height = mode == 0 ? 96 : 192;
		const frame = new Uint8Array(61440);
		for (let y = 0; y < height; y++) {
			switch (mode) {
			case 0:
				this.#decodeAtari8Gr7(bitmap, y * 40, frame, y * 640, 1);
				break;
			case 1:
				this.#decodeAtari8Gr9(bitmap, y * 40, 40, frame, y * 320, 320, 320, 1);
				break;
			case 2:
				this.#decodeAtari8Gr10(bitmap, y * 40, frame, y * 320, 320, 1);
				break;
			case 3:
				this.#decodeAtari8Gr11(bitmap, y * 40, frame, y * 320, 320, 1);
				break;
			case 4:
				this.#decodeAtari8Gr15(bitmap, y * 40, 40, frame, y * 320, 320, 1);
				break;
			default:
				throw new Error();
			}
			if (dliPresent[y]) {
				let vcount = mode == 0 ? 16 + y : 16 + ((y - 1) >> 1);
				let reg = content[dliOffset + 128 + vcount];
				if (reg < 9)
					this.#setGtiaColor(reg, content[dliOffset + 256 + vcount]);
				else if (reg != 128)
					return false;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeRm(content, contentLength, mode, resolution)
	{
		const rle = Object.assign(new XeKoalaStream(), { content: content, contentOffset: 0, contentLength: contentLength - 464 });
		if (rle.unpackWrapped(mode == 0 ? 3840 : 7680)) {
			return this.#decodeRmUnpacked(content, contentLength - 464, contentLength - 384, rle.unpacked, mode, resolution);
		}
		else if (contentLength == 8192) {
			return this.#decodeRmUnpacked(content, 7680, 7808, content, mode, resolution);
		}
		return false;
	}

	#decodeAgp(content, contentLength)
	{
		if (contentLength != 7690)
			return false;
		this.#setGtiaColors(content, 1);
		const frame = new Uint8Array(61440);
		switch (content[0]) {
		case 8:
			this.#setSize(320, 192, RECOILResolution.XE1X1);
			this.#decodeAtari8Gr8(content, 10, frame, 0, 192);
			break;
		case 9:
			this.#setSize(320, 192, RECOILResolution.XE4X1);
			this.#decodeAtari8Gr9(content, 10, 40, frame, 0, 320, 320, 192);
			break;
		case 10:
			this.#setSize(320, 192, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			this.#decodeAtari8Gr10(content, 10, frame, 0, 320, 192);
			break;
		case 11:
			this.#setSize(320, 192, RECOILResolution.XE4X1);
			this.#decodeAtari8Gr11(content, 10, frame, 0, 320, 192);
			break;
		case 15:
			this.#setSize(320, 192, RECOILResolution.XE2X1);
			this.#decodeAtari8Gr15(content, 10, 40, frame, 0, 320, 192);
			break;
		default:
			return false;
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeShc(content, contentLength)
	{
		if (contentLength != 17920)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE1X1);
		const frame1 = new Uint8Array(61440);
		const frame2 = new Uint8Array(61440);
		let col1 = 15360;
		let col2 = 16640;
		for (let y = 0; y < 192; y++) {
			for (let x = 0; x < 320; x++) {
				let i = 320 * y + x;
				let bit = ~x & 7;
				switch (x) {
				case 94:
				case 166:
				case 214:
				case 262:
				case 306:
					col1++;
					break;
				case 46:
				case 142:
				case 190:
				case 238:
				case 286:
					col2++;
					break;
				default:
					break;
				}
				frame1[i] = content[col1] & ((content[i >> 3] >> bit & 1) != 0 ? 240 : 254);
				frame2[i] = content[col2] & ((content[7680 + (i >> 3)] >> bit & 1) != 0 ? 240 : 254);
			}
			col1++;
			col2++;
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeMgp(content, contentLength)
	{
		if (contentLength != 3845)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		this.#setPF0123Bak(content, 0);
		let rainbow = content[5];
		const bitmap = new Uint8Array(3840);
		bitmap.set(content.subarray(6, 3845));
		bitmap[3839] = 0;
		for (let y = 0; y < 96; y++) {
			if (rainbow < 4) {
				this.#gtiaColors[rainbow == 0 ? 8 : 3 + rainbow] = (16 + y) & 254;
			}
			this.#decodeAtari8Gr7(bitmap, y * 40, frame, y * 640, 1);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeGad(content, contentLength)
	{
		if (contentLength != 4325)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		this.#setPF0123Bak(content, 0);
		for (let y = 0; y < 96; y++) {
			this.#decodeAtari8Gr7(content, 5 + y * 40, frame, y * 640, 1);
			if (content[3845 + y] < 128) {
				for (let i = 0; i < 4; i++)
					this.#gtiaColors[i == 3 ? 8 : 4 + i] = content[3941 + i * 96 + y] & 254;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeFwa(content, contentLength)
	{
		if (contentLength < 7960 || content[0] != 254 || content[1] != 254 || content[6] != 112 || content[7] != 112 || content[8] != 112 || content[11] != 80 || content[115] != 96 || content[205] != 65 || 7960 + content[7958] + (content[7959] << 8) != contentLength)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		this.#setBakPF012(content, 2, 1);
		let dlOffset = 9;
		let dliOffset = 7960;
		for (let y = 0; y < 192; y++) {
			this.#decodeAtari8Gr15(content, 262 + 40 * y + (y >= 102 ? 16 : 0), 40, frame, y * 320, 320, 1);
			let dlInstr = content[dlOffset];
			if (dlOffset == 9 || dlOffset == 113) {
				if ((dlInstr & 127) != 78 || content[dlOffset + 1] != 0)
					return false;
				dlOffset += 3;
			}
			else {
				if ((dlInstr & 127) != 14)
					return false;
				dlOffset++;
			}
			if (dlInstr >= 128) {
				if (dliOffset + 14 > contentLength || content[dliOffset] != 72 || content[dliOffset + 1] != 138 || content[dliOffset + 2] != 72 || content[dliOffset + 3] != 169 || content[dliOffset + 5] != 141 || content[dliOffset + 6] != 10 || content[dliOffset + 7] != 212)
					return false;
				let a = content[dliOffset + 4];
				dliOffset += 8;
				while (content[dliOffset] != 32) {
					switch (content[dliOffset]) {
					case 169:
						a = content[dliOffset + 1];
						dliOffset += 2;
						break;
					case 141:
						if (content[dliOffset + 2] != 208)
							return false;
						let lo = content[dliOffset + 1];
						switch (lo) {
						case 22:
						case 23:
						case 24:
						case 26:
							this.#gtiaColors[lo - 18] = a & 254;
							break;
						default:
							return false;
						}
						dliOffset += 3;
						break;
					default:
						return false;
					}
					if (dliOffset + 3 > contentLength)
						return false;
				}
				if (content[dliOffset + 1] != 202 || content[dliOffset + 2] != 6)
					return false;
				dliOffset += 3;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Font(characters, font, fontOffset)
	{
		this.#setSize(256, 32, RECOILResolution.XE1X1);
		const frame = new Uint8Array(8192);
		this.#decodeAtari8Gr0(characters, 0, 32, font, fontOffset, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Fnt(content, contentLength)
	{
		let contentOffset;
		switch (contentLength) {
		case 1024:
		case 1025:
		case 1026:
			contentOffset = 0;
			break;
		case 1030:
			if (RECOIL.#parseAtari8ExecutableHeader(content, 0) != 1024)
				return false;
			contentOffset = 6;
			break;
		default:
			return false;
		}
		return this.#decodeAtari8Font(null, content, contentOffset);
	}

	#decodeF80(content, contentLength)
	{
		if (contentLength != 512)
			return false;
		this.#setSize(128, 32, RECOILResolution.XE1X1);
		const frame = new Uint8Array(4096);
		this.#decodeAtari8Gr0(null, 0, 16, content, 0, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeSxs(content, contentLength)
	{
		if (contentLength != 1030 || RECOIL.#parseAtari8ExecutableHeader(content, 0) != 1024)
			return false;
		const characters = new Uint8Array(128);
		for (let i = 0; i < 128; i++)
			characters[i] = (i & 65) | (i >> 4 & 2) | (i & 30) << 1;
		return this.#decodeAtari8Font(characters, content, 6);
	}

	#decodeFn2(content, contentLength)
	{
		if (contentLength != 2048)
			return false;
		this.#setSize(256, 64, RECOILResolution.XE1X1);
		this.#gtiaColors[6] = 0;
		this.#gtiaColors[5] = 14;
		const frame = new Uint8Array(16384);
		for (let y = 0; y < 64; y += 8)
			this.#decodeAtari8Gr0Line(null, y >> 4 << 5, content, (y & 8) << 7, frame, y << 8, 8);
		return this.#applyAtari8Palette(frame);
	}

	#decodeOdf(content, contentLength)
	{
		if (contentLength != 1280)
			return false;
		this.#setSize(256, 40, RECOILResolution.XE1X1);
		const frame = new Uint8Array(10240);
		for (let y = 0; y < 40; y++) {
			for (let x = 0; x < 256; x++)
				frame[(y << 8) + x] = (content[(y / 10 | 0) * 320 + (x >> 3) * 10 + y % 10] >> (~x & 7) & 1) == 0 ? 0 : 14;
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeNlq(content, contentLength)
	{
		if (contentLength < 379 || !RECOIL.isStringAt(content, 0, "DAISY-DOT NLQ FONT") || content[18] != 155)
			return false;
		this.#setSize(320, 96, RECOILResolution.XE1X1);
		const frame = new Uint8Array(30720);
		let contentOffset = 19;
		for (let i = 0; i < 91; i++) {
			if (contentOffset >= contentLength)
				return false;
			let width = content[contentOffset];
			if (width == 0 || width > 19)
				return false;
			let nextContentOffset = contentOffset + (width + 1) * 2;
			if (nextContentOffset > contentLength || content[nextContentOffset - 1] != 155)
				return false;
			let c = i < 64 ? i : i < 90 ? i + 1 : 92;
			for (let y = 0; y < 16; y++) {
				for (let x = 0; x < width; x++) {
					let b = content[contentOffset + 1 + (y & 1) * width + x] >> (7 - (y >> 1)) & 1;
					frame[((c & 240) | y) * 320 + (c & 15) * 20 + x] = b == 0 ? 0 : 14;
				}
			}
			contentOffset = nextContentOffset;
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeGr1(content, contentLength, doubleHeight)
	{
		let charsLength = 480 >> doubleHeight;
		switch (contentLength - charsLength) {
		case 0:
			this.#setXeOsDefaultColors();
			break;
		case 5:
			this.#setBakPF0123(content, charsLength);
			break;
		default:
			return false;
		}
		this.#setSize(320, 192, doubleHeight == 0 ? RECOILResolution.XE2X1 : RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		let font = Fu.atari8_fnt;
		for (let offset = 0; offset < charsLength; offset += 20)
			this.#decodeAtari8Gr1Line(content, offset, font, 0, frame, offset << (7 + doubleHeight), doubleHeight);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAcs(content, contentLength)
	{
		if (contentLength != 1028)
			return false;
		this.#setBakPF012(content, 0, 1);
		this.#setSize(128, 64, RECOILResolution.XE2X1);
		const frame = new Uint8Array(8192);
		for (let y = 0; y < 8; y++)
			this.#decodeAtari8Gr12Line(null, 0, content, 4 + (y << 7), frame, y << 10, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decodeJgp(content, contentLength)
	{
		if (contentLength != 2054 || RECOIL.#parseAtari8ExecutableHeader(content, 0) != 2048)
			return false;
		this.#setGr15DefaultColors();
		this.#setSize(256, 64, RECOILResolution.XE2X1);
		const frame = new Uint8Array(16384);
		for (let y = 0; y < 8; y++)
			this.#decodeAtari8Gr12Line(null, 0, content, 6 + ((y & 6) << 7) + ((y & 1) << 10), frame, y << 11, 0);
		return this.#applyAtari8Palette(frame);
	}

	#decodeLeo(content, contentLength)
	{
		if (contentLength != 2580)
			return false;
		this.#setSize(256, 64, RECOILResolution.XE2X1);
		const frame = new Uint8Array(16384);
		const characters = new Uint8Array(32);
		this.#setPF0123Bak(content, 2560);
		for (let y = 0; y < 8; y++) {
			for (let x = 0; x < 32; x++)
				characters[x] = content[2048 + ((x & 1) << 7) + ((y & 1) << 6) + ((y & 6) << 3) + (x >> 1)];
			this.#decodeAtari8Gr12Line(characters, 0, content, (y & 1) << 10, frame, y << 11, 0);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Sif(content, contentLength)
	{
		if (contentLength != 2048)
			return false;
		this.#setSize(256, 32, RECOILResolution.XE2X1);
		this.#gtiaColors[4] = 76;
		this.#gtiaColors[5] = 204;
		this.#gtiaColors[6] = 140;
		this.#gtiaColors[8] = 0;
		const frame1 = new Uint8Array(8192);
		const frame2 = new Uint8Array(8192);
		for (let y = 0; y < 4; y++) {
			this.#decodeAtari8Gr12Line(null, 0, content, y << 8, frame1, y << 11, 0);
			this.#decodeAtari8Gr12Line(null, 0, content, 1024 + (y << 8), frame2, y << 11, 0);
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeDlm(content, contentLength)
	{
		if (contentLength != 256)
			return false;
		const characters = new Uint8Array(176);
		for (let y = 0; y < 16; y++)
			for (let x = 0; x < 11; x++)
				characters[y * 11 + x] = RECOIL.#toAtari8Char(content[y * 16 + 5 + x]);
		this.#setSize(88, 128, RECOILResolution.XE1X1);
		const frame = new Uint8Array(11264);
		this.#decodeAtari8Gr0(characters, 0, 11, Fu.atari8_fnt, 0, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAtari8Gr0Screen(content, font)
	{
		this.#setSize(320, 192, RECOILResolution.XE1X1);
		const frame = new Uint8Array(61440);
		this.#decodeAtari8Gr0(content, 0, 40, font, 0, frame);
		this.#applyAtari8Palette(frame);
	}

	#decodeGr0(content, contentLength)
	{
		if (contentLength != 960 && contentLength != 1024)
			return false;
		this.#decodeAtari8Gr0Screen(content, Fu.atari8_fnt);
		return true;
	}

	#decodeSge(content, contentLength)
	{
		if (contentLength != 960)
			return false;
		const font = new Uint8Array(1024);
		font.set(Fu.atari8_fnt);
		for (let i = 0; i < 4; i++) {
			font[1004 + i] = font[728 + i] = 15;
			font[1000 + i] = font[732 + i] = 240;
		}
		this.#decodeAtari8Gr0Screen(content, font);
		return true;
	}

	#decodeAn2(content, contentLength)
	{
		if (contentLength < 3)
			return false;
		let columns = content[0] + 1;
		let rows = content[1] + 1;
		if (columns > 40 || rows > 24 || contentLength != 2 + columns * rows)
			return false;
		this.#setSize(columns << 3, rows << 3, RECOILResolution.XE1X1);
		const frame = new Uint8Array(61440);
		this.#decodeAtari8Gr0(content, 2, columns, Fu.atari8_fnt, 0, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAn4(content, contentLength, doubleHeight)
	{
		if (contentLength < 8)
			return false;
		let columns;
		let rows;
		let charactersOffset;
		if (contentLength << doubleHeight == 960) {
			columns = 40;
			rows = 24 >> doubleHeight;
			this.#setXeOsDefaultColors();
			charactersOffset = 0;
		}
		else {
			columns = content[0] + 1;
			rows = content[1] + 1;
			if (columns > 40 || rows << doubleHeight > 24 || contentLength != 7 + columns * rows)
				return false;
			this.#setBakPF0123(content, 2);
			charactersOffset = 7;
		}
		if (doubleHeight == 0)
			this.#setSize(columns << 3, rows << 3, RECOILResolution.XE2X1);
		else
			this.#setSize(columns << 3, rows << 4, RECOILResolution.XE2X2);
		const frame = new Uint8Array(61440);
		let font = Fu.atari8_fnt;
		for (let y = 0; y < rows; y++)
			this.#decodeAtari8Gr12Line(content, charactersOffset + y * columns, font, 0, frame, y * columns << (6 + doubleHeight), doubleHeight);
		return this.#applyAtari8Palette(frame);
	}

	#decodeTl4(content, contentLength)
	{
		if (contentLength < 11)
			return false;
		let columns = content[0];
		let rows = content[1];
		if (columns == 0 || columns > 4 || rows == 0 || rows > 5 || contentLength != 2 + columns * rows * 9)
			return false;
		this.#setSize(columns << 3, rows << 3, RECOILResolution.XE2X1);
		const frame = new Uint8Array(1280);
		for (let y = 0; y < rows << 3; y++) {
			for (let x = 0; x < columns << 3; x++) {
				let offset = 2 + ((y >> 3) * columns + (x >> 3)) * 9;
				let c;
				switch (content[offset + (y & 7)] >> (~x & 6) & 3) {
				case 1:
					c = 40;
					break;
				case 2:
					c = 202;
					break;
				case 3:
					c = content[offset + 8] == 0 ? 148 : 70;
					break;
				default:
					c = 0;
					break;
				}
				frame[(y * columns << 3) + x] = c;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeAsciiArtEditor(content, contentLength)
	{
		if (contentLength <= 0 || content[contentLength - 1] != 155)
			return false;
		const characters = new Uint8Array(1536);
		let columns = 1;
		let x = 0;
		let y = 0;
		for (let contentOffset = 0; contentOffset < contentLength; contentOffset++) {
			let ch = content[contentOffset];
			if (y >= 24)
				return false;
			if (ch == 155) {
				if (columns < x)
					columns = x;
				while (x < 64)
					characters[y * 64 + x++] = 0;
				x = 0;
				y++;
			}
			else {
				if (x >= 64)
					return false;
				characters[y * 64 + x++] = RECOIL.#toAtari8Char(ch);
			}
		}
		this.#setSize(columns << 3, y << 3, RECOILResolution.XE1X1);
		const frame = new Uint8Array(98304);
		this.#decodeAtari8Gr0(characters, 0, 64, Fu.atari8_fnt, 0, frame);
		return this.#applyAtari8Palette(frame);
	}

	#decodeAll(content, contentLength)
	{
		if ((contentLength & 1023) != 989)
			return false;
		this.#setPF0123Bak(content, contentLength - 5);
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		for (let y = 0; y < 24; y++) {
			let fontOffset = 24 + (content[y] << 10);
			if (fontOffset >= contentLength - 965)
				return false;
			this.#decodeAtari8Gr12Line(content, contentLength - 965 + y * 40, content, fontOffset, frame, y * 2560, 0);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeKpr(content, contentLength)
	{
		if (contentLength < 11 || RECOIL.#getAtari8ExecutableOffset(content, contentLength) != 6)
			return false;
		let frames = content[8];
		let cols = content[9];
		let rows = content[10];
		let tiles = frames * cols * rows;
		if (contentLength < 11 + tiles || !this.#setSize(frames * cols << 3, rows << 3, RECOILResolution.XE2X1))
			return false;
		let pixelsOffset = 0;
		for (let y = 0; y < rows << 3; y++) {
			for (let f = 0; f < frames; f++) {
				for (let x = 0; x < cols << 3; x++) {
					let c = content[11 + (f * rows + (y >> 3)) * cols + (x >> 3)];
					c = 11 + tiles + (c << 3) + (y & 7);
					if (c >= contentLength)
						return false;
					c = content[c] >> (~x & 6) & 3;
					this.#pixels[pixelsOffset++] = this.#atari8Palette[c << 2];
				}
			}
		}
		return true;
	}

	#decodeEnvisionCommon(content, mode, columns, rows, charactersOffset, fontId2Offset)
	{
		let charWidth;
		let charHeight;
		let resolution;
		switch (mode) {
		case 2:
			charWidth = 8;
			charHeight = 8;
			resolution = RECOILResolution.XE1X1;
			break;
		case 3:
			charWidth = 8;
			charHeight = 10;
			resolution = RECOILResolution.XE1X1;
			break;
		case 4:
			charWidth = 8;
			charHeight = 8;
			resolution = RECOILResolution.XE2X1;
			break;
		case 5:
			charWidth = 8;
			charHeight = 16;
			resolution = RECOILResolution.XE2X2;
			break;
		case 6:
			charWidth = 16;
			charHeight = 8;
			resolution = RECOILResolution.XE2X1;
			break;
		case 7:
			charWidth = 16;
			charHeight = 16;
			resolution = RECOILResolution.XE2X2;
			break;
		default:
			return false;
		}
		if (!this.#setSize(columns * charWidth, rows * charHeight, resolution))
			return false;
		let frame = new Uint8Array(this.#width * this.#height);
		for (let row = 0; row < rows; row++) {
			let fontOffset;
			if (fontId2Offset != null) {
				fontOffset = fontId2Offset[content[8 + columns * rows + 256 + row]];
				if (fontOffset == 0)
					return false;
			}
			else {
				fontOffset = 10 + columns * rows;
			}
			let frameOffset = row * charHeight * this.#width;
			switch (mode >> 1) {
			case 1:
				this.#decodeAtari8Gr0Line(content, charactersOffset, content, fontOffset, frame, frameOffset, charHeight);
				break;
			case 2:
				this.#decodeAtari8Gr12Line(content, charactersOffset, content, fontOffset, frame, frameOffset, mode & 1);
				break;
			case 3:
				this.#decodeAtari8Gr1Line(content, charactersOffset, content, fontOffset, frame, frameOffset, mode & 1);
				break;
			default:
				throw new Error();
			}
			charactersOffset += columns;
		}
		this.#applyAtari8Palette(frame);
		return true;
	}

	#decodeEnvision(content, contentLength)
	{
		if (contentLength < 1505)
			return false;
		let columns = content[1] + 1;
		let rows = content[2] + 1;
		if (rows > 204)
			return false;
		let fontOffset = 8 + columns * rows + 463;
		if (contentLength < fontOffset || contentLength != fontOffset + content[fontOffset - 1] * 1033)
			return false;
		const fontId2Offset = new Int32Array(256);
		for (; fontOffset < contentLength; fontOffset += 1033)
			fontId2Offset[content[fontOffset]] = fontOffset + 1 + 8;
		this.#setPF0123Bak(content, 3);
		return this.#decodeEnvisionCommon(content, content[0] & 127, columns, rows, 8, fontId2Offset);
	}

	#decodeEnvisionPC(content, contentLength)
	{
		if (contentLength < 1035 || content[2] >= 128)
			return false;
		let columns = content[1] | content[2] << 8;
		let rows = content[3] | content[4] << 8;
		let contentOffset = 10 + columns * rows + 1024;
		while (contentOffset < contentLength) {
			switch (content[contentOffset++]) {
			case 0:
				break;
			case 1:
				if (contentOffset + 6 >= contentLength || content[contentOffset + 1] >= 5 || content[contentOffset + 3] >= 5 || content[contentOffset + 5] >= 5)
					return false;
				contentOffset += (content[contentOffset] + (content[contentOffset + 1] << 8)) * (content[contentOffset + 2] + (content[contentOffset + 3] << 8)) * (content[contentOffset + 4] + (content[contentOffset + 5] << 8) + 1);
				break;
			case 2:
				contentOffset += columns * rows;
				break;
			case 3:
				contentOffset += 1027;
				break;
			default:
				return false;
			}
		}
		if (contentOffset > contentLength)
			return false;
		this.#setBakPF0123(content, 5);
		return this.#decodeEnvisionCommon(content, content[0], columns, rows, 10, null);
	}

	#decodeMcs(content, contentLength)
	{
		if (contentLength != 10185)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		for (let y = 0; y < 192; y++) {
			let fontOffset = 9 + ((y / 24 | 0) << 10);
			for (let x = 0; x < 320; x++) {
				let ch = content[8201 + (y >> 3) * 40 + (x >> 3)];
				let c;
				switch (content[fontOffset + ((ch & 127) << 3) + (y & 7)] >> (~x & 6) & 3) {
				case 0:
					c = x / 80 | 0;
					let pmgBit = (x >> 3) % 10;
					let pmgOffset;
					if (pmgBit < 8) {
						pmgBit = 7 - pmgBit;
						pmgOffset = 9305 + (c << 7);
					}
					else {
						pmgBit = c << 1 | (pmgBit ^ 9);
						pmgOffset = 9177;
					}
					if ((content[pmgOffset + (y >> 1)] >> pmgBit & 1) == 0)
						c = 8;
					break;
				case 1:
					c = 4;
					break;
				case 2:
					c = 5;
					break;
				default:
					c = 6 + (ch >> 7);
					break;
				}
				frame[y * 320 + x] = content[c] & 254;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	static #gr12GtiaNibbleToGr8(nibble, ch, gtia10)
	{
		switch (nibble) {
		case 0:
		case 1:
		case 4:
		case 5:
			return 0;
		case 2:
		case 6:
			return 1;
		case 3:
		case 7:
			return (ch & 128) == 0 ? 2 : 3;
		case 8:
			return gtia10 ? 8 : 4;
		case 9:
			return 4;
		case 10:
			return 5;
		case 11:
			return (ch & 128) == 0 ? 6 : 7;
		case 12:
			return gtia10 || (ch & 128) == 0 ? 8 : 12;
		case 13:
			return (ch & 128) == 0 ? 8 : 12;
		case 14:
			return (ch & 128) == 0 ? 9 : 13;
		case 15:
			return (ch & 128) == 0 ? 10 : 15;
		default:
			return 0;
		}
	}

	static #gr12GtiaByteToGr8(b, ch, gtia10)
	{
		return RECOIL.#gr12GtiaNibbleToGr8(b >> 4, ch, gtia10) << 4 | RECOIL.#gr12GtiaNibbleToGr8(b & 15, ch, gtia10);
	}

	#decodeIceFrame(content, charactersOffset, fontOffset, frame, mode)
	{
		let doubleLine;
		switch (mode) {
		case IceFrameMode.GR13_GTIA9:
		case IceFrameMode.GR13_GTIA10:
		case IceFrameMode.GR13_GTIA11:
			doubleLine = 1;
			break;
		default:
			doubleLine = 0;
			break;
		}
		let frameOffset = 0;
		const bitmap = new Uint8Array(40);
		for (let y = 0; y < this.#height; y++) {
			for (let col = 0; col < this.#width >> 3; col++) {
				let ch;
				switch (charactersOffset) {
				case -1:
					ch = RECOIL.#DECODE_ICE_FRAME_ROW2CHAR1[y >> (3 + doubleLine)] + col;
					break;
				case -2:
					ch = RECOIL.#DECODE_ICE_FRAME_ROW2CHAR2[y >> (3 + doubleLine)] + col;
					break;
				default:
					ch = ((y / 24 | 0) << 8) + content[charactersOffset + (y >> 3) * 40 + col];
					break;
				}
				let b = content[fontOffset + ((ch & ~128) << 3) + (y >> doubleLine & 7)];
				switch (mode) {
				case IceFrameMode.GR0:
				case IceFrameMode.GR0_GTIA9:
				case IceFrameMode.GR0_GTIA10:
				case IceFrameMode.GR0_GTIA11:
					if (charactersOffset < 0 && (ch & 128) != 0)
						b ^= 255;
					bitmap[col] = b;
					break;
				case IceFrameMode.GR12:
					for (let x = col == 0 ? this.#leftSkip : 0; x < 8; x++) {
						let c = b >> (~x & 6) & 3;
						let gr12Registers = (ch & 128) == 0 ? 25928 : 30024;
						frame[frameOffset + (col << 3) + x - this.#leftSkip] = this.#gtiaColors[gr12Registers >> (c << 2) & 15];
					}
					break;
				case IceFrameMode.GR12_GTIA9:
				case IceFrameMode.GR12_GTIA11:
				case IceFrameMode.GR13_GTIA9:
				case IceFrameMode.GR13_GTIA11:
					bitmap[col] = RECOIL.#gr12GtiaByteToGr8(b, ch, false);
					break;
				case IceFrameMode.GR12_GTIA10:
				case IceFrameMode.GR13_GTIA10:
					bitmap[col] = RECOIL.#gr12GtiaByteToGr8(b, ch, true);
					break;
				}
			}
			switch (mode) {
			case IceFrameMode.GR0:
				this.#decodeAtari8Gr8(bitmap, 0, frame, frameOffset, 1);
				break;
			case IceFrameMode.GR12:
				for (let x = this.#width; x < this.#width + this.#leftSkip; x++)
					frame[frameOffset + x] = this.#gtiaColors[8];
				break;
			case IceFrameMode.GR0_GTIA9:
			case IceFrameMode.GR12_GTIA9:
			case IceFrameMode.GR13_GTIA9:
				this.#decodeAtari8Gr9(bitmap, 0, 0, frame, frameOffset, 0, this.#width, 1);
				break;
			case IceFrameMode.GR0_GTIA10:
			case IceFrameMode.GR12_GTIA10:
			case IceFrameMode.GR13_GTIA10:
				this.#decodeAtari8Gr10(bitmap, 0, frame, frameOffset, 0, 1);
				break;
			case IceFrameMode.GR0_GTIA11:
			case IceFrameMode.GR12_GTIA11:
			case IceFrameMode.GR13_GTIA11:
				this.#decodeAtari8Gr11(bitmap, 0, frame, frameOffset, 0, 1);
				break;
			}
			frameOffset += this.#width;
		}
	}

	#verifyIce(content, contentLength, font, fontLength, imageLength, resolution)
	{
		if (font) {
			if (contentLength != fontLength)
				return false;
			this.#setSize(256, 128, resolution);
		}
		else {
			if (contentLength != imageLength || content[0] != 1)
				return false;
			this.#setSize(320, 192, resolution);
		}
		return true;
	}

	#decodeIce20Frame(content, second, fontOffset, frame, mode)
	{
		const bitmap = new Uint8Array(32);
		for (let y = 0; y < 288; y++) {
			let row = y >> 5;
			let c = (second ? row / 3 | 0 : row % 3) + 1;
			for (let col = 0; col < 32; col++) {
				let ch = ((y & 24) << 1) + (col >> 1);
				let b = content[fontOffset + (ch << 3) + (y & 7)];
				b = (col & 1) == 0 ? b >> 4 : b & 15;
				b = ((b & 8) << 3 | (b & 4) << 2 | (b & 2) << 1 | (b & 1)) * c;
				if (mode == 10) {
					if ((b & 112) == 64)
						b = 128 + (b & 15);
					if ((b & 7) == 4)
						b = (b & 240) + 8;
				}
				bitmap[col] = b;
			}
			switch (mode) {
			case 9:
				this.#decodeAtari8Gr9(bitmap, 0, 0, frame, y << 8, 0, 256, 1);
				break;
			case 10:
				this.#decodeAtari8Gr10(bitmap, 0, frame, y << 8, 0, 1);
				break;
			case 11:
				this.#decodeAtari8Gr11(bitmap, 0, frame, y << 8, 0, 1);
				break;
			default:
				throw new Error();
			}
		}
	}

	#decodeAtari8Ice(content, contentLength, font, mode)
	{
		const frame1 = new Uint8Array(73728);
		const frame2 = new Uint8Array(73728);
		switch (mode) {
		case 0:
			if (contentLength != 2053)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE1X1);
			this.#gtiaColors[5] = content[1] & 254;
			this.#gtiaColors[6] = content[3] & 254;
			this.#decodeIceFrame(content, -1, 5, frame1, IceFrameMode.GR0);
			this.#gtiaColors[5] = content[2] & 254;
			this.#gtiaColors[6] = content[4] & 254;
			this.#decodeIceFrame(content, -2, 1029, frame2, IceFrameMode.GR0);
			break;
		case 1:
			if (!this.#verifyIce(content, contentLength, font, 2054, 18310, RECOILResolution.XE2X1))
				return false;
			this.#setBakPF0123(content, 1);
			this.#decodeIceFrame(content, font ? -1 : 16390, 6, frame1, IceFrameMode.GR12);
			this.#decodeIceFrame(content, font ? -2 : 17350, 1030, frame2, IceFrameMode.GR12);
			break;
		case 2:
			if (!this.#verifyIce(content, contentLength, font, 2058, 18314, RECOILResolution.XE2X1))
				return false;
			this.#gtiaColors[8] = content[1] & 254;
			this.#setPF0123Even(content, 2);
			this.#decodeIceFrame(content, font ? -1 : 16394, 10, frame1, IceFrameMode.GR12);
			this.#setPF0123Even(content, 3);
			this.#decodeIceFrame(content, font ? -2 : 17354, 1034, frame2, IceFrameMode.GR12);
			break;
		case 3:
			if (font) {
				if (contentLength != 2055)
					return false;
				this.#setSize(256, 128, RECOILResolution.XE1X1);
			}
			else {
				if (contentLength != 17351 || content[0] != 3)
					return false;
				this.#setSize(320, 192, RECOILResolution.XE1X1);
			}
			this.#setPF21(content, 1);
			this.#decodeIceFrame(content, font ? -1 : 16391, 7, frame1, IceFrameMode.GR0);
			this.#setBakPF0123(content, 2);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, font ? -2 : 16391, 1031, frame2, IceFrameMode.GR12);
			break;
		case 4:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR0_GTIA10);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR0_GTIA10);
			break;
		case 5:
			if (contentLength != 2065 && contentLength != 2066)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			this.#gtiaColors[0] = content[1] & 254;
			for (let i = 0; i < 8; i++)
				this.#setGtiaColor(i + 1, content[2 + i * 2]);
			if (contentLength == 2065) {
				this.#decodeIceFrame(content, -1, 17, frame1, IceFrameMode.GR0_GTIA10);
				for (let i = 0; i < 7; i++)
					this.#setGtiaColor(i + 1, content[3 + i * 2]);
				this.#decodeIceFrame(content, -2, 1041, frame2, IceFrameMode.GR0_GTIA10);
			}
			else {
				this.#decodeIceFrame(content, -1, 18, frame1, IceFrameMode.GR0_GTIA10);
				for (let i = 0; i < 8; i++)
					this.#setGtiaColor(i + 1, content[3 + i * 2]);
				this.#decodeIceFrame(content, -2, 1042, frame2, IceFrameMode.GR0_GTIA10);
			}
			break;
		case 6:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR0_GTIA9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR0_GTIA9);
			break;
		case 7:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR0_GTIA11);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR0_GTIA11);
			break;
		case 8:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR0_GTIA9);
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR0_GTIA10);
			break;
		case 9:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR0_GTIA11);
			this.#gtiaColors[0] = 0;
			this.#setPM123PF0123Bak(content, 2);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR0_GTIA10);
			break;
		case 10:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR0_GTIA9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR0_GTIA11);
			break;
		case 11:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE1X1);
			this.#gtiaColors[6] = 0;
			this.#gtiaColors[5] = content[2] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR0);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR0_GTIA11);
			break;
		case 12:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE1X1);
			this.#setPF21(content, 1);
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR0);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR0_GTIA9);
			break;
		case 13:
			if (contentLength != 2059)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE1X1);
			this.#setPF21(content, 1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 11, frame1, IceFrameMode.GR0);
			this.#leftSkip = 2;
			this.#gtiaColors[0] = content[1] & 254;
			this.#setPM123PF0123Bak(content, 3);
			this.#decodeIceFrame(content, -2, 1035, frame2, IceFrameMode.GR0_GTIA10);
			break;
		case 14:
			if (contentLength != 2054)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE2X1);
			this.#setBakPF0123(content, 1);
			this.#decodeIceFrame(content, -2, 1030, frame2, IceFrameMode.GR12_GTIA11);
			this.#gtiaColors[8] = 0;
			this.#decodeIceFrame(content, -1, 6, frame1, IceFrameMode.GR12);
			break;
		case 15:
			if (contentLength != 2054)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE2X1);
			this.#setBakPF0123(content, 1);
			this.#decodeIceFrame(content, -1, 6, frame1, IceFrameMode.GR12);
			this.#decodeIceFrame(content, -2, 1030, frame2, IceFrameMode.GR12_GTIA9);
			break;
		case 16:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 128, RECOILResolution.XE2X1);
			this.#leftSkip = 2;
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR12_GTIA10);
			this.#leftSkip = 0;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR12);
			break;
		case 17:
			if (!this.#verifyIce(content, contentLength, font, 2054, 17350, RECOILResolution.XE2X1))
				return false;
			this.#setBakPF0123(content, 1);
			this.#decodeIceFrame(content, font ? -2 : 16390, 1030, frame2, IceFrameMode.GR0_GTIA11);
			this.#gtiaColors[8] = 0;
			this.#decodeIceFrame(content, font ? -1 : 16390, 6, frame1, IceFrameMode.GR12);
			break;
		case 18:
			if (!this.#verifyIce(content, contentLength, font, 2054, 17350, RECOILResolution.XE2X1))
				return false;
			this.#setBakPF0123(content, 1);
			this.#decodeIceFrame(content, font ? -1 : 16390, 6, frame1, IceFrameMode.GR12);
			this.#decodeIceFrame(content, font ? -2 : 16390, 1030, frame2, IceFrameMode.GR0_GTIA9);
			break;
		case 19:
			if (!this.#verifyIce(content, contentLength, font, 2058, 17354, RECOILResolution.XE2X1))
				return false;
			this.#setPF0123Bak(content, 5);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, font ? -1 : 16394, 10, frame1, IceFrameMode.GR12);
			this.#leftSkip = 2;
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, font ? -2 : 16394, 1034, frame2, IceFrameMode.GR0_GTIA10);
			break;
		case 22:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE4X2);
			this.#leftSkip = 2;
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR13_GTIA10);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR13_GTIA10);
			break;
		case 23:
			if (contentLength != 2065)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE4X2);
			this.#leftSkip = 2;
			this.#gtiaColors[0] = content[1] & 254;
			for (let i = 0; i < 8; i++)
				this.#setGtiaColor(i + 1, content[2 + i * 2]);
			this.#decodeIceFrame(content, -1, 17, frame1, IceFrameMode.GR13_GTIA10);
			for (let i = 0; i < 7; i++)
				this.#setGtiaColor(i + 1, content[3 + i * 2]);
			this.#decodeIceFrame(content, -2, 1041, frame2, IceFrameMode.GR13_GTIA10);
			break;
		case 24:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE4X2);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR13_GTIA9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR13_GTIA9);
			break;
		case 25:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE4X2);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR13_GTIA11);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR13_GTIA11);
			break;
		case 26:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE2X2);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR13_GTIA9);
			this.#setGtiaColors(content, 1);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR13_GTIA10);
			break;
		case 27:
			if (contentLength != 2058)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE2X2);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 10, frame1, IceFrameMode.GR13_GTIA11);
			this.#gtiaColors[0] = 0;
			this.#setPM123PF0123Bak(content, 2);
			this.#decodeIceFrame(content, -2, 1034, frame2, IceFrameMode.GR13_GTIA10);
			break;
		case 28:
			if (contentLength != 2051)
				return false;
			this.#setSize(256, 256, RECOILResolution.XE4X2);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIceFrame(content, -1, 3, frame1, IceFrameMode.GR13_GTIA9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIceFrame(content, -2, 1027, frame2, IceFrameMode.GR13_GTIA11);
			break;
		case 31:
			if (contentLength != 1032)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			for (let i = 0; i < 7; i++)
				this.#setGtiaColor(RECOIL.#DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS[i], content[1 + i]);
			this.#decodeIce20Frame(content, false, 8, frame1, 10);
			this.#decodeIce20Frame(content, true, 520, frame2, 10);
			break;
		case 32:
			if (contentLength != 1038)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE4X1);
			this.#leftSkip = 2;
			this.#gtiaColors[0] = content[1] & 254;
			for (let i = 1; i < 7; i++)
				this.#setGtiaColor(RECOIL.#DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS[i], content[i * 2]);
			this.#decodeIce20Frame(content, false, 14, frame1, 10);
			for (let i = 1; i < 7; i++)
				this.#setGtiaColor(RECOIL.#DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS[i], content[1 + i * 2]);
			this.#decodeIce20Frame(content, true, 526, frame2, 10);
			break;
		case 33:
			if (contentLength != 1027)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIce20Frame(content, false, 3, frame1, 9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIce20Frame(content, true, 515, frame2, 9);
			break;
		case 34:
			if (contentLength != 1027)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIce20Frame(content, false, 3, frame1, 11);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIce20Frame(content, true, 515, frame2, 11);
			break;
		case 35:
			if (contentLength != 1032)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIce20Frame(content, false, 8, frame1, 9);
			for (let i = 0; i < 7; i++)
				this.#setGtiaColor(RECOIL.#DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS[i], content[1 + i]);
			this.#decodeIce20Frame(content, true, 520, frame2, 10);
			break;
		case 36:
			if (contentLength != 1032)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE2X1);
			this.#leftSkip = 1;
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIce20Frame(content, false, 8, frame1, 11);
			this.#gtiaColors[0] = 0;
			for (let i = 1; i < 7; i++)
				this.#setGtiaColor(RECOIL.#DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS[i], content[1 + i]);
			this.#decodeIce20Frame(content, true, 520, frame2, 10);
			break;
		case 37:
			if (contentLength != 1027)
				return false;
			this.#setSize(256, 288, RECOILResolution.XE4X1);
			this.#gtiaColors[8] = content[1] & 254;
			this.#decodeIce20Frame(content, false, 3, frame1, 9);
			this.#gtiaColors[8] = content[2] & 254;
			this.#decodeIce20Frame(content, true, 515, frame2, 11);
			break;
		default:
			return false;
		}
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeIp2(content, contentLength)
	{
		if (contentLength != 17358 || content[0] != 1)
			return false;
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		this.#gtiaColors[8] = content[1] & 254;
		this.#gtiaColors[4] = content[5] & 254;
		this.#gtiaColors[5] = content[7] & 254;
		this.#gtiaColors[6] = content[9] & 254;
		this.#gtiaColors[7] = content[11] & 254;
		const frame1 = new Uint8Array(61440);
		this.#decodeIceFrame(content, 16398, 14, frame1, IceFrameMode.GR12);
		this.#leftSkip = 2;
		for (let i = 0; i < 4; i++) {
			this.#gtiaColors[i] = content[1 + i] & 254;
			this.#setGtiaColor(4 + i, content[6 + i * 2]);
		}
		this.#setGtiaColor(8, content[13]);
		const frame2 = new Uint8Array(61440);
		this.#decodeIceFrame(content, 16398, 1038, frame2, IceFrameMode.GR0_GTIA10);
		return this.#applyAtari8PaletteBlend(frame1, frame2);
	}

	#decodeAtari8RgbScreen(screens, screensOffset, color, frame)
	{
		if (this.#resolution == RECOILResolution.XE4X1) {
			this.#gtiaColors[8] = color;
			this.#decodeAtari8Gr9(screens, screensOffset, 40, frame, 0, this.#width, this.#width, this.#height);
		}
		else {
			this.#gtiaColors[8] = 0;
			this.#gtiaColors[4] = color | 4;
			this.#gtiaColors[5] = color | 10;
			this.#gtiaColors[6] = color | 14;
			this.#decodeAtari8Gr15(screens, screensOffset, 40, frame, 0, this.#width, this.#height);
		}
	}

	#decodeAtari8Rgb(content, contentLength)
	{
		if (contentLength < 9 || !RECOIL.isStringAt(content, 0, "RGB1"))
			return false;
		let titleLength = content[4];
		if (contentLength < 9 + titleLength)
			return false;
		let width = content[6 + titleLength];
		let height = content[7 + titleLength];
		if (width == 0 || (width & 1) != 0 || width > 80 || height == 0 || height > 192 || content[8 + titleLength] != 1)
			return false;
		switch (content[5 + titleLength]) {
		case 9:
			this.#setSize(width << 2, height, RECOILResolution.XE4X1);
			break;
		case 15:
			this.#setSize(width << 2, height, RECOILResolution.XE2X1);
			break;
		default:
			return false;
		}
		const leftRgbs = new Int32Array(192);
		const screens = new Uint8Array(23040);
		const rle = Object.assign(new RgbStream(), { content: content, contentOffset: 9 + titleLength, contentLength: contentLength });
		for (let x = 0; x < width; x++) {
			for (let y = 0; y < height; y++) {
				let rgb = rle.readRle();
				if (rgb < 0)
					return false;
				if ((x & 1) == 0)
					leftRgbs[y] = rgb;
				else {
					let leftRgb = leftRgbs[y];
					let screenOffset = y * 40 + (x >> 1);
					screens[screenOffset] = (leftRgb >> 4 & 240) | rgb >> 8;
					screens[7680 + screenOffset] = (leftRgb & 240) | (rgb >> 4 & 15);
					screens[15360 + screenOffset] = (leftRgb << 4 & 240) | (rgb & 15);
				}
			}
		}
		const frame1 = new Uint8Array(61440);
		this.#decodeAtari8RgbScreen(screens, 0, 48, frame1);
		const frame2 = new Uint8Array(61440);
		this.#decodeAtari8RgbScreen(screens, 7680, 192, frame2);
		const frame3 = new Uint8Array(61440);
		this.#decodeAtari8RgbScreen(screens, 15360, 112, frame3);
		return this.#applyAtari8PaletteBlend3(frame1, frame2, frame3);
	}

	#drawBlazingPaddlesVector(content, contentLength, frame, frameOffset, index, startAddress)
	{
		if (index * 2 + 1 >= contentLength)
			return false;
		let contentOffset = content[index * 2] + (content[index * 2 + 1] << 8) - startAddress;
		if (contentOffset < 0)
			return false;
		while (contentOffset < contentLength) {
			let control = content[contentOffset++];
			if (control == 8)
				return true;
			for (; control >= 0; control -= 16) {
				if ((control & 4) == 0)
					frame[frameOffset + 1] = frame[frameOffset] = 14;
				switch (control & 3) {
				case 0:
					frameOffset += 2;
					break;
				case 1:
					frameOffset -= 2;
					break;
				case 2:
					frameOffset -= this.#width;
					break;
				case 3:
					frameOffset += this.#width;
					break;
				default:
					throw new Error();
				}
			}
		}
		return false;
	}

	#decodeBlazingPaddlesVectors(content, contentLength, startAddress)
	{
		let x = 0;
		let y = 0;
		let i;
		let lineI = 0;
		let lineTop = 0;
		let lineBottom = 0;
		const xs = new Int32Array(256);
		const ys = new Int32Array(256);
		let width = 0;
		const box = new BlazingPaddlesBoundingBox();
		for (i = 0; i < 256; i++) {
			if (!box.calculate(content, contentLength, i, startAddress))
				break;
			let shapeWidth = box.right - box.left + 2;
			if (x + shapeWidth > 160) {
				y -= lineTop;
				while (lineI < i)
					ys[lineI++] = y;
				if (width < x)
					width = x;
				x = 0;
				y += lineBottom + 2;
				lineTop = box.top;
				lineBottom = box.bottom;
			}
			xs[i] = x - box.left;
			x += shapeWidth;
			if (lineTop > box.top)
				lineTop = box.top;
			if (lineBottom < box.bottom)
				lineBottom = box.bottom;
		}
		y -= lineTop;
		while (lineI < i)
			ys[lineI++] = y;
		if (width < x)
			width = x;
		y += lineBottom + 1;
		if (i == 0 || width > 160 || y > 240)
			return false;
		this.#setSize(width << 1, y, RECOILResolution.XE2X1);
		const frame = new Uint8Array(76800);
		for (let j = 0; j < i; j++) {
			if (!this.#drawBlazingPaddlesVector(content, contentLength, frame, (ys[j] * width + xs[j]) << 1, j, startAddress))
				break;
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeChr(content, contentLength)
	{
		return contentLength == 3072 && this.#decodeBlazingPaddlesVectors(content, contentLength, 28672);
	}

	#decodeShp(content, contentLength)
	{
		if (this.#decodeC64Shp(content, contentLength))
			return true;
		switch (contentLength) {
		case 1024:
			return this.#decodeBlazingPaddlesVectors(content, contentLength, 31744);
		case 4384:
			return this.#decodeGr7(content, 528, 3844);
		case 10018:
			return this.#decodeOcp(content, contentLength);
		default:
			return false;
		}
	}

	static #drawSpcChar(pixels, x1, y1, ch)
	{
		if (ch < 32 || ch > 95)
			return;
		let font = Fu.atari8_fnt;
		let fontOffset = (ch - 32) << 3;
		for (let y = 0; y < 8 && y1 + y < 192; y++) {
			for (let x = 0; x < 4 && x1 + x < 160; x++)
				pixels[(y1 + y) * 160 + x1 + x] = font[fontOffset + y] >> (6 - x * 2) & 3;
		}
	}

	static #drawSpcLine(pixels, x1, y1, x2, y2, color)
	{
		let dx = Math.abs(x2 - x1);
		let dy = Math.abs(y2 - y1);
		if (dx >= dy) {
			let e = dx;
			if (x2 < x1) {
				let ty = y1;
				x1 = x2;
				x2 += dx;
				y1 = y2;
				y2 = ty;
			}
			for (; x1 <= x2; x1++) {
				if (x1 < 160 && y1 < 192)
					pixels[160 * y1 + x1] = color;
				e -= dy * 2;
				if (e < 0) {
					e += dx * 2;
					y1 += y1 < y2 ? 1 : -1;
				}
			}
		}
		else {
			let e = dy;
			if (y2 < y1) {
				let tx = x1;
				x1 = x2;
				x2 = tx;
				y1 = y2;
				y2 += dy;
			}
			for (; y1 <= y2; y1++) {
				if (x1 < 160 && y1 < 192)
					pixels[160 * y1 + x1] = color;
				e -= dx * 2;
				if (e < 0) {
					e += dy * 2;
					x1 += x1 < x2 ? 1 : -1;
				}
			}
		}
	}

	static #plotSpcPattern(pixels, x, y, pattern)
	{
		pixels[y * 160 + x] = pattern >> (((~y & 1) << 3) + ((~x & 3) << 1)) & 3;
	}

	static #drawSpcBrush(pixels, x1, y1, brush, pattern)
	{
		for (let y = 0; y < 16 && y1 + y < 192; y++) {
			let brushShape = RECOIL.#DRAW_SPC_BRUSH_BRUSHES[brush * 16 + y];
			for (let x = 0; x < 8 && x1 + x < 160; x++) {
				if ((brushShape >> (7 - x) & 1) != 0)
					RECOIL.#plotSpcPattern(pixels, x, y, pattern);
			}
		}
	}

	static #fillSpc(pixels, x, y, pattern)
	{
		if (x >= 160 || y >= 192)
			return false;
		while (y >= 0 && pixels[y * 160 + x] == 0)
			y--;
		while (++y < 192 && pixels[y * 160 + x] == 0) {
			do
				x--;
			while (x >= 0 && pixels[y * 160 + x] == 0);
			let x1 = x;
			while (x < 159) {
				if (pixels[y * 160 + ++x] != 0)
					break;
				RECOIL.#plotSpcPattern(pixels, x, y, pattern);
			}
			x = x1 + ((x - x1 + 1) >> 1);
		}
		return true;
	}

	#decodeAtari8Spc(content, contentLength)
	{
		if (contentLength < 3 || contentLength != content[0] + (content[1] << 8) + 3 || content[contentLength - 1] != 0)
			return false;
		const pixels = new Uint8Array(30720);
		const lineColors = new Int32Array(96);
		let textX = 0;
		let textY = 0;
		let lineX = 0;
		let lineY = 0;
		let brush = 0;
		let pattern = 8840;
		let lineColor = 3;
		let x;
		let y;
		for (let contentOffset = 2; content[contentOffset] != 0;) {
			switch (content[contentOffset]) {
			case 16:
				if (contentOffset + 3 >= contentLength)
					return false;
				textX = content[contentOffset + 1];
				textY = content[contentOffset + 2];
				contentOffset += 3;
				break;
			case 32:
			case 33:
			case 34:
			case 35:
				if (contentOffset + 1 >= contentLength)
					return false;
				lineColor = content[contentOffset] & 3;
				contentOffset++;
				break;
			case 48:
			case 80:
				if (contentOffset + 2 >= contentLength)
					return false;
				RECOIL.#drawSpcChar(pixels, textX, textY, content[contentOffset + 1]);
				textX += 4;
				contentOffset += 2;
				break;
			case 64:
			case 65:
			case 66:
			case 67:
			case 68:
			case 69:
			case 70:
			case 71:
				if (contentOffset + 1 >= contentLength)
					return false;
				brush = content[contentOffset] & 7;
				contentOffset++;
				break;
			case 96:
				if (contentOffset + 2 >= contentLength)
					return false;
				pattern = content[contentOffset + 1];
				if (pattern >= 71)
					return false;
				pattern = RECOIL.#DECODE_ATARI8_SPC_PATTERNS[pattern];
				contentOffset += 2;
				break;
			case 112:
				if (contentOffset + 7 >= contentLength)
					return false;
				for (y = content[contentOffset + 1]; y <= content[contentOffset + 2]; y++) {
					if (y >= 96)
						return false;
					lineColors[y] = contentOffset + 3;
				}
				contentOffset += 7;
				break;
			case 128:
				if (contentOffset + 3 >= contentLength)
					return false;
				lineX = content[contentOffset + 1];
				lineY = content[contentOffset + 2];
				contentOffset += 3;
				break;
			case 160:
				if (contentOffset + 3 >= contentLength)
					return false;
				x = content[contentOffset + 1];
				y = content[contentOffset + 2];
				RECOIL.#drawSpcLine(pixels, lineX, lineY, x, y, lineColor);
				lineX = x;
				lineY = y;
				contentOffset += 3;
				break;
			case 192:
				if (contentOffset + 3 >= contentLength)
					return false;
				RECOIL.#drawSpcBrush(pixels, content[contentOffset + 1], content[contentOffset + 2], brush, pattern);
				contentOffset += 3;
				break;
			case 224:
				if (contentOffset + 3 >= contentLength)
					return false;
				if (!RECOIL.#fillSpc(pixels, content[contentOffset + 1], content[contentOffset + 2], pattern))
					return false;
				contentOffset += 3;
				break;
			default:
				return false;
			}
		}
		this.#setSize(320, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(61440);
		for (y = 0; y < 192; y++) {
			let colorsOffset = lineColors[y >> 1];
			let colors = colorsOffset == 0 ? RECOIL.#DECODE_ATARI8_SPC_DEFAULT_COLORS : content;
			for (x = 0; x < 160; x++) {
				let offset = y * 320 + x * 2;
				frame[offset + 1] = frame[offset] = colors[colorsOffset + pixels[y * 160 + x]] & 254;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	static #getMcmSprite(content, x, y)
	{
		if ((y & 7) == 0)
			return false;
		let b = content[11440 + RECOIL.#GET_MCM_SPRITE_OFFSETS[x >> 4] * 30 + (y >> 3)];
		return (b >> (RECOIL.#GET_MCM_SPRITE_BITS[x >> 4] ^ (x >> 3 & 1)) & 1) != 0;
	}

	#decodeMcm(content, contentLength)
	{
		if (contentLength != 11626)
			return false;
		this.#setSize(320, 240, RECOILResolution.XE2X1);
		const frame = new Uint8Array(76800);
		for (let y = 0; y < 240; y++) {
			for (let x = 0; x < 320; x++) {
				let ch = content[10240 + (y & ~7) * 5 + (x >> 3)];
				let c;
				switch (content[((y / 24 | 0) << 10) + ((ch & 127) << 3) + (y & 7)] >> (~x & 6) & 3) {
				case 0:
					c = content[RECOIL.#getMcmSprite(content, x, y) ? 11625 : 11620];
					break;
				case 1:
					c = content[11621];
					break;
				case 2:
					c = content[11622];
					break;
				case 3:
					c = content[11623 + (ch >> 7)];
					if (RECOIL.#getMcmSprite(content, x, y))
						c |= content[11625];
					break;
				default:
					throw new Error();
				}
				frame[y * 320 + x] = c & 254;
			}
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeHcm(content, contentLength)
	{
		if (contentLength != 8208 || !RECOIL.isStringAt(content, 0, "HCMA8") || content[5] != 1)
			return false;
		const gtia = new HcmRenderer();
		let leftSprite;
		switch (content[6]) {
		case 0:
			leftSprite = 2;
			gtia.prior = 0;
			break;
		case 2:
			leftSprite = 1;
			gtia.prior = 36;
			break;
		default:
			return false;
		}
		gtia.playerHpos[3] = gtia.playerHpos[3 - leftSprite] = 104;
		gtia.missileHpos[leftSprite] = gtia.missileHpos[0] = 136;
		gtia.missileHpos[3] = gtia.missileHpos[3 - leftSprite] = 144;
		for (let i = 0; i < 4; i++)
			gtia.missileSize[i] = gtia.playerSize[i] = 4;
		gtia.colors[8] = content[7] & 254;
		gtia.colors[3 - leftSprite] = gtia.colors[0] = content[8] & 254;
		gtia.colors[3] = gtia.colors[leftSprite] = content[9] & 254;
		gtia.colors[4] = content[10] & 254;
		gtia.colors[5] = content[11] & 254;
		gtia.colors[6] = content[12] & 254;
		gtia.content = content;
		gtia.playfieldColumns = 32;
		this.#setSize(256, 192, RECOILResolution.XE2X1);
		const frame = new Uint8Array(49152);
		for (let y = 0; y < 192; y++) {
			gtia.playerHpos[leftSprite] = gtia.playerHpos[0] = 72;
			gtia.processSpriteDma(content, 816 + y);
			gtia.startLine(64);
			gtia.drawSpan(y, 64, 128, AnticMode.FOUR_COLOR, frame, 256);
			gtia.playerHpos[leftSprite] = gtia.playerHpos[0] = 152;
			gtia.playerGraphics[0] = content[48 + y];
			gtia.playerGraphics[leftSprite] = content[304 + y];
			gtia.drawSpan(y, 128, 192, AnticMode.FOUR_COLOR, frame, 256);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodeGed(content, contentLength)
	{
		if (contentLength != 11302 || content[0] != 255 || content[1] != 255 || content[2] != 48 || content[3] != 83 || content[4] != 79 || content[5] != 127)
			return false;
		let cycle = content[3300];
		if (cycle > 7)
			return false;
		const gtia = new GedRenderer();
		GtiaRenderer.setSpriteSizes(gtia.missileSize, content[3291]);
		gtia.colors[7] = content[3293] & 254;
		gtia.colors[8] = content[3294] & 254;
		let prior = content[3292];
		gtia.prior = prior;
		for (let i = 0; i < 4; i++) {
			gtia.setPlayerSize(i, content[3290] >> ((3 - i) << 1));
			gtia.playerHpos[i] = (48 + content[3295 + i]) & 255;
			gtia.missileHpos[i] = ((prior & 16) == 0 ? gtia.playerHpos[i] + (gtia.playerSize[i] << 3) : i == 0 ? 48 + content[3299] : gtia.missileHpos[i - 1] + (gtia.missileSize[i - 1] << 1)) & 255;
			gtia.colors[i] = content[3286 + i] & 254;
		}
		gtia.content = content;
		gtia.playfieldColumns = 40;
		this.#setSize(320, 200, RECOILResolution.XE2X1);
		const frame = new Uint8Array(64000);
		for (let y = 0; y < 200; y++) {
			gtia.processSpriteDma(content, 2034 + y);
			gtia.poke(content[206 + y] & 31, content[6 + y]);
			gtia.colors[4] = content[406 + y] & 254;
			gtia.colors[5] = content[606 + y] & 254;
			gtia.colors[6] = content[806 + y] & 254;
			gtia.startLine(48);
			let hpos = gtia.drawSpan(y, 48, 63 + (cycle << 3), AnticMode.FOUR_COLOR, frame, 320);
			gtia.colors[4] = content[1006 + y] & 254;
			hpos = gtia.drawSpan(y, hpos, cycle < 4 ? hpos + 32 : 107 + (cycle << 2), AnticMode.FOUR_COLOR, frame, 320);
			gtia.colors[5] = content[1206 + y] & 254;
			hpos = gtia.drawSpan(y, hpos, 123 + (cycle << 2), AnticMode.FOUR_COLOR, frame, 320);
			gtia.colors[6] = content[1406 + y] & 254;
			hpos = gtia.drawSpan(y, hpos, hpos + 24, AnticMode.FOUR_COLOR, frame, 320);
			gtia.colors[4] = content[1606 + y] & 254;
			hpos = gtia.drawSpan(y, hpos, hpos + 24, AnticMode.FOUR_COLOR, frame, 320);
			gtia.colors[5] = content[1806 + y] & 254;
			gtia.drawSpan(y, hpos, 208, AnticMode.FOUR_COLOR, frame, 320);
		}
		return this.#applyAtari8Palette(frame);
	}

	#decodePgr(content, contentLength)
	{
		if (contentLength < 1776 || 6 + RECOIL.#parseAtari8ExecutableHeader(content, 0) != contentLength || content[2] != 6 || content[3] != 130 || !RECOIL.isStringAt(content, 8, "PowerGFX"))
			return false;
		const gtia = new PgrRenderer();
		for (let i = 0; i < 14; i++) {
			gtia.poke(i, content[504 + i]);
			gtia.poke(14 + i, content[760 + i]);
		}
		gtia.content = content;
		let dmaCtl = content[774];
		switch (dmaCtl & 243) {
		case 49:
			gtia.playfieldColumns = 32;
			break;
		case 50:
			gtia.playfieldColumns = 40;
			break;
		default:
			return false;
		}
		let dlOffset = 16;
		let rasterOffset = content[6] + (content[7] << 8) - 33280;
		if (rasterOffset < 1536)
			return false;
		gtia.screenOffset = -1;
		let a = 0;
		const frame = new Uint8Array(80640);
		let resolution = RECOILResolution.XE4X1;
		for (let y = 0; y < 240; y++) {
			let hpos = -11;
			let dlOp = content[dlOffset++];
			switch (dlOp) {
			case 0:
			case 14:
			case 15:
				break;
			case 65:
				dlOffset--;
				break;
			case 78:
			case 79:
				hpos += 4;
				gtia.screenOffset = content[dlOffset] + (content[dlOffset + 1] << 8) - 33280;
				dlOffset += 2;
				break;
			default:
				return false;
			}
			let anticMode;
			switch (dlOp & 15) {
			case 14:
				anticMode = AnticMode.FOUR_COLOR;
				if (resolution == RECOILResolution.XE4X1 && gtia.prior < 64)
					resolution = RECOILResolution.XE2X1;
				break;
			case 15:
				anticMode = AnticMode.HI_RES;
				if (gtia.prior < 64)
					resolution = RECOILResolution.XE1X1;
				break;
			default:
				anticMode = AnticMode.BLANK;
				break;
			}
			if (anticMode != AnticMode.BLANK && (gtia.screenOffset < 1536 || gtia.screenOffset + 40 > contentLength))
				return false;
			gtia.startLine(44);
			if ((dmaCtl & 12) != 0) {
				hpos += 2;
				if ((dmaCtl & 4) != 0)
					gtia.missileGraphics = content[264 + y];
				if ((dmaCtl & 8) != 0) {
					hpos += 8;
					gtia.processPlayerDma(content, 520 + y);
				}
			}
			for (let cpuCycles = 1;;) {
				if (rasterOffset >= contentLength)
					return false;
				let rasterOp = content[rasterOffset++];
				if ((rasterOp & 32) != 0) {
					if (rasterOffset >= contentLength)
						return false;
					cpuCycles += 2;
					a = content[rasterOffset++];
				}
				let addr = rasterOp & 31;
				if (addr <= 27) {
					let untilHpos = gtia.advanceCpuCycles(hpos, cpuCycles, anticMode != AnticMode.BLANK);
					gtia.drawSpan(y, hpos >= 44 ? hpos : 44, untilHpos < 212 ? untilHpos : 212, anticMode, frame, 336);
					hpos = untilHpos;
					gtia.poke(addr, a);
					if (rasterOp >= 128)
						break;
					cpuCycles = 4;
				}
				else {
					let nops = (rasterOp >> 6 & 3) | (rasterOp & 3) << 2;
					if (nops == 0)
						break;
					cpuCycles += nops << 1;
				}
			}
			gtia.drawSpan(y, hpos >= 44 ? hpos : 44, 212, anticMode, frame, 336);
			if (anticMode != AnticMode.BLANK)
				gtia.screenOffset += gtia.playfieldColumns;
		}
		this.#setSize(336, 240, resolution);
		return this.#applyAtari8Palette(frame);
	}

	static #hasG2fRaster(content, contentOffset, count, hitClr)
	{
		do {
			switch (content[contentOffset]) {
			case 0:
			case 1:
			case 2:
			case 3:
			case 65:
			case 66:
			case 67:
			case 97:
			case 98:
			case 99:
				break;
			case 129:
			case 130:
			case 131:
				if (content[contentOffset + 1] != hitClr)
					return true;
				break;
			default:
				return true;
			}
			contentOffset += 2;
		}
		while (--count > 0);
		return false;
	}

	#decodeMch(content, contentLength)
	{
		let columns;
		switch (contentLength) {
		case 9840:
		case 28673:
			columns = 32;
			break;
		case 12000:
		case 30833:
			columns = 40;
			break;
		case 14160:
		case 32993:
			columns = 48;
			break;
		default:
			return false;
		}
		let bitmapLength = columns * 270;
		let sprites = contentLength > bitmapLength + 1200;
		let anticMode;
		switch (content[0] & 3) {
		case 0:
			if (sprites && RECOIL.#hasG2fRaster(content, bitmapLength + 6080, 6960, 30))
				return false;
			anticMode = AnticMode.FIVE_COLOR;
			break;
		case 1:
			anticMode = AnticMode.FIVE_COLOR;
			break;
		case 2:
			if (sprites && RECOIL.#hasG2fRaster(content, bitmapLength + 6080, 6960, 30))
				return false;
			anticMode = AnticMode.FOUR_COLOR;
			break;
		default:
			return false;
		}
		let resolution;
		let gtiaMode = 0;
		switch (content[0] & 60) {
		case 0:
			anticMode = AnticMode.HI_RES;
			resolution = RECOILResolution.XE1X1;
			break;
		case 4:
			resolution = RECOILResolution.XE2X1;
			break;
		case 8:
			anticMode = AnticMode.HI_RES;
			resolution = RECOILResolution.XE4X1;
			gtiaMode = 64;
			break;
		case 24:
			anticMode = AnticMode.HI_RES;
			resolution = RECOILResolution.XE4X1;
			gtiaMode = 128;
			break;
		case 40:
			anticMode = AnticMode.HI_RES;
			resolution = RECOILResolution.XE4X1;
			gtiaMode = 192;
			break;
		default:
			return false;
		}
		this.#setSize(336, 240, resolution);
		const frame = new Uint8Array(80640);
		const gtia = new MchRenderer();
		gtia.playerHpos.fill(0);
		gtia.missileHpos.fill(0);
		gtia.colors.fill(0);
		gtia.prior = gtiaMode;
		gtia.content = content;
		gtia.playfieldColumns = columns;
		gtia.dliPlus = false;
		for (let i = 0; i < bitmapLength; i += 9) {
			if ((content[i] & 64) != 0) {
				gtia.dliPlus = true;
				break;
			}
		}
		for (let y = 0; y < 240; y++) {
			let colorsOffset = bitmapLength + y;
			gtia.setG2fColors(colorsOffset, 240, sprites ? 9 : 5, gtiaMode);
			if (sprites) {
				for (let i = 0; i < 4; i++) {
					gtia.playerHpos[i] = content[colorsOffset + (9 + i) * 240];
					gtia.missileHpos[i] = content[colorsOffset + (13 + i) * 240];
				}
				GtiaRenderer.setSpriteSizes(gtia.playerSize, content[colorsOffset + 4080]);
				GtiaRenderer.setSpriteSizes(gtia.missileSize, content[colorsOffset + 4320]);
				gtia.prior = gtiaMode | content[colorsOffset + 4560];
				gtia.processSpriteDma(content, colorsOffset + 4800);
			}
			gtia.startLine(44);
			gtia.drawSpan(y, 44, 212, anticMode, frame, 336);
		}
		return this.#applyAtari8Palette(frame);
	}

	static #g2fHasRaster(content, contentOffset)
	{
		return RECOIL.#hasG2fRaster(content, contentOffset, 2880, content[0] < 128 ? 22 : 30);
	}

	#decodeG2fUnpacked(content, contentLength, frame, yOffset)
	{
		if (contentLength < 155711)
			return false;
		let columns = content[0] & 127;
		switch (columns) {
		case 32:
		case 40:
		case 48:
			break;
		default:
			return false;
		}
		let fontsOffset = 3 + 30 * columns;
		let fontNumberOffset = fontsOffset + (((content[2] & 127) + 1) << 10);
		if (contentLength < fontNumberOffset + 153724)
			return false;
		let charMode;
		let vbxeOffset = fontNumberOffset + 155231;
		let inverse2Offset = -1;
		switch (content[fontNumberOffset + 147679] & 127) {
		case 1:
			if (RECOIL.#g2fHasRaster(content, fontNumberOffset + 147934))
				return false;
			charMode = true;
			break;
		case 2:
			charMode = true;
			break;
		case 3:
			if (RECOIL.#g2fHasRaster(content, fontNumberOffset + 147934))
				return false;
			charMode = false;
			break;
		case 66:
			charMode = true;
			inverse2Offset = vbxeOffset + 138244;
			if (contentLength < inverse2Offset + 30 * columns)
				return false;
			break;
		default:
			return false;
		}
		if (contentLength < vbxeOffset + 138243)
			vbxeOffset = -1;
		else {
			switch (content[vbxeOffset]) {
			case 0:
				vbxeOffset = -1;
				break;
			case 1:
				if (content[vbxeOffset + 1] != 8 || content[vbxeOffset + 2] == 0)
					return false;
				this.#resolution = RECOILResolution.VBXE2X1;
				break;
			default:
				return false;
			}
		}
		const gtia = Object.assign(new G2fRenderer(), { content: content, playfieldColumns: columns, inverse2Offset: inverse2Offset, vbxeOffset: vbxeOffset });
		for (let y = 0; y < 240; y++) {
			let row = y >> 3;
			gtia.fontOffset = fontsOffset + ((content[fontNumberOffset + row] & 127) << 10);
			if (gtia.fontOffset >= fontNumberOffset)
				return false;
			let spriteOffset = fontNumberOffset + 2334 + (y << 1);
			let prior = content[spriteOffset + 1] >> 4 & 7;
			if (prior >= 5)
				return false;
			prior = RECOIL.#DECODE_G2F_UNPACKED_PRIORS[prior] | (content[spriteOffset + 1025] & 48);
			let anticMode;
			switch (content[fontNumberOffset + 153694 + row]) {
			case 1:
				this.#resolution = this.#resolution == RECOILResolution.VBXE2X1 || this.#resolution == RECOILResolution.VBXE1X1 ? RECOILResolution.VBXE1X1 : RECOILResolution.XE1X1;
				anticMode = AnticMode.HI_RES;
				break;
			case 2:
				if (this.#resolution == RECOILResolution.XE4X1)
					this.#resolution = RECOILResolution.XE2X1;
				anticMode = charMode ? AnticMode.FIVE_COLOR : AnticMode.FOUR_COLOR;
				break;
			case 4:
				prior |= RECOIL.#DECODE_G2F_UNPACKED_GTIA_MODES[content[1] & 7];
				anticMode = AnticMode.HI_RES;
				break;
			case 255:
				anticMode = AnticMode.BLANK;
				break;
			default:
				return false;
			}
			let colorsOffset = fontNumberOffset + 30 + y;
			gtia.setG2fColors(colorsOffset, 256, 9, prior);
			let missileGraphics = 0;
			for (let i = 0; i < 4; i++) {
				if (!G2fRenderer.setSprite(gtia.playerHpos, gtia.playerSize, i, content, spriteOffset) || !G2fRenderer.setSprite(gtia.missileHpos, gtia.missileSize, i, content, spriteOffset + 512))
					return false;
				gtia.playerGraphics[i] = content[colorsOffset + 6400 + (i << 9)];
				missileGraphics |= content[colorsOffset + 6656 + (i << 9)] >> 6 << (i << 1);
			}
			gtia.missileGraphics = missileGraphics;
			gtia.prior = prior;
			gtia.startLine(44);
			gtia.drawSpan(y, 44, 212, anticMode, frame, 336, yOffset);
		}
		return true;
	}

	#decodeG2fFrame(content, contentLength, frame, yOffset)
	{
		if (contentLength < 11)
			return false;
		if (RECOIL.isStringAt(content, 0, "G2FZLIB")) {
			let unpacked = new Uint8Array(327078);
			const stream = Object.assign(new InflateStream(), { content: content, contentOffset: 7, contentLength: contentLength });
			contentLength = stream.uncompress(unpacked, 327078);
			return this.#decodeG2fUnpacked(unpacked, contentLength, frame, yOffset);
		}
		return this.#decodeG2fUnpacked(content, contentLength, frame, yOffset);
	}

	#decodeG2f(content, contentLength)
	{
		const frame = new Uint8Array(80640);
		this.#resolution = RECOILResolution.XE4X1;
		if (!this.#decodeG2fFrame(content, contentLength, frame, 0))
			return false;
		this.#setSize(336, 240, this.#resolution);
		return this.#applyAtari8Palette(frame);
	}

	#decodeVsc(vscFilename, content, contentLength)
	{
		const s = Object.assign(new Stream(), { content: content, contentOffset: 0, contentLength: contentLength });
		let height = 0;
		for (;;) {
			let c = s.readByte();
			if (c < 0)
				break;
			switch (c) {
			case 13:
				if (s.readByte() != 10)
					return false;
				height += 240;
				break;
			case 47:
			case 58:
			case 92:
				return false;
			default:
				if (c < 32 || c > 126)
					return false;
				break;
			}
		}
		let frame = new Uint8Array(336 * height);
		let g2f = new Uint8Array(327078);
		s.contentOffset = 0;
		this.#resolution = RECOILResolution.XE4X1;
		for (height = 0;; height += 240) {
			let filenameOffset = s.contentOffset;
			if (!s.skipUntilByte(10))
				break;
			let filename = new TextDecoder().decode(content.subarray(filenameOffset, filenameOffset + s.contentOffset - 2 - filenameOffset));
			contentLength = this.#readSiblingFile(vscFilename, filename, g2f, 327078);
			if (!this.#decodeG2fFrame(g2f, contentLength, frame, height))
				return false;
		}
		return this.#setSize(336, height, this.#resolution) && this.#applyAtari8Palette(frame);
	}

	#decodeDap(content, contentLength)
	{
		if (contentLength != 77568)
			return false;
		this.#setSize(320, 240, RECOILResolution.VBXE1X1);
		for (let i = 0; i < 256; i++)
			this.contentPalette[i] = content[76800 + i] << 16 | content[77056 + i] << 8 | content[77312 + i];
		this.#decodeBytes(content, 0);
		return true;
	}

	#decodeTandyPnt(content, contentLength)
	{
		if (contentLength < 236 || content[0] != 19 || content[1] != 80 || content[2] != 78 || content[3] != 84)
			return false;
		this.#setSize(312, 176, RECOILResolution.TANDY1X1);
		if (contentLength == 27478) {
			this.contentPalette.set(RECOIL.#DECODE_TANDY_PNT_PALETTE);
			this.#decodeNibbles(content, 22, 156);
			return true;
		}
		let contentOffset = 22;
		let repeatCount = 1;
		let repeatValue = 0;
		for (let pixelsOffset = 0; pixelsOffset < 54912; pixelsOffset += 2) {
			if (--repeatCount == 0) {
				if (contentOffset + 1 >= contentLength)
					return false;
				repeatCount = content[contentOffset + 1];
				if (repeatCount == 0)
					return false;
				repeatValue = content[contentOffset];
				contentOffset += 2;
			}
			this.#pixels[pixelsOffset] = RECOIL.#DECODE_TANDY_PNT_PALETTE[repeatValue >> 4];
			this.#pixels[pixelsOffset + 1] = RECOIL.#DECODE_TANDY_PNT_PALETTE[repeatValue & 15];
		}
		return contentOffset == contentLength;
	}

	#decodeHs2(content, contentLength)
	{
		if (contentLength % 105 != 0)
			return false;
		return this.#setSize(840, contentLength / 105 | 0, RECOILResolution.PC1X1) && this.#decodeBlackAndWhite(content, 0, contentLength, false, 0);
	}

	#decodeImage72Fnt(content, contentLength)
	{
		if (contentLength < 4 || content[0] != 0 || content[1] != 8)
			return false;
		let fontHeight = content[2];
		if (contentLength != 3 + (fontHeight << 8))
			return false;
		this.#setSize(256, fontHeight << 3, RECOILResolution.PC1X1);
		this.#decodeBlackAndWhiteFont(content, 3, contentLength, fontHeight);
		return true;
	}

	#decodeMsp(content, contentLength)
	{
		if (contentLength < 32)
			return false;
		let width = content[4] | content[5] << 8;
		let height = content[6] | content[7] << 8;
		if (RECOIL.isStringAt(content, 0, "DanM"))
			return this.#setSize(width, height, RECOILResolution.PC1X1) && this.#decodeBlackAndWhite(content, 32, contentLength, false, 0);
		if (RECOIL.isStringAt(content, 0, "LinS") && this.#setSize(width, height, RECOILResolution.PC1X1)) {
			const rle = Object.assign(new MspStream(), { content: content, contentOffset: 32 + (height << 1), contentLength: contentLength });
			return this.#decodeRleBlackAndWhite(rle, 0);
		}
		return false;
	}

	#decodeAwbmPalette(content, contentLength, paletteOffset, colors)
	{
		if (contentLength < paletteOffset + 4 + colors * 3 || !RECOIL.isStringAt(content, paletteOffset, "RGB "))
			return false;
		for (let i = 0; i < colors; i++) {
			let rgb = RECOIL.#getR8G8B8Color(content, paletteOffset + 4 + i * 3);
			this.contentPalette[i] = (rgb & 4144959) << 2 | (rgb >> 4 & 197379);
		}
		return true;
	}

	#decodeAwbm(content, contentLength)
	{
		let width = content[4] | content[5] << 8;
		let height = content[6] | content[7] << 8;
		if (!this.#setSize(width, height, RECOILResolution.PC1X1))
			return false;
		if (this.#decodeAwbmPalette(content, contentLength, 8 + width * height, 256)) {
			this.#decodeBytes(content, 8);
			return true;
		}
		let planeStride = (width + 7) >> 3;
		if (!this.#decodeAwbmPalette(content, contentLength, 8 + (height * planeStride << 2), 16))
			return false;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++)
				this.#pixels[y * width + x] = this.contentPalette[RECOIL.#getBitplanePixel(content, 8 + (y * planeStride << 2) + (x >> 3), x, 4, planeStride)];
		}
		return true;
	}

	static #CGA_PALETTE = new Int32Array([ 0, 170, 43520, 43690, 11141120, 11141290, 11162880, 11184810, 5592405, 5592575, 5635925, 5636095, 16733525, 16733695, 16777045, 16777215 ]);

	#decodeEpa(content, contentLength)
	{
		if (contentLength < 17)
			return false;
		if (RECOIL.isStringAt(content, 0, "AWBM"))
			return this.#decodeAwbm(content, contentLength);
		let columns = content[0];
		let rows = content[1];
		if (columns > 80 || rows > 25 || contentLength != 2 + columns * rows * 15 + 70)
			return false;
		let width = columns * 8;
		let height = rows * 14;
		this.#setSize(width, height, RECOILResolution.PC1X1);
		let bitmapOffset = 2 + columns * rows;
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let ch = (y / 14 | 0) * columns + (x >> 3);
				let attribute = content[2 + ch];
				let b = content[bitmapOffset + ch * 14 + y % 14] >> (~x & 7) & 1;
				this.#pixels[y * width + x] = RECOIL.#CGA_PALETTE[b == 0 ? attribute >> 4 : attribute & 15];
			}
		}
		return true;
	}

	#decodeBkMono(content, height)
	{
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < 512; x++) {
				let c = content[(y >> 1 << 6) + (x >> 3)] >> (x & 7) & 1;
				if (c != 0)
					c = 16777215;
				this.#pixels[(y << 9) + x] = c;
			}
		}
	}

	#decodeBkColorFrame(content, paletteOffset, frame)
	{
		paletteOffset <<= 2;
		for (let i = 0; i < 65536; i++) {
			this.#pixels[(frame << 16) + i] = RECOIL.#DECODE_BK_COLOR_FRAME_PALETTE[paletteOffset + (content[(frame << 14) + (i >> 2)] >> ((i & 3) << 1) & 3)];
		}
	}

	#decodeBkColor(content, palette)
	{
		this.#setSize(256, 256, RECOILResolution.BK1X1);
		this.#decodeBkColorFrame(content, palette, 0);
		return true;
	}

	#decodeBks(content, contentLength)
	{
		switch (contentLength) {
		case 16384:
			if (!this.#setSize(512, 512, RECOILResolution.BK1X2))
				return false;
			this.#decodeBkMono(content, 512);
			return true;
		case 16385:
			let palette = content[16384];
			if (palette > 15)
				return false;
			return this.#decodeBkColor(content, palette);
		case 32768:
			if (!this.#setSize(512, 512, RECOILResolution.BK1X2, 2))
				return false;
			this.#decodeBkMono(content, 1024);
			return this.#applyBlend();
		case 32770:
			let palette1 = content[32768];
			let palette2 = content[32769];
			if (palette1 > 15 || palette2 > 15)
				return false;
			this.#setSize(256, 256, RECOILResolution.BK1X1, 2);
			this.#decodeBkColorFrame(content, palette1, 0);
			this.#decodeBkColorFrame(content, palette2, 1);
			return this.#applyBlend();
		default:
			return false;
		}
	}

	#decodeVectorSpr(content, contentLength)
	{
		const rle = Object.assign(new VectorSprStream(), { content: content, contentOffset: contentLength });
		const unpacked = new Uint8Array(32768);
		if (!rle.unpack(unpacked, 0, 1, 32768))
			return false;
		for (let i = 0; i < 16; i++) {
			let c = content[i];
			this.contentPalette[i] = (c & 7) * 73 >> 1 << 16 | (c >> 3 & 7) * 72 >> 1 << 8 | (c >> 6) * 85;
		}
		this.#setSize(256, 256, RECOILResolution.VECTOR1X1);
		for (let y = 0; y < 256; y++) {
			for (let x = 0; x < 256; x++)
				this.#pixels[(y << 8) + x] = this.contentPalette[RECOIL.#getBitplanePixel(unpacked, (31 - (x >> 3)) << 8 | y, x, 4, 8192)];
		}
		return true;
	}

	#decodePi9(content, contentLength)
	{
		switch (contentLength) {
		case 7684:
		case 7808:
		case 7936:
			return this.#decodeGr9(content, 7680);
		case 7720:
			return this.#decodeApc(content, contentLength);
		default:
			return this.#decodeFuckpaint(content, contentLength);
		}
	}

	static #isPaint256(filename)
	{
		let i = filename.length - 10;
		if (i < 0)
			return false;
		if (i > 0 && filename.charCodeAt(i - 1) != 47 && filename.charCodeAt(i - 1) != 92)
			return false;
		return (filename.charCodeAt(i) | 32) == 112 && (filename.charCodeAt(i + 1) | 32) == 97 && (filename.charCodeAt(i + 2) | 32) == 105 && (filename.charCodeAt(i + 3) | 32) == 110 && (filename.charCodeAt(i + 4) | 32) == 116 && filename.charCodeAt(i + 5) != 47 && filename.charCodeAt(i + 5) != 92;
	}

	#decodePic(filename, content, contentLength)
	{
		if (this.#decodePsion3Pic(content, contentLength) || this.#decodeX68KPic(content, contentLength) || this.#decodeAtari8Koala(content, 0, contentLength))
			return true;
		switch (contentLength) {
		case 3325:
			return this.#decodeVisualizer(content);
		case 4325:
			return this.#decodeGad(content, contentLength);
		case 7680:
			return RECOIL.#isPaint256(filename) ? this.#decode256(content, contentLength) : this.#decodeGr8(content, contentLength);
		case 7681:
		case 7682:
		case 7683:
		case 7684:
		case 7685:
			return this.#decodeMic(null, content, contentLength);
		case 16384:
			return this.#decodeBkColor(content, 0);
		case 32000:
			return this.#decodeDoo(content, contentLength);
		case 32768:
			return this.#decodeAppleIIShr(content, contentLength);
		default:
			return this.#decodeStPi(content, contentLength) || this.#decodeSc8(null, content, contentLength);
		}
	}

	#decodeScr(filename, content, contentLength)
	{
		switch (contentLength) {
		case 960:
			return this.#decodeGr0(content, contentLength);
		case 1002:
			return this.#decodeScrCol(filename, content, contentLength);
		case 6144:
			this.#setZx(RECOILResolution.SPECTRUM1X1);
			this.#decodeZx(content, 0, -1, -3, 0);
			return true;
		case 6160:
			return this.#decodeAmstradScr(filename, content, contentLength) || this.#decodeRad(content, contentLength);
		case 6912:
		case 6913:
			this.#setZx(RECOILResolution.SPECTRUM1X1);
			this.#decodeZx(content, 0, 6144, 3, 0);
			return true;
		case 6976:
			this.#setUlaPlus(RECOILResolution.SPECTRUM_ULA_PLUS1X1, content, 6912, 64);
			this.#decodeZx(content, 0, 6144, 3, 0);
			return true;
		case 12288:
			return this.#decodeThc(content, contentLength);
		case 12289:
			return this.#decodeThr(content, contentLength);
		case 12352:
			return this.#decodeTcu(content, contentLength);
		case 13824:
			return this.#decodeGsc(content, contentLength);
		case 13825:
			return this.#decodeSkl(content, contentLength);
		case 15360:
			return this.#decodeHrc(content, contentLength);
		case 15456:
			return this.#decodeHrx(content, contentLength);
		case 16000:
			if (this.#decodeAmstradScr(filename, content, contentLength))
				return true;
			this.#setSize(640, 400, RECOILResolution.MC05151X2);
			this.contentPalette[0] = 0;
			this.contentPalette[1] = 16777215;
			this.#decodeScaledBitplanes(content, 0, 640, 200, 1, false, null);
			return true;
		case 30720:
			return this.#decodeHgs(content, contentLength);
		case 30721:
			return this.#decodeHkl(content, contentLength);
		case 30913:
			return this.#decodeXkl(content, contentLength);
		case 32768:
			return this.#decodeAppleIIShr(content, contentLength);
		default:
			return this.#decodeAmstradScr(filename, content, contentLength);
		}
	}

	#decodeFlfFont(content, contentOffset, contentLength, columns, rows, resolution, palette, colors, xMask, cMask)
	{
		if (contentLength != contentOffset + columns * rows * 12)
			return false;
		let width = columns << 3;
		let height = rows << 3;
		this.#setSize(width, height, resolution);
		for (let y = 0; y < height; y++) {
			for (let x = 0; x < width; x++) {
				let offset = contentOffset + ((y >> 3) * columns + (x >> 3)) * 12;
				let c = content[offset + (y & 7)] >> (x & xMask) & cMask;
				c = content[offset + 8 + c];
				if (c >= colors)
					return false;
				this.#pixels[y * width + x] = palette[c];
			}
		}
		return true;
	}

	#decodeFlfBytes(content, contentLength)
	{
		let colorsOffset = 14 + 320 * this.#height;
		if (contentLength < colorsOffset + 6)
			return false;
		let colors = content[colorsOffset - 1];
		if (colors == 0)
			colors = 256;
		switch (contentLength - colorsOffset - colors * 3) {
		case 0:
		case 256:
			break;
		default:
			return false;
		}
		RECOIL.#decodeR8G8B8Colors(content, colorsOffset, colors, this.contentPalette, 0);
		this.#decodeBytes(content, 13);
		return true;
	}

	#decodeFlf(content, contentLength)
	{
		if (contentLength < 20 || !RECOIL.isStringAt(content, 0, "FLUFF64"))
			return false;
		this.contentPalette.fill(0);
		switch (content[11]) {
		case 1:
			return this.#decodeFlfFont(content, 15, contentLength, 40, 25, RECOILResolution.C642X1, this.#c64Palette, 16, 6, 3);
		case 4:
		case 5:
			return this.#decodeFlfFont(content, 18, contentLength, 40, 25, RECOILResolution.C642X1, this.#c64Palette, 16, 6, 3);
		case 6:
			return this.#decodeFlfFont(content, 18, contentLength, 40, 25, RECOILResolution.C641X1, this.#c64Palette, 16, 7, 1);
		case 7:
			let columns = content[15];
			let rows = content[16];
			let length = columns * rows;
			return contentLength >= 45 + (length << 1) && this.#decodePetScreen(content, 29 + length, 29, content[13], columns, rows);
		case 9:
			if (content[12] != 6)
				return false;
			return this.#decodeFlfFont(content, 20, contentLength, content[18], content[19], RECOILResolution.VIC202X1, RECOIL.#VIC20_PALETTE, 8, 6, 3);
		case 11:
			if (contentLength != 64269)
				return false;
			let c;
			switch (content[12]) {
			case 2:
				c = 1;
				break;
			case 3:
				c = 9;
				break;
			case 4:
				c = 0;
				break;
			case 5:
				c = 8;
				break;
			default:
				return false;
			}
			this.contentPalette[1] = RECOIL.#CGA_PALETTE[c + 2];
			this.contentPalette[2] = RECOIL.#CGA_PALETTE[c + 4];
			this.contentPalette[3] = RECOIL.#CGA_PALETTE[c + 6];
			this.#setSize(320, 200, RECOILResolution.PC1X1);
			this.#decodeBytes(content, 13);
			return true;
		case 12:
			this.#setSize(320, 200, RECOILResolution.AMIGA1X1);
			return this.#decodeFlfBytes(content, contentLength);
		case 13:
			this.#setSize(320, 256, RECOILResolution.AMIGA1X1);
			return this.#decodeFlfBytes(content, contentLength);
		case 22:
			this.#setSize(320, 200, RECOILResolution.ST1X1);
			return this.#decodeFlfBytes(content, contentLength);
		case 24:
			if (content[12] != 11 || contentLength != 32269)
				return false;
			this.#setAmstradFirmwarePalette(content, 32205, 16);
			this.#setSize(320, 200, RECOILResolution.AMSTRAD2X1);
			this.#decodeBytes(content, 13);
			return true;
		case 25:
			if (content[12] != 11 || contentLength < 282)
				return false;
			let width = RECOIL.get32LittleEndian(content, 13);
			let height = RECOIL.get32LittleEndian(content, 17);
			if (RECOIL.get32LittleEndian(content, 21) != 0 || !this.#setSize(width << 1, height, RECOILResolution.AMSTRAD2X1) || contentLength != 281 + width * height)
				return false;
			this.#setAmstradFirmwarePalette(content, contentLength - 64, 16);
			this.#decodeBytes(content, 25);
			return true;
		case 26:
			if (content[12] != 12)
				return false;
			switch (content[13]) {
			case 4:
				if (contentLength != 82190)
					return false;
				this.contentPalette[1] = 16777215;
				this.#setSize(320, 256, RECOILResolution.BBC1X1);
				this.#decodeBytes(content, 13);
				return true;
			case 5:
				if (contentLength != 41230)
					return false;
				this.contentPalette.set(RECOIL.#BBC_PALETTE2_BIT);
				this.#setSize(320, 256, RECOILResolution.BBC2X1);
				this.#decodeBytes(content, 13);
				return true;
			default:
				return false;
			}
		case 27:
			this.#setSize(320, 200, RECOILResolution.PC1X1);
			return this.#decodeFlfBytes(content, contentLength);
		case 28:
			if (content[12] != 14 || contentLength < 49165)
				return false;
			this.#setZx(RECOILResolution.SPECTRUM1X1);
			this.#decodeBytes(content, 13);
			return true;
		default:
			return false;
		}
	}

	/**
	 * Checks whether the filename extension is supported by RECOIL.
	 * <code>true</code> doesn't necessarily mean that the file contents is valid for RECOIL.
	 * With this function you can avoid reading files which are known to be unsupported.
	 * @param filename Name of the file to be checked.
	 */
	static isOurFile(filename)
	{
		switch (RECOIL.#getPackedExt(filename)) {
		case 540423474:
		case 538976307:
		case 825242163:
		case 544498228:
		case 543780148:
		case 543977524:
		case 544043060:
		case 540423221:
		case 543372342:
		case 538976353:
		case 544355425:
		case 540292705:
		case 543648119:
		case 544432481:
		case 543715433:
		case 543519336:
		case 543908449:
		case 544432993:
		case 543975009:
		case 544237409:
		case 544434017:
		case 543976545:
		case 543780193:
		case 540175969:
		case 540307041:
		case 540372577:
		case 540176481:
		case 540242017:
		case 544632929:
		case 543778660:
		case 544237412:
		case 543388517:
		case 543386729:
		case 544045680:
		case 543256673:
		case 543387745:
		case 544042096:
		case 543977569:
		case 544239713:
		case 544436321:
		case 544502369:
		case 544633441:
		case 544371809:
		case 544679522:
		case 544702306:
		case 540041826:
		case 540107362:
		case 540172898:
		case 540303970:
		case 540369506:
		case 543646306:
		case 544039522:
		case 544236642:
		case 543975010:
		case 1768711778:
		case 540632930:
		case 540618855:
		case 544237410:
		case 543975778:
		case 543648610:
		case 544435042:
		case 1937076834:
		case 538996841:
		case 1952672112:
		case 540109922:
		case 540175458:
		case 540240994:
		case 543452258:
		case 543976802:
		case 543648870:
		case 538996834:
		case 540110946:
		case 540176482:
		case 540307554:
		case 540438626:
		case 540569698:
		case 540094563:
		case 540160099:
		case 540291171:
		case 540422243:
		case 540553315:
		case 540422499:
		case 540291683:
		case 540160867:
		case 543977570:
		case 544567906:
		case 538997602:
		case 538993255:
		case 538994544:
		case 543388514:
		case 878931298:
		case 544240482:
		case 540107107:
		case 540172643:
		case 540238179:
		case 543777635:
		case 544564323:
		case 540108131:
		case 540173667:
		case 540239203:
		case 543974755:
		case 1768711779:
		case 544761699:
		case 539256931:
		case 540305507:
		case 540436579:
		case 540567651:
		case 543516771:
		case 544368739:
		case 544434275:
		case 544761955:
		case 544106851:
		case 543517795:
		case 544238691:
		case 540372323:
		case 544238947:
		case 543977315:
		case 540242019:
		case 543780963:
		case 544370787:
		case 544501859:
		case 543650403:
		case 544044131:
		case 544503139:
		case 543651683:
		case 540303716:
		case 544235876:
		case 540107620:
		case 538993764:
		case 544236644:
		case 544499048:
		case 543715442:
		case 543974756:
		case 540108644:
		case 1919379556:
		case 544368740:
		case 544106852:
		case 544500068:
		case 544042084:
		case 543977316:
		case 543450466:
		case 543451510:
		case 544173924:
		case 543715428:
		case 543650404:
		case 543978084:
		case 544238692:
		case 544895588:
		case 544240228:
		case 540112228:
		case 544175460:
		case 540177764:
		case 543449701:
		case 543777637:
		case 544236389:
		case 543386981:
		case 543256677:
		case 543716197:
		case 544043877:
		case 543259237:
		case 540031078:
		case 543777382:
		case 544236390:
		case 544501862:
		case 540173414:
		case 543450470:
		case 543975014:
		case 1768711782:
		case 543516518:
		case 543583334:
		case 543779942:
		case 544042086:
		case 540175974:
		case 544501350:
		case 538996838:
		case 540176486:
		case 544370790:
		case 543388774:
		case 543978854:
		case 544109926:
		case 543258470:
		case 538976359:
		case 540029287:
		case 540094823:
		case 543568487:
		case 543308135:
		case 544422247:
		case 543450739:
		case 543450471:
		case 543319655:
		case 538994535:
		case 543647847:
		case 543648103:
		case 540372071:
		case 540371059:
		case 540437607:
		case 540436595:
		case 540503143:
		case 540502131:
		case 540568679:
		case 540567667:
		case 543255655:
		case 543321191:
		case 543254643:
		case 543320179:
		case 543386727:
		case 544435303:
		case 543453031:
		case 538997351:
		case 538997603:
		case 540045927:
		case 543388513:
		case 540111463:
		case 540176999:
		case 540242535:
		case 540504679:
		case 540570215:
		case 540635751:
		case 1882813031:
		case 543322727:
		case 544174695:
		case 543584871:
		case 544240231:
		case 544764519:
		case 538997607:
		case 1936157033:
		case 543896115:
		case 543388519:
		case 544109927:
		case 544039272:
		case 544039528:
		case 544434022:
		case 544108397:
		case 543449959:
		case 543318888:
		case 544039784:
		case 543450472:
		case 543385192:
		case 543450728:
		case 543319912:
		case 543713128:
		case 543975272:
		case 544368488:
		case 544434024:
		case 544041320:
		case 544237928:
		case 544369000:
		case 543517800:
		case 543583336:
		case 543517032:
		case 543976296:
		case 544369768:
		case 543387752:
		case 543780968:
		case 544043112:
		case 544436328:
		case 538997352:
		case 540177000:
		case 543777640:
		case 543388264:
		case 543650408:
		case 544043624:
		case 544436840:
		case 544764520:
		case 540177256:
		case 540238441:
		case 543777385:
		case 540107625:
		case 540173161:
		case 540238697:
		case 543515497:
		case 544105321:
		case 543581801:
		case 1835164513:
		case 1835099490:
		case 544498532:
		case 1987339108:
		case 1885693284:
		case 538997348:
		case 913138024:
		case 946692456:
		case 544039532:
		case 1835166825:
		case 538996845:
		case 945973106:
		case 1851942770:
		case 1835100275:
		case 543975017:
		case 543516521:
		case 543516777:
		case 544041321:
		case 543452265:
		case 543517801:
		case 544435305:
		case 538996073:
		case 543649129:
		case 1735223668:
		case 1735223672:
		case 544107881:
		case 1868983913:
		case 543649385:
		case 544239209:
		case 544435817:
		case 544501353:
		case 540176489:
		case 543387753:
		case 544501865:
		case 543519340:
		case 540177001:
		case 543650409:
		case 543716201:
		case 544043881:
		case 544502633:
		case 544237418:
		case 538995306:
		case 544761451:
		case 543451499:
		case 543255659:
		case 543256427:
		case 544043122:
		case 544370795:
		case 544437099:
		case 540308587:
		case 544830571:
		case 543515500:
		case 544040044:
		case 544171372:
		case 540242028:
		case 543912044:
		case 543912045:
		case 543912040:
		case 544044396:
		case 543383917:
		case 1735683696:
		case 543646061:
		case 543779693:
		case 544235885:
		case 544760173:
		case 543646317:
		case 538993517:
		case 543712109:
		case 543777645:
		case 544039789:
		case 544236397:
		case 1886413677:
		case 544433005:
		case 538994541:
		case 540108653:
		case 540174189:
		case 540305261:
		case 540567405:
		case 543254381:
		case 544237421:
		case 543385965:
		case 543582573:
		case 543648109:
		case 543975789:
		case 544434541:
		case 540109933:
		case 543517805:
		case 544500845:
		case 543977581:
		case 544239725:
		case 543978349:
		case 544240493:
		case 543585645:
		case 543782253:
		case 544241005:
		case 544372077:
		case 543782765:
		case 1852405613:
		case 540113005:
		case 544171374:
		case 540241006:
		case 544304238:
		case 543585646:
		case 544241006:
		case 543783022:
		case 543842927:
		case 544236399:
		case 543780973:
		case 1667854445:
		case 543581295:
		case 538976368:
		case 540094832:
		case 543372144:
		case 540095600:
		case 543765616:
		case 540292720:
		case 544828518:
		case 540238192:
		case 543383920:
		case 1953456752:
		case 544760432:
		case 540107632:
		case 540173168:
		case 540238704:
		case 543777648:
		case 544433008:
		case 544498544:
		case 544367728:
		case 544499056:
		case 540108656:
		case 540174192:
		case 540239728:
		case 543385456:
		case 543582064:
		case 544368496:
		case 538995056:
		case 540109168:
		case 540174704:
		case 540240240:
		case 540371312:
		case 540436848:
		case 543716723:
		case 540305776:
		case 540502384:
		case 540567920:
		case 540633456:
		case 543385968:
		case 811821424:
		case 544762224:
		case 540306544:
		case 543255664:
		case 544435312:
		case 543452528:
		case 543649136:
		case 544501360:
		case 538996848:
		case 543715440:
		case 544239728:
		case 543388528:
		case 543585136:
		case 538981489:
		case 543449458:
		case 543646066:
		case 1667719538:
		case 544235890:
		case 544694642:
		case 543319922:
		case 543713138:
		case 544237938:
		case 543517810:
		case 540044658:
		case 540110194:
		case 540175730:
		case 540241266:
		case 540306802:
		case 538996850:
		case 544174194:
		case 543713639:
		case 543717234:
		case 543979378:
		case 544438642:
		case 544366963:
		case 540044387:
		case 540109923:
		case 540175459:
		case 540043120:
		case 540042099:
		case 540107635:
		case 540173171:
		case 540238707:
		case 540304243:
		case 540369779:
		case 540370279:
		case 540435315:
		case 540500851:
		case 540501351:
		case 540566387:
		case 540566887:
		case 540570227:
		case 543253363:
		case 543318899:
		case 543257203:
		case 543384435:
		case 544436851:
		case 543910521:
		case 544367475:
		case 540042355:
		case 540107891:
		case 540173427:
		case 544630131:
		case 540239731:
		case 543516531:
		case 544761715:
		case 540108915:
		case 540174451:
		case 540239987:
		case 808464947:
		case 543385715:
		case 543516787:
		case 543582323:
		case 543778931:
		case 544237683:
		case 544368755:
		case 544434291:
		case 544761971:
		case 543582579:
		case 543976307:
		case 544238451:
		case 543387763:
		case 543453299:
		case 544370803:
		case 544436339:
		case 544567411:
		case 544764019:
		case 540373619:
		case 540439155:
		case 540504691:
		case 543781491:
		case 544502387:
		case 540111731:
		case 540177267:
		case 540242803:
		case 540308339:
		case 879977331:
		case 543322995:
		case 544764787:
		case 543978611:
		case 544240755:
		case 543651955:
		case 544438387:
		case 544236404:
		case 544564084:
		case 540108660:
		case 543385716:
		case 544368756:
		case 544041332:
		case 544237940:
		case 540306548:
		case 540110452:
		case 540175988:
		case 540241524:
		case 540307060:
		case 540372596:
		case 540438132:
		case 544829044:
		case 543780980:
		case 543519348:
		case 544240244:
		case 544567924:
		case 540047476:
		case 543520884:
		case 544438388:
		case 543975029:
		case 543582581:
		case 544039542:
		case 538996066:
		case 543778934:
		case 543385974:
		case 543388534:
		case 543783542:
		case 544106871:
		case 543452791:
		case 543975032:
		case 543254392:
		case 543976312:
		case 544238712:
		case 544041338:
		case 540306810:
		case 544042874:
		case 540110970:
		case 538997626:
		case 544241786:
		case 544438394:
			return true;
		default:
			return false;
		}
	}

	/**
	 * Decodes a picture file to an RGB bitmap.
	 * Returns <code>true</code> on success.
	 * @param filename Name of the file to decode. Only the extension is processed, for format recognition.
	 * @param content File contents.
	 * @param contentLength File length.
	 */
	decode(filename, content, contentLength)
	{
		switch (RECOIL.#getPackedExt(filename)) {
		case 540423474:
			return this.#decodeIff(content, contentLength, RECOILResolution.AMIGA1X1) || this.#decode256(content, contentLength);
		case 538976307:
			return this.#decode3(content, contentLength);
		case 825242163:
			return this.#decode3201(content, contentLength);
		case 544498228:
			return this.#decode4bt(content, contentLength);
		case 543780148:
			return this.#decode4mi(content, contentLength);
		case 543977524:
			return this.#decode4pl(content, contentLength);
		case 544043060:
			return this.#decode4pm(content, contentLength);
		case 540423221:
			return this.#decode546(content, contentLength);
		case 543372342:
			return this.#decode64c(content, contentLength);
		case 538976353:
			return this.#decodeA(content, contentLength);
		case 544355425:
			return this.#decodeA4r(content, contentLength);
		case 540292705:
		case 543648119:
			return contentLength == 10242 && this.#decodeC64Multicolor(content, 2, 8194, 9218, 10241);
		case 544432481:
		case 543715433:
		case 543519336:
			return this.#decodeIph(content, contentLength);
		case 543908449:
			return this.#decodeAbk(content, contentLength);
		case 544432993:
			return this.#decodeAcs(content, contentLength);
		case 543975009:
			return this.#decodeAfl(content, contentLength);
		case 544237409:
			return this.#decodeAgp(content, contentLength);
		case 544434017:
			return this.#decodeAgs(content, contentLength);
		case 543976545:
			return this.#decodeAll(content, contentLength);
		case 543780193:
			return this.#decodeAmi(content, contentLength);
		case 540175969:
			return this.#decodeAn2(content, contentLength);
		case 540307041:
			return this.#decodeAn4(content, contentLength, 0);
		case 540372577:
			return this.#decodeAn4(content, contentLength, 1);
		case 540176481:
			return this.#decode256(content, contentLength);
		case 540242017:
		case 544632929:
		case 543778660:
		case 544237412:
		case 543388517:
		case 543386729:
		case 544045680:
			return this.#decodeAp3(content, contentLength);
		case 543256673:
		case 543387745:
		case 544042096:
			return this.#decodeApc(content, contentLength);
		case 543977569:
			return this.#decodeApl(content, contentLength);
		case 544239713:
			return this.#decodeApp(content, contentLength);
		case 544436321:
			return this.#decodeAps(content, contentLength);
		case 544502369:
			return this.#decodeIph(content, contentLength) || this.#decodeArtDirector(content, contentLength) || this.#decodeGfaArtist(content, contentLength) || this.#decodeDoo(content, contentLength) || this.#decodePaletteMaster(content, contentLength) || this.#decodeAtari8Artist(content, contentLength) || this.#decodeMonoArt(content, contentLength) || this.#decodeAsciiArtEditor(content, contentLength);
		case 544633441:
			return this.#decodeArtMaster88(content, contentLength);
		case 544371809:
			return this.#decodeAtr(content, contentLength);
		case 544679522:
		case 544702306:
			return this.#decodeBw(content, contentLength);
		case 540041826:
			return this.#decodeBb0(content, contentLength, RECOIL.#BBC_PALETTE1_BIT);
		case 540107362:
			return this.#decodeBb1(content, contentLength, RECOIL.#BBC_PALETTE2_BIT);
		case 540172898:
			return this.#decodeBb2(content, contentLength, RECOIL.#BBC_PALETTE);
		case 540303970:
			return this.#decodeBb4(content, contentLength, RECOIL.#BBC_PALETTE1_BIT);
		case 540369506:
			return this.#decodeBb5(content, contentLength, RECOIL.#BBC_PALETTE2_BIT);
		case 543646306:
			return this.#decodeBbg(content, contentLength);
		case 544039522:
			return this.#decodeIff(content, contentLength, RECOILResolution.PC1X1);
		case 544236642:
			return this.#decodeBdp(content, contentLength);
		case 543975010:
		case 1768711778:
			return this.#decodeBfli(content, contentLength);
		case 540632930:
		case 540618855:
			return this.#decodeG09(content, contentLength);
		case 544237410:
			return this.#decodeBgp(content, contentLength);
		case 543975778:
			return this.#decodeBil(content, contentLength);
		case 543648610:
			return this.#decodeBkg(content, contentLength);
		case 544435042:
			return this.#decodeBks(content, contentLength);
		case 1937076834:
		case 538996841:
		case 1952672112:
			return this.#decodeBrus(content, contentLength);
		case 540109922:
		case 540175458:
		case 540240994:
			return this.#decodeIff(content, contentLength, RECOILResolution.ST1X1);
		case 543452258:
			return this.#decodeBld(content, contentLength);
		case 543976802:
		case 543648870:
			return this.#decodeBml(content, contentLength);
		case 538996834:
			return this.#decodeBp(content, contentLength);
		case 540110946:
		case 540176482:
		case 540307554:
		case 540438626:
		case 540569698:
		case 540094563:
		case 540160099:
		case 540291171:
		case 540422243:
		case 540553315:
		case 540422499:
		case 540291683:
		case 540160867:
			return this.#decodeUimg(content, contentLength);
		case 543977570:
			return this.#decodeBpl(content, contentLength);
		case 544567906:
			return this.#decodeBru(content, contentLength);
		case 538997602:
		case 538993255:
		case 538994544:
			return this.#decodePrintfox(content, contentLength);
		case 543388514:
		case 878931298:
			return this.#decodeBsc(content, contentLength);
		case 544240482:
			return this.#decodeBsp(content, contentLength);
		case 540107107:
		case 540172643:
		case 540238179:
			return this.#decodeCa(content, contentLength);
		case 543777635:
			return this.#decodeCci(content, contentLength);
		case 544564323:
			return contentLength == 10277 && this.#decodeC64Multicolor(content, 275, 8275, 9275, 10275);
		case 540108131:
		case 540173667:
		case 540239203:
			return this.#decodeCe(content, contentLength);
		case 543974755:
			return this.#decodeCel(content, contentLength);
		case 1768711779:
			return this.#decodeCfli(content, contentLength);
		case 544761699:
			return this.#decodeCgx(content, contentLength);
		case 539256931:
			return this.#decodeChrd(content, contentLength);
		case 540305507:
		case 540436579:
		case 540567651:
			return this.#decodeCh8(content, contentLength);
		case 543516771:
			return contentLength == 20482 && this.#decodeC64Multicolor(content, 2, 16898, 18434, 20479);
		case 544368739:
			return this.#decodeChr(content, contentLength);
		case 544434275:
			return this.#decodeChs(content, contentLength);
		case 544761955:
			return this.#decodeChx(content, contentLength);
		case 544106851:
			return this.#decodeCin(content, contentLength);
		case 543517795:
			return this.#decodeCle(content, contentLength);
		case 544238691:
			return this.#decodeGodotClp(content, contentLength) || this.#decodeCocoClp(content, contentLength);
		case 540372323:
			return this.#decodeCm5(filename, content, contentLength);
		case 544238947:
			return this.#decodeDdGraph(filename, content, contentLength) || this.#decodeStCmp(content, contentLength);
		case 543977315:
			return this.#decodeCol(content, contentLength);
		case 540242019:
			return this.#decodeCp3(content, contentLength);
		case 543780963:
			return this.#decodeCpi(content, contentLength);
		case 544370787:
			return this.#decodeCpr(content, contentLength);
		case 544501859:
			return this.#decodeCpt(filename, content, contentLength);
		case 543650403:
			return this.#decodeCrg(content, contentLength);
		case 544044131:
			return this.#decodeCtm(content, contentLength);
		case 544503139:
			return this.#decodeGr8Raw(content, contentLength, 96, 99);
		case 543651683:
			return contentLength == 10007 && this.#decodeIpt(content);
		case 540303716:
			return this.#decodeDa4(content, contentLength);
		case 544235876:
			return this.#decodeDap(content, contentLength);
		case 540107620:
			return this.#decodeDc1(content, contentLength);
		case 538993764:
		case 544236644:
		case 544499048:
		case 543715442:
			return this.#decodeDd(content, contentLength);
		case 543974756:
			return this.#decodeDel(content, contentLength);
		case 540108644:
			return this.#decodeDg1(content, contentLength);
		case 1919379556:
			return this.#decodeAppleIIDhr(content, contentLength);
		case 544368740:
			return this.#decodeIff(content, contentLength, RECOILResolution.AMIGA1X1) || this.#decodeAppleIIDhr(content, contentLength);
		case 544106852:
			return this.#decodeAtari8Ice(content, contentLength, false, 3);
		case 544500068:
			return this.#decodeDit(content, contentLength);
		case 544042084:
			return this.#decodeDlm(content, contentLength);
		case 543977316:
		case 543450466:
		case 543451510:
			return this.#decodeDol(content, contentLength);
		case 544173924:
			return this.#decodeDoo(content, contentLength);
		case 543715428:
			return this.#decodeDph(content, contentLength);
		case 543650404:
			return this.#decodeDrg(content, contentLength);
		case 543978084:
		case 544238692:
			return this.#decodeDrl(content, contentLength);
		case 544895588:
		case 544240228:
			return this.#decodeDrz(content, contentLength);
		case 540112228:
		case 544175460:
			return this.#decodeDuo(content, contentLength);
		case 540177764:
			return this.#decodeDu2(content, contentLength);
		case 543449701:
			return this.#decodeEbd(content, contentLength);
		case 543777637:
			return this.#decodeEci(content, contentLength);
		case 544236389:
			return this.#decodeEcp(content, contentLength);
		case 543386981:
			return this.#decodeEmc(content, contentLength);
		case 543256677:
			return this.#decodeEpa(content, contentLength);
		case 543716197:
			return this.#decodeEsh(content, contentLength);
		case 544043877:
			return this.#decodeEsm(content, contentLength);
		case 543259237:
			return this.#decodeEza(content, contentLength);
		case 540031078:
			return this.#decodeF80(content, contentLength);
		case 543777382:
			return this.#decodeFbi(content, contentLength);
		case 544236390:
		case 544501862:
			return contentLength == 10004 && this.#decodeIpt(content);
		case 540173414:
			return this.#decodeFli(content, contentLength);
		case 543450470:
			return this.#decodeFed(content, contentLength);
		case 543975014:
		case 1768711782:
			return this.#decodeFfli(content, contentLength);
		case 543516518:
			return this.#decodeFge(content, contentLength);
		case 543583334:
			return this.#decodeFlf(content, contentLength);
		case 543779942:
			return this.#decodeFli(content, contentLength) || this.#decodeBml(content, contentLength);
		case 544042086:
			return this.#decodeFlm(content, contentLength);
		case 540175974:
			return this.#decodeFn2(content, contentLength);
		case 544501350:
			return this.#decodePct(content, contentLength) || this.#decodeGdosFnt(content, contentLength) || this.#decodeAtari8Fnt(content, contentLength) || this.#decodeStFnt(content, contentLength) || this.#decodeAmstradFnt(content, contentLength) || this.#decodeImage72Fnt(content, contentLength);
		case 538996838:
			return this.#decodeFp(content, contentLength);
		case 540176486:
			return this.#decodeC64Fun(content, contentLength);
		case 544370790:
			return this.#decodeFpr(content, contentLength);
		case 543388774:
			return this.#decodeFtc(content, contentLength);
		case 543978854:
			return this.#decodeFul(content, contentLength);
		case 544109926:
			return this.#decodeC64Fun(content, contentLength) || this.#decodeFalconFun(content, contentLength);
		case 543258470:
			return this.#decodeFwa(content, contentLength);
		case 538976359:
			return this.#decodeG(content, contentLength);
		case 540029287:
			return this.#decodeG10(content, contentLength);
		case 540094823:
			return this.#decodeG11(content, contentLength);
		case 543568487:
			return this.#decodeG2f(content, contentLength);
		case 543308135:
			return this.#decodeG9b(content, contentLength);
		case 544422247:
		case 543450739:
			return this.#decodeG9s(content, contentLength);
		case 543450471:
			return this.#decodeGed(content, contentLength);
		case 543319655:
			return this.#decodeGfb(content, contentLength);
		case 538994535:
			return this.#decodeGg(content, contentLength);
		case 543647847:
			return this.#decodeGhg(content, contentLength);
		case 543648103:
			return this.#decodeIph(content, contentLength) || this.#decodeKoa(content, contentLength);
		case 540372071:
		case 540371059:
			return this.#decodeGl5(filename, content, contentLength);
		case 540437607:
		case 540436595:
			return this.#decodeGl6(filename, content, contentLength);
		case 540503143:
		case 540502131:
			return this.#decodeGl7(filename, content, contentLength);
		case 540568679:
		case 540567667:
			return this.#decodeGl8(content, contentLength);
		case 543255655:
		case 543321191:
		case 543254643:
		case 543320179:
			return this.#decodeGlYjk(filename, content, contentLength);
		case 543386727:
		case 544435303:
			return this.#decodeGlYjk(null, content, contentLength);
		case 543453031:
			return this.#decodeGod(content, contentLength);
		case 538997351:
		case 538997603:
			return this.#decodeGr(content, contentLength);
		case 540045927:
		case 543388513:
			return this.#decodeGr0(content, contentLength);
		case 540111463:
			return this.#decodeGr1(content, contentLength, 0);
		case 540176999:
			return this.#decodeGr1(content, contentLength, 1);
		case 540242535:
			return this.#decodeGr3(content, contentLength);
		case 540504679:
			return this.#decodeGr7(content, 0, contentLength);
		case 540570215:
			return this.#decodeGr8(content, contentLength);
		case 540635751:
			return this.#decodeGr9(content, contentLength);
		case 1882813031:
			return this.#decodeGr9p(content, contentLength);
		case 543322727:
		case 544174695:
			return this.#decodeGrb(content, contentLength);
		case 543584871:
			return this.#decodeCocoMax(content, contentLength) || this.#decodeProfiGrf(content, contentLength);
		case 544240231:
			return this.#decodeSc2(content, contentLength);
		case 544764519:
			return this.#decodeGrx(content, contentLength);
		case 538997607:
		case 1936157033:
		case 543896115:
			return this.#decodeApfShr(content, contentLength);
		case 543388519:
			return this.#decodeGsc(content, contentLength);
		case 544109927:
			return this.#decodeGun(content, contentLength);
		case 544039272:
			return this.#decodeIff(content, contentLength, RECOILResolution.AMIGA1X1) || this.#decodeElementZxHam(content, contentLength);
		case 544039528:
		case 544434022:
		case 544108397:
		case 543449959:
			return this.#decodeC64Hir(content, contentLength);
		case 543318888:
			return this.#decodeHcb(content, contentLength);
		case 544039784:
			return this.#decodeHcm(content, contentLength);
		case 543450472:
			return contentLength == 9218 && this.#decodeHed(content);
		case 543385192:
		case 543450728:
			return this.#decodeHfc(content, contentLength);
		case 543319912:
			return this.#decodeHgb(content, contentLength);
		case 543713128:
			return this.#decodeHgfx(content, contentLength, 512, 0);
		case 543975272:
			return this.#decodeHgfx(content, contentLength, 256, 0);
		case 544368488:
			return this.#decodeHgr(content, contentLength);
		case 544434024:
			return this.#decodeHgs(content, contentLength);
		case 544041320:
			return this.#decodeHim(content, contentLength);
		case 544237928:
			return this.#decodeHip(content, contentLength);
		case 544369000:
			return this.#decodeFalconHir(content, contentLength) || this.#decodeC64Hir(content, contentLength) || this.#decodeHrs(content, contentLength);
		case 543517800:
			return this.#decodeHle(content, contentLength);
		case 543583336:
		case 543517032:
			return this.#decodeHlf(content, contentLength);
		case 543976296:
			return this.#decodeHkl(content, contentLength);
		case 544369768:
			return this.#decodeHlr(content, contentLength);
		case 543387752:
			return this.#decodeIph(content, contentLength);
		case 543780968:
			return this.#decodeC64Hir(content, contentLength) || this.#decodeIph(content, contentLength);
		case 544043112:
			return this.#decodeHpm(content, contentLength);
		case 544436328:
			return this.#decodeHps(content, contentLength);
		case 538997352:
			return this.#decodeTrsHr(content, contentLength) || this.#decodeAtari8Hr(content, contentLength);
		case 540177000:
		case 543777640:
			return this.#decodeHr2(content, contentLength);
		case 543388264:
			return this.#decodeHrc(content, contentLength);
		case 543650408:
			return this.#decodeHrg(content, contentLength);
		case 544043624:
			return this.#decodeHrm(content, contentLength);
		case 544436840:
			return this.#decodeHrs(content, contentLength);
		case 544764520:
			return this.#decodeHrx(content, contentLength);
		case 540177256:
			return this.#decodeHs2(content, contentLength);
		case 540238441:
		case 543777385:
			return this.#decodeIbi(content, contentLength);
		case 540107625:
		case 540173161:
		case 540238697:
			return this.#decodeIc(content, contentLength);
		case 543515497:
			return contentLength > 1024 && this.#decodeAtari8Ice(content, contentLength, true, content[0]);
		case 544105321:
			return this.#decodeStIcn(content, contentLength) || this.#decodePsion3Pic(content, contentLength) || this.#decodeAtari8Ice(content, contentLength, false, 17);
		case 543581801:
		case 1835164513:
		case 1835099490:
		case 544498532:
		case 1987339108:
		case 1885693284:
		case 538997348:
		case 913138024:
		case 946692456:
		case 544039532:
		case 1835166825:
		case 538996845:
		case 945973106:
		case 1851942770:
		case 1835100275:
			return this.#decodeIff(content, contentLength, RECOILResolution.AMIGA1X1);
		case 543975017:
			return this.#decodeGun(content, contentLength) || this.#decodeZxIfl(content, contentLength);
		case 543516521:
			return this.#decodeIge(content, contentLength);
		case 543516777:
			return this.#decodeIhe(content, contentLength);
		case 544041321:
			return this.#decodeIim(content, contentLength);
		case 543452265:
			return this.#decodeIld(content, contentLength);
		case 543517801:
			return this.#decodeIle(content, contentLength);
		case 544435305:
			return this.#decodeIls(content, contentLength);
		case 538996073:
			return this.#decodeIm(content, contentLength);
		case 543649129:
			return this.#decodeStImg(content, contentLength) || this.#decodeGsc(content, contentLength) || this.#decodeArtMaster88(content, contentLength) || this.#decodeDaVinci(content, contentLength);
		case 1735223668:
		case 1735223672:
			return this.#decodeStImg(content, contentLength);
		case 544107881:
			return this.#decodeAtari8Ice(content, contentLength, false, 18);
		case 1868983913:
			return this.#decodeInfo(content, contentLength);
		case 543649385:
		case 544239209:
			return this.#decodeInp(content, contentLength);
		case 544435817:
			return this.#decodeIns(content, contentLength);
		case 544501353:
			return this.#decodeInt(content, contentLength) || this.#decodeInp(content, contentLength);
		case 540176489:
			return this.#decodeIp2(content, contentLength);
		case 543387753:
			return this.#decodeAtari8Ice(content, contentLength, false, 19);
		case 544501865:
		case 543519340:
			return contentLength == 10003 && this.#decodeIpt(content);
		case 540177001:
			return this.#decodeAtari8Ice(content, contentLength, false, 2);
		case 543650409:
			return this.#decodeAtari8Ice(content, contentLength, false, 1);
		case 543716201:
			return this.#decodeIsh(content, contentLength);
		case 544043881:
			return contentLength == 10218 && this.#decodeC64Multicolor(content, 1026, 9218, 2, 9217);
		case 544502633:
			return this.#decodeIst(content, contentLength);
		case 544237418:
			return this.#decodeJgp(content, contentLength);
		case 538995306:
			return this.#decodeJj(content, contentLength);
		case 544761451:
			return this.#decodeGr8Raw(content, contentLength, 56, 60);
		case 543451499:
			return this.#decodeKid(content, contentLength);
		case 543255659:
		case 543256427:
		case 544043122:
			return this.#decodeKoa(content, contentLength);
		case 544370795:
			return this.#decodeKpr(content, contentLength);
		case 544437099:
			return this.#decodeKss(content, contentLength);
		case 540308587:
		case 544830571:
			return this.#decodeKty(content, contentLength);
		case 543515500:
			return this.#decodeLce(content, contentLength);
		case 544040044:
			return this.#decodeLdm(content, contentLength);
		case 544171372:
			return this.#decodeLeo(content, contentLength);
		case 540242028:
			return this.#decodeLp3(content, contentLength);
		case 543912044:
			return this.#decodeDaliCompressed(content, contentLength, 0);
		case 543912045:
			return this.#decodeDaliCompressed(content, contentLength, 1);
		case 543912040:
			return this.#decodeDaliCompressed(content, contentLength, 2);
		case 544044396:
			return this.#decodeLum(filename, content, contentLength);
		case 543383917:
		case 1735683696:
			return this.#decodeMac(content, contentLength);
		case 543646061:
		case 543779693:
			return this.#decodeMag(content, contentLength);
		case 544235885:
			return this.#decodeEnvision(content, contentLength) || this.#decodeEnvisionPC(content, contentLength);
		case 544760173:
			return this.#decodeMag(content, contentLength) || this.#decodeAtari8Max(content, contentLength) || this.#decodeCocoMax(content, contentLength);
		case 543646317:
			return this.#decodeGr8Raw(content, contentLength, 512, 256);
		case 538993517:
			return this.#decodeMcMlt(content, contentLength, -1);
		case 543712109:
			return this.#decodeMch(content, contentLength);
		case 543777645:
			return this.#decodeMci(content, contentLength);
		case 544039789:
			return this.#decodeMcm(content, contentLength);
		case 544236397:
			return this.#decodeMcp(content, contentLength);
		case 1886413677:
			return this.#decodeMcpp(content, contentLength);
		case 544433005:
			return this.#decodeMcs(content, contentLength);
		case 538994541:
			return this.#decodeVic20Mg(content, contentLength);
		case 540108653:
		case 540174189:
		case 540305261:
		case 540567405:
			return this.#decodeMg(content, contentLength);
		case 543254381:
			return this.#decodeMga(content, contentLength);
		case 544237421:
			return this.#decodeMgp(content, contentLength);
		case 543385965:
			return this.#decodeMic(filename, content, contentLength);
		case 543582573:
			return this.#decodeMif(content, contentLength);
		case 543648109:
			return this.#decodeMig(content, contentLength);
		case 543975789:
			return this.#decodeMil(content, contentLength);
		case 544434541:
			return this.#decodeMis(content, contentLength);
		case 540109933:
			return this.#decodeMl1(content, contentLength);
		case 543517805:
			return this.#decodeMle(content, contentLength);
		case 544500845:
			return this.#decodeMcMlt(content, contentLength, 0);
		case 543977581:
			return this.#decodeMpl(content, contentLength);
		case 544239725:
			return this.#decodeMpp(content, contentLength);
		case 543978349:
			return this.#decodeMsl(content, contentLength);
		case 544240493:
			return this.#decodeMsp(content, contentLength);
		case 543585645:
			return this.#decodeMuf(content, contentLength);
		case 543782253:
			return this.#decodeMui(content, contentLength);
		case 544241005:
			return this.#decodeMup(content, contentLength);
		case 544372077:
			return this.#decodeMur(filename, content, contentLength);
		case 543782765:
		case 1852405613:
			return this.#decodeMwi(content, contentLength);
		case 540113005:
			return this.#decodeMx1(content, contentLength);
		case 544171374:
			return this.#decodeNeo(filename, content, contentLength) || this.#decodeIff(content, contentLength, RECOILResolution.STE1X1);
		case 540241006:
			return this.#decodeNl3(content, contentLength);
		case 544304238:
			return this.#decodeNlq(content, contentLength);
		case 543585646:
			return this.#decodeNuf(content, contentLength);
		case 544241006:
			return this.#decodeNup(content, contentLength);
		case 543783022:
			return this.#decodeNxi(content, contentLength);
		case 543842927:
			return this.#decodeObj(content, contentLength);
		case 544236399:
		case 543780973:
		case 1667854445:
			return this.#decodeOcp(content, contentLength);
		case 543581295:
			return this.#decodeOdf(content, contentLength);
		case 538976368:
			return this.#decodeP(content, contentLength);
		case 540094832:
			return this.#decodeP11(content, contentLength);
		case 543372144:
			return this.#decodeP3c(content, contentLength);
		case 540095600:
			return this.#decodeCocoMax(content, contentLength);
		case 543765616:
			return this.#decodeP4i(content, contentLength);
		case 540292720:
		case 544828518:
			return contentLength == 10050 && this.#decodeC64Multicolor(content, 2050, 1026, 2, 2049);
		case 540238192:
			return this.#decodeStPpp(content, contentLength);
		case 543383920:
			return this.#decodePac(content, contentLength);
		case 1953456752:
			return this.#decodePbot(content, contentLength);
		case 544760432:
			return this.#decodePbx(content, contentLength);
		case 540107632:
		case 540173168:
		case 540238704:
			return this.#decodePc(content, contentLength);
		case 543777648:
			return this.#decodePci(content, contentLength);
		case 544433008:
			return this.#decodePcs(content, contentLength);
		case 544498544:
			return this.#decodePct(content, contentLength);
		case 544367728:
			return this.#decodePdr(content, contentLength);
		case 544499056:
			return this.#decodePet(content, contentLength);
		case 540108656:
		case 540174192:
			return this.#decodeSc(content, contentLength) || this.#decodeGraphicsProcessor(content, contentLength);
		case 540239728:
			return this.#decodeGraphicsProcessor(content, contentLength);
		case 543385456:
			return this.#decodePgc(content, contentLength);
		case 543582064:
			return this.#decodePgf(content, contentLength);
		case 544368496:
			return this.#decodePgr(content, contentLength);
		case 538995056:
			return this.#decodePi(content, contentLength) || this.#decodeBpl(content, contentLength);
		case 540109168:
		case 540174704:
		case 540240240:
		case 540371312:
		case 540436848:
		case 543716723:
			return this.#decodeStPi(content, contentLength);
		case 540305776:
			return this.#decodeFuckpaint(content, contentLength) || this.#decodeStPi(content, contentLength);
		case 540502384:
			return this.#decodeFuckpaint(content, contentLength);
		case 540567920:
			return this.#decodePi8(content, contentLength);
		case 540633456:
			return this.#decodePi9(content, contentLength);
		case 543385968:
			return this.#decodePic(filename, content, contentLength);
		case 811821424:
			return this.#decodePic0(filename, content, contentLength);
		case 544762224:
			return this.#decodeFalconPix(content, contentLength) || this.#decodeCocoMax(content, contentLength) || this.#decodeAtari8Pix(content, contentLength);
		case 540306544:
			return this.#decodePl4(content, contentLength);
		case 543255664:
			return this.#decodePla(content, contentLength);
		case 544435312:
			return this.#decodePls(content, contentLength);
		case 543452528:
			return this.#decodePmd(content, contentLength);
		case 543649136:
			return this.#decodePmg(content, contentLength);
		case 544501360:
			return this.#decodeFalconPnt(content, contentLength) || this.#decodeTandyPnt(content, contentLength) || this.#decodeApfShr(content, contentLength) || this.#decodeMac(content, contentLength) || this.#decodeAppleIIShr(content, contentLength) || this.#decodePaintworks(content, contentLength);
		case 538996848:
			return this.#decodePp(content, contentLength);
		case 543715440:
			return this.#decodePph(filename, content, contentLength);
		case 544239728:
			return this.#decodeStPpp(content, contentLength) || this.#decodePp(content, contentLength);
		case 543388528:
			return this.#decodePsc(content, contentLength);
		case 543585136:
			return this.#decodePsf(content, contentLength);
		case 538981489:
			return this.#decodeQ4(content, contentLength);
		case 543449458:
			return this.#decodeRad(content, contentLength);
		case 543646066:
			return this.#decodeRag(content, contentLength);
		case 1667719538:
			return this.#decodeRagc(content, contentLength);
		case 544235890:
			return this.#decodeRap(content, contentLength);
		case 544694642:
			return this.#decodeZx81Raw(content, contentLength) || this.#decodeAtari8Raw(content, contentLength) || this.#decodeRw(content, contentLength);
		case 543319922:
			return this.#decodeStRgb(content, contentLength) || this.#decodeAtari8Rgb(content, contentLength) || this.#decodeZxRgb(content, contentLength);
		case 543713138:
			return this.#decodeRgh(content, contentLength);
		case 544237938:
			return this.#decodeRip(content, contentLength);
		case 543517810:
			return this.#decodeRle(content, contentLength);
		case 540044658:
			return this.#decodeRm(content, contentLength, 0, RECOILResolution.XE2X2);
		case 540110194:
			return this.#decodeRm(content, contentLength, 1, RECOILResolution.XE4X1);
		case 540175730:
			return this.#decodeRm(content, contentLength, 2, RECOILResolution.XE4X1);
		case 540241266:
			return this.#decodeRm(content, contentLength, 3, RECOILResolution.XE4X1);
		case 540306802:
			return this.#decodeRm(content, contentLength, 4, RECOILResolution.XE2X1);
		case 538996850:
			return contentLength == 10242 && this.#decodeC64Multicolor(content, 1026, 2, 9218, -1);
		case 544174194:
		case 543713639:
			return this.#decodeRpo(content, contentLength);
		case 543717234:
		case 543979378:
			return this.#decodeRw(content, contentLength);
		case 544438642:
			return this.#decodeRys(content, contentLength);
		case 544366963:
			return contentLength == 10219 && this.#decodeC64Multicolor(content, 1026, 2, 9218, 1010);
		case 540044387:
		case 540109923:
		case 540175459:
		case 540043120:
		case 540042099:
		case 540107635:
			return this.#decodeSc(content, contentLength);
		case 540173171:
			return this.#decodeSc(content, contentLength) || this.#decodeSc2(content, contentLength);
		case 540238707:
			return this.#decodeSc3(content, contentLength);
		case 540304243:
			return this.#decodeSc4(content, contentLength);
		case 540369779:
		case 540370279:
			return this.#decodeSc5(filename, content, contentLength);
		case 540435315:
			return this.#decodeSc6(filename, content, contentLength);
		case 540500851:
		case 540501351:
			return this.#decodeSc7(filename, content, contentLength);
		case 540566387:
		case 540566887:
		case 540570227:
			return this.#decodeSc8(filename, content, contentLength);
		case 543253363:
		case 543318899:
		case 543257203:
			return this.#decodeSca(filename, content, contentLength);
		case 543384435:
		case 544436851:
		case 543910521:
			return this.#decodeScc(filename, content, contentLength);
		case 544367475:
			return this.#decodeScr(filename, content, contentLength);
		case 540042355:
			return this.#decodeSd(content, contentLength, 0);
		case 540107891:
			return this.#decodeSd(content, contentLength, 1);
		case 540173427:
			return this.#decodeSd(content, contentLength, 2);
		case 544630131:
			return this.#decodeSev(content, contentLength);
		case 540239731:
			return this.#decodeSg3(content, contentLength);
		case 543516531:
			return this.#decodeSge(content, contentLength);
		case 544761715:
			return this.#decodeSgx(content, contentLength);
		case 540108915:
			return this.#decodeSh1(content, contentLength);
		case 540174451:
			return this.#decodeSh2(content, contentLength);
		case 540239987:
		case 808464947:
			return this.#decodeApfShr(content, contentLength) || this.#decode3201(content, contentLength) || this.#decodeSh3(content, contentLength) || this.#decodeAppleIIShr(content, contentLength);
		case 543385715:
			return this.#decodeShc(content, contentLength) || this.#decodeGlYjk(null, content, contentLength);
		case 543516787:
			return this.#decodeShe(content, contentLength);
		case 543582323:
			return this.#decodeShf(content, contentLength);
		case 543778931:
			return this.#decodeShi(content, contentLength);
		case 544237683:
			return this.#decodeShp(content, contentLength);
		case 544368755:
			return this.#decodeApfShr(content, contentLength) || this.#decodeAppleIIShr(content, contentLength) || this.#decodeSh3(content, contentLength) || this.#decodeHgfx(content, contentLength, 512, 1) || this.#decodeTrsShr(content, contentLength);
		case 544434291:
			return this.#decodeShs(content, contentLength);
		case 544761971:
			return this.#decodeShx(content, contentLength);
		case 543582579:
			return this.#decodeAtari8Sif(content, contentLength) || this.#decodeC64Sif(content, contentLength);
		case 543976307:
			return this.#decodeSkl(content, contentLength);
		case 544238451:
			return this.#decodeSkp(content, contentLength);
		case 543387763:
			return this.#decodeStSpc(content, contentLength) || this.#decodeAtari8Spc(content, contentLength);
		case 543453299:
			return this.#decodeSpd(content, contentLength);
		case 544370803:
			return this.#decodeSprEd(content, contentLength) || this.#decodeAppleSpr(content, contentLength) || this.#decodeAtari8Spr(content, contentLength) || this.#decodeVectorSpr(content, contentLength);
		case 544436339:
			return this.#decodeSps(content, contentLength);
		case 544567411:
			return this.#decodeSpu(content, contentLength);
		case 544764019:
			return this.#decodeSpx(content, contentLength);
		case 540373619:
			return this.#decodeSr5(filename, content, contentLength);
		case 540439155:
			return this.#decodeSr6(filename, content, contentLength);
		case 540504691:
			return this.#decodeSr7(filename, content, contentLength);
		case 543781491:
			return this.#decodeSri(filename, content, contentLength);
		case 544502387:
			return this.#decodeSrt(content, contentLength);
		case 540111731:
			return this.#decodeSs1(content, contentLength);
		case 540177267:
			return this.#decodeSs2(content, contentLength);
		case 540242803:
			return this.#decodeSs3(content, contentLength);
		case 540308339:
		case 879977331:
			return this.#decodeSs4(content, contentLength) || this.#decodeSsx(content, contentLength);
		case 543322995:
			return this.#decodeSsb(content, contentLength);
		case 544764787:
			return this.#decodeSsx(content, contentLength);
		case 543978611:
			return this.#decodeStl(content, contentLength);
		case 544240755:
			return this.#decodeGl6(null, content, contentLength);
		case 543651955:
			return this.#decodeSxg(content, contentLength);
		case 544438387:
			return this.#decodeSxs(content, contentLength);
		case 544236404:
			return this.#decodeTcp(content, contentLength);
		case 544564084:
			return this.#decodeTcu(content, contentLength);
		case 540108660:
			return this.#decodeTg1(content, contentLength);
		case 543385716:
			return this.#decodeThc(content, contentLength);
		case 544368756:
			return this.#decodeThr(content, contentLength);
		case 544041332:
			return this.#decodeTim(content, contentLength);
		case 544237940:
			return this.#decodeTip(content, contentLength);
		case 540306548:
			return this.#decodeTl4(content, contentLength);
		case 540110452:
		case 540175988:
		case 540241524:
		case 540307060:
		case 540372596:
		case 540438132:
		case 544829044:
			return this.#decodeTny(content, contentLength);
		case 543780980:
			return this.#decodeFalconPnt(content, contentLength);
		case 543519348:
			return this.#decodeTre(content, contentLength);
		case 544240244:
			return this.#decodeTrp(content, contentLength);
		case 544567924:
			return this.#decodeTru(content, contentLength);
		case 540047476:
			return this.#decodeTx0(content, contentLength);
		case 543520884:
			return this.#decodeTxe(content, contentLength);
		case 544438388:
			return this.#decodeTxs(content, contentLength);
		case 543975029:
			return this.#decodeUfl(content, contentLength);
		case 543582581:
			return this.#decodeUif(content, contentLength);
		case 544039542:
		case 538996066:
			return this.#decodeVbm(content, contentLength);
		case 543778934:
			return this.#decodeVhi(content, contentLength);
		case 543385974:
			return this.#decodeVic(content, contentLength);
		case 543388534:
			return this.#decodeVsc(filename, content, contentLength);
		case 543783542:
			return this.#decodeVzi(content, contentLength);
		case 544106871:
			return this.#decodeWin(filename, content, contentLength);
		case 543452791:
			return this.#decodeWnd(content, contentLength);
		case 543975032:
			return this.#decodeXfl(content, contentLength);
		case 543254392:
			return this.#decodeXga(content, contentLength);
		case 543976312:
			return this.#decodeXkl(content, contentLength);
		case 544238712:
			return this.#decodeXlp(content, contentLength);
		case 544041338:
			return this.#decodeZim(content, contentLength);
		case 540306810:
			return this.#decodeZm4(content, contentLength);
		case 544042874:
			return this.#decodeZom(content, contentLength);
		case 540110970:
			return this.#decodeZp1(content, contentLength);
		case 538997626:
			return this.#decodeZs(content, contentLength);
		case 544241786:
			return this.#decodeZxp(content, contentLength);
		case 544438394:
			return this.#decodeZxs(content, contentLength);
		default:
			return false;
		}
	}

	/**
	 * Returns decoded image width.
	 */
	getWidth()
	{
		return this.#width;
	}

	/**
	 * Returns decoded image height.
	 */
	getHeight()
	{
		return this.#height;
	}

	/**
	 * Returns pixels of the decoded image, top-down, left-to-right.
	 * Each pixel is a 24-bit integer 0xRRGGBB.
	 */
	getPixels()
	{
		return this.#pixels;
	}

	/**
	 * Returns the computer family of the decoded file format.
	 */
	getPlatform()
	{
		switch (this.#resolution) {
		case RECOILResolution.AMIGA1X1:
		case RECOILResolution.AMIGA2X1:
		case RECOILResolution.AMIGA4X1:
		case RECOILResolution.AMIGA8X1:
		case RECOILResolution.AMIGA1X2:
		case RECOILResolution.AMIGA1X4:
			return "Amiga";
		case RECOILResolution.AMIGA_DCTV1X1:
		case RECOILResolution.AMIGA_DCTV1X2:
			return "Amiga DCTV";
		case RECOILResolution.AMIGA_HAME1X1:
		case RECOILResolution.AMIGA_HAME2X1:
			return "Amiga HAM-E";
		case RECOILResolution.AMSTRAD1X1:
		case RECOILResolution.AMSTRAD2X1:
		case RECOILResolution.AMSTRAD1X2:
			return "Amstrad CPC";
		case RECOILResolution.APPLE_I_I1X1:
			return "Apple II";
		case RECOILResolution.APPLE_I_IE1X2:
			return "Apple IIe";
		case RECOILResolution.APPLE_I_I_G_S1X1:
		case RECOILResolution.APPLE_I_I_G_S1X2:
			return "Apple IIGS";
		case RECOILResolution.MACINTOSH1X1:
			return "Apple Macintosh";
		case RECOILResolution.XE1X1:
		case RECOILResolution.XE2X1:
		case RECOILResolution.XE4X1:
		case RECOILResolution.XE2X2:
		case RECOILResolution.XE4X2:
		case RECOILResolution.XE4X4:
		case RECOILResolution.XE8X8:
			return "Atari 8-bit";
		case RECOILResolution.VBXE1X1:
		case RECOILResolution.VBXE2X1:
			return "Atari 8-bit VBXE";
		case RECOILResolution.PORTFOLIO1X1:
			return "Atari Portfolio";
		case RECOILResolution.ST1X1:
		case RECOILResolution.ST1X2:
			return "Atari ST";
		case RECOILResolution.STE1X1:
		case RECOILResolution.STE1X2:
			return "Atari STE";
		case RECOILResolution.TT1X1:
		case RECOILResolution.TT2X1:
			return "Atari TT";
		case RECOILResolution.FALCON1X1:
		case RECOILResolution.FALCON2X1:
			return "Atari Falcon";
		case RECOILResolution.BBC1X1:
		case RECOILResolution.BBC2X1:
		case RECOILResolution.BBC1X2:
			return "BBC Micro";
		case RECOILResolution.VIC201X1:
		case RECOILResolution.VIC202X1:
			return "Commodore VIC-20";
		case RECOILResolution.C161X1:
		case RECOILResolution.C162X1:
			return "Commodore 16/116/Plus4";
		case RECOILResolution.C641X1:
		case RECOILResolution.C642X1:
			return "Commodore 64";
		case RECOILResolution.C1281X1:
			return "Commodore 128";
		case RECOILResolution.BK1X1:
		case RECOILResolution.BK1X2:
			return "Electronika BK";
		case RECOILResolution.MC05151X2:
			return "Electronika MC 0515";
		case RECOILResolution.FM_TOWNS1X1:
			return "FM Towns";
		case RECOILResolution.HP481X1:
			return "HP 48";
		case RECOILResolution.MSX11X1:
		case RECOILResolution.MSX14X4:
			return "MSX";
		case RECOILResolution.MSX21X1:
		case RECOILResolution.MSX21X2:
		case RECOILResolution.MSX21X1I:
		case RECOILResolution.MSX22X1I:
			return "MSX2";
		case RECOILResolution.MSX2_PLUS1X1:
		case RECOILResolution.MSX2_PLUS2X1I:
			return "MSX2+";
		case RECOILResolution.MSX_V99901X1:
			return "MSX V9990 VDP";
		case RECOILResolution.ORIC1X1:
			return "Oric";
		case RECOILResolution.PC1X1:
			return "PC";
		case RECOILResolution.PC801X2:
			return "NEC PC-80";
		case RECOILResolution.PC881X2:
			return "NEC PC-88";
		case RECOILResolution.PC88_VA1X1:
			return "NEC PC-88 VA";
		case RECOILResolution.PC981X1:
			return "NEC PC-98";
		case RECOILResolution.PLAY_STATION1X1:
			return "PlayStation";
		case RECOILResolution.PSION31X1:
			return "Psion Series 3";
		case RECOILResolution.SAM_COUPE1X1:
		case RECOILResolution.SAM_COUPE1X2:
		case RECOILResolution.SAM_COUPE2X1I:
			return "SAM Coupe";
		case RECOILResolution.X68_K1X1:
			return "Sharp X68000";
		case RECOILResolution.TANDY1X1:
			return "Tandy 1000";
		case RECOILResolution.VECTOR1X1:
			return "Vector-06C";
		case RECOILResolution.ZX811X1:
			return "ZX81";
		case RECOILResolution.SPECTRUM1X1:
		case RECOILResolution.SPECTRUM4X4:
			return "ZX Spectrum";
		case RECOILResolution.SPECTRUM_PROFI1X2:
			return "ZX Spectrum Profi";
		case RECOILResolution.SPECTRUM_ULA_PLUS1X1:
			return "ZX Spectrum ULAplus";
		case RECOILResolution.ZX_EVOLUTION1X1:
			return "ZX Evolution";
		case RECOILResolution.ZX_UNO2X2:
			return "ZX-Uno";
		case RECOILResolution.SPECTRUM_NEXT1X1:
			return "ZX Spectrum Next";
		case RECOILResolution.ELEMENT_ZX1X1:
		case RECOILResolution.ELEMENT_ZX1X2:
			return "eLeMeNt ZX";
		case RECOILResolution.TIMEX1X1:
		case RECOILResolution.TIMEX1X2:
			return "Timex 2048";
		case RECOILResolution.TRS1X1:
		case RECOILResolution.TRS1X2:
			return "TRS-80";
		case RECOILResolution.COCO1X1:
		case RECOILResolution.COCO2X2:
			return "TRS-80 Color Computer";
		default:
			return "Unknown";
		}
	}

	/**
	 * Returns original width of the decoded image (informational).
	 */
	getOriginalWidth()
	{
		switch (this.#resolution) {
		case RECOILResolution.AMIGA2X1:
		case RECOILResolution.AMIGA_HAME2X1:
		case RECOILResolution.AMSTRAD2X1:
		case RECOILResolution.XE2X1:
		case RECOILResolution.XE2X2:
		case RECOILResolution.VBXE2X1:
		case RECOILResolution.TT2X1:
		case RECOILResolution.FALCON2X1:
		case RECOILResolution.BBC2X1:
		case RECOILResolution.VIC202X1:
		case RECOILResolution.C162X1:
		case RECOILResolution.C642X1:
		case RECOILResolution.COCO2X2:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS2X1I:
		case RECOILResolution.SAM_COUPE2X1I:
		case RECOILResolution.ZX_UNO2X2:
			return this.#width >> 1;
		case RECOILResolution.AMIGA4X1:
		case RECOILResolution.MSX14X4:
		case RECOILResolution.SPECTRUM4X4:
		case RECOILResolution.XE4X1:
		case RECOILResolution.XE4X2:
		case RECOILResolution.XE4X4:
			return this.#width >> 2;
		case RECOILResolution.AMIGA8X1:
		case RECOILResolution.XE8X8:
			return this.#width >> 3;
		default:
			return this.#width;
		}
	}

	/**
	 * Returns original height of the decoded image (informational).
	 */
	getOriginalHeight()
	{
		switch (this.#resolution) {
		case RECOILResolution.AMIGA1X2:
		case RECOILResolution.AMSTRAD1X2:
		case RECOILResolution.APPLE_I_IE1X2:
		case RECOILResolution.APPLE_I_I_G_S1X2:
		case RECOILResolution.XE2X2:
		case RECOILResolution.XE4X2:
		case RECOILResolution.ST1X2:
		case RECOILResolution.STE1X2:
		case RECOILResolution.BBC1X2:
		case RECOILResolution.BK1X2:
		case RECOILResolution.MC05151X2:
		case RECOILResolution.MSX21X2:
		case RECOILResolution.PC801X2:
		case RECOILResolution.PC881X2:
		case RECOILResolution.SAM_COUPE1X2:
		case RECOILResolution.SPECTRUM_PROFI1X2:
		case RECOILResolution.ELEMENT_ZX1X2:
		case RECOILResolution.TIMEX1X2:
		case RECOILResolution.TRS1X2:
		case RECOILResolution.COCO2X2:
		case RECOILResolution.ZX_UNO2X2:
			return this.#height >> 1;
		case RECOILResolution.AMIGA1X4:
		case RECOILResolution.MSX14X4:
		case RECOILResolution.SPECTRUM4X4:
		case RECOILResolution.XE4X4:
			return this.#height >> 2;
		case RECOILResolution.XE8X8:
			return this.#height >> 3;
		default:
			return this.#height;
		}
	}

	/**
	 * Returns horizontal pixel density per meter or zero if unknown.
	 */
	getXPixelsPerMeter()
	{
		switch (this.#resolution) {
		case RECOILResolution.APPLE_I_I1X1:
			return 1530;
		case RECOILResolution.XE1X1:
		case RECOILResolution.XE2X1:
		case RECOILResolution.XE4X1:
		case RECOILResolution.XE2X2:
		case RECOILResolution.XE4X2:
		case RECOILResolution.XE4X4:
		case RECOILResolution.XE8X8:
		case RECOILResolution.VBXE1X1:
		case RECOILResolution.VBXE2X1:
			return this.#ntsc ? 1530 : 1261;
		case RECOILResolution.PORTFOLIO1X1:
			return 2123;
		case RECOILResolution.BBC1X1:
		case RECOILResolution.BBC2X1:
			return this.#ntsc ? 1710 : 1423;
		case RECOILResolution.BBC1X2:
			return this.#ntsc ? 3421 : 2846;
		case RECOILResolution.VIC201X1:
		case RECOILResolution.VIC202X1:
			return this.#ntsc ? 1749 : 1574;
		case RECOILResolution.C161X1:
		case RECOILResolution.C162X1:
			return this.#ntsc ? 1530 : 1261;
		case RECOILResolution.C641X1:
		case RECOILResolution.C642X1:
			return this.#ntsc ? 1749 : 1402;
		case RECOILResolution.MSX11X1:
		case RECOILResolution.MSX14X4:
		case RECOILResolution.MSX21X1:
		case RECOILResolution.MSX2_PLUS1X1:
			return 1148;
		case RECOILResolution.MSX21X2:
		case RECOILResolution.MSX21X1I:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS2X1I:
			return 2296;
		case RECOILResolution.ORIC1X1:
			return 1067;
		case RECOILResolution.VECTOR1X1:
			return 1067;
		case RECOILResolution.ZX811X1:
			return 1156;
		case RECOILResolution.SPECTRUM1X1:
		case RECOILResolution.SPECTRUM4X4:
		case RECOILResolution.SPECTRUM_ULA_PLUS1X1:
		case RECOILResolution.ZX_EVOLUTION1X1:
		case RECOILResolution.SPECTRUM_NEXT1X1:
		case RECOILResolution.TIMEX1X1:
			return 1245;
		case RECOILResolution.TIMEX1X2:
			return 2490;
		default:
			return 0;
		}
	}

	/**
	 * Returns vertical pixel density per meter or zero if unknown.
	 */
	getYPixelsPerMeter()
	{
		switch (this.#resolution) {
		case RECOILResolution.APPLE_I_I1X1:
			return 1312;
		case RECOILResolution.XE1X1:
		case RECOILResolution.XE2X1:
		case RECOILResolution.XE4X1:
		case RECOILResolution.XE2X2:
		case RECOILResolution.XE4X2:
		case RECOILResolution.XE4X4:
		case RECOILResolution.XE8X8:
		case RECOILResolution.VBXE1X1:
		case RECOILResolution.VBXE2X1:
			return this.#ntsc ? 1312 : 1312;
		case RECOILResolution.PORTFOLIO1X1:
			return 2123;
		case RECOILResolution.BBC1X1:
		case RECOILResolution.BBC2X1:
			return this.#ntsc ? 1312 : 1312;
		case RECOILResolution.BBC1X2:
			return this.#ntsc ? 2624 : 2624;
		case RECOILResolution.VIC201X1:
		case RECOILResolution.VIC202X1:
		case RECOILResolution.C161X1:
		case RECOILResolution.C162X1:
			return this.#ntsc ? 1312 : 1312;
		case RECOILResolution.C641X1:
		case RECOILResolution.C642X1:
			return this.#ntsc ? 1312 : 1312;
		case RECOILResolution.MSX11X1:
		case RECOILResolution.MSX14X4:
		case RECOILResolution.MSX21X1:
		case RECOILResolution.MSX2_PLUS1X1:
			return 1312;
		case RECOILResolution.MSX21X2:
		case RECOILResolution.MSX21X1I:
		case RECOILResolution.MSX22X1I:
		case RECOILResolution.MSX2_PLUS2X1I:
			return 2624;
		case RECOILResolution.ORIC1X1:
			return 1312;
		case RECOILResolution.VECTOR1X1:
			return 1312;
		case RECOILResolution.ZX811X1:
			return 1312;
		case RECOILResolution.SPECTRUM1X1:
		case RECOILResolution.SPECTRUM4X4:
		case RECOILResolution.SPECTRUM_ULA_PLUS1X1:
		case RECOILResolution.ZX_EVOLUTION1X1:
		case RECOILResolution.SPECTRUM_NEXT1X1:
		case RECOILResolution.TIMEX1X1:
			return 1312;
		case RECOILResolution.TIMEX1X2:
			return 2624;
		default:
			return 0;
		}
	}

	/**
	 * Returns horizontal pixel density per inch or zero if unknown.
	 */
	getXPixelsPerInch()
	{
		return this.getXPixelsPerMeter() * 0.0254;
	}

	/**
	 * Returns vertical pixel density per inch or zero if unknown.
	 */
	getYPixelsPerInch()
	{
		return this.getYPixelsPerMeter() * 0.0254;
	}

	/**
	 * Returns the number of alternating frames the pictures is composed of.
	 * 
	 * <ul>
	 * <li>1 means the picture doesn't flicker.</li>
	 * <li>2 means the picture is displayed by quickly alternating two sub-pictures.</li>
	 * <li>3 means the picture is displayed by alternating three sub-pictures.</li>
	 * </ul>
	 */
	getFrames()
	{
		return this.#frames;
	}
	#colorInUse = null;
	#colors;
	#palette = new Int32Array(256);
	#indexes = null;
	#indexesLength = 0;

	/**
	 * Calculates palette for the decoded picture.
	 */
	#calculatePalette()
	{
		if (this.#colorInUse == null)
			this.#colorInUse = new Uint8Array(2097152);
		this.#colorInUse.fill(0, 0, 2097152);
		this.#colors = 0;
		this.#palette.fill(0);
		let pixelsCount = this.#width * this.#height;
		for (let pixelsOffset = 0; pixelsOffset < pixelsCount; pixelsOffset++) {
			let rgb = this.#pixels[pixelsOffset];
			let i = rgb >> 3;
			let mask = 1 << (rgb & 7);
			if ((this.#colorInUse[i] & mask) == 0) {
				this.#colorInUse[i] |= mask;
				if (this.#colors < 256)
					this.#palette[this.#colors] = rgb;
				this.#colors++;
			}
		}
	}

	/**
	 * Returns number of unique colors in the decoded picture.
	 */
	getColors()
	{
		if (this.#colors == -1)
			this.#calculatePalette();
		return this.#colors;
	}

	/**
	 * Find the index of the <code>rgb</code> color in the sorted palette.
	 */
	#findInSortedPalette(rgb)
	{
		let left = 0;
		let right = this.#colors;
		while (left < right) {
			let index = (left + right) >> 1;
			let paletteRgb = this.#palette[index];
			if (rgb == paletteRgb)
				return index;
			if (rgb < paletteRgb)
				right = index;
			else
				left = index + 1;
		}
		return 0;
	}

	/**
	 * Converts the decoded picture to palette-indexed.
	 * Returns palette of 256 0xRRGGBB entries.
	 * Call <code>GetColors()</code> for the actual number of colors.
	 * Returns <code>null</code> if conversion fails,
	 * because there are more than 256 colors.
	 */
	toPalette()
	{
		if (this.#colors == -1)
			this.#calculatePalette();
		if (this.#colors > 256)
			return null;
		this.#palette.subarray(0, this.#colors).sort();
		let pixelsLength = this.#width * this.#height;
		if (this.#indexesLength < pixelsLength) {
			this.#indexesLength = pixelsLength;
			this.#indexes = new Uint8Array(pixelsLength);
		}
		for (let i = 0; i < pixelsLength; i++)
			this.#indexes[i] = this.#findInSortedPalette(this.#pixels[i]);
		return this.#palette;
	}

	/**
	 * Returns the palette-indexed picture,
	 * as a bitmap of <code>GetHeight()</code> rows of <code>GetWidth()</code> pixels.
	 * Call after <code>ToPalette()</code> returns non-null.
	 */
	getIndexes()
	{
		return this.#indexes;
	}

	static #DECODE_COCO_CLP_HEADER = new Uint8Array([ 0, 0, 0, 3, 1, 94, 0, 0, 32, 0, 32, 1, 1, 44, 0, 10,
		0, 56, 0, 32, 0, 56, 0, 32, 5 ]);

	static #DECODE_P11_PALETTE = new Int32Array([ 524032, 16776960, 3868927, 13369403 ]);

	static #SET_AMSTRAD_FIRMWARE_PALETTE_TRI_LEVEL = new Uint8Array([ 0, 128, 255 ]);

	static #DECODE_SGX_PALETTE4 = new Int32Array([ 16777215, 11184810, 0, 5592405 ]);

	static #DECODE_SGX_PALETTE16 = new Int32Array([ 16777088, 0, 16744448, 8388608, 65535, 128, 8421631, 255, 16777215, 32768, 65280, 16711935, 16776960, 8421504, 16744576, 16711680 ]);

	static #DECODE_ZX_RGB_FRAME_COMPONENTS = new Uint8Array([ 16, 8, 0 ]);

	static #DECODE3_FRAME_COMPONENTS = new Uint8Array([ 0, 16, 8 ]);

	static #SET_SC8_PALETTE_BLUES = new Uint8Array([ 0, 2, 4, 7 ]);

	static #DECODE_SC8_SPRITE_PALETTE = new Uint8Array([ 0, 0, 2, 0, 48, 0, 50, 0, 0, 3, 2, 3, 48, 3, 50, 3,
		114, 4, 7, 0, 112, 0, 119, 0, 0, 7, 7, 7, 112, 7, 119, 7 ]);

	static #UNPACK_MAG_DELTA_X = new Uint8Array([ 0, 2, 4, 8, 0, 2, 0, 2, 4, 0, 2, 4, 0, 2, 4, 0 ]);

	static #UNPACK_MAG_DELTA_Y = new Uint8Array([ 0, 0, 0, 0, 1, 1, 2, 2, 2, 4, 4, 4, 8, 8, 8, 16 ]);

	static #DECODE_BRUS_PALETTE = new Int32Array([ 0, 5592405, 170, 5592575, 43520, 5635925, 43690, 5636095, 11141120, 16733525, 11141290, 16733695, 11162880, 16777045, 11184810, 16777215 ]);

	static #DECODE_P4I_LOGO_COLORS = new Uint8Array([ 0, 49, 81, 113 ]);

	static #DECODE_GODOT_BY_BRIGHTNESS = new Uint8Array([ 0, 6, 9, 11, 2, 4, 8, 12, 14, 10, 5, 15, 3, 7, 13, 1 ]);

	static #DECODE_MLE_FRAME_COLORS = new Uint8Array([ 0, 9, 8, 5 ]);

	static #GET_SHF_PIXEL_SPRITES = new Uint8Array([ 128, 132, 133, 137, 138, 142, 143, 147, 148, 152, 153, 157, 158, 162, 163, 167,
		168, 172, 173, 177, 178, 182, 183, 187, 188, 192, 193, 197, 198, 202, 203, 207,
		208, 212, 213, 217, 218, 222, 223, 227, 228, 232, 233, 234, 235, 236, 237, 238,
		239, 240, 241, 242, 243, 244, 245, 246, 247, 30, 46, 62, 78, 94, 110, 126 ]);

	static #DECODE_XFL_SPRITES = new Uint8Array([ 228, 229, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 246, 247, 248,
		14, 30, 46, 62, 78, 94, 110, 126, 128, 129, 133, 134, 138, 139, 143, 144,
		148, 149, 153, 154, 158, 159, 163, 164, 168, 169, 173, 174, 178, 179, 183, 184,
		188, 189, 193, 194, 198, 199, 203, 204, 208, 209, 213, 214, 218, 219, 223, 224 ]);

	static #DECODE_MPP_SCREEN_FIRST_CHANGE_X = new Uint8Array([ 33, 9, 4, 69 ]);

	static #DECODE_MPP_SCREEN_RIGHT_BORDER_COLOR = new Uint8Array([ 32, 16, 32, 127 ]);

	static #DECODE_MPP_MODE_COLORS_PER_LINE = new Uint8Array([ 52, 46, 54, 48 ]);

	static #DECODE_HRM_COLOR_OFFSETS = new Uint8Array([ 80, 72, 40, 32 ]);

	static #DECODE_UIMG_PALETTE_UNIT = new Uint8Array([ 0, 2, 2, 4, 6 ]);

	static #DECODE_INFO_OS1_PALETTE = new Int32Array([ 5614335, 16777215, 0, 16746496 ]);

	static #DECODE_INFO_OS2_PALETTE = new Int32Array([ 9803157, 0, 16777215, 3893154, 8092539, 11513775, 11178108, 16755095 ]);

	static #IS_HAME_MAGIC = new Uint8Array([ 162, 245, 132, 220, 109, 176, 127 ]);

	static #DECODE_HIP_GR10_COLORS = new Uint8Array([ 0, 0, 2, 4, 6, 8, 10, 12, 14 ]);

	static #DECODE_TIP_COLORS = new Uint8Array([ 0, 2, 4, 6, 8, 10, 12, 14, 0 ]);

	static #DECODE_ICE_FRAME_ROW2CHAR1 = new Uint8Array([ 64, 0, 32, 96, 192, 128, 160, 224, 64, 0, 32, 96, 192, 128, 160, 224 ]);

	static #DECODE_ICE_FRAME_ROW2CHAR2 = new Uint8Array([ 64, 0, 32, 96, 192, 128, 160, 224, 192, 128, 160, 224, 64, 0, 32, 96 ]);

	static #DECODE_ATARI8_ICE_ICE20_GTIA11_COLORS = new Uint8Array([ 0, 1, 2, 3, 5, 7, 8 ]);

	static #DRAW_SPC_BRUSH_BRUSHES = new Uint8Array([ 0, 0, 0, 0, 0, 0, 16, 16, 0, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 48, 48, 48, 48, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 16, 56, 56, 56, 56, 16, 0, 0, 0, 0, 0, 0,
		0, 0, 16, 56, 56, 124, 124, 124, 124, 56, 56, 16, 0, 0, 0, 0,
		0, 24, 24, 60, 60, 126, 126, 126, 126, 60, 60, 24, 24, 0, 0, 0,
		16, 56, 124, 124, 124, 254, 254, 254, 254, 124, 124, 124, 56, 16, 0, 0,
		0, 0, 16, 40, 40, 80, 60, 120, 20, 40, 40, 16, 0, 0, 0, 0,
		16, 40, 84, 40, 84, 186, 124, 124, 186, 84, 40, 84, 40, 16, 0, 0 ]);

	static #DECODE_ATARI8_SPC_PATTERNS = new Int32Array([ 0, 21845, 43690, 65535, 4420, 8840, 13260, 26265, 30685, 48110, 5457, 10914, 16371, 16388, 27302, 32759,
		32776, 38233, 49147, 49164, 54621, 60078, 21896, 8908, 13124, 17561, 17629, 30617, 35054, 34918, 39406, 52343,
		52411, 56763, 7089, 5465, 5469, 38237, 16392, 16396, 32780, 27308, 10926, 27298, 32763, 16379, 49143, 21892,
		8900, 13128, 17553, 17617, 30609, 35042, 34914, 39393, 52339, 52403, 56755, 21900, 8904, 13132, 17565, 17625,
		30621, 35046, 34926, 39397, 52347, 52407, 56759 ]);

	static #DECODE_ATARI8_SPC_DEFAULT_COLORS = new Uint8Array([ 0, 21, 149, 54 ]);

	static #GET_MCM_SPRITE_OFFSETS = new Uint8Array([ 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 5, 3, 3, 3,
		3, 5, 4, 4 ]);

	static #GET_MCM_SPRITE_BITS = new Uint8Array([ 7, 5, 3, 1, 7, 5, 3, 1, 7, 5, 3, 1, 5, 7, 5, 3,
		1, 7, 7, 5 ]);

	static #DECODE_G2F_UNPACKED_PRIORS = new Uint8Array([ 4, 2, 1, 8, 0 ]);

	static #DECODE_G2F_UNPACKED_GTIA_MODES = new Uint8Array([ 64, 64, 64, 64, 64, 128, 192, 64 ]);

	static #DECODE_TANDY_PNT_PALETTE = new Int32Array([ 0, 153, 39168, 3381657, 10027008, 13382604, 13395456, 10066329, 10053171, 6697983, 3394560, 6737100, 16764108, 16751103, 16776960, 16777215 ]);

	static #DECODE_BK_COLOR_FRAME_PALETTE = new Int32Array([ 0, 255, 65280, 16711680, 0, 16776960, 16711935, 16711680, 0, 65535, 255, 16711935, 0, 65280, 65535, 16776960,
		0, 16711935, 65535, 16777215, 0, 16777215, 16777215, 16777215, 0, 12582912, 8388608, 16711680, 0, 65280, 65535, 16776960,
		0, 12583104, 8388863, 16711935, 0, 16776960, 8388863, 12582912, 0, 16776960, 12583104, 16711680, 0, 65535, 16776960, 16711680,
		0, 16711680, 65280, 65535, 0, 65535, 16776960, 16777215, 0, 16776960, 65280, 16777215, 0, 65535, 65280, 16777215 ]);
}

class Fu
{
	static altirrantsc_pal = new Uint8Array([
		0, 0, 0, 1, 1, 1, 22, 21, 23, 42, 41, 43, 62, 60, 63, 81,
		78, 83, 103, 100, 106, 122, 118, 124, 131, 126, 133, 149, 144, 152, 170, 164,
		173, 188, 181, 192, 205, 198, 210, 223, 215, 227, 243, 235, 248, 255, 252, 255,
		0, 2, 0, 0, 20, 0, 7, 42, 0, 33, 61, 0, 54, 79, 0, 75,
		96, 0, 98, 117, 0, 118, 134, 0, 127, 142, 0, 146, 159, 0, 167, 179,
		39, 186, 196, 63, 203, 213, 85, 221, 230, 106, 242, 249, 129, 255, 255, 148,
		12, 0, 0, 35, 2, 0, 61, 24, 0, 81, 43, 0, 101, 61, 0, 120,
		79, 0, 143, 100, 0, 161, 117, 0, 170, 126, 0, 188, 143, 28, 210, 163,
		58, 228, 180, 80, 245, 197, 100, 255, 214, 120, 255, 234, 143, 255, 251, 162,
		40, 0, 0, 63, 0, 0, 90, 0, 0, 111, 21, 0, 131, 41, 0, 150,
		60, 0, 173, 82, 22, 192, 100, 47, 200, 109, 57, 219, 126, 78, 240, 147,
		101, 255, 164, 121, 255, 182, 140, 255, 199, 158, 255, 219, 180, 255, 236, 198,
		54, 0, 0, 77, 0, 0, 103, 0, 0, 124, 0, 19, 144, 24, 41, 164,
		46, 62, 187, 69, 86, 205, 87, 105, 214, 96, 114, 233, 114, 133, 254, 135,
		155, 255, 153, 173, 255, 170, 191, 255, 188, 209, 255, 208, 231, 255, 225, 248,
		51, 0, 16, 73, 0, 37, 99, 2, 61, 120, 8, 81, 140, 26, 101, 160,
		44, 120, 183, 66, 142, 201, 85, 160, 210, 93, 169, 229, 111, 187, 250, 132,
		209, 255, 150, 227, 255, 167, 244, 255, 184, 255, 255, 204, 255, 255, 221, 255,
		26, 10, 66, 50, 15, 86, 76, 21, 109, 98, 27, 128, 119, 39, 147, 139,
		54, 166, 161, 74, 187, 180, 91, 205, 189, 100, 214, 207, 117, 232, 229, 137,
		253, 246, 154, 255, 255, 171, 255, 255, 188, 255, 255, 208, 255, 255, 225, 255,
		0, 19, 95, 0, 25, 114, 34, 31, 137, 59, 39, 156, 81, 52, 174, 102,
		67, 193, 125, 86, 214, 144, 103, 232, 153, 111, 241, 172, 128, 255, 193, 148,
		255, 211, 165, 255, 229, 182, 255, 246, 198, 255, 255, 218, 255, 255, 235, 255,
		0, 20, 99, 0, 26, 118, 0, 35, 141, 0, 47, 160, 18, 62, 178, 49,
		78, 196, 76, 98, 218, 97, 115, 236, 106, 124, 244, 125, 141, 255, 148, 161,
		255, 166, 178, 255, 185, 194, 255, 203, 211, 255, 224, 231, 255, 241, 248, 255,
		0, 14, 77, 0, 21, 97, 0, 37, 120, 0, 54, 139, 0, 72, 157, 0,
		90, 176, 0, 110, 197, 23, 128, 216, 42, 136, 224, 69, 153, 242, 96, 174,
		255, 117, 191, 255, 137, 208, 255, 156, 224, 255, 179, 244, 255, 197, 255, 255,
		0, 4, 33, 0, 21, 54, 0, 44, 77, 0, 63, 97, 0, 82, 116, 0,
		100, 135, 0, 121, 157, 0, 139, 175, 0, 147, 184, 0, 165, 202, 34, 185,
		223, 69, 202, 241, 94, 219, 255, 117, 236, 255, 142, 255, 255, 162, 255, 255,
		0, 11, 0, 0, 31, 0, 0, 53, 18, 0, 72, 40, 0, 91, 60, 0,
		109, 80, 0, 130, 103, 0, 148, 122, 0, 156, 131, 0, 173, 150, 0, 194,
		171, 40, 211, 190, 74, 227, 208, 100, 244, 225, 127, 255, 246, 148, 255, 255,
		0, 18, 0, 0, 37, 0, 0, 59, 0, 0, 77, 0, 0, 95, 0, 0,
		113, 14, 0, 134, 43, 0, 151, 65, 0, 159, 74, 0, 177, 94, 38, 197,
		117, 72, 214, 136, 97, 230, 154, 119, 247, 173, 144, 255, 194, 164, 255, 212,
		0, 15, 0, 0, 35, 0, 0, 57, 0, 0, 75, 0, 0, 93, 0, 0,
		110, 0, 0, 131, 0, 33, 148, 0, 49, 156, 13, 75, 173, 43, 101, 193,
		70, 122, 210, 90, 142, 227, 110, 161, 243, 130, 183, 255, 152, 201, 255, 171,
		0, 5, 0, 0, 24, 0, 0, 47, 0, 4, 65, 0, 35, 83, 0, 58,
		100, 0, 83, 121, 0, 103, 138, 0, 112, 146, 0, 132, 163, 0, 154, 183,
		41, 172, 200, 65, 190, 217, 86, 208, 233, 107, 229, 253, 130, 247, 255, 149,
		3, 0, 0, 25, 7, 0, 50, 30, 0, 70, 48, 0, 90, 67, 0, 109,
		84, 0, 132, 105, 0, 150, 122, 0, 159, 131, 0, 177, 148, 13, 199, 168,
		49, 217, 185, 72, 234, 202, 93, 252, 219, 113, 255, 239, 136, 255, 255, 155 ]);
	static altirrapal_pal = new Uint8Array([
		0, 0, 0, 17, 17, 17, 34, 34, 34, 51, 51, 51, 68, 68, 68, 85,
		85, 85, 102, 102, 102, 119, 119, 119, 136, 136, 136, 153, 153, 153, 170, 170,
		170, 187, 187, 187, 204, 204, 204, 221, 221, 221, 238, 238, 238, 255, 255, 255,
		63, 0, 0, 80, 5, 0, 97, 22, 0, 114, 39, 0, 131, 56, 0, 148,
		73, 0, 165, 90, 1, 182, 107, 18, 199, 124, 35, 216, 141, 52, 233, 158,
		69, 250, 175, 86, 255, 192, 103, 255, 209, 120, 255, 226, 137, 255, 243, 154,
		80, 0, 0, 97, 0, 0, 114, 3, 0, 131, 20, 3, 148, 37, 20, 165,
		54, 37, 182, 71, 54, 199, 88, 71, 216, 105, 88, 233, 122, 105, 250, 139,
		122, 255, 156, 139, 255, 173, 156, 255, 190, 173, 255, 207, 190, 255, 224, 207,
		84, 0, 3, 101, 0, 20, 118, 0, 37, 135, 8, 54, 152, 25, 71, 169,
		42, 88, 186, 59, 105, 203, 76, 122, 220, 93, 139, 237, 110, 156, 254, 127,
		173, 255, 144, 190, 255, 161, 207, 255, 178, 224, 255, 195, 241, 255, 212, 255,
		79, 0, 53, 96, 0, 70, 113, 0, 87, 130, 1, 104, 147, 18, 121, 164,
		35, 138, 181, 52, 155, 198, 69, 172, 215, 86, 189, 232, 103, 206, 249, 120,
		223, 255, 137, 240, 255, 154, 255, 255, 171, 255, 255, 188, 255, 255, 205, 255,
		61, 0, 104, 78, 0, 121, 95, 0, 138, 112, 0, 155, 129, 17, 172, 146,
		34, 189, 163, 51, 206, 180, 68, 223, 197, 85, 240, 214, 102, 255, 231, 119,
		255, 248, 136, 255, 255, 153, 255, 255, 170, 255, 255, 187, 255, 255, 204, 255,
		32, 0, 139, 49, 0, 156, 66, 0, 173, 83, 8, 190, 100, 25, 207, 117,
		42, 224, 134, 59, 241, 151, 76, 255, 168, 93, 255, 185, 110, 255, 202, 127,
		255, 219, 144, 255, 236, 161, 255, 253, 178, 255, 255, 195, 255, 255, 212, 255,
		0, 0, 137, 0, 8, 154, 0, 25, 171, 16, 42, 188, 33, 59, 205, 50,
		76, 222, 67, 93, 239, 84, 110, 255, 101, 127, 255, 118, 144, 255, 135, 161,
		255, 152, 178, 255, 169, 195, 255, 186, 212, 255, 203, 229, 255, 220, 246, 255,
		0, 12, 101, 0, 29, 118, 0, 46, 135, 0, 63, 152, 5, 80, 169, 22,
		97, 186, 39, 114, 203, 56, 131, 220, 73, 148, 237, 90, 165, 254, 107, 182,
		255, 124, 199, 255, 141, 216, 255, 158, 233, 255, 175, 250, 255, 192, 255, 255,
		0, 31, 48, 0, 48, 65, 0, 65, 82, 0, 82, 99, 0, 99, 116, 5,
		116, 133, 22, 133, 150, 39, 150, 167, 56, 167, 184, 73, 184, 201, 90, 201,
		218, 107, 218, 235, 124, 235, 252, 141, 252, 255, 158, 255, 255, 175, 255, 255,
		0, 43, 0, 0, 60, 14, 0, 77, 31, 0, 94, 48, 0, 111, 65, 1,
		128, 82, 18, 145, 99, 35, 162, 116, 52, 179, 133, 69, 196, 150, 86, 213,
		167, 103, 230, 184, 120, 247, 201, 137, 255, 218, 154, 255, 235, 171, 255, 252,
		0, 51, 0, 0, 68, 0, 0, 85, 0, 0, 102, 0, 7, 119, 0, 24,
		136, 0, 41, 153, 0, 58, 170, 15, 75, 187, 32, 92, 204, 49, 109, 221,
		66, 126, 238, 83, 143, 255, 100, 160, 255, 117, 177, 255, 134, 194, 255, 151,
		0, 43, 0, 0, 60, 0, 2, 77, 0, 19, 94, 0, 36, 111, 0, 53,
		128, 0, 70, 145, 0, 87, 162, 0, 104, 179, 0, 121, 196, 14, 138, 213,
		31, 155, 230, 48, 172, 247, 65, 189, 255, 82, 206, 255, 99, 223, 255, 116,
		1, 28, 0, 18, 45, 0, 35, 62, 0, 52, 79, 0, 69, 96, 0, 86,
		113, 0, 103, 130, 0, 120, 147, 0, 137, 164, 0, 154, 181, 3, 171, 198,
		20, 188, 215, 37, 205, 232, 54, 222, 249, 71, 239, 255, 88, 255, 255, 105,
		35, 9, 0, 52, 26, 0, 69, 43, 0, 86, 60, 0, 103, 77, 0, 120,
		94, 0, 137, 111, 0, 154, 128, 0, 171, 145, 0, 188, 162, 16, 205, 179,
		33, 222, 196, 50, 239, 213, 67, 255, 230, 84, 255, 247, 101, 255, 255, 118,
		63, 0, 0, 80, 5, 0, 97, 22, 0, 114, 39, 0, 131, 56, 0, 148,
		73, 0, 165, 90, 1, 182, 107, 18, 199, 124, 35, 216, 141, 52, 233, 158,
		69, 250, 175, 86, 255, 192, 103, 255, 209, 120, 255, 226, 137, 255, 243, 154 ]);
	static atari8_fnt = new Uint8Array([
		0, 0, 0, 0, 0, 0, 0, 0, 0, 24, 24, 24, 24, 0, 24, 0,
		0, 102, 102, 102, 0, 0, 0, 0, 0, 102, 255, 102, 102, 255, 102, 0,
		24, 62, 96, 60, 6, 124, 24, 0, 0, 102, 108, 24, 48, 102, 70, 0,
		28, 54, 28, 56, 111, 102, 59, 0, 0, 24, 24, 24, 0, 0, 0, 0,
		0, 14, 28, 24, 24, 28, 14, 0, 0, 112, 56, 24, 24, 56, 112, 0,
		0, 102, 60, 255, 60, 102, 0, 0, 0, 24, 24, 126, 24, 24, 0, 0,
		0, 0, 0, 0, 0, 24, 24, 48, 0, 0, 0, 126, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 24, 24, 0, 0, 6, 12, 24, 48, 96, 64, 0,
		0, 60, 102, 110, 118, 102, 60, 0, 0, 24, 56, 24, 24, 24, 126, 0,
		0, 60, 102, 12, 24, 48, 126, 0, 0, 126, 12, 24, 12, 102, 60, 0,
		0, 12, 28, 60, 108, 126, 12, 0, 0, 126, 96, 124, 6, 102, 60, 0,
		0, 60, 96, 124, 102, 102, 60, 0, 0, 126, 6, 12, 24, 48, 48, 0,
		0, 60, 102, 60, 102, 102, 60, 0, 0, 60, 102, 62, 6, 12, 56, 0,
		0, 0, 24, 24, 0, 24, 24, 0, 0, 0, 24, 24, 0, 24, 24, 48,
		6, 12, 24, 48, 24, 12, 6, 0, 0, 0, 126, 0, 0, 126, 0, 0,
		96, 48, 24, 12, 24, 48, 96, 0, 0, 60, 102, 12, 24, 0, 24, 0,
		0, 60, 102, 110, 110, 96, 62, 0, 0, 24, 60, 102, 102, 126, 102, 0,
		0, 124, 102, 124, 102, 102, 124, 0, 0, 60, 102, 96, 96, 102, 60, 0,
		0, 120, 108, 102, 102, 108, 120, 0, 0, 126, 96, 124, 96, 96, 126, 0,
		0, 126, 96, 124, 96, 96, 96, 0, 0, 62, 96, 96, 110, 102, 62, 0,
		0, 102, 102, 126, 102, 102, 102, 0, 0, 126, 24, 24, 24, 24, 126, 0,
		0, 6, 6, 6, 6, 102, 60, 0, 0, 102, 108, 120, 120, 108, 102, 0,
		0, 96, 96, 96, 96, 96, 126, 0, 0, 99, 119, 127, 107, 99, 99, 0,
		0, 102, 118, 126, 126, 110, 102, 0, 0, 60, 102, 102, 102, 102, 60, 0,
		0, 124, 102, 102, 124, 96, 96, 0, 0, 60, 102, 102, 102, 108, 54, 0,
		0, 124, 102, 102, 124, 108, 102, 0, 0, 60, 96, 60, 6, 6, 60, 0,
		0, 126, 24, 24, 24, 24, 24, 0, 0, 102, 102, 102, 102, 102, 126, 0,
		0, 102, 102, 102, 102, 60, 24, 0, 0, 99, 99, 107, 127, 119, 99, 0,
		0, 102, 102, 60, 60, 102, 102, 0, 0, 102, 102, 60, 24, 24, 24, 0,
		0, 126, 12, 24, 48, 96, 126, 0, 0, 30, 24, 24, 24, 24, 30, 0,
		0, 64, 96, 48, 24, 12, 6, 0, 0, 120, 24, 24, 24, 24, 120, 0,
		0, 8, 28, 54, 99, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 0,
		0, 54, 127, 127, 62, 28, 8, 0, 24, 24, 24, 31, 31, 24, 24, 24,
		3, 3, 3, 3, 3, 3, 3, 3, 24, 24, 24, 248, 248, 0, 0, 0,
		24, 24, 24, 248, 248, 24, 24, 24, 0, 0, 0, 248, 248, 24, 24, 24,
		3, 7, 14, 28, 56, 112, 224, 192, 192, 224, 112, 56, 28, 14, 7, 3,
		1, 3, 7, 15, 31, 63, 127, 255, 0, 0, 0, 0, 15, 15, 15, 15,
		128, 192, 224, 240, 248, 252, 254, 255, 15, 15, 15, 15, 0, 0, 0, 0,
		240, 240, 240, 240, 0, 0, 0, 0, 255, 255, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 255, 255, 0, 0, 0, 0, 240, 240, 240, 240,
		0, 28, 28, 119, 119, 8, 28, 0, 0, 0, 0, 31, 31, 24, 24, 24,
		0, 0, 0, 255, 255, 0, 0, 0, 24, 24, 24, 255, 255, 24, 24, 24,
		0, 0, 60, 126, 126, 126, 60, 0, 0, 0, 0, 0, 255, 255, 255, 255,
		192, 192, 192, 192, 192, 192, 192, 192, 0, 0, 0, 255, 255, 24, 24, 24,
		24, 24, 24, 255, 255, 0, 0, 0, 240, 240, 240, 240, 240, 240, 240, 240,
		24, 24, 24, 31, 31, 0, 0, 0, 120, 96, 120, 96, 126, 24, 30, 0,
		0, 24, 60, 126, 24, 24, 24, 0, 0, 24, 24, 24, 126, 60, 24, 0,
		0, 24, 48, 126, 48, 24, 0, 0, 0, 24, 12, 126, 12, 24, 0, 0,
		0, 24, 60, 126, 126, 60, 24, 0, 0, 0, 60, 6, 62, 102, 62, 0,
		0, 96, 96, 124, 102, 102, 124, 0, 0, 0, 60, 96, 96, 96, 60, 0,
		0, 6, 6, 62, 102, 102, 62, 0, 0, 0, 60, 102, 126, 96, 60, 0,
		0, 14, 24, 62, 24, 24, 24, 0, 0, 0, 62, 102, 102, 62, 6, 124,
		0, 96, 96, 124, 102, 102, 102, 0, 0, 24, 0, 56, 24, 24, 60, 0,
		0, 6, 0, 6, 6, 6, 6, 60, 0, 96, 96, 108, 120, 108, 102, 0,
		0, 56, 24, 24, 24, 24, 60, 0, 0, 0, 102, 127, 127, 107, 99, 0,
		0, 0, 124, 102, 102, 102, 102, 0, 0, 0, 60, 102, 102, 102, 60, 0,
		0, 0, 124, 102, 102, 124, 96, 96, 0, 0, 62, 102, 102, 62, 6, 6,
		0, 0, 124, 102, 96, 96, 96, 0, 0, 0, 62, 96, 60, 6, 124, 0,
		0, 24, 126, 24, 24, 24, 14, 0, 0, 0, 102, 102, 102, 102, 62, 0,
		0, 0, 102, 102, 102, 60, 24, 0, 0, 0, 99, 107, 127, 62, 54, 0,
		0, 0, 102, 60, 24, 60, 102, 0, 0, 0, 102, 102, 102, 62, 12, 120,
		0, 0, 126, 12, 24, 48, 126, 0, 0, 24, 60, 126, 126, 24, 60, 0,
		24, 24, 24, 24, 24, 24, 24, 24, 0, 126, 120, 124, 110, 102, 6, 0,
		8, 24, 56, 120, 56, 24, 8, 0, 16, 24, 28, 30, 28, 24, 16, 0 ]);
	static c16_pal = new Uint8Array([
		3, 3, 3, 47, 47, 47, 104, 16, 16, 0, 66, 66, 88, 0, 109, 0,
		78, 0, 25, 28, 148, 56, 56, 0, 86, 32, 0, 75, 40, 0, 22, 72,
		0, 105, 7, 47, 0, 70, 38, 6, 42, 128, 42, 20, 155, 11, 73, 0,
		3, 3, 3, 61, 61, 61, 117, 30, 32, 0, 80, 79, 106, 16, 120, 4,
		92, 0, 42, 42, 163, 76, 71, 0, 105, 47, 0, 89, 56, 0, 38, 86,
		0, 117, 21, 65, 0, 88, 61, 21, 61, 143, 57, 34, 174, 25, 89, 0,
		3, 3, 3, 66, 66, 66, 123, 40, 32, 2, 86, 89, 111, 26, 130, 10,
		101, 9, 48, 52, 167, 80, 81, 0, 110, 54, 0, 101, 64, 0, 44, 92,
		0, 125, 30, 69, 1, 97, 69, 28, 69, 153, 66, 45, 173, 29, 98, 0,
		3, 3, 3, 86, 85, 90, 144, 60, 59, 23, 109, 114, 135, 45, 153, 31,
		123, 21, 70, 73, 193, 102, 99, 0, 132, 76, 13, 115, 85, 0, 64, 114,
		0, 145, 51, 94, 25, 116, 92, 50, 89, 174, 89, 63, 195, 50, 118, 0,
		3, 3, 3, 132, 126, 133, 187, 103, 104, 69, 150, 150, 175, 88, 195, 74,
		167, 62, 115, 115, 236, 146, 141, 17, 175, 120, 50, 161, 128, 32, 108, 158,
		18, 186, 95, 137, 70, 159, 131, 97, 133, 221, 132, 108, 239, 93, 163, 41,
		3, 3, 3, 178, 172, 179, 233, 146, 146, 108, 195, 193, 217, 134, 240, 121,
		209, 118, 157, 161, 255, 189, 190, 64, 220, 162, 97, 209, 169, 76, 147, 200,
		61, 233, 138, 177, 111, 205, 171, 138, 180, 255, 178, 154, 255, 136, 203, 89,
		3, 3, 3, 202, 202, 202, 255, 172, 172, 133, 216, 224, 243, 156, 255, 146,
		234, 138, 183, 186, 255, 214, 211, 91, 243, 190, 121, 230, 197, 101, 176, 224,
		87, 255, 164, 207, 137, 229, 200, 164, 202, 255, 200, 184, 255, 162, 229, 122,
		3, 3, 3, 249, 249, 249, 255, 246, 242, 209, 255, 255, 255, 233, 255, 219,
		255, 211, 240, 255, 255, 255, 255, 163, 255, 255, 193, 255, 255, 178, 252, 255,
		162, 255, 238, 255, 209, 255, 255, 235, 255, 255, 255, 248, 255, 237, 255, 188 ]);
	static c64_fnt = new Uint8Array([
		60, 102, 110, 110, 96, 98, 60, 0, 24, 60, 102, 126, 102, 102, 102, 0,
		124, 102, 102, 124, 102, 102, 124, 0, 60, 102, 96, 96, 96, 102, 60, 0,
		120, 108, 102, 102, 102, 108, 120, 0, 126, 96, 96, 120, 96, 96, 126, 0,
		126, 96, 96, 120, 96, 96, 96, 0, 60, 102, 96, 110, 102, 102, 60, 0,
		102, 102, 102, 126, 102, 102, 102, 0, 60, 24, 24, 24, 24, 24, 60, 0,
		30, 12, 12, 12, 12, 108, 56, 0, 102, 108, 120, 112, 120, 108, 102, 0,
		96, 96, 96, 96, 96, 96, 126, 0, 99, 119, 127, 107, 99, 99, 99, 0,
		102, 118, 126, 126, 110, 102, 102, 0, 60, 102, 102, 102, 102, 102, 60, 0,
		124, 102, 102, 124, 96, 96, 96, 0, 60, 102, 102, 102, 102, 60, 14, 0,
		124, 102, 102, 124, 120, 108, 102, 0, 60, 102, 96, 60, 6, 102, 60, 0,
		126, 24, 24, 24, 24, 24, 24, 0, 102, 102, 102, 102, 102, 102, 60, 0,
		102, 102, 102, 102, 102, 60, 24, 0, 99, 99, 99, 107, 127, 119, 99, 0,
		102, 102, 60, 24, 60, 102, 102, 0, 102, 102, 102, 60, 24, 24, 24, 0,
		126, 6, 12, 24, 48, 96, 126, 0, 60, 48, 48, 48, 48, 48, 60, 0,
		12, 18, 48, 124, 48, 98, 252, 0, 60, 12, 12, 12, 12, 12, 60, 0,
		0, 24, 60, 126, 24, 24, 24, 24, 0, 16, 48, 127, 127, 48, 16, 0,
		0, 0, 0, 0, 0, 0, 0, 0, 24, 24, 24, 24, 0, 0, 24, 0,
		102, 102, 102, 0, 0, 0, 0, 0, 102, 102, 255, 102, 255, 102, 102, 0,
		24, 62, 96, 60, 6, 124, 24, 0, 98, 102, 12, 24, 48, 102, 70, 0,
		60, 102, 60, 56, 103, 102, 63, 0, 6, 12, 24, 0, 0, 0, 0, 0,
		12, 24, 48, 48, 48, 24, 12, 0, 48, 24, 12, 12, 12, 24, 48, 0,
		0, 102, 60, 255, 60, 102, 0, 0, 0, 24, 24, 126, 24, 24, 0, 0,
		0, 0, 0, 0, 0, 24, 24, 48, 0, 0, 0, 126, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 24, 24, 0, 0, 3, 6, 12, 24, 48, 96, 0,
		60, 102, 110, 118, 102, 102, 60, 0, 24, 24, 56, 24, 24, 24, 126, 0,
		60, 102, 6, 12, 48, 96, 126, 0, 60, 102, 6, 28, 6, 102, 60, 0,
		6, 14, 30, 102, 127, 6, 6, 0, 126, 96, 124, 6, 6, 102, 60, 0,
		60, 102, 96, 124, 102, 102, 60, 0, 126, 102, 12, 24, 24, 24, 24, 0,
		60, 102, 102, 60, 102, 102, 60, 0, 60, 102, 102, 62, 6, 102, 60, 0,
		0, 0, 24, 0, 0, 24, 0, 0, 0, 0, 24, 0, 0, 24, 24, 48,
		14, 24, 48, 96, 48, 24, 14, 0, 0, 0, 126, 0, 126, 0, 0, 0,
		112, 24, 12, 6, 12, 24, 112, 0, 60, 102, 6, 12, 24, 0, 24, 0,
		0, 0, 0, 255, 255, 0, 0, 0, 8, 28, 62, 127, 127, 28, 62, 0,
		24, 24, 24, 24, 24, 24, 24, 24, 0, 0, 0, 255, 255, 0, 0, 0,
		0, 0, 255, 255, 0, 0, 0, 0, 0, 255, 255, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 255, 255, 0, 0, 48, 48, 48, 48, 48, 48, 48, 48,
		12, 12, 12, 12, 12, 12, 12, 12, 0, 0, 0, 224, 240, 56, 24, 24,
		24, 24, 28, 15, 7, 0, 0, 0, 24, 24, 56, 240, 224, 0, 0, 0,
		192, 192, 192, 192, 192, 192, 255, 255, 192, 224, 112, 56, 28, 14, 7, 3,
		3, 7, 14, 28, 56, 112, 224, 192, 255, 255, 192, 192, 192, 192, 192, 192,
		255, 255, 3, 3, 3, 3, 3, 3, 0, 60, 126, 126, 126, 126, 60, 0,
		0, 0, 0, 0, 0, 255, 255, 0, 54, 127, 127, 127, 62, 28, 8, 0,
		96, 96, 96, 96, 96, 96, 96, 96, 0, 0, 0, 7, 15, 28, 24, 24,
		195, 231, 126, 60, 60, 126, 231, 195, 0, 60, 126, 102, 102, 126, 60, 0,
		24, 24, 102, 102, 24, 24, 60, 0, 6, 6, 6, 6, 6, 6, 6, 6,
		8, 28, 62, 127, 62, 28, 8, 0, 24, 24, 24, 255, 255, 24, 24, 24,
		192, 192, 48, 48, 192, 192, 48, 48, 24, 24, 24, 24, 24, 24, 24, 24,
		0, 0, 3, 62, 118, 54, 54, 0, 255, 127, 63, 31, 15, 7, 3, 1,
		0, 0, 0, 0, 0, 0, 0, 0, 240, 240, 240, 240, 240, 240, 240, 240,
		0, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0,
		0, 0, 0, 0, 0, 0, 0, 255, 192, 192, 192, 192, 192, 192, 192, 192,
		204, 204, 51, 51, 204, 204, 51, 51, 3, 3, 3, 3, 3, 3, 3, 3,
		0, 0, 0, 0, 204, 204, 51, 51, 255, 254, 252, 248, 240, 224, 192, 128,
		3, 3, 3, 3, 3, 3, 3, 3, 24, 24, 24, 31, 31, 24, 24, 24,
		0, 0, 0, 0, 15, 15, 15, 15, 24, 24, 24, 31, 31, 0, 0, 0,
		0, 0, 0, 248, 248, 24, 24, 24, 0, 0, 0, 0, 0, 0, 255, 255,
		0, 0, 0, 31, 31, 24, 24, 24, 24, 24, 24, 255, 255, 0, 0, 0,
		0, 0, 0, 255, 255, 24, 24, 24, 24, 24, 24, 248, 248, 24, 24, 24,
		192, 192, 192, 192, 192, 192, 192, 192, 224, 224, 224, 224, 224, 224, 224, 224,
		7, 7, 7, 7, 7, 7, 7, 7, 255, 255, 0, 0, 0, 0, 0, 0,
		255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255,
		3, 3, 3, 3, 3, 3, 255, 255, 0, 0, 0, 0, 240, 240, 240, 240,
		15, 15, 15, 15, 0, 0, 0, 0, 24, 24, 24, 248, 248, 0, 0, 0,
		240, 240, 240, 240, 0, 0, 0, 0, 240, 240, 240, 240, 15, 15, 15, 15 ]);
	static zx81_fnt = new Uint8Array([
		0, 0, 0, 0, 0, 0, 0, 0, 240, 240, 240, 240, 0, 0, 0, 0,
		15, 15, 15, 15, 0, 0, 0, 0, 255, 255, 255, 255, 0, 0, 0, 0,
		0, 0, 0, 0, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240, 240,
		15, 15, 15, 15, 240, 240, 240, 240, 255, 255, 255, 255, 240, 240, 240, 240,
		170, 85, 170, 85, 170, 85, 170, 85, 0, 0, 0, 0, 170, 85, 170, 85,
		170, 85, 170, 85, 0, 0, 0, 0, 0, 36, 36, 0, 0, 0, 0, 0,
		0, 28, 34, 120, 32, 32, 126, 0, 0, 8, 62, 40, 62, 10, 62, 8,
		0, 0, 0, 16, 0, 0, 16, 0, 0, 60, 66, 4, 8, 0, 8, 0,
		0, 4, 8, 8, 8, 8, 4, 0, 0, 32, 16, 16, 16, 16, 32, 0,
		0, 0, 16, 8, 4, 8, 16, 0, 0, 0, 4, 8, 16, 8, 4, 0,
		0, 0, 0, 62, 0, 62, 0, 0, 0, 0, 8, 8, 62, 8, 8, 0,
		0, 0, 0, 0, 62, 0, 0, 0, 0, 0, 20, 8, 62, 8, 20, 0,
		0, 0, 2, 4, 8, 16, 32, 0, 0, 0, 16, 0, 0, 16, 16, 32,
		0, 0, 0, 0, 0, 8, 8, 16, 0, 0, 0, 0, 0, 24, 24, 0,
		0, 60, 70, 74, 82, 98, 60, 0, 0, 24, 40, 8, 8, 8, 62, 0,
		0, 60, 66, 2, 60, 64, 126, 0, 0, 60, 66, 12, 2, 66, 60, 0,
		0, 8, 24, 40, 72, 126, 8, 0, 0, 126, 64, 124, 2, 66, 60, 0,
		0, 60, 64, 124, 66, 66, 60, 0, 0, 126, 2, 4, 8, 16, 16, 0,
		0, 60, 66, 60, 66, 66, 60, 0, 0, 60, 66, 66, 62, 2, 60, 0,
		0, 60, 66, 66, 126, 66, 66, 0, 0, 124, 66, 124, 66, 66, 124, 0,
		0, 60, 66, 64, 64, 66, 60, 0, 0, 120, 68, 66, 66, 68, 120, 0,
		0, 126, 64, 124, 64, 64, 126, 0, 0, 126, 64, 124, 64, 64, 64, 0,
		0, 60, 66, 64, 78, 66, 60, 0, 0, 66, 66, 126, 66, 66, 66, 0,
		0, 62, 8, 8, 8, 8, 62, 0, 0, 2, 2, 2, 66, 66, 60, 0,
		0, 68, 72, 112, 72, 68, 66, 0, 0, 64, 64, 64, 64, 64, 126, 0,
		0, 66, 102, 90, 66, 66, 66, 0, 0, 66, 98, 82, 74, 70, 66, 0,
		0, 60, 66, 66, 66, 66, 60, 0, 0, 124, 66, 66, 124, 64, 64, 0,
		0, 60, 66, 66, 82, 74, 60, 0, 0, 124, 66, 66, 124, 68, 66, 0,
		0, 60, 64, 60, 2, 66, 60, 0, 0, 254, 16, 16, 16, 16, 16, 0,
		0, 66, 66, 66, 66, 66, 60, 0, 0, 66, 66, 66, 66, 36, 24, 0,
		0, 66, 66, 66, 66, 90, 36, 0, 0, 66, 36, 24, 24, 36, 66, 0,
		0, 130, 68, 40, 16, 16, 16, 0, 0, 126, 4, 8, 16, 32, 126, 0 ]);

}

if (typeof module !== "undefined" && module.exports) module.exports = RECOIL;
else root.RECOIL = RECOIL;
})(typeof globalThis !== "undefined" ? globalThis : this);
