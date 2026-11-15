const SVG = 'http://www.w3.org/2000/svg';
const $ = (id) => document.getElementById(id);
const state = { data: null, selected: 1, query: '', capitalsOnly: false, showRails: true };
const byId = (id) => state.data.cities[id - 1];

function svg(tag, attrs = {}) {
  const element = document.createElementNS(SVG, tag);
  Object.entries(attrs).forEach(([name, value]) => element.setAttribute(name, value));
  return element;
}
function hex(byte) { return '$' + byte.toString(16).toUpperCase().padStart(2, '0'); }
function displayName(city) { return city.name; }
function matches(city, query) { return !query || city.name.toLowerCase().includes(query) || city.region.toLowerCase().includes(query); }
function population(city) { return city.population.toLocaleString('pl-PL'); }
function attr(label, value) {
  const wrapper = document.createElement('div');
  const dt = document.createElement('dt'); dt.textContent = label;
  const dd = document.createElement('dd'); dd.textContent = value;
  wrapper.append(dt, dd);
  return wrapper;
}
function selectCity(id, scrollList = false) {
  state.selected = id;
  renderMap(); renderDetails(); renderList();
  if (scrollList) document.querySelector('.city-button.active')?.scrollIntoView({ block: 'nearest' });
}
function uniqueDestinations(city) {
  const destinations = new Map();
  for (const departure of city.departures) {
    const previous = destinations.get(departure.cityId);
    if (!previous) destinations.set(departure.cityId, { cityId: departure.cityId, express: departure.express, km: departure.km, slots: [departure.slot] });
    else previous.slots.push(departure.slot);
  }
  return [...destinations.values()].sort((a, b) => byId(a.cityId).name.localeCompare(byId(b.cityId).name));
}
function renderMap() {
  const { outline, cities } = state.data;
  const outlineLayer = $('outline-layer');
  if (!outlineLayer.childNodes.length) {
    const path = outline.map(([x, y, width]) => `M${x * 2} ${y}h${width * 2}v1h-${width * 2}z`).join('');
    outlineLayer.append(svg('path', { d: path, class: 'map-outline', 'shape-rendering': 'crispEdges' }));
  }
  const railLayer = $('rail-layer');
  const selectedLayer = $('selected-rail-layer');
  const cityLayer = $('city-layer');
  railLayer.replaceChildren(); selectedLayer.replaceChildren(); cityLayer.replaceChildren();
  const selected = byId(state.selected);
  const neighbors = new Set(uniqueDestinations(selected).map((entry) => entry.cityId));
  if (state.showRails) {
    const seen = new Set();
    for (const city of cities) for (const destination of uniqueDestinations(city)) {
      const target = byId(destination.cityId);
      const key = [Math.min(city.id, target.id), Math.max(city.id, target.id)].join('-');
      if (seen.has(key)) continue;
      seen.add(key);
      railLayer.append(svg('line', { x1: city.x * 2 + 1, y1: city.y + .5, x2: target.x * 2 + 1, y2: target.y + .5, class: `rail${destination.express ? ' express' : ''}` }));
    }
  }
  for (const destination of uniqueDestinations(selected)) {
    const target = byId(destination.cityId);
    selectedLayer.append(svg('line', { x1: selected.x * 2 + 1, y1: selected.y + .5, x2: target.x * 2 + 1, y2: target.y + .5, class: `rail selected${destination.express ? ' express' : ''}` }));
  }
  for (const city of cities) {
    const matched = matches(city, state.query);
    const filtered = (state.capitalsOnly && !city.capital) || (state.query && !matched);
    const circle = svg('circle', { cx: city.x * 2 + 1, cy: city.y + .5, r: city.id === state.selected ? 2.8 : city.capital ? 1.6 : 1.15,
      class: `city-marker${city.capital ? ' capital' : ''}${filtered ? ' dim' : ''}${neighbors.has(city.id) ? ' neighbor' : ''}${city.id === state.selected ? ' selected' : ''}`,
      tabindex: '0', role: 'button', 'aria-label': `${city.name}, ${city.region}`, 'aria-pressed': String(city.id === state.selected) });
    const title = svg('title'); title.textContent = `${city.name} (${city.region})`; circle.append(title);
    circle.addEventListener('click', () => selectCity(city.id, true));
    circle.addEventListener('keydown', (event) => { if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); selectCity(city.id, true); } });
    cityLayer.append(circle);
  }
}
function fitMap() {
  // frame the outline and cities instead of the whole 320x160 grid
  const xs = [], ys = [];
  for (const [x, y, width] of state.data.outline) { xs.push(x * 2, (x + width) * 2); ys.push(y, y + 1); }
  for (const city of state.data.cities) { xs.push(city.x * 2 + 1); ys.push(city.y); }
  const pad = 6, minX = Math.min(...xs) - pad, minY = Math.min(...ys) - pad;
  $('map').setAttribute('viewBox', `${minX} ${minY} ${Math.max(...xs) + pad - minX} ${Math.max(...ys) + pad - minY}`);
}
function renderCounts() {
  const { cities } = state.data;
  const links = new Set();
  for (const city of cities) for (const d of city.departures) if (d.express) links.add([Math.min(city.id, d.cityId), Math.max(city.id, d.cityId)].join('-'));
  $('count-cities').textContent = cities.length;
  $('count-booths').textContent = cities.filter((city) => city.capital).length;
  $('count-express').textContent = links.size;
}
function renderList() {
  const list = $('city-list'); list.replaceChildren();
  const filtered = state.data.cities.filter((city) => (!state.capitalsOnly || city.capital) && matches(city, state.query));
  $('result-count').textContent = `${filtered.length} shown`;
  if (!filtered.length) { const empty = document.createElement('div'); empty.className = 'empty-state'; empty.textContent = 'No cities match your search.'; list.append(empty); return; }
  for (const city of filtered) {
    const button = document.createElement('button'); button.type = 'button'; button.className = `city-button${city.id === state.selected ? ' active' : ''}`;
    button.setAttribute('aria-pressed', String(city.id === state.selected));
    const number = document.createElement('span'); number.className = 'number'; number.textContent = String(city.id).padStart(2, '0');
    const name = document.createElement('span'); name.textContent = displayName(city);
    button.append(number, name);
    if (city.capital) { const mark = document.createElement('span'); mark.className = 'capital-mark'; mark.textContent = '◆'; mark.setAttribute('aria-label', 'InfoBooth'); button.append(mark); }
    button.addEventListener('click', () => selectCity(city.id)); list.append(button);
  }
}
function renderDetails() {
  const city = byId(state.selected);
  $('city-id').textContent = `CITY ${String(city.id).padStart(2, '0')} / ${state.data.cities.length} · ${city.region.toUpperCase()}`;
  $('city-name').textContent = displayName(city);
  const badges = $('city-badges'); badges.replaceChildren();
  const booth = document.createElement('span'); booth.className = `badge${city.capital ? ' accent' : ''}`; booth.textContent = city.capital ? 'InfoBooth · voivodeship seat' : 'No InfoBooth'; badges.append(booth);
  const zone = document.createElement('span'); zone.className = 'badge'; zone.textContent = 'Time zone CET'; badges.append(zone);
  $('base-attributes').replaceChildren(
    attr('Population', population(city)), attr('Voivodeship', city.region),
    attr('Map coordinates', `${city.x}, ${city.y}`), attr('Lat / lon', `${city.lat.toFixed(2)}°, ${city.lon.toFixed(2)}°`),
    attr('Station layout', String(city.stationLayout)), attr('People generated', String(city.people)),
    attr('Station data byte', hex(city.stationByte))
  );
  $('visual-attributes').replaceChildren(
    attr('Skyline type', String(city.skylineType)), attr('Skyline offset', String(city.skylineOffset)),
    attr('Capital / booth flag', city.capital ? 'Set' : 'Clear'), attr('Flags data byte', hex(city.flagsByte))
  );
  const destinations = uniqueDestinations(city);
  $('destination-count').textContent = `${destinations.length} cities`;
  const destinationList = $('destinations'); destinationList.replaceChildren();
  for (const item of destinations) {
    const button = document.createElement('button'); button.type = 'button'; button.className = `destination${item.express ? ' express' : ''}`;
    button.textContent = byId(item.cityId).name;
    const meta = document.createElement('small'); meta.textContent = `${item.express ? 'Express' : 'Regional'} · ${item.km} km · ${item.slots.length} departure${item.slots.length === 1 ? '' : 's'}`; button.append(meta);
    button.addEventListener('click', () => selectCity(item.cityId, true)); destinationList.append(button);
  }
  const slots = new Map(city.departures.map((departure) => [departure.slot, departure]));
  const departures = $('departures'); departures.replaceChildren();
  for (let slot = 0; slot < 16; slot++) {
    const entry = slots.get(slot); const row = document.createElement('div'); row.className = `departure${entry ? '' : ' empty'}`;
    const label = document.createElement('b'); label.textContent = String(slot).padStart(2, '0'); row.append(label);
    row.append(document.createTextNode(entry ? byId(entry.cityId).name : 'No train'));
    if (entry) { const sub = document.createElement('span'); sub.textContent = `${entry.express ? 'Express' : 'Regional'} · ${entry.km} km · ride index ${entry.rideIndex}`; row.append(sub); }
    departures.append(row);
  }
  const navigation = $('navigation'); navigation.replaceChildren();
  for (const direction of ['left', 'right', 'up', 'down']) {
    const id = city.navigation[direction]; const button = document.createElement('button'); button.type = 'button'; button.className = 'nav-button';
    const label = document.createElement('b'); label.textContent = direction; button.append(label, document.createTextNode(byId(id).name));
    button.addEventListener('click', () => selectCity(id, true)); navigation.append(button);
  }
}
async function start() {
  try {
    const response = await fetch('data.json');
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    state.data = await response.json();
    if (state.data.cities.length !== 100) throw new Error('The city data is incomplete.');
    fitMap(); renderCounts();
    renderMap(); renderList(); renderDetails();
    $('search').addEventListener('input', (event) => { state.query = event.target.value.trim().toLowerCase(); renderMap(); renderList(); });
    $('show-rails').addEventListener('change', (event) => { state.showRails = event.target.checked; renderMap(); });
    $('show-capitals').addEventListener('change', (event) => { state.capitalsOnly = event.target.checked; renderMap(); renderList(); });
  } catch (error) {
    $('city-list').textContent = `Could not load the city map: ${error.message}`;
  }
}
start();
