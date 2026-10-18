/* Editor-only encounter authoring and deterministic scout previews. No game state is changed. */
(function (root) {
  'use strict';
  const REGION_IDS = ['forest', 'catacombs', 'caves', 'ruins'];
  const copy = value => JSON.parse(JSON.stringify(value));
  const integer = (value, min, max) => Number.isInteger(value) && value >= min && value <= max;
  const validName = value => typeof value === 'string' && /^[a-zA-Z0-9 -]{1,48}$/.test(value) && value.trim().length > 0;
  const power = unit => unit.hp + (unit.id === 'warlock' ? 0 : unit.damage * 2) + Math.min(unit.move, 4) * 0.5 + Math.min(unit.shootRange, 6) * 0.5 + (unit.id === 'warlock' ? 8 : 0);

  function validate(data) {
    const errors = [];
    const config = data.encounterConfig;
    if (!config || config.version !== 1 || config.selection !== 'weighted-seeded' || config.terrain !== 'fixed' || config.retrySameSeed !== true) {
      return ['Encounter configuration must use version 1, weighted seeds, fixed terrain and the same seed on retry.'];
    }
    const rules = progression(data);
    if (rules.mode !== 'previous-region-wins' || !Array.isArray(rules.winsRequired) || rules.winsRequired.length !== 4 || rules.winsRequired.some(n => !integer(n, 3, 9))) errors.push('Region progression needs three to nine victories per region, in order.');
    const chapel = data.chapel;
    if (!chapel || chapel.baseCapacity !== 3 || JSON.stringify(chapel.capacityByLevel) !== '[3,4,5,5]' || chapel.recruitDiscount !== 10) {
      errors.push('Chapel effects must match the game: three starting slots, four/five unlocked slots and a 10-gold recruit discount.');
    }
    if (!Array.isArray(data.players) || !Array.isArray(data.enemies)) errors.push('Expected player and enemy unit arrays.');
    for (const unit of [...(Array.isArray(data.players) ? data.players : []), ...(Array.isArray(data.enemies) ? data.enemies : [])]) {
      if (!unit || !integer(unit.hp, 1, 99) || !integer(unit.damage, 1, 99) || !integer(unit.move, 1, 9) || !integer(unit.shootRange, 0, 9)) {
        errors.push('Every fighter needs valid HP, damage, movement and shooting range.'); continue;
      }
      if (unit.range !== (unit.id === 'warlock' ? 3 : Math.max(1, unit.shootRange))) {
        errors.push(`${unit.name}: legacy range and shooting range disagree. Re-enter the shooting range.`);
      }
    }
    if (!Array.isArray(config.regions) || config.regions.length !== 4) return [...errors, 'Expected four encounter regions.'];
    const enemyIds = new Set((Array.isArray(data.enemies) ? data.enemies : []).map(unit => unit && unit.id));
    config.regions.forEach((region, r) => {
      if (!region || region.id !== REGION_IDS[r] || !validName(region.name) || !integer(region.replayReward, 0, 65535)) {
        errors.push(`Region ${r + 1}: invalid ID, name or replay reward.`); return;
      }
      if (!Array.isArray(region.stages) || region.stages.length !== 3) {
        errors.push(`${region.name}: expected three progression stages.`); return;
      }
      region.stages.forEach((stage, s) => {
        const label = `${region.name}, stage ${s + 1}`;
        if (!stage || !validName(stage.name) || !integer(stage.reward, 0, 65535) || !Array.isArray(stage.variants) || stage.variants.length < 1 || stage.variants.length > 8) {
          errors.push(`${label}: use a name, valid reward and one to eight groups.`); return;
        }
        let total = 0;
        stage.variants.forEach((variant, v) => {
          if (!variant || !validName(variant.name) || !integer(variant.weight, 0, 100) || !Array.isArray(variant.enemies) || variant.enemies.length < 1 || variant.enemies.length > 5 || variant.enemies.some(id => !enemyIds.has(id))) {
            errors.push(`${label}, group ${v + 1}: use a name, weight 0-100 and one to five known enemies.`); return;
          }
          total += variant.weight;
          if (variant.enemies.includes('warlock') && (r !== 3 || s !== 2)) errors.push(`${label}: Warlock is reserved for the final fight.`);
        });
        if (total === 0) errors.push(`${label}: at least one group needs a positive weight.`);
        if (r === 3 && s === 2 && (stage.variants.length !== 1 || stage.variants[0]?.enemies?.filter(id => id === 'warlock').length !== 1)) {
          errors.push('Final Warlock stage needs exactly one authored group containing one Warlock.');
        }
      });
    });
    return errors;
  }

  function generate(data, regionIndex, stageIndex, seed, replay = false) {
    const errors = validate(data);
    if (errors.length) throw Error(errors[0]);
    if (!integer(regionIndex, 0, 3) || !integer(stageIndex, 0, 2) || !integer(seed, 0, 0xffffffff) || (replay && stageIndex !== 2)) throw Error('Choose a valid region, stage and seed. Replays use stage 3.');
    const region = data.encounterConfig.regions[regionIndex], stage = region.stages[stageIndex];
    // Integer avalanche: seed zero is supported, and regions/stages have distinct streams.
    let state = (seed ^ Math.imul(regionIndex + 1, 0x9e3779b1) ^ Math.imul(stageIndex + 1, 0x85ebca6b)) >>> 0;
    state = Math.imul(state ^ state >>> 16, 0x7feb352d) >>> 0;
    state = Math.imul(state ^ state >>> 15, 0x846ca68b) >>> 0;
    state = (state ^ state >>> 16) >>> 0;
    const total = stage.variants.reduce((sum, variant) => sum + variant.weight, 0);
    let pick = (state / 4294967296) * total;
    const index = stage.variants.findIndex(variant => { pick -= variant.weight; return pick < 0; });
    const variant = stage.variants[index];
    const enemies = variant.enemies.map((id, i) => ({ ...copy(data.enemies.find(unit => unit.id === id)), cell: [6, 13, 20, 27, 34][i] }));
    return { seed, regionId: region.id, region: region.name, stage: stageIndex + 1, name: variant.name, variant: index, reward: replay ? region.replayReward : stage.reward, replay, enemies, terrain: [10, 31], playerCells: [0, 7, 14, 21, 28], strength: enemies.reduce((sum, enemy) => sum + power(enemy), 0), victory: enemies.some(enemy => enemy.id === 'warlock') ? 'Defeat the Warlock' : 'Defeat all enemies' };
  }

  function progression(data) {
    return data.encounterConfig.progression || { mode: 'previous-region-wins', winsRequired: [3, 3, 3, 3] };
  }
  function createCampaign(data) {
    return { wins: [0, 0, 0, 0], gold: data.startingGold, seed: 1, pending: null, lastResult: 'New campaign preview. Only Dark Forest is open.' };
  }
  function checkCampaign(data, state) {
    const errors = validate(data);
    if (errors.length) throw Error(errors[0]);
    if (!state || !Array.isArray(state.wins) || state.wins.length !== 4 || state.wins.some((w, i) => !integer(w, 0, data.endlessLairs ? 255 : progression(data).winsRequired[i])) || !integer(state.gold, 0, 65535) || !integer(state.seed, 0, 0xffffffff)) throw Error('Invalid campaign preview state.');
  }
  function isUnlocked(data, state, regionIndex) {
    if (!integer(regionIndex, 0, 3)) return false;
    return state.wins.slice(0, regionIndex).every((wins, i) => wins >= progression(data).winsRequired[i]);
  }
  function beginEncounter(data, state, regionIndex) {
    checkCampaign(data, state);
    if (!isUnlocked(data, state, regionIndex)) throw Error('Clear the previous region before entering this location.');
    if (state.pending) {
      if (state.pending.regionIndex !== regionIndex) throw Error('Finish or retreat from the current encounter first.');
      return copy(state); // Retry preserves the exact generated group and reward.
    }
    const next = copy(state), required = progression(data).winsRequired[regionIndex];
    const wins = next.wins[regionIndex], replay = wins >= required;
    const stage = replay ? 2 : Math.min(2, Math.floor(wins * 3 / required));
    const encounter = generate(data, regionIndex, stage, next.seed, data.endlessLairs ? false : replay);
    if (data.endlessLairs) {
      const hpBonus = Math.min(90, Math.max(0, wins - required + 1));
      const damageBonus = Math.min(8, Math.floor(hpBonus / 3));
      encounter.enemies.forEach(unit => { unit.hp = Math.min(99, unit.hp + hpBonus); unit.damage = Math.min(9, unit.damage + damageBonus); });
      encounter.reward = Math.min(65535, encounter.reward + hpBonus * 10);
      encounter.escalation = { hpBonus, damageBonus };
      encounter.strength = encounter.enemies.reduce((sum, unit) => sum + power(unit), 0);
    }
    next.pending = { regionIndex, encounter };
    next.lastResult = 'Encounter prepared. Record a test result below; no battle is simulated.';
    return next;
  }
  function recordResult(data, state, result) {
    checkCampaign(data, state);
    if (!state.pending) throw Error('Prepare an encounter before recording a result.');
    if (!['victory', 'defeat', 'retreat'].includes(result)) throw Error('Unknown encounter result.');
    const next = copy(state), regionIndex = next.pending.regionIndex, encounter = next.pending.encounter;
    if (result === 'defeat') {
      next.lastResult = 'Test defeat: no gold or victory credit. Retry keeps the same encounter.';
      return next;
    }
    if (result === 'retreat') {
      next.pending = null;
      next.lastResult = 'Retreated: no gold or victory credit. The seed is unchanged.';
      return next;
    }
    next.gold = Math.min(65535, next.gold + encounter.reward);
    if (data.endlessLairs || !encounter.replay) next.wins[regionIndex] = Math.min(data.endlessLairs ? 255 : progression(data).winsRequired[regionIndex], next.wins[regionIndex] + 1);
    next.seed = (next.seed + 1) >>> 0;
    next.pending = null;
    if (data.endlessLairs) {
      const unlocked = regionIndex < 3 && next.wins[regionIndex] === progression(data).winsRequired[regionIndex];
      next.lastResult = `Test victory: +${encounter.reward} gold. ${unlocked ? 'Next lair unlocked. ' : ''}This lair remains open; further victories increase enemy strength.`;
      return next;
    }
    const cleared = next.wins[regionIndex] >= progression(data).winsRequired[regionIndex];
    next.lastResult = `Test victory: +${encounter.reward} gold.${encounter.replay ? ' Replay gives no further progress.' : cleared ? (regionIndex < 3 ? ' Next region unlocked.' : ' Campaign complete.') : ' Victory counted toward the next region.'}`;
    return next;
  }
  function difficultyBands(data) {
    const units = new Map(data.enemies.map(unit => [unit.id, unit]));
    return data.encounterConfig.regions.map(region => {
      const values = region.stages.flatMap(stage => stage.variants.filter(v => v.weight > 0).map(v => v.enemies.reduce((sum, id) => sum + (units.has(id) ? power(units.get(id)) : NaN), 0))).filter(Number.isFinite);
      return { min: Math.min(...values), max: Math.max(...values) };
    });
  }

  let campaign = null, campaignSignature = '';
  function renderProgression(data) {
    const host = document.getElementById('progression-editor');
    if (!host) return;
    host.replaceChildren();
    host.append(el('h3', 'Campaign progression preview'), el('p', 'Dark Forest is the easiest region; each next region requires victories in the previous one. These buttons record test results to check unlocks and rewards. They do not simulate combat. Editing the configuration resets this preview.'));
    const table = el('table'), head = el('thead'), row = el('tr'), body = el('tbody');
    for (const text of ['Location', 'Estimated strength', 'Victories to unlock next lair', 'Availability', '']) row.append(el('th', text));
    head.append(row); table.append(head, body); const bands = difficultyBands(data);
    data.encounterConfig.regions.forEach((region, r) => {
      const tr = body.insertRow(), required = progression(data).winsRequired[r], open = isUnlocked(data, campaign, r), cleared = campaign.wins[r] >= required;
      tr.insertCell().textContent = `${r + 1}. ${region.name}${r === 0 ? ' (easiest)' : r === 3 ? ' (hardest)' : ''}`;
      tr.insertCell().textContent = `${bands[r].min.toFixed(1)}–${bands[r].max.toFixed(1)}`;
      tr.insertCell().append(numberInput(required, 3, 9, `${region.name} victories to clear`, value => {
        if (!data.encounterConfig.progression) data.encounterConfig.progression = copy(progression(data));
        data.encounterConfig.progression.winsRequired[r] = value; changed();
      }));
      tr.insertCell().textContent = !open ? `Locked — win ${progression(data).winsRequired[r - 1]} encounters in ${data.encounterConfig.regions[r - 1].name}` : data.endlessLairs ? 'Open · unlimited battles; enemies strengthen with victories' : `${campaign.wins[r]} / ${required} victories · ${cleared ? 'Cleared; replay available' : 'Open'}`;
      const enter = button(campaign.pending?.regionIndex === r ? 'Retry same encounter' : cleared && !data.endlessLairs ? 'Preview replay' : 'Preview next encounter', () => {
        try { campaign = beginEncounter(data, campaign, r); renderProgression(data); } catch (error) { campaign.lastResult = error.message; renderProgression(data); }
      });
      enter.setAttribute('aria-label', `${region.name} preview next encounter`);
      enter.disabled = !open || (!!campaign.pending && campaign.pending.regionIndex !== r);
      tr.insertCell().append(enter);
    });
    const scroll = el('div', undefined, 'table-wrap'); scroll.append(table); host.append(scroll);
    host.append(el('p', `Preview gold: ${campaign.gold}. ${campaign.lastResult}`));
    if (campaign.pending) {
      const encounter = campaign.pending.encounter;
      host.append(el('p', `${encounter.region} · stage ${encounter.stage} · seed ${encounter.seed} · ${encounter.reward} gold${encounter.replay ? ' (replay)' : ''}. Enemies: ${encounter.enemies.map(unit => unit.name).join(', ')}. ${encounter.victory}.`));
      const actions = el('div', undefined, 'encounter-bar');
      for (const [label, result] of [['Record test victory', 'victory'], ['Record test defeat', 'defeat'], ['Retreat from preview', 'retreat']]) actions.append(button(label, () => { campaign = recordResult(data, campaign, result); renderProgression(data); }));
      host.append(actions);
    }
    host.append(button('Reset campaign preview', () => { campaign = createCampaign(data); renderProgression(data); }));
  }

  function csvRows(data) {
    const rows = [['Settings', 'Starting gold', '', '', '', '', '', '', data.startingGold, '', '', '', '', '']];
    rows.push(['Encounter region', 'Stage', 'Stage name', 'Group name', 'Weight', 'Enemies (IDs)', 'First-clear gold', 'Replay gold', 'Selection', 'Terrain', 'Retry seed', 'Victory', '', '']);
    for (const region of data.encounterConfig.regions) region.stages.forEach((stage, s) => stage.variants.forEach(variant => {
      rows.push([region.name, s + 1, stage.name, variant.name, variant.weight, variant.enemies.join(' + '), stage.reward, s === 2 ? region.replayReward : '', 'weighted-seeded', 'fixed', 'same', variant.enemies.includes('warlock') ? 'Defeat Warlock' : 'Defeat all', '', '']);
    }));
    rows.push(['Progression location', 'Victories to clear', 'Prerequisite', '', '', '', '', '', '', '', '', '', '', '']);
    data.encounterConfig.regions.forEach((region, i) => rows.push([region.name, progression(data).winsRequired[i], i === 0 ? 'Initially open' : data.encounterConfig.regions[i-1].name, '', '', '', '', '', '', '', '', '', '', '']));
    return rows;
  }

  let controls, tables, report, summary, currentPreview = null, onEdit;
  let selected = { region: 0, stage: 0, seed: 1, replay: false };
  const el = (tag, text, className) => { const node = document.createElement(tag); if (text !== undefined) node.textContent = text; if (className) node.className = className; return node; };
  function numberInput(value, min, max, label, change) {
    const input = el('input'); input.type = 'number'; input.min = min; input.max = max; input.step = 1; input.value = value; input.required = true; input.setAttribute('aria-label', label);
    input.addEventListener('input', () => change(input.value === '' ? null : input.valueAsNumber));
    return input;
  }
  function textInput(value, label, change) {
    const input = el('input'); input.value = value; input.maxLength = 48; input.required = true; input.pattern = '[a-zA-Z0-9 -]{1,48}'; input.setAttribute('aria-label', label);
    input.addEventListener('input', () => change(input.value)); return input;
  }
  function button(text, action) { const node = el('button', text); node.type = 'button'; node.addEventListener('click', action); return node; }
  function changed() { if (currentPreview) report.textContent = 'Configuration changed. Preview this seed again to update the scout report.'; onEdit(); }

  function render(data, callback) {
    onEdit = callback;
    controls = document.getElementById('encounter-controls'); tables = document.getElementById('encounter-tables'); report = document.getElementById('scout-preview'); summary = document.getElementById('encounter-summary');
    const previousDetails = Array.from(tables.querySelectorAll('details'));
    const openRegions = previousDetails.length ? new Set(previousDetails.flatMap((detail, i) => detail.open ? [i] : [])) : null;
    controls.replaceChildren(); tables.replaceChildren(); currentPreview = null;
    const bar = el('div', undefined, 'encounter-bar'); controls.append(bar);
    const regionSelect = el('select'); regionSelect.setAttribute('aria-label', 'Preview region');
    data.encounterConfig.regions.forEach((region, i) => { const option = el('option', region.name); option.value = i; regionSelect.append(option); }); regionSelect.value = selected.region;
    const stageSelect = el('select'); stageSelect.setAttribute('aria-label', 'Preview stage');
    for (let s = 0; s < 3; s++) { const option = el('option', `Stage ${s + 1}`); option.value = s; stageSelect.append(option); } stageSelect.value = selected.stage;
    regionSelect.addEventListener('change', () => { selected.region = Number(regionSelect.value); report.textContent = 'Press Preview seed to inspect this encounter.'; });
    stageSelect.addEventListener('change', () => { selected.stage = Number(stageSelect.value); if (selected.stage !== 2) { selected.replay = false; replay.checked = false; } replay.disabled = selected.stage !== 2; report.textContent = 'Press Preview seed to inspect this encounter.'; });
    const seed = numberInput(selected.seed, 0, 0xffffffff, 'Encounter seed', value => { selected.seed = value; }); seed.id = 'encounter-seed';
    const replayLabel = el('label'), replay = el('input'); replay.type = 'checkbox'; replay.checked = selected.replay; replay.disabled = selected.stage !== 2; replay.addEventListener('change', () => { selected.replay = replay.checked; }); replayLabel.append(replay, document.createTextNode(' Cleared-region replay'));
    bar.append(regionSelect, stageSelect, el('label', 'Seed'), seed, replayLabel,
      button('Preview seed', () => preview(data)), button('Next seed', () => { selected.seed = integer(selected.seed, 0, 0xffffffff) ? (selected.seed + 1) >>> 0 : 1; seed.value = selected.seed; preview(data); }));
    const odds = el('p', 'Selection chance = group weight ÷ total active weight. Victories unlock regions in order using the requirements above; cleared regions replay stage 3 for their replay reward. The authoring preview can inspect locked regions.', 'note'); controls.append(odds);
    data.encounterConfig.regions.forEach((region, r) => {
      const detail = el('details'); detail.open = openRegions ? openRegions.has(r) : r === selected.region;
      detail.append(el('summary', `${r + 1}. ${region.name}`));
      const settings = el('div', undefined, 'encounter-bar'); settings.append(el('label', 'Replay gold'), numberInput(region.replayReward, 0, 65535, `${region.name} replay reward`, value => { region.replayReward = value; changed(); })); detail.append(settings);
      region.stages.forEach((stage, s) => {
        const heading = el('div', undefined, 'encounter-bar'); heading.append(el('strong', `Stage ${s + 1}`), textInput(stage.name, `${region.name} stage ${s + 1} name`, value => { stage.name = value; changed(); }), el('label', 'Victory gold'), numberInput(stage.reward, 0, 65535, `${region.name} stage ${s + 1} reward`, value => { stage.reward = value; changed(); })); detail.append(heading);
        const wrap = el('div', undefined, 'table-wrap'), table = el('table'), head = el('thead'), tr = el('tr'), body = el('tbody');
        for (const text of ['Group', 'Weight', 'Chance', 'Enemies (up to five)', 'Strength estimate', '']) tr.append(el('th', text)); head.append(tr); table.append(head, body); wrap.append(table); detail.append(wrap);
        stage.variants.forEach((variant, v) => {
          const row = body.insertRow(), key = `${r}-${s}-${v}`;
          row.insertCell().append(textInput(variant.name, `${region.name} stage ${s + 1} group ${v + 1} name`, value => { variant.name = value; changed(); }));
          row.insertCell().append(numberInput(variant.weight, 0, 100, `${region.name} stage ${s + 1} group ${v + 1} weight`, value => { variant.weight = value; changed(); }));
          const chance = el('output'); chance.id = 'chance-' + key; row.insertCell().append(chance);
          const enemyCell = row.insertCell(); enemyCell.className = 'enemy-picks'; const selects = [];
          for (let i = 0; i < 5; i++) {
            const select = el('select'); select.setAttribute('aria-label', `${region.name} stage ${s + 1} group ${v + 1} enemy ${i + 1}`);
            const empty = el('option', 'Empty'); empty.value = ''; select.append(empty);
            for (const enemy of data.enemies) { if (enemy.id === 'warlock' && (r !== 3 || s !== 2)) continue; const option = el('option', enemy.name); option.value = enemy.id; option.dataset.enemyId = enemy.id; select.append(option); }
            select.value = variant.enemies[i] || ''; selects.push(select); enemyCell.append(select);
            select.addEventListener('change', () => { variant.enemies = selects.map(node => node.value).filter(Boolean); changed(); });
          }
          const strength = el('output'); strength.id = 'strength-' + key; row.insertCell().append(strength);
          const remove = button('Remove', () => { stage.variants.splice(v, 1); render(data, callback); changed(); }); remove.disabled = stage.variants.length <= 1 || (r === 3 && s === 2); row.insertCell().append(remove);
        });
        const add = button('Add group', () => { stage.variants.push({ name: `Group ${stage.variants.length + 1}`, weight: 1, enemies: [stage.variants[0].enemies.find(id => id !== 'warlock') || 'minibeast'] }); render(data, callback); changed(); }); add.disabled = stage.variants.length >= 8 || (r === 3 && s === 2); const footer = el('div', undefined, 'encounter-bar'); footer.append(add); detail.append(footer);
      });
      tables.append(detail);
    });
    report.textContent = 'Press Preview seed to inspect the enemies, reward and starting positions. This is an encounter preview, not a combat simulation.';
    update(data);
  }

  function preview(data) {
    try {
      currentPreview = generate(data, selected.region, selected.stage, selected.seed, selected.replay);
      const p = currentPreview; report.replaceChildren();
      report.append(el('strong', `${p.region} · stage ${p.stage} · ${p.name}`), el('p', `Seed ${p.seed} · ${p.reward} gold${p.replay ? ' (replay; no progress)' : ''} · ${p.victory}. Strength estimate ${p.strength.toFixed(1)}.`));
      const board = el('div', undefined, 'scout-board'); board.setAttribute('role', 'img'); board.setAttribute('aria-label', '7 by 6 battlefield: player starts on the left, enemies on the right, two fixed trees.');
      for (let cell = 0; cell < 42; cell++) {
        const enemy = p.enemies.find(unit => unit.cell === cell), tile = el('span', enemy ? 'E' : p.terrain.includes(cell) ? '♠' : p.playerCells.includes(cell) ? 'P' : '·', 'scout-cell');
        tile.classList.toggle('scout-enemy', !!enemy); tile.title = enemy ? enemy.name : p.terrain.includes(cell) ? 'Tree' : p.playerCells.includes(cell) ? 'Possible player slot' : 'Open'; board.append(tile);
      }
      report.append(board);
      const list = el('ul'); for (const unit of p.enemies) list.append(el('li', `${unit.name}: ${unit.hp} HP, ${unit.damage} damage${unit.id === 'warlock' ? ' (unused; summons)' : ''}, move ${unit.move}, shooting ${unit.shootRange}`)); report.append(list);
      report.append(el('p', 'P = possible player slot; E = enemy. Trees and deployment cells match the current native layout. Retry this seed to reproduce the same group while the configuration is unchanged.'));
    } catch (error) { currentPreview = null; report.textContent = 'Cannot preview: ' + error.message; }
  }

  function update(data) {
    if (!tables) return;
    if (!validate(data).length) {
      const signature = JSON.stringify(data);
      if (signature !== campaignSignature) { campaign = createCampaign(data); campaignSignature = signature; }
      renderProgression(data);
    } else {
      for (const button of document.querySelectorAll('#progression-editor button')) button.disabled = true;
    }
    const warnings = [];
    data.encounterConfig.regions.forEach((region, r) => region.stages.forEach((stage, s) => {
      const total = stage.variants.reduce((sum, variant) => sum + (variant.weight || 0), 0), strengths = [];
      stage.variants.forEach((variant, v) => {
        const key = `${r}-${s}-${v}`, units = variant.enemies.map(id => data.enemies.find(unit => unit.id === id));
        const strength = units.every(Boolean) ? units.reduce((sum, unit) => sum + power(unit), 0) : NaN;
        const chance = document.getElementById('chance-' + key), output = document.getElementById('strength-' + key);
        if (chance) chance.textContent = total && integer(variant.weight, 0, 100) ? (variant.weight / total * 100).toFixed(1) + '%' : '—';
        if (output) output.textContent = Number.isFinite(strength) ? strength.toFixed(1) : '—';
        if (variant.weight > 0 && Number.isFinite(strength)) strengths.push(strength);
      });
      if (strengths.length > 1 && Math.max(...strengths) > Math.min(...strengths) * 1.3) warnings.push(`${region.name} stage ${s + 1} groups differ by more than 30% estimated strength.`);
    }));
    const enemyNames = new Map(data.enemies.map(unit => [unit.id, unit.name]));
    for (const option of tables.querySelectorAll('[data-enemy-id]')) option.textContent = enemyNames.get(option.dataset.enemyId);
    const forest = data.encounterConfig.regions[0], gold = data.startingGold + forest.stages[0].reward + forest.stages[1].reward;
    const spear = data.players.find(unit => unit.id === 'barracks-2');
    const four = data.chapel.costs[0] + 2 * spear.recruit, five = data.chapel.costs[0] + data.chapel.costs[1] + 3 * spear.recruit;
    summary.replaceChildren(el('p', `Before Forest stage 3: ${gold} total gold available before purchases. From the starting two Spearmen, four Spearmen cost ${four} gold (including slot 4); five cost ${five} gold (including both slot upgrades).`),
      el('p', `Chapel level 3 breaks even after ${Math.ceil(data.chapel.costs[2] / 10)} recruits at the full 10-gold saving. Strength estimate = HP + 2 × damage + 0.5 × move (capped at 4) + 0.5 × shooting range (capped at 6), with stored summoner damage ignored and 8 added for summoning. This excludes positioning, focus fire and AI.`));
    const bands = difficultyBands(data);
    bands.forEach((band, r) => { if (r > 0 && band.min <= bands[r-1].max) warnings.push(`${data.encounterConfig.regions[r].name} overlaps the previous region in estimated difficulty; raise its weakest group or lower the previous region's strongest group.`); });
    if (warnings.length) summary.append(el('p', warnings.join(' '), 'balance-warning'));
  }

  const api = { validate, generate, power, csvRows, render, update, progression, createCampaign, isUnlocked, beginEncounter, recordResult, difficultyBands };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.GreenhavenBalance = api;
})(typeof window !== 'undefined' ? window : globalThis);
