# Rookframe UI Kit

The public Godot UI Kit. The standalone catalogue now shows only the new
Main Menu and Settings elements implemented in `rookframe-godot`, with the same
**Cyberpunk** and **Fantasy** themes. Switch themes, regular/compact density,
and Menu, Settings, or Type & icons pages from the catalogue header.

The copied resources live at `res://rookframe/ui/menu/`: native Themes, primary
and standard menu Button scenes, a textured Panel scene, decorative illustrations,
semantic mappings and their materials. Settings use native Controls and the
existing action-row scene. No host application, SDK, C#, or Package is required.

The **Old catalogue** button opens the previous Silkbound Ledger catalogue,
including its original tabs and interactive demos. **Current catalogue** returns
to the new design with its theme, density and page selection preserved. Older
components and their documentation remain available for existing consumers. The current theme covers only the
implemented menu/settings vocabulary, not every Godot Control.

## Exact-commit installation

Commit `plug.gd` and gd-plug's runtime to the consuming Godot project, then
declare the UI Kit with a full 40-character commit:

```gdscript
extends "res://addons/gd-plug/plug.gd"


func _plugging() -> void:
	plug("rookframe/rookframe-ui-kit", {
		"commit": "839da122c44a231a70cc608a9fc121514fe64aa3",
		"include": ["rookframe/ui"],
	})
```

Run gd-plug with Godot 4:

```sh
godot --headless -s plug.gd install
```

The copied Theme then exists at
`res://rookframe/ui/theme/rookframe_theme.tres`. Assign it to a scene root or
set it as the project Theme:

```ini
[gui]

theme/custom="res://rookframe/ui/theme/rookframe_theme.tres"
```

The checked-in [exact-commit consumer](examples/exact-commit-consumer) is the
normal-Godot proof of this seam. It pins the complete candidate runtime content
commit and instances a public Search Field directly from the materialized
canonical path. Repository catalogues remain outside the installed runtime
subtree.

## Public boundary

Every normal resource beneath `rookframe/ui/` is public and supported. Its
path, UID, semantic Theme variation name, and documented purpose participate in
the UI Kit's independent SemVer contract. Only `rookframe/ui/_internal/` is
unsupported. Examples, repository tools, and development material live outside
the installed subtree. `rookframe/ui/catalogue.json` is the machine-readable
index of public component contracts.

The UI Kit uses SemVer and does not participate in SDK Editions. A Package
records the human-readable UI Kit version and exact authoring commit as
provenance, excludes the materialized kit from its artifact, and declares
compatible Rookframe Versions—not a runtime UI Kit range—for runtime
compatibility. The selected Rookframe Version supplies the canonical subtree
before Package scenes load. Direct use of Godot APIs and formats remains
outside Rookframe's backwards-compatibility guarantee; see the
[full compatibility consequences](docs/compatibility.md).

Stable `v1.0.0` has not been published. Release timing remains an explicit
owner action.

## Development catalogue

Open this repository as a Godot 4.7 project or run it with the pinned toolchain:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --path .
```

The project opens `examples/catalogue/visual_catalogue.tscn`. Menu samples retain native Normal, Hovered, Pressed, Disabled and Focused
states inside a padded surface. Settings choices open themed popups.
Samples do not change application settings.

Use `rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres` or
`rookframe/ui/menu/MenuTheme.tres` (Fantasy) as a scene or project Theme. Instance
`MenuButtonPrimary.tscn`, `MenuButtonStandard.tscn`, and `MenuSurface.tscn` from
that directory. Native Settings controls use the `settings_*` Theme variations;
set an OptionButton's popup variation to `settings_popup` and a ScrollContainer's
vertical scrollbar variation to `settings_scrollbar`, as the catalogue does.
The earlier pinned installation example above predates these additions;
select a commit containing them when consuming the new design.

Standalone smoke check (no test add-on needed), after the normal editor import:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --editor --path . --import
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . --script res://tests/current_design_system.gd
```

## License

Rookframe-owned source and assets use the [MIT License](LICENSE). Third-party
fonts and icons retain their compatible licenses and attribution in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Automated component checks

The full-screen wizard and Miniature browser suites use GdUnit4 v6.2.1,
pinned in `plug.gd`. Install the development dependency with gd-plug; consumers
continue to install only `rookframe/ui/`.

```sh
mkdir -p addons/gd-plug
curl -fsSL https://raw.githubusercontent.com/imjp94/gd-plug/209276d1f00d14b49b74403d9839f29598e9a8eb/addons/gd-plug/plug.gd -o addons/gd-plug/plug.gd
godot --headless --path . --script plug.gd install
godot --headless --editor --path . --import
godot --headless --path . --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests/fullscreen_wizard.gd -a res://tests/silkbound_miniature_browser.gd -c -rd reports/fullscreen
godot --headless --path . --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd --ignoreHeadlessMode -a res://tests/theme_font_resources.gd -c -rd reports/theme-fonts
```

Require every discovered case to pass in the fresh JUnit report, with no
errors, failures, skips, or flaky results. For graphical capture, omit
`--headless` and `--ignoreHeadlessMode`; after `--`, pass `--capture=<file.png>`
for the wizard and `--evidence-dir=<directory>` for the browser.

Themes share their Latin font files. The default chain does not eagerly load
all four CJK companions: load the explicit locale font when its text is needed
(see regional typography), with stock system fallback for other supported text.
The font-resource suite bounds a fresh uncached Theme to 64 MiB and checks
Latin/CJK measurements. A small pre-rendered atlas covers common Latin, Russian
and punctuation; the complete original font renders other glyphs on demand.
