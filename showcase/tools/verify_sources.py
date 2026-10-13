"""Verify the showcase consumes the current local workspace packages."""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT.parent / 'tools'))
from workspace import CONFIG, verify

verify(ROOT, CONFIG['showcase']['dependencies'])
tracked = subprocess.check_output(['git', 'ls-files', '-z', '--', 'rookframe/'], cwd=ROOT).decode()
assert not tracked, 'Showcase must consume package sources, not track a runtime copy'
count = 0
for directory in ('examples', 'tests'):
    for path in (ROOT / directory).rglob('*'):
        if path.suffix not in {'.gd', '.tscn'} or 'local-consumer' in path.parts:
            continue
        for resource in re.findall(r'"res://([^"%]+\.(?:gd|tscn|tres|svg|png))"', path.read_text()):
            assert (ROOT / resource).is_file(), f'Missing {resource} in {path.relative_to(ROOT)}'
            count += 1
print(f'{count} showcase resource references verified against local packages')
