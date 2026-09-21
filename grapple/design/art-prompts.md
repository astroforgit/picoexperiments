# Title screen art prompts — comic-ink, 80s

Ready to fire at the Hugging Face MCP (`hf-mcp-server`, FLUX.1-schnell) once
`HF_TOKEN` is set and the session has restarted. Two variants, because the
converter takes either a cutout figure or a whole frame.

Style target: hard black ink linework over flat cel colour, the way 80s comic
interiors were printed — spot colours, halftone screentone in the shadows, no
soft airbrush gradients. This matters for the port: flat ink art survives
quantization to 63 colours almost losslessly, where a painted render turns to
mud. Run it with `--no-dither`; dithering fights hard-edged linework.

## A. Character cutout (preferred)

Composites over the generated cave background, so the figure needs a plain
background that keys out cleanly. Generate tall — 768x1344 or similar.

> Full body pin-up of a redhead action heroine, 1980s comic book interior art,
> bold black ink linework, flat cel colour, halftone screentone shading, heavy
> spot blacks. She wears a fitted crimson bodysuit with black gloves and
> knee-high black boots, a utility belt with a coiled rope. Long wild red hair.
> She holds a steel three-prong grappling hook raised in one hand, rope
> trailing down. Confident stance, chin up, looking at the viewer. Strong
> silhouette, high contrast, limited palette of red, black, cream and steel
> grey. Flat solid teal background, no scenery, no text, full figure from head
> to boots, centered.

Convert with:

    python3 make_title.py generated.png --fit cutout --no-dither

If the background does not key out on its own, cut it first — the flat teal is
chosen to be far from every colour in the figure, so a colour-distance key is
trivial.

## B. Full title frame

For a complete illustrated scene behind the type. Generate at 1280x800 (320x200
is 8:5, so this crops cleanly).

> 1980s comic book cover, bold black ink linework and flat cel colour with
> halftone screentone. A redhead heroine in a fitted crimson bodysuit and
> black knee-high boots stands on a rock ledge at the right, holding a steel
> grappling hook, rope trailing off the top of the frame. Behind her a vast
> dark cave chasm plunges into orange lava glow far below, jagged rock walls
> framing the edges. Dramatic underlighting from the lava, deep spot blacks,
> limited palette of red, black, orange and steel blue. Empty dark space on
> the left third of the image for a logo. No text, no lettering.

Convert with:

    python3 make_title.py generated.png --fit cover --no-dither

The left-third instruction matters: the logo and the four menu items live
there, and the converter's shadow panel can only do so much if the art is busy
under them. Add `--no-panel` if the generated art is already dark enough there.

## Notes for whoever runs this

- Ask for "no text" every time. Generators produce garbled lettering, and the
  real type is composited afterwards from the game's own deluxe16 font.
- Keep the palette instruction in the prompt. Naming four or five colours up
  front does more for the 63-colour conversion than any amount of tuning after.
- FLUX.1-schnell ignores negative prompts; it is a distilled few-step model.
  Push exclusions positively instead ("flat solid background" rather than "no
  background clutter").
