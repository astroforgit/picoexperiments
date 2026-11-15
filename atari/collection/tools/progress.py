#!/usr/bin/env python3
"""Build an honest per-game index of archive, runtime and semantic recovery."""
from pathlib import Path
import csv,json,collections
ROOT=Path(__file__).resolve().parents[1]
def read(path):return json.loads(path.read_text()) if path.exists() else {}
def install_runtime_build_hook(dec):
    """Keep normal archive builds checking the additional view; preserve curated builds."""
    if (dec/'reconstruction.json').exists() or not (dec/'runtime-archive.json').exists():return False
    build=dec/'build.sh'
    if not build.exists() or not (dec/'build-runtime-archive.sh').exists():return False
    text=build.read_text()
    if 'sh build-runtime-archive.sh' in text:return False
    # The guard also protects a project curated after this hook was installed.
    if (dec/'reconstruction.json').exists():return False
    build.write_text(text+'\nif [ ! -f reconstruction.json ] && [ -f build-runtime-archive.sh ]; then sh build-runtime-archive.sh; fi\n')
    return True

def build_index(manifest,verification):
    """Read progress without publishing reports or changing any game files."""
    archive={r['folder']:r['status'] for r in verification.get('results',[])};rows=[]
    for rec in manifest['games']:
        game=ROOT/rec['folder'];dec=game/'decompiled';curated=read(dec/'reconstruction.json');stages=read(dec/'recovered-stages/recovery.json');runtime=read(dec/'recovered-stages/verification/runtime-recovery.json');pal=read(dec/'recovered-stages/verification/pal.json') or read(dec/'verification/pal.json')
        row={'title':rec['title'],'folder':rec['folder'],'archive_mads_check':archive.get(rec['folder'],'not_checked'),'recovery_level':'archive_listing_only','semantic_annotation':'none','recovered_stages':len(stages.get('stages',[])),'recovered_bytes':sum(s['bytes'] for s in stages.get('stages',[])),'decoded_code_bytes':sum(s['code_bytes'] for s in stages.get('stages',[])),'decoded_instructions':sum(s['instructions'] for s in stages.get('stages',[])),'unverified_stage_candidates':len(stages.get('excluded_candidates',[])),'emulator_machine':pal.get('machine','-xl'),'runtime_code_evidence':runtime.get('status','not_run'),'emulator_check':pal.get('status','not_run'),'emulator_frames':pal.get('rebuilt',{}).get('frames',0),'emulator_errors':pal.get('rebuilt',{}).get('errors_after_boot',''),'source':''}
        relocated=read(dec/'relocated-runtime/recovery.json')
        row.update(relocated_runtime_images=len(relocated.get('stages',[])),relocated_runtime_bytes=sum(x['bytes'] for x in relocated.get('stages',[])),relocated_runtime_code_bytes=sum(x['code_bytes'] for x in relocated.get('stages',[])),relocated_runtime_source=rec['folder']+'/decompiled/relocated-runtime/' if relocated.get('stages') else '')
        archive_runtime=read(dec/'runtime-archive.json')
        enhanced=archive_runtime.get('status')=='runtime_enhanced_original_archive_verified' and archive_runtime.get('byte_exact_rebuild') is True
        evidence=archive_runtime.get('runtime_evidence',{}) if enhanced else {}
        row.update(archive_runtime_added_code_bytes=evidence.get('added_code_bytes',0),archive_runtime_added_instructions=evidence.get('added_runtime_instructions',0),archive_runtime_evidence=archive_runtime.get('status','not_run'),archive_runtime_baseline_errors=archive_runtime.get('baseline',{}).get('errors_after_boot',''),archive_runtime_baseline_quiet=archive_runtime.get('baseline_quiet',''))
        if enhanced:
            row['recovery_level']='archive_listing_runtime_enhanced';row['source']=rec['folder']+'/decompiled/runtime-archive.asm'
        if stages.get('stages'):
            row['recovery_level']='unpacked_stages_mads_verified';row['source']=rec['folder']+'/decompiled/recovered-stages/'
        if curated:
            row.update(recovered_stages=curated.get('recovered_stage_count',1+bool(curated.get('loading_screen_bytes'))),recovery_level=curated['status'],semantic_annotation='partial' if 'partially' in curated['status'] else 'annotated_with_documented_limitations',recovered_bytes=curated['image_bytes']+curated.get('loading_screen_bytes',0),decoded_code_bytes=curated['code_bytes'],decoded_instructions=curated['instructions'],emulator_check=curated.get('emulator_check_status','game_specific_pal_ntsc_smoke_passed'),emulator_frames=curated['test_frames'],emulator_errors=curated.get('emulator_errors',0),source=rec['folder']+'/decompiled/'+curated['source'])
        rows.append(row)
    summary={'catalogue_entries':len(rows),'archive_mads_byte_exact':sum(r['archive_mads_check']=='pass' for r in rows),'individual_reconstructions':sum(r['semantic_annotation']!='none' for r in rows),'automatic_stage_projects':sum(r['recovery_level']=='unpacked_stages_mads_verified' for r in rows),'archive_listing_only':sum(r['recovery_level']=='archive_listing_only' for r in rows),'verified_recovered_stage_images':sum(r['recovered_stages'] for r in rows),'excluded_unverified_candidates':sum(r['unverified_stage_candidates'] for r in rows),'recovered_stage_bytes_including_overlays':sum(r['recovered_bytes'] for r in rows),'decoded_recovered_code_bytes':sum(r['decoded_code_bytes'] for r in rows),'emulator_status_counts':dict(collections.Counter(r['emulator_check'] for r in rows))}
    summary.update(archive_runtime_view_projects=sum(r['archive_runtime_evidence']=='runtime_enhanced_original_archive_verified' for r in rows),archive_listing_runtime_enhanced=sum(r['recovery_level']=='archive_listing_runtime_enhanced' for r in rows),archive_runtime_added_code_bytes=sum(r['archive_runtime_added_code_bytes'] for r in rows),archive_runtime_added_instructions=sum(r['archive_runtime_added_instructions'] for r in rows))
    summary.update(relocated_runtime_projects=sum(r['relocated_runtime_images']>0 for r in rows),relocated_runtime_images=sum(r['relocated_runtime_images'] for r in rows),relocated_runtime_bytes=sum(r['relocated_runtime_bytes'] for r in rows),relocated_runtime_code_bytes=sum(r['relocated_runtime_code_bytes'] for r in rows))
    summary['not_yet_unpacked_or_individually_reconstructed']=summary['archive_listing_only']+summary['archive_listing_runtime_enhanced']
    return rows,summary

