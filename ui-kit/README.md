# Rookframe UI Kit

Unthemed Godot controls, composition and behavior. A core-only install uses
Godot defaults and includes no custom fonts, material assets or Theme resources.
Silkbound Ledger is an optional sibling package in `../themes/silkbound-ledger`.

## Agent entry points

Read [the design contract](docs/design-system/principles.md) before UI work.
Use [public components](docs/public-components.md), [native recipes](docs/native-controls-and-recipes.md)
and [linked action/HUD leaves](docs/action-panel.md) for implementation.
`rookframe/ui/catalogue.json` indexes the public resources.

The interactive Godot catalogue, native examples and integration checks live in
[the sibling showcase](../showcase/README.md), which consumes current local
package sources. Fantasy and Cyberpunk are optional packages in `../themes/`.

## Consume a revision

Check out the required monorepo commit and run the installer from its root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project
```

Install optional appearance with `--theme silkbound-ledger`, `--theme fantasy`
or `--theme cyberpunk`. Silkbound component variants are native inherited scenes
under `res://rookframe/ui/silkbound-ledger/`; base scene paths stay unthemed.
Public Godot paths remain `res://rookframe/ui/`; the installer includes runtime
resources and legal notices, excluding tests and examples.

## Support and verification

Normal resources under `rookframe/ui/` are public; `_internal/` is unsupported.
Paths, UIDs, semantic Theme variations and documented behavior participate in the
kit's independent SemVer contract. [Compatibility](docs/compatibility.md) defines
the relationship to SDK Editions and Rookframe Versions. An exact Git revision is
available source, not a claim that a stable release has been published.

From `ui-kit/`, install the development-only runner:

```sh
godot --headless -s plug.gd install
```

Run the standalone core-only regression without optional packages:

```sh
godot --headless --editor --path ui-kit --import --quit
godot --headless --path ui-kit --script res://tests/unthemed_components.gd
```

From the repository root, `python3 tools/check_components.py` creates a temporary
consumer with Silkbound installed, copies the component suites and the installed
GdUnit runner, imports it, and runs the suites. It never installs theme resources
into the owning core package. Use `--headless` for non-rendering checks; the motion
and pointer suites need the native display. Reports are written to the supplied
`--reports` directory. Require no failed, skipped or flaky cases.

Rookframe-owned source/assets use [MIT](LICENSE); third-party resources retain
[their notices](THIRD_PARTY_NOTICES.md). The optional Silkbound package’s `rookframe/ui/assets/generated-assets.json`
tracks generated production art by stable replacement ID, path and checksum.
Design discussion, proposals and review evidence live in [Linear](https://linear.app/rookframe/document/silkbound-ledger-design-examples-and-distribution-d2dd1e70a906).
