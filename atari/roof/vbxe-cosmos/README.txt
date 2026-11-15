Star Fisher: Paris cosmic sky, VBXE graphics asset

320 x 240 pixels, 8-bit indexed, 320-byte row stride.
PNG and BMP contain the indexed palette.
RAW: 76800 bytes, top-to-bottom rows, left-to-right pixels; no header.
PAL: 768 bytes, 256 RGB triplets, 8-bit register-scale components.
Palette components have their least significant bit cleared.
Index 0 is reserved and unused; opaque pixels use indices 1..255.

Loader requirements: configure VBXE SR graphics, normal 320-pixel
width, 240 scanlines, OVSTEP 320. Load RAW into VBXE VRAM and
point the XDL overlay address to it. Load PAL into overlay palette 1
when the colour attribute map is disabled. Use OV_COLOR_SHIFT 0
and disable trans15. These files do not include an XDL or executable.
240 scanlines assumes a suitable display configuration (PAL target).
Not tested on hardware or in an emulator.

Artwork created with built-in image generation; resized and indexed
with Pillow. Preview uses nearest-neighbour 3x enlargement.
Prompt direction: preserve grainy Paris rooftops and fisherman;
add many stars, two moons, a galactic band, comets and shooting stars.

Reference: VBXE FX Programmer's Manual, Overlay Modes and XDL:
https://www.mathyvannisselroy.nl/VBXE/VBXE%20fx_en.pdf
