# Rookframe UI Kit

The public Godot UI Kit. The standalone catalogue shows the new
Main Menu and Settings elements implemented in `rookframe-godot`, plus an
in-game editor foundation, with the same
**Cyberpunk** and **Fantasy** themes. Switch themes, regular/compact density,
and Menu, Settings, Type & icons, or In-game editor pages from the catalogue header.

The copied resources live at `res://rookframe/ui/menu/`: native Themes, primary
and standard menu Button scenes, a textured Panel scene, decorative illustrations,
semantic mappings and their materials. Settings use native Controls and the
existing action-row scene. No host application, SDK, C#, or Package is required.

The **Old catalogue** button opens the previous Silkbound Ledger catalogue,
including its original tabs and interactive demos. **Current catalogue** returns
to the new design with its theme, density and page selection preserved. Older
components and their documentation remain available for existing consumers. The current theme covers only the
implemented menu/settings/editor vocabulary, not every Godot Control.

## Design system

The shared [design principles](docs/design-system/principles.md) and
[design choices](docs/design-system/choices.md) are copied from the main app repo.
The principles guide UI Kit design work. The choices remain a draft, including
the proposed Theme Package selection capability.

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

The project opens `examples/catalogue/visual_catalogue.tscn`. The Menu showcase
stacks Structure-framed sections: Surfaces, then Buttons, with future component
families appended below. Both primary and secondary buttons retain native Normal,
Hovered, Pressed, Hovered + pressed, Disabled and Focused states. Focused previews
are captured in turn so both appearances remain visible without competing for
keyboard focus. Their columns
stack on narrow screens. `examples/catalogue/showcase_section.tscn` supplies the
shared section frame and content inset. Settings choices open themed popups.
Samples do not change application settings.

Use `rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres` or
`rookframe/ui/menu/MenuTheme.tres` (Fantasy) as a scene or project Theme. Instance
`MenuButtonPrimary.tscn`, `MenuButtonStandard.tscn`, `MenuChoice.tscn`, and
`MenuSurface.tscn` from that directory. `MenuChoice` is a native OptionButton
recipe: Fantasy uses a restrained walnut frame with an inset tray; Cyberpunk
retains its virtual blue surfaces and cyan signals. It binds its popup Theme,
places the selected checkmark at the trailing edge, and keeps long menus within
the available space above or below the control. Native keyboard navigation,
incremental search, item IDs, metadata, tooltips and selection signals remain
available. Set `compact` or call `set_compact(true)` for the smaller density;
the popup follows the same density. Theme or density changes dismiss an open
tray before refreshing its materials. Give the control an `accessibility_name`
that describes the setting. Its own minimum height is 64/48 px in Fantasy and
52/48 px in Cyberpunk; containers choose the width.

Menu buttons own their themed minimum height: primary 64/44 px, Fantasy standard
50/34 px, and Cyberpunk standard 60/44 px (regular/compact). Fantasy's standard
face is slightly slimmer than the primary's narrow central body; 6 px is depth.
Let Containers size the buttons instead of imposing the old 60/44 px standard
height. To align secondary menu actions inside the primary's carved ends, place
their VBoxContainer inside a MarginContainer with `theme_type_variation =
&"menu_buttons"` (Usage `menu.buttons`), or `&"menu_buttons__compact"`. Keep the
primary outside this wrapper. Fantasy reserves 34/22 px on each side; Cyberpunk
reserves none. These are menu layout margins, so standalone standard buttons do
not acquire any external inset.

Native Settings controls use the `settings_*` Theme variations;
for a bare OptionButton, set its popup variation to `settings_popup` (or
`settings_popup__compact`). Set a ScrollContainer's
vertical scrollbar variation to `settings_scrollbar`, as the catalogue does.
Use `Control.CURSOR_POINTING_HAND` for native Settings buttons and scrollbars'
`mouse_default_cursor_shape`. The menu/editor button recipes and `MenuChoice`
already provide this cursor, including selectable dropdown items and popup
scrollbars. Disabled dropdown items and separators retain the arrow cursor.
The earlier pinned installation example above predates these additions;
select a commit containing them when consuming the new design.

Standalone smoke check (no test add-on needed), after the normal editor import:

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --editor --path . --import
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . --script res://tests/current_design_system.gd
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --path . --script res://tests/menu_choice.gd
```

For dropdown visual evidence, run the second check without `--headless` and
append `-- --capture-dir=<directory>`. This captures both themes and densities,
open, closed and disabled states, a long scrolling list, RTL and scaled layout.
Use `-- --preview` instead to leave the interactive Fantasy example open.

### In-game editor buttons and surfaces

The editor components extend the **new** Fantasy and Cyberpunk themes above.
Fantasy reserves carved brass fittings for primary actions. Tools, secondary
actions, and dropdowns use recessed walnut with a slim, beveled brass casing and
gently rounded corners, alongside
textured stone rails/panels and walnut inset/log surfaces.
Cyberpunk uses the menu's alloy switches, emissive actions, and virtual
chassis materials. There is no dependency on the legacy Silkbound theme.

| Scene under `res://rookframe/ui/editor/` | Use |
| --- | --- |
| `EditorToolButton.tscn` | Square icon tool, 64px regular / 52px compact |
| `EditorActionButton.tscn` | Primary labelled action; optional native icon |
| `EditorToolRail.tscn` | Framed native `Tools` BoxContainer; set `vertical = false` for a horizontal rail |
| `EditorSurface.tscn` | PanelContainer with native content sizing and material padding |

Buttons expose `compact` / `set_compact(bool)` and `usage`:
`editor.button.tool`, `editor.button.action`, or `editor.button.standard`.
The `action` usage is primary; `standard` is secondary.
Use native `icon`, `text`, `disabled`, `shortcut`, `pressed`, `toggled`, and
`toggle_mode`. Give icon tools an explicit `accessibility_name` and `tooltip_text`.
For exclusive selection, assign the same `ButtonGroup` to the participating
buttons; create it once in the owning scene so instanced recipes share it.
Selection survives live theme and density changes. The recipes reserve their
target height and square tool width; native Button sizing accommodates copy.

Surface variations are `editor_surface_panel`, `editor_surface_rail`,
`editor_surface_inset`, and `editor_surface_log`. Append `__compact` for compact
padding. Place a normal Container inside a surface and add content to that
Container. Surface gaps stop pointer input from falling through to the world;
hosts should handle world input through `_unhandled_input`. Hosts own tool
actions, placement, dismissals, and scene data.

The In-game editor catalogue page has native state previews and an interactive
tool/layer/placement example. Run its input, layout and material checks with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/editor_components.gd
# Omit --headless to render evidence for both themes and densities:
/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tests/editor_components.gd -- --capture-dir=/tmp/editor-components
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
