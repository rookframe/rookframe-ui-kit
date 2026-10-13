"""Package boundaries must work with no themes or either theme in isolation."""
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from workspace import ROOT, install, sources, verify


class PackageTests(unittest.TestCase):
    def test_independent_resource_closures(self):
        for packages in [['ui-kit'], ['fantasy'], ['cyberpunk'], ['fantasy', 'cyberpunk']]:
            with self.subTest(packages=packages):
                files = sources(packages)
                for relative, path in files.items():
                    if path.suffix not in {'.gd', '.tscn', '.tres'}:
                        continue
                    text = path.read_text()
                    refs = re.findall(r'(?:preload\(|load\(|extends |path=)"([^"]+)"', text)
                    for ref in refs:
                        if ref.startswith(('user://', 'uid://')) or '%' in ref:
                            continue
                        resolved = ref[6:] if ref.startswith('res://') else str((Path('/') / relative).parent.joinpath(ref).resolve()).lstrip('/')
                        self.assertIn(resolved, files, f'{packages}: {relative} -> {ref}')

    def test_core_excludes_optional_theme_payloads(self):
        core = sources(['ui-kit'])
        self.assertNotIn('rookframe/ui/menu/MenuTheme.tres', core)
        self.assertFalse(any('/cyberpunk/' in p for p in core))
        self.assertFalse(any('/materials/textures/' in p for p in core))

    def test_install_switches_theme_and_detects_stale_files(self):
        with tempfile.TemporaryDirectory() as folder:
            dest = Path(folder)
            install(dest, ['fantasy'])
            verify(dest, ['fantasy'])
            install(dest, ['cyberpunk'])
            self.assertFalse((dest / 'rookframe/ui/menu/MenuTheme.tres').exists())
            verify(dest, ['cyberpunk'])
            (dest / 'rookframe/ui/menu/menu_theme.gd').write_text('stale')
            with self.assertRaises(ValueError):
                verify(dest, ['cyberpunk'])
            install(dest, ['ui-kit'])
            verify(dest, ['ui-kit'])

    def test_source_directories_and_unmanaged_files_are_protected(self):
        with self.assertRaises(ValueError):
            install(ROOT / 'ui-kit', ['ui-kit'])
        with tempfile.TemporaryDirectory() as folder:
            dest = Path(folder)
            file = dest / 'rookframe/ui/menu/menu_theme.gd'
            file.parent.mkdir(parents=True)
            file.write_text('consumer code')
            with self.assertRaises(ValueError):
                install(dest, ['ui-kit'])
            self.assertEqual(file.read_text(), 'consumer code')


if __name__ == '__main__':
    unittest.main()
