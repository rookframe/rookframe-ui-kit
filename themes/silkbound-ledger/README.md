# Silkbound Ledger

Optional appearance for the unthemed Rookframe UI Kit. Install from the repository root:

```sh
python3 tools/workspace.py install --destination /path/to/project --theme silkbound-ledger
```

Assign `res://rookframe/ui/themes/silkbound-ledger/theme.tres` to the owning
Control, in code or the Inspector. Instance the ordinary
`res://rookframe/ui/components/...` scenes. The Theme supplies native styling,
leather surfaces, bindings, shaders and responsive presentation through the shared
component hooks. Runtime-created children inherit the selection too.

The package retains its existing native Themes, inherited scene paths and script
UIDs for compatibility. Inherited scenes also author the static appearance
properties used by the canonical resource; presentation strategies hold the
existing visual methods. Core behavior and live content are never replaced.
Installation does not activate a Theme. Hosts own selection and persistence.
See [the common activation contract](../../ui-kit/docs/world-theme-styling.md).

Material resources, fonts, tokens, licenses and existing UIDs retain their
installed paths. Shared licensed fonts come from the optional `fonts` package.
The previous green MenuButtonStandard smoke tint is preserved only in this
package's explicit variant. Fantasy/Cyberpunk remain independent installations.

Run `python3 tools/workspace.py prepare` after edits. Core component checks stay
in `ui-kit/tests`; themed component integration suites live in
`showcase/tests/theme_components`. Run them with `python3 tools/check_components.py`.
See [appearance resources](docs/foundation.md), [action panel appearance](docs/action-panel.md)
and the [v2 migration steps](../../docs/migration-to-v2.md).
