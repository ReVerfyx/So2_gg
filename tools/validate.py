#!/usr/bin/env python3
"""Validate project contracts without requiring a Roblox client. Not a playtest."""
import json
import re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
project = json.loads((ROOT / 'default.project.json').read_text())
for service in ('ReplicatedStorage', 'ServerScriptService', 'StarterPlayer'):
    assert service in project['tree'], service
assert project['tree']['Workspace']['$properties']['StreamingEnabled']
courses = (ROOT / 'src/ReplicatedStorage/Shared/Courses.lua').read_text()
assert courses.count('{name=') == 36, 'Expected exactly 36 authored stages'
for kind in ('road', 'curve', 'gaps', 'bridge', 'slalom', 'sweeper'):
    assert f'kind="{kind}"' in courses
config = (ROOT / 'src/ReplicatedStorage/Shared/Config.lua').read_text()
assert 'C.MAX_GARAGES = 11' in config
workflow = (ROOT / '.github/workflows/build.yml').read_text()
for keep in ('8860447734', '79281925900541', 'secrets.ROBLOX_API_KEY', 'versionType=Published'):
    assert keep in workflow, f'Publication contract changed: {keep}'
assert "github.ref == 'refs/heads/main'" in workflow
for path in (ROOT / 'src').rglob('*.lua'):
    code = path.read_text()
    assert not re.search(r'require\s*\(\s*\d', code), f'Unreviewed remote script: {path}'
    assert 'SetAsync("u_"' not in code, f'Unsafe profile overwrite: {path}'
    assert not any(x in code for x in ('Config.LANES', 'GenerateMore', 'moveLane(')), path
    for child in re.findall(r'require\(script\.Parent\.(\w+)\)', code):
        assert (path.parent / (child + '.lua')).exists(), (path, child)
print('Project contracts OK: 36 stages, 6 patterns, 11 garages, preserved publication IDs, main-only publish.')
