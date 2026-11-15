# Stillwater

An original, quiet pixel-art evening: a cabin, mountain lake, dock and resting traveler.

Open `index.html` in a modern browser. No installation, server, network connection or external assets are required. This is a silent visual animation; no music is included.

- **Pause / Play** stops or resumes the scene. Space works when the page body has focus.
- **Fullscreen** expands the artwork; Escape returns to the page.
- The initial scene is paused when your system requests reduced motion.
- Rendering uses a 320 × 180 canvas with crisp nearest-neighbor scaling.
- All movement repeats every 24 seconds. Background tabs freeze the scene.

## Edit

`scene.js` contains the palette, layered drawing and animation. `style.css` controls the surrounding page. The artwork is drawn with Canvas primitives and has no dependencies. Adjust `LOOP` to change the duration. Keep animated sine/cosine frequencies at integer multiples of the common phase to preserve the loop.

For a local HTTP preview, run `python3 -m http.server 8080` in this directory and visit http://localhost:8080.

The development hook `window.stillwater.draw(seconds)` renders a specific frame; `window.stillwater.loopSeconds` reports the duration. Pause playback before using the hook in the browser console.
