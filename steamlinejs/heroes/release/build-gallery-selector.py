"""Build a file:// compatible selector beside the collected picture archive."""
from pathlib import Path
import argparse
import json
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
out = args.output.resolve()
root = Path(__file__).resolve().parents[1]
manifest = json.loads((out / 'manifest.json').read_text())
# The complete archive stays available, including discarded story variants.
if not (out / 'archive.html').exists():
    shutil.copyfile(out / 'index.html', out / 'archive.html')
discarded = {'gallery-v1--borrowed-crown.png',
             'gallery-v1--moonlight-dance.png', 'gallery-v1--loaded-dice.png'}
titles = {}
for folder in sorted((root / 'art').glob('gallery-v[0-9]*')):
    group = folder.name
    if not (folder / 'generation.json').exists():
        continue
    metadata = json.loads((root / 'art' / group / 'generation.json').read_text())
    for painting in metadata.get('paintings', metadata.get('prompts', [])):
        if 'name' in painting and 'title' in painting:
            titles[(group, painting['name'])] = painting['title']
pictures = []
for item in manifest:
    if not item['group'].startswith('gallery-v') or item['file'] in discarded:
        continue
    assert (out / item['file']).is_file(), item['file']
    name = Path(item['file'].split('--', 1)[1]).stem
    pictures.append(dict(item, title=titles.get((item['group'], name),
                                               name.replace('-', ' ').title())))
pictures.sort(key=lambda p: (-int(p['group'].split('v')[-1]), p['title']))
template = (Path(__file__).with_name('gallery-selector.html')).read_text()
groups = sorted({p['group'] for p in pictures},
                key=lambda name: int(name.split('v')[-1]), reverse=True)
options = ''.join('<option value="%s">Version %s%s</option>' %
                  (name, name.split('v')[-1], ' (latest)' if i == 0 else '')
                  for i, name in enumerate(groups))
template = template.replace('__VERSION_OPTIONS__', options)
encoded = json.dumps(pictures).replace('<', '\\u003c')
(out / 'index.html').write_text(template.replace('__PICTURES__', encoded))
(out / 'gallery-candidates.json').write_text(json.dumps(pictures, indent=2) + '\n')
print('Built selector: %d candidates; %d pictures remain in archive.' %
      (len(pictures), len(manifest)))
