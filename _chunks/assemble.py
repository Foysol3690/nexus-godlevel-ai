#!/usr/bin/env python3
"""Assembles chunked dart source files before flutter build.

Chunk file naming: _chunks/{safe_path}.{NNN}
where safe_path has '__' instead of '/' in the original path.
Chunks are sorted by NNN and concatenated in order.
"""
import os
import glob
import re
import sys

chunks_dir = os.path.dirname(os.path.abspath(__file__))
repo_root = os.path.dirname(chunks_dir)

chunk_files = sorted(glob.glob(os.path.join(chunks_dir, '*.???')))
targets = {}

for chunk_path in chunk_files:
    base = os.path.basename(chunk_path)
    m = re.match(r'^(.+)\.([0-9]{3})$', base)
    if not m:
        continue
    safe = m.group(1)
    idx = int(m.group(2))
    # Replace double underscore back to slash to get the target path
    target = os.path.join(repo_root, safe.replace('__', '/'))
    if target not in targets:
        targets[target] = []
    targets[target].append((idx, chunk_path))

if not targets:
    print('No chunked files found. Nothing to assemble.')
    sys.exit(0)

assembled = 0
for target, chunks in sorted(targets.items()):
    chunks.sort(key=lambda x: x[0])
    os.makedirs(os.path.dirname(target), exist_ok=True)
    with open(target, 'w', encoding='utf-8') as out:
        for _, c in chunks:
            with open(c, 'r', encoding='utf-8') as f:
                out.write(f.read())
    rel = os.path.relpath(target, repo_root)
    print(f'  Assembled: {rel} ({len(chunks)} chunks)')
    assembled += 1

print(f'Done. Assembled {assembled} file(s) from {len(chunk_files)} chunks.')
