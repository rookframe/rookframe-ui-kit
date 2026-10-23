# Fantasy theme

Optional native Godot theme package. The sibling UI Kit supplies controls and
the Theme compiler. `shared/fonts` and `shared/shell-common` supply optional fonts,
semantic mappings and geometry. This package owns materials, artwork and its mapping.

Install from the monorepo root:

```sh
python3 tools/workspace.py install --destination /path/to/godot-project --theme fantasy
```

Assign `res://rookframe/ui/themes/fantasy/theme.tres` to the owning Control
in code or the Inspector. Use the same `res://rookframe/ui/components/...` scenes
as every other theme. The shared native Theme entry wraps this package's existing
mapping compiler. Installation does not activate it; hosts own selection and
persistence. `res://rookframe/ui/menu/MenuTheme.tres` remains a compatibility resource.
See [the common activation contract](../../ui-kit/docs/world-theme-styling.md).
The shared `components/actions/button.tscn` renders the original menu's carved
brass primary, walnut secondary and oxblood/steel destructive caps. Native text
and icons share their state foreground. The theme owns layered depth, press and
release motion, and primary hover/focus ornaments; `reduced_motion` settles them
immediately. Normal/compact sizing and live theme changes retain the same Button.
Verify with `godot --path showcase --script res://tests/fantasy_button.gd` from
the workspace root; append `-- --capture-dir=/absolute/temp/path` for native
state captures on bright/dark backgrounds at all three target sizes. Inspect
the Button catalogue with `--preview=fantasy`
as documented in the showcase README.

The shared `components/forms/checkbox.tscn` uses the same walnut-and-brass cap,
engraved type and brass checkmark through native `CheckBox` Theme items. Checked
indicators sit into their casing; hover, keyboard focus and disabled states stay
distinct. Every row retains its 44px minimum target, native toggled signal,
RTL layout and live theme inheritance. No behavior script or motion is added.
Run `godot --path showcase --script res://tests/fantasy_checkbox.gd` to verify
input, theme switching and all three native sizes. Append
`-- --capture-dir=/absolute/temp/path` for state and catalogue captures, or
`-- --preview` to open the interactive Fantasy Checkbox page.

HUD components reuse the same walnut casing, brass leaf finial and engraved
ink. Stacked Button tiles stay on the carved Button presentation: a selected
tile sits into its casing, lights it beyond hover and takes the brightest ink,
while keyboard focus is a separate brass ring. Tall tiles stretch the walnut
instead of thickening the rim (`art_height`). `EMBLEM` is a square primary
casing with cast leaves; stacked and compact tiles omit the leaves because a
wrapping label cannot measure their clearance. The HudBar, attached panel (with
its brass bridge to the bar) and IdentityPlate draw the casing at a fixed rim.
`hud_bar.tscn` scopes a profile Theme to the identity slot so the plate reads
at HUD scale. Vital levels differ in lightness, edge and glow, not hue alone;
the favorite star is original vector art under this package's license.

Runtime paths and existing UIDs are preserved; resources are merged into the
consumer's `rookframe/ui/`. Review this package through `../../showcase`.
See the [recipe contract](../../ui-kit/docs/native-controls-and-recipes.md).
Shared appearance rules live in [shell styling](../../shared/shell-common/docs/styling.md)
and [Chronicle styling](../../shared/shell-common/docs/chronicle.md).
Source and generated art use [MIT](LICENSE); shipped fonts retain their licenses.
