# Public runtime subtree

This directory is installed verbatim at `res://rookframe/ui/` and is the public
support boundary of the Rookframe UI Kit.

- `theme/rookframe_theme.tres` is the shared native Godot Theme.
- `tokens.gd` exposes semantic values required by reusable kit relationships.
- `components/` contains the editor-authored public scenes for relationships
  Godot does not supply as one native Control.
- `catalogue.json` is the machine-readable index of the public component and
  Theme contract.
- `assets/fonts/` contains the licensed UI and display fonts.
- `assets/frames/` contains Rookframe-owned nine-slice surface, action, and
  focus frames.
- `icons/` contains the semantic icon registry and one SVG per semantic role.
- `_internal/` is the only unsupported subtree.

Everything else in this directory is public even if its documentation is
accidentally incomplete. Public paths, Godot resource UIDs, Theme variation
names, and documented meanings are stable within a SemVer major line.

Examples and repository development material intentionally live outside this
subtree and are not copied by the documented gd-plug declaration.

The human-readable component API is in
[`docs/public-components.md`](../../docs/public-components.md). Native Control
configuration is in
[`docs/native-controls-and-recipes.md`](../../docs/native-controls-and-recipes.md),
and shared accessibility behavior is in
[`docs/accessibility-and-input.md`](../../docs/accessibility-and-input.md).