def main():
    rows,summary=build_index(read(ROOT/'manifest.json'),read(ROOT/'verification.json'))
    (ROOT/'progress.json').write_text(json.dumps({'summary':summary,'games':rows},indent=2)+'\n')
    with (ROOT/'progress.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
    lines=['Atari collection recovery progress','',json.dumps(summary,indent=2),'',
        'Archive listing: preserves executable bytes, including compressed payload; not equivalent to recovered game code.',
        'Runtime-enhanced archive listing: adds observed instructions only where CPU address and three bytes uniquely match one original file segment. This is partial original-file code discovery, not unpacked-stage recovery or semantic annotation. Added archive code has separate totals and never increases recovered stage counts or bytes.',
        'Both archive listing categories remain in not_yet_unpacked_or_individually_reconstructed. Runtime archive baseline errors and quiet activity are reported separately; the trace covers 1,200 scripted PAL frames, not a complete playthrough.',
        'Relocated runtime views: verified file-backed copies at their runtime addresses beneath ROM. Shared runtime recovery is recorded separately and does not increase unpacked-game counts.',
        'Unpacked stages: actual depacker output assembled with MADS, with static and/or observed runtime instruction decoding.',
        'Automatic stage projects are not fully annotated games and can cover only a subset of load stages. Multiple stages can overlap or contain graphics and level data. Unverified candidates are excluded from builds and counts.',
        'Generic emulator comparisons check 1,200 PAL frames against the original, with fixed initial hardware RNG phase; 130-XE/128K-labelled titles use XE memory and 256/320-XE labels use 320 XE memory.',
        'Matching the original does not establish full gameplay. Low activity and baseline errors are flagged separately. For curated projects, emulator_errors follows the documented marker scope; Star Raiders counts diagnostic events across all six runs.',
        'Individually reconstructed games have local notes and PAL/NTSC tests. Semantic annotation remains partial for most; see the per-game index.',
        'The entire collection has NOT been annotated to the depth of the Zorro reference. See progress.csv for each game.',
        '', 'Build a recovered project: cd games/GAME/decompiled/recovered-stages && sh build.sh',
        'Build an archive runtime view: cd games/GAME/decompiled && sh build-runtime-archive.sh (also checked by the normal noncurated build)',
        'Build an individual reconstruction: cd games/GAME/decompiled && sh build.sh',
        'Dependencies: MADS, Python 3, py65, Pillow. Runtime tracing additionally needs the documented Atari800 build.',
        '', 'Next manual priorities: further annotation of individual games, other popular titles and unresolved loaders.']
    (ROOT/'PROGRESS.txt').write_text('\n'.join(lines)+'\n')
    for row in rows:
        install_runtime_build_hook(ROOT/row['folder']/'decompiled')
        dec=ROOT/row['folder']/'decompiled';build=dec/'build.sh'
        if row['relocated_runtime_images'] and not (dec/'reconstruction.json').exists() and build.exists() and 'relocated-runtime/build.sh' not in build.read_text():
            build.write_text(build.read_text()+'\nif [ ! -f reconstruction.json ] && [ -f relocated-runtime/build.sh ]; then sh relocated-runtime/build.sh; fi\n')
        out=ROOT/row['folder']/'decompiled/recovered-stages'
        if not (out/'recovery.json').exists():continue
        report=read(out/'recovery.json')
        families=sorted({f for f in [report.get('decoder_family')]+[s.get('decoder_family') for s in report.get('stages',[])] if f not in (None,'homesoft-forward')})
        if not report.get('stages'):
            if families and (out/'README.txt').exists():continue
            (out/'README.txt').write_text('No independently verified stages yet. Unverified candidates are preserved in needs-loader-context/ and excluded from normal builds. The original archive listing remains available in the parent directory.\n')
            continue
        dec=out.parent
        if (dec/'reconstruction.json').exists():
            (out/'README.txt').write_text('Archived automatic-stage reference. Use ../build.sh and ../README.md for the individually reconstructed source and tests.\n')
            continue
        if not (dec/'reconstruction.json').exists():
            build=dec/'build.sh'
            if build.exists() and 'recovered-stages/build.sh' not in build.read_text():
                build.write_text(build.read_text()+'\nif [ -f recovered-stages/build.sh ]; then sh recovered-stages/build.sh; fi\n')
        game_readme=out.parent.parent/'README.md'
        if game_readme.exists():
            text=game_readme.read_text();start='<!-- recovered-status-start -->';end='<!-- recovered-status-end -->'
            if start in text and end in text:text=text[:text.index(start)]+text[text.index(end)+len(end):].lstrip('\n')
            first,sep,rest=text.partition('\n')
            note=f'\n\n{start}\nRecovered unpacked stages are now available in `decompiled/recovered-stages/`. The normal build also assembles and verifies them. Semantic annotation remains incomplete. Current emulator status: `{row["emulator_check"]}`. See the stage README and collection `progress.csv`.\n{end}\n'
            game_readme.write_text(first+note+rest.lstrip('\n'))
        if families:
            # Family workers supply decoder-specific limitations and audit commands.
            # Never replace those notes with the common forward-decoder description.
            if not (out/'README.txt').exists():
                audit_tools={'backward-zaxxon-v1':'recover_backward.py','backward-fiji-v1':'recover_backward_tables.py'}
                audits='\n'.join('Family audit: python3 ../../../../tools/'+audit_tools[f]+' --audit "$(cd ../.. && pwd)"' for f in families if f in audit_tools)
                (out/'README.txt').write_text(f"{row['title']} — recovered compressed stages\n\nDecoder family: {', '.join(families)}\nBuild and byte checks: sh build.sh\n{audits}\nSee recovery.json for family-specific evidence, limitations and literal mappings.\n"+'\n'.join(report.get('limitations',[]))+'\nAutomatic partial recovery; no complete gameplay or semantic-annotation claim.\n')
            continue
        (out/'README.txt').write_text(f'''{row['title']} — recovered compressed stages

These files contain actual unpacked memory from the archived Homesoft release.
MADS rebuilds each stage byte for byte. Recognized instructions are assembly;
unidentified bytes remain explicit DTA. Labels are addresses, not original names.
This is automatic recovery, not a fully annotated game reconstruction.

Run: sh build.sh
The build checks every assembled stage hash and reconstructs the original packed
executable by replaying its literal tokens. Original loader and compression
choices are preserved. This is not a general compressor for arbitrary edits.

Recovered stages: {row['recovered_stages']}
Code bytes currently decoded: {row['decoded_code_bytes']}
Emulator status: {row['emulator_check']}

recovery.json lists output ranges, entry seeds, hashes and literal-token mappings.
verification/pal.json records the generic original-versus-rebuilt comparison.
Where available, verification/runtime.pcmap holds five-byte records: little-endian
CPU address followed by the three instruction bytes captured before execution.
Only matching source bytes seed the additional runtime-assisted disassembly.
Overlay code, self-modification, other input paths and semantic names need review.

The collection-wide progress.csv distinguishes this stage recovery from the
individual reconstructions and from archive-only listings.
''')
    print(json.dumps(summary,indent=2))
if __name__=='__main__':main()
