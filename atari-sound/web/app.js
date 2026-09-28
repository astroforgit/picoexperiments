import { asapWeb } from './vendor/asapweb.js';

const $ = id => document.getElementById(id);
const state = { collection: 'pico', page: 0, query: '', includeSfx: false, data: null, current: null, file: null, bytes: null, request: 0 };
const PAGE_SIZE = 25;
const cache = new Map();
const midiAudio = new Audio();

function pathFor(track, side, bank = 0) {
  const segments = state.collection === 'pico'
    ? [side === 'original' ? 'mscsrc' : 'rmt-variations', track.id, (side === 'original' ? track.banks : track.variations)[bank]]
    : state.collection === 'midi'
      ? [side === 'midi' ? track.midi : side === 'preview' ? track.audio : track.file]
      : ['remixes', track.id, side === 'original' ? 'original.sap' : 'remix.sap'];
  return '../' + segments.map(encodeURIComponent).join('/');
}
function formatTime(seconds) {
  if (!Number.isFinite(seconds) || seconds < 0) return '—:—';
  return `${Math.floor(seconds / 60)}:${String(Math.floor(seconds % 60)).padStart(2, '0')}`;
}
function filtered() {
  const q = state.query.trim().toLocaleLowerCase();
  return state.data[state.collection].filter(t => {
    if (state.collection === 'pico' && !state.includeSfx && t.kind !== 'music') return false;
    return !q || [t.title, t.remix, t.author, t.donor].some(v => v?.toLocaleLowerCase().includes(q));
  });
}
function render() {
  const rows = filtered();
  const pages = Math.max(1, Math.ceil(rows.length / PAGE_SIZE));
  state.page = Math.min(state.page, pages - 1);
  const list = $('track-list');
  list.replaceChildren();
  if (!rows.length) {
    const empty = document.createElement('div'); empty.className = 'empty'; empty.textContent = 'No tracks match your search.'; list.append(empty);
  }
  for (const track of rows.slice(state.page * PAGE_SIZE, (state.page + 1) * PAGE_SIZE)) {
    const row = document.createElement('div'); row.className = `track-row${state.collection === 'midi' ? ' midi-row' : ''}`; row.setAttribute('role', 'listitem');
    const name = document.createElement('div');
    const title = document.createElement('span'); title.className = 'track-name'; title.textContent = track.title;
    const sub = document.createElement('span'); sub.className = 'track-sub';
    sub.textContent = state.collection === 'pico'
      ? (track.kind === 'music' ? `${track.donor || 'RMT instruments'} · ${track.banks.length} bank${track.banks.length === 1 ? '' : 's'}` : `SFX audition · ${track.donor || 'RMT instruments'}`)
      : state.collection === 'midi'
        ? `MIDI arrangement · ${track.donor} instruments · ${formatTime(track.duration)}`
        : `${track.author && track.author !== '<?>' ? track.author + ' · ' : ''}${track.remix} · ${formatTime(track.duration)}`;
    name.append(title, sub);
    const actions = document.createElement('div'); actions.className = 'row-actions';
    for (const side of state.collection === 'midi' ? ['preview', 'rmt'] : ['original', 'variation']) {
      const button = document.createElement('button'); button.className = `play-version ${side === 'variation' ? 'secondary' : ''}`;
      button.textContent = side === 'preview' ? '▶ MIDI' : side === 'rmt' ? '▶ RMT' : side === 'original' ? '▶ Original' : (state.collection === 'pico' ? '▶ RMT' : '▶ Remix');
      button.setAttribute('aria-label', `Play ${side === 'preview' ? 'original MIDI rendition' : side === 'rmt' ? 'RMT conversion' : side === 'original' ? 'original' : state.collection === 'pico' ? 'RMT variation' : 'remix'} of ${track.title}`);
      if (state.current?.id === track.id && state.current?.side === side && state.current?.collection === state.collection) button.classList.add('active');
      button.addEventListener('click', () => play(track, side)); actions.append(button);
    }
    if (state.collection === 'midi') {
      for (const side of ['midi', 'rmt']) {
        const download = document.createElement('a');
        download.className = 'play-version download-link';
        download.href = pathFor(track, side);
        download.download = side === 'midi' ? track.midi : track.file;
        download.textContent = side === 'midi' ? '↓ MIDI' : '↓ RMT';
        download.setAttribute('aria-label', `Download ${track.title} ${side.toUpperCase()} file`);
        actions.append(download);
      }
    }
    row.append(name, actions); list.append(row);
  }
  $('result-count').textContent = `${rows.length} tracks · showing ${rows.length ? state.page * PAGE_SIZE + 1 : 0}–${Math.min(rows.length, (state.page + 1) * PAGE_SIZE)}`;
  $('page-label').textContent = `${state.page + 1} / ${pages}`;
  $('prev-page').disabled = state.page === 0; $('next-page').disabled = state.page >= pages - 1;
}
function setCollection(collection) {
  if (state.collection !== collection) stop();
  state.collection = collection; state.page = 0; state.query = ''; $('search').value = '';
  for (const button of document.querySelectorAll('.tab')) { const active = button.dataset.tab === collection; button.classList.toggle('active', active); button.setAttribute('aria-selected', String(active)); }
  const labels = {
    pico: ['PICO-8 → ATARI', 'PICO conversions', 'Original PICO music conversions and versions using RMT instruments.', 'Search games or RMT donors'],
    remixes: ['ATARI ORIGINALS → NEW ARRANGEMENTS', 'Atari remixes', 'Classic Atari tracks beside new arrangements. Choose either version.', 'Search titles, remixes or composers'],
    midi: ['MIDI → RASTER MUSIC TRACKER', 'MIDI to RMT', 'Hear the original MIDI rendition beside its four-voice POKEY arrangement, and download either file.', 'Search MIDI conversions'],
  }[collection];
  $('section-kicker').textContent = labels[0];
  $('section-title').textContent = labels[1];
  $('section-description').textContent = labels[2];
  $('search').placeholder = labels[3];
  $('sfx-option').hidden = collection !== 'pico'; render();
}
async function play(track, side, bank = 0, song) {
  const collection = state.collection;
  const request = ++state.request;
  const file = pathFor(track, side, bank);
  $('playing-title').textContent = track.title;
  $('playing-version').textContent = 'Loading…';
  try {
    if (collection === 'midi' && side === 'preview') {
      stopEngines();
      state.current = { ...track, side, collection, bank: 0 };
      state.file = file; state.bytes = null;
      midiAudio.src = file;
      $('playing-version').textContent = 'Original MIDI · General MIDI rendition';
      $('pause').disabled = false; $('pause').textContent = 'Ⅱ'; $('stop').disabled = false;
      $('bank').replaceChildren(); $('bank').disabled = true;
      $('song').replaceChildren(); $('song').disabled = true;
      $('elapsed').textContent = '0:00'; $('duration').textContent = formatTime(track.duration);
      $('seek').disabled = false; $('seek').max = String(track.duration * 1000); $('seek').value = '0';
      render();
      await midiAudio.play();
      return;
    }
    let bytes = cache.get(file);
    if (!bytes) {
      const response = await fetch(file);
      if (!response.ok) throw new Error(`Audio file unavailable (${response.status})`);
      bytes = new Uint8Array(await response.arrayBuffer());
      cache.set(file, bytes);
      if (cache.size > 24) cache.delete(cache.keys().next().value);
    }
    if (request !== state.request) return;
    stopEngines();
    // ASAP's official browser player renders the Atari 6502/POKEY sound locally.
    asapWeb.playContent(file, bytes, song);
    if (!asapWeb.asap) throw new Error('ASAP could not open this track');
    asapWeb.onUpdate = updateProgress;
    state.current = { ...track, side, collection, bank };
    state.file = file; state.bytes = bytes;
    $('playing-version').textContent = collection === 'midi' ? `RMT · ${track.donor} instruments` : side === 'original' ? 'Original Atari sound' : collection === 'pico' ? `${track.donor || 'RMT instrument version'}` : `Remix: ${track.remix}`;
    $('pause').disabled = false; $('pause').textContent = 'Ⅱ'; $('stop').disabled = false;
    const banks = collection === 'pico' ? (side === 'original' ? track.banks : track.variations) : collection === 'midi' ? [track.file] : [file];
    $('bank').replaceChildren();
    banks.forEach((filename, i) => $('bank').add(new Option(filename.replace('.sap', '').replace('MUSIC', 'Bank ') || `Bank ${i + 1}`, String(i))));
    $('bank').value = String(bank); $('bank').disabled = banks.length < 2;
    const info = asapWeb.asap.getInfo();
    $('song').replaceChildren();
    for (let i = 0; i < info.getSongs(); i++) $('song').add(new Option(`Song ${i + 1}`, String(i)));
    $('song').value = String(song ?? info.getDefaultSong()); $('song').disabled = info.getSongs() < 2;
    updateProgress(); render();
  } catch (error) {
    if (request !== state.request) return;
    $('playing-version').textContent = error.message;
    console.error(error);
  }
}
function updateProgress() {
  if (!state.current) return;
  if (state.current.side === 'preview') {
    const duration = Number.isFinite(midiAudio.duration) ? midiAudio.duration : state.current.duration;
    const elapsed = midiAudio.currentTime;
    $('elapsed').textContent = formatTime(elapsed);
    $('duration').textContent = formatTime(duration);
    $('seek').disabled = !duration;
    if (duration && document.activeElement !== $('seek')) { $('seek').max = String(Math.round(duration * 1000)); $('seek').value = String(Math.round(elapsed * 1000)); }
    return;
  }
  if (!asapWeb.asap) return;
  const info = asapWeb.asap.getInfo();
  const song = Number($('song').value || info.getDefaultSong());
  const duration = info.getDuration(song);
  const elapsed = asapWeb.asap.getPosition();
  $('elapsed').textContent = formatTime(elapsed / 1000);
  $('duration').textContent = formatTime(duration / 1000);
  $('seek').disabled = duration <= 0;
  if (duration > 0 && document.activeElement !== $('seek')) { $('seek').max = String(duration); $('seek').value = String(Math.min(duration, elapsed)); }
}
function stopEngines() {
  midiAudio.pause();
  midiAudio.removeAttribute('src');
  midiAudio.load();
  asapWeb.stop();
  if (asapWeb.context) { asapWeb.context.close(); delete asapWeb.context; }
  delete asapWeb.asap;
}
function stop() {
  ++state.request;
  stopEngines();
  state.current = null; state.file = null; state.bytes = null;
  $('playing-title').textContent = 'Choose a track'; $('playing-version').textContent = 'Select a version to listen';
  $('pause').disabled = true; $('stop').disabled = true; $('bank').disabled = true; $('song').disabled = true; $('seek').disabled = true;
  $('elapsed').textContent = '0:00'; $('duration').textContent = '—:—'; $('seek').value = '0'; render();
}
async function main() {
  const response = await fetch('./tracks.json');
  if (!response.ok) throw new Error('Could not load catalog');
  state.data = await response.json();
  $('pico-count').textContent = state.data.pico.filter(t => t.kind === 'music').length;
  $('remix-count').textContent = state.data.remixes.length;
  $('midi-count').textContent = state.data.midi.length;
  document.querySelectorAll('.tab').forEach(button => button.addEventListener('click', () => setCollection(button.dataset.tab)));
  $('search').addEventListener('input', e => { state.query = e.target.value; state.page = 0; render(); });
  $('include-sfx').addEventListener('change', e => { state.includeSfx = e.target.checked; state.page = 0; render(); });
  $('prev-page').addEventListener('click', () => { state.page--; render(); });
  $('next-page').addEventListener('click', () => { state.page++; render(); });
  midiAudio.addEventListener('timeupdate', updateProgress);
  midiAudio.addEventListener('loadedmetadata', updateProgress);
  midiAudio.addEventListener('ended', () => { if (state.current?.side === 'preview') { $('pause').textContent = '▶'; $('pause').setAttribute('aria-label', 'Replay'); updateProgress(); } });
  $('pause').addEventListener('click', async () => {
    if (state.current?.side === 'preview') {
      if (midiAudio.paused) { try { await midiAudio.play(); } catch (error) { $('playing-version').textContent = error.message; } }
      else midiAudio.pause();
      $('pause').textContent = midiAudio.paused ? '▶' : 'Ⅱ';
      $('pause').setAttribute('aria-label', midiAudio.paused ? 'Resume' : 'Pause');
    } else {
      const paused = asapWeb.togglePause(); $('pause').textContent = paused ? '▶' : 'Ⅱ'; $('pause').setAttribute('aria-label', paused ? 'Resume' : 'Pause');
    }
  });
  $('stop').addEventListener('click', stop);
  $('bank').addEventListener('change', () => { if (state.current) play(state.current, state.current.side, Number($('bank').value)); });
  $('song').addEventListener('change', () => { if (state.current) play(state.current, state.current.side, state.current.bank, Number($('song').value)); });
  $('seek').addEventListener('change', () => { if (state.current) { if (state.current.side === 'preview') midiAudio.currentTime = Number($('seek').value) / 1000; else asapWeb.seek(Number($('seek').value)); updateProgress(); } });
  setCollection('pico');
}
main().catch(error => { $('track-list').textContent = `Unable to load the music catalog: ${error.message}. Start a local HTTP server as described in README.md.`; console.error(error); });
