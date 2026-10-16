#!/usr/bin/env python3
"""Run component suites in a disposable consumer with optional Silkbound installed."""
import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile

from workspace import ROOT, install


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--headless', action='store_true')
    parser.add_argument('--reports', type=Path, default=ROOT / 'showcase/reports/theme-components')
    args = parser.parse_args()
    runner = ROOT / 'ui-kit/addons/gdUnit4'
    if not runner.is_dir():
        parser.error('Install the pinned runner first: godot --headless --path ui-kit --script res://plug.gd install')
    with tempfile.TemporaryDirectory(prefix='rookframe-components-') as folder:
        project = Path(folder)
        install(project, ['ui-kit', 'silkbound-ledger'])
        shutil.copy2(ROOT / 'ui-kit/project.godot', project / 'project.godot')
        shutil.copytree(ROOT / 'showcase/tests/theme_components', project / 'tests')
        shutil.copytree(runner, project / 'addons/gdUnit4')
        subprocess.run(['godot', '--headless', '--editor', '--path', folder,
                        '--log-file', str(project / 'import.log'), '--import', '--quit'], check=True)
        command = ['godot'] + (['--headless'] if args.headless else [])
        command += ['--path', folder, '--log-file', str(project / 'tests.log'), '--script',
                    'res://addons/gdUnit4/bin/GdUnitCmdTool.gd']
        if args.headless:
            command += ['--ignoreHeadlessMode']
        command += ['-a', 'res://tests', '-c', '-rd', 'reports']
        result = subprocess.run(command)
        # GdUnit's report root is relative to the project even for absolute -rd.
        args.reports.mkdir(parents=True, exist_ok=True)
        for log in ['import.log', 'tests.log']:
            shutil.copy2(project / log, args.reports / log)
        shutil.copytree(project / 'reports', args.reports, dirs_exist_ok=True)
        if result.returncode:
            raise SystemExit(result.returncode)
        # Pointer input crosses native layout frames; this is a standalone test.
        pointer = subprocess.run(['godot'] + (['--headless'] if args.headless else []) +
                                 ['--path', folder, '--log-file', str(args.reports / 'pointer.log'),
                                  '--script', 'res://tests/miniature_browser_pointer.gd'])
        raise SystemExit(pointer.returncode)


if __name__ == '__main__':
    main()
