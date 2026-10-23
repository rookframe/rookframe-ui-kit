# Cyberpunk theme

Optional native Godot theme package. The sibling UI Kit supplies controls and
the Theme compiler. `shared/fonts` and `shared/shell-common` supply optional fonts,
semantic mappings and geometry. This package owns materials, artwork and its mapping.

Install from the monorepo root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project --theme cyberpunk
```

Assign `res://rookframe/ui/themes/cyberpunk/theme.tres` to the owning Control
in code or the Inspector. Use the same `res://rookframe/ui/components/...` scenes
as every other theme. The shared native Theme entry wraps this package's existing
mapping compiler. Installation does not activate it; hosts own selection and
persistence. `res://rookframe/ui/menu/cyberpunk/CyberpunkTheme.tres` remains a compatibility resource.
See [the common activation contract](../../ui-kit/docs/world-theme-styling.md).
HUD mappings (stacked and emblem Buttons, HudBar, IdentityPlate, VitalMeter,
FavoriteToggle) live in `hud_theme_map.gd` with values in `materials/hud_materials.gd`;
`RookframeHud` sets a zero gap so the attached tray stands on the bar rail. The favorite star SVGs are hand-authored for this package.

The shared `components/navigation/arc_picker.tscn` and `arc_track.tscn` use
native Theme items only (`rookframe/ui/themes/cyberpunk/arc_picker_theme_map.gd`,
values in `menu/cyberpunk/materials/arc_picker_materials.gd`). The rail is a
neon trace with a dark core that brightens while its track is active, ending in
outlined arrowheads. Categories and items are dark-glass medallions with signal
rings and a drop shade for bright and dark scenes. The open category turns
emissive with dark ink. A selected item gains a heavier glowing ring and a
chamfered check tag. Keyboard focus adds a separate white ring with a dark halo.
Unavailable entries swap the lit ring for a broken, unpowered one. Previews are
clipped to a circular well. The caption hub is a chamfered HUD readout. Run
`godot --path showcase --script res://tests/arc_picker.gd -- --theme=cyberpunk`,
appending `--capture-dir=/absolute/temp/path` (windowed) for captures at all
three native sizes.
Runtime paths and existing UIDs are preserved; resources are merged into the
consumer's `rookframe/ui/`. Review this package through `../../showcase`.
See the [recipe contract](../../ui-kit/docs/native-controls-and-recipes.md).
Shared appearance rules live in [shell styling](../../shared/shell-common/docs/styling.md)
and [Chronicle styling](../../shared/shell-common/docs/chronicle.md).
Source and generated art use [MIT](LICENSE); shipped fonts retain their licenses.
