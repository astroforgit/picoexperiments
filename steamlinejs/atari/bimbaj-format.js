// Bimbaj campaign format, shared by generate_data.js (Node) and
// bimbaj-editor.html (browser). bimbaj.json holds one ordered list: levels
// are played in list order and every text is shown after the levels above it.
(function (root, factory) {
    if (typeof module === 'object' && module.exports) module.exports = factory();
    else root.BimbajFormat = factory();
}(typeof self !== 'undefined' ? self : this, function () {
    'use strict';

    // Index = CT_* cell value in bimbaj.asm.
    const TILE_CHARS = '.@E#PRX%^>v<LK';
    const TILE_NAMES = [
        'Floor', 'Elephant (start)', 'Ring (goal)', 'Boulder', 'Pause bar', 'Spiral (retract)',
        'Cross (trap)', 'Portal', 'Arrow up', 'Arrow right', 'Arrow down', 'Arrow left', 'Lock', 'Key',
    ];

    const MAX_WIDTH = 20;
    const MAX_HEIGHT = 18;          // 20 board rows minus the frame
    const MAX_CELLS = 254;          // path indices and lengths are bytes
    const MAX_LEVELS = 99;          // the status bar shows two digits
    const MAX_PAGES = 255;

    // Story pages: ANTIC 2, 40x24 screen, text in columns 2..37, rows 2..21.
    const STORY_WIDTH = 36;
    const STORY_ROWS = 20;
    const STORY_EXTRA = 'ĄĆĘŁŃÓŚŹŻąćęłńóśźż–';

    // Data under the OS ROM, copied out by INIT segments at load time.
    const BANK_WINDOWS = [[0xC000, 0xD000], [0xD800, 0xFFFA]];
    const STAGE_LIMIT = 0x2000 - 4;  // $8000 staging area minus the chunk header

    // Common typography that the story font lacks.
    const SUBSTITUTES = {
        '„': '"', '”': '"', '“': '"', '«': '"', '»': '"',
        '‘': "'", '’': "'", '‚': "'", '—': '–', '−': '-',
        '…': '...', ' ': ' ', '\t': ' ', '\r': '',
    };

    function normalizeText(text) {
        return [...text].map(char => (char in SUBSTITUTES ? SUBSTITUTES[char] : char)).join('');
    }

    function storyCode(char) {
        if (char >= ' ' && char <= '~') return char.charCodeAt(0) - 32;
        const extra = STORY_EXTRA.indexOf(char);
        return extra < 0 ? -1 : 96 + extra;
    }

    function unsupportedChars(text) {
        return [...new Set([...text].filter(char => char !== '\n' && storyCode(char) < 0))];
    }

    // Paragraphs are separated by blank lines; single newlines join words.
    function wrapStory(text) {
        const lines = [];
        for (const paragraph of text.split('\n\n')) {
            if (lines.length) lines.push('');
            let line = '';
            for (const word of paragraph.split(/\s+/).filter(Boolean)) {
                if (word.length > STORY_WIDTH) throw new Error(`Word longer than ${STORY_WIDTH} columns: ${word}`);
                if (line && line.length + 1 + word.length > STORY_WIDTH) {
                    lines.push(line);
                    line = '';
                }
                line += (line ? ' ' : '') + word;
            }
            if (line) lines.push(line);
        }
        const pages = [];
        for (let i = 0; i < lines.length; i += STORY_ROWS) pages.push(lines.slice(i, i + STORY_ROWS));
        return pages;
    }

    function storyFooter(index, count) {
        return `FIRE / SPACE / START  -  DALEJ  ${index + 1}/${count}`;
    }

    // Text rows as [row, column, string] on the 40x24 story screen.
    function pageLayout(lines, index, count) {
        const rows = lines.map((line, i) => [2 + i, 2, line]);
        rows.push([23, 2, storyFooter(index, count)]);
        return rows.filter(([, , line]) => line.length);
    }

    // Page data: [row, column, length, screen codes...]..., $FF.
    function pageBytes(layout) {
        const bytes = [];
        for (const [row, col, line] of layout) bytes.push(row, col, line.length, ...[...line].map(storyCode));
        bytes.push(0xFF);
        return bytes;
    }

    function levelSize(level) {
        const rows = level.rows || [];
        return { width: rows.length ? rows[0].length : 0, height: rows.length };
    }

    function levelErrors(level) {
        const rows = level.rows || [];
        const errors = [];
        const { width, height } = levelSize(level);
        if (!height || !width) return ['The board is empty'];
        if (!rows.every(row => row.length === width)) errors.push('Rows have different lengths');
        if (width > MAX_WIDTH) errors.push(`Width ${width} exceeds ${MAX_WIDTH}`);
        if (height > MAX_HEIGHT) errors.push(`Height ${height} exceeds ${MAX_HEIGHT}`);
        if (width * height > MAX_CELLS) errors.push(`${width}x${height} = ${width * height} cells exceeds ${MAX_CELLS}`);
        const cells = rows.join('');
        const unknown = [...new Set([...cells].filter(char => TILE_CHARS.indexOf(char) < 0))];
        if (unknown.length) errors.push(`Unknown tile symbols: ${unknown.join(' ')}`);
        const count = char => [...cells].filter(c => c === char).length;
        const starts = count('@');
        if (starts < 1 || starts > 2) errors.push(`Needs 1 or 2 elephants, has ${starts}`);
        if (count('E') < 1) errors.push('Needs at least one ring');
        if (![0, 2].includes(count('%'))) errors.push(`Portals come in one pair, has ${count('%')}`);
        if (count('L') && !count('K')) errors.push('Locks need a key');
        return errors;
    }

    function levelBytes(level) {
        const { width, height } = levelSize(level);
        return [width, height, ...[...level.rows.join('')].map(char => TILE_CHARS.indexOf(char))];
    }

    // Large boards use 1x1 tiles, medium 2x2 and small 3x3 (see calculate_board).
    function levelZoom(level) {
        const { width, height } = levelSize(level);
        if (width < 7 && height < 7) return 3;
        if (width < 10 && height <= 10) return 2;   // 10 rows fill the frame's rows too
        return 1;
    }

    // Pack blobs into the under-ROM windows without crossing a window end.
    function layoutBank(blobs) {
        const windows = BANK_WINDOWS.map(([start, end]) => ({ start, end, next: start }));
        let windowIndex = 0;
        const addresses = [];
        for (const blob of blobs) {
            while (windowIndex < windows.length && windows[windowIndex].next + blob.length > windows[windowIndex].end) {
                windowIndex++;
            }
            if (windowIndex >= windows.length) return { addresses, overflow: true, windows };
            addresses.push(windows[windowIndex].next);
            windows[windowIndex].next += blob.length;
        }
        return { addresses, overflow: false, windows };
    }

    function bankCapacity() {
        return BANK_WINDOWS.reduce((sum, [start, end]) => sum + end - start, 0);
    }

    // Compile the campaign. Errors are collected per item so the editor can
    // show all of them; the build refuses to continue when any exist.
    function compile(project) {
        const items = (project && project.items) || [];
        const errors = [];
        const levels = [];
        const breaks = [];     // { after, pages: [{ layout, bytes }] }
        let pending = null;
        items.forEach((item, index) => {
            const where = `Item ${index + 1}`;
            if (item.type === 'level') {
                const problems = levelErrors(item);
                problems.forEach(message => errors.push({ index, message: `${where} (${item.name || 'level'}): ${message}` }));
                levels.push({ name: item.name || `Level ${levels.length + 1}`, item: index,
                    bytes: problems.length ? [] : levelBytes(item) });
                pending = null;
            } else if (item.type === 'text') {
                const text = normalizeText(item.text || '');
                const bad = unsupportedChars(text);
                if (bad.length) errors.push({ index, message: `${where}: characters not in the story font: ${bad.join(' ')}` });
                let wrapped = [];
                try {
                    wrapped = wrapStory(text);
                } catch (error) {
                    errors.push({ index, message: `${where}: ${error.message}` });
                }
                if (!wrapped.length) errors.push({ index, message: `${where}: the text is empty` });
                if (!pending) {
                    pending = { after: levels.length, pages: [] };
                    breaks.push(pending);
                }
                for (const lines of wrapped) pending.pages.push({ lines, item: index });
            } else {
                errors.push({ index, message: `${where}: unknown item type ${item.type}` });
            }
        });
        if (!levels.length) errors.push({ index: -1, message: 'The campaign needs at least one level' });
        if (levels.length > MAX_LEVELS) errors.push({ index: -1, message: `${levels.length} levels exceed ${MAX_LEVELS}` });

        // Page numbering runs across all consecutive texts in one break.
        for (const pause of breaks) {
            pause.pages.forEach((page, index) => {
                page.layout = pageLayout(page.lines, index, pause.pages.length);
                page.bytes = bad(page.layout) ? [] : pageBytes(page.layout);
            });
        }
        const pageCount = breaks.reduce((sum, pause) => sum + pause.pages.length, 0);
        if (pageCount > MAX_PAGES) errors.push({ index: -1, message: `${pageCount} story pages exceed ${MAX_PAGES}` });

        const blobs = [...levels.map(level => level.bytes), ...breaks.flatMap(pause => pause.pages.map(page => page.bytes))];
        const bank = layoutBank(blobs);
        const used = blobs.reduce((sum, blob) => sum + blob.length, 0);
        if (bank.overflow) errors.push({ index: -1, message: `Levels and texts need ${used} bytes; ${bankCapacity()} are available` });
        return { levels, breaks, pageCount, errors, bank, used, capacity: bankCapacity() };

        function bad(layout) {
            return layout.some(([, , line]) => [...line].some(char => storyCode(char) < 0));
        }
    }

    return {
        TILE_CHARS, TILE_NAMES, MAX_WIDTH, MAX_HEIGHT, MAX_CELLS, MAX_LEVELS, MAX_PAGES,
        STORY_WIDTH, STORY_ROWS, STORY_EXTRA, BANK_WINDOWS, STAGE_LIMIT,
        normalizeText, storyCode, unsupportedChars, wrapStory, pageLayout, pageBytes,
        levelSize, levelErrors, levelBytes, levelZoom, compile,
    };
}));
