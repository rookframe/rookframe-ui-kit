# Silkbound Ledger

Optional appearance for the unthemed Rookframe UI Kit. Install from the repository root:

```sh
python3 tools/workspace.py install --destination /path/to/project --theme silkbound-ledger
```

Instance `res://rookframe/ui/silkbound-ledger/components/...` instead of the
corresponding `res://rookframe/ui/components/...` scene. These are native Godot
inherited scenes: the core owns node composition, slots, signals, focus, data and
input; this package owns Theme assignments, scene overrides and presentation
subclasses. Exported `row_scene`, `step_scene` and similar PackedScene properties
select themed runtime-created children without adding core dependencies.

For native Controls, assign `res://rookframe/ui/theme/silkbound_theme.tres` or
`action_panel_theme.tres` to the owning Control. A Theme alone supplies native
styles; use the inherited component scene for decoration and responsive skin
hooks. Installation never changes or globally themes the base scenes.

Material resources, fonts, tokens, licenses and existing UIDs retain their
installed paths. Shared licensed fonts come from the optional `fonts` package.
The previous green MenuButtonStandard smoke tint is preserved only in this
package's explicit variant. Fantasy/Cyberpunk remain independent installations.

Run `python3 tools/workspace.py prepare` after edits. Core component checks stay
in `ui-kit/tests`; themed component integration suites live in
`showcase/tests/theme_components`. Run them with `python3 tools/check_components.py`.
See [appearance resources](docs/foundation.md), [action panel appearance](docs/action-panel.md)
and the [v2 migration steps](../../docs/migration-to-v2.md).
